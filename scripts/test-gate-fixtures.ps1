<#
.SYNOPSIS
Run gate fixture tests for blocked-check.
#>
param([switch]$KeepTemp)
$ErrorActionPreference = "Continue"
$starterRoot = Split-Path -Parent $PSScriptRoot
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("gate-fixture-" + [guid]::NewGuid().ToString("N"))
$fixtureProject = Join-Path $tempRoot "project"
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $fixtureProject "agent-flow") -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $starterRoot "agent-flow/manifest.yaml") -Destination (Join-Path $fixtureProject "agent-flow/manifest.yaml") -Force
$passed = 0; $failed = 0

function Test-HasOutput {
    param([string]$ChangeDir, [string]$MatchPattern)
    $global:LASTEXITCODE = 0
    $output = & "$starterRoot/agent-flow/scripts/blocked-check.ps1" -ChangeDir $ChangeDir -ProjectRoot $fixtureProject -Manifest "agent-flow/manifest.yaml" *>&1
    $text = ($output | Out-String)
    return ($text -match $MatchPattern)
}

Write-Host "=== blocked-check Gate Fixture Tests ===" -ForegroundColor Yellow
Write-Host ""

# Scenario 1: hard_delete_without_approval
Write-Host "Test: hard-delete-detection" -ForegroundColor Cyan
$d1 = Join-Path $tempRoot "hard-delete"
New-Item -ItemType Directory -Path $d1 -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $fixtureProject "src/main/resources/db/migration") -Force | Out-Null
Set-Content -Path (Join-Path $d1 "TASKS.md") -Value @"
write_files:
  - src/main/resources/db/migration/V1__cleanup.sql
"@ -Encoding utf8
Set-Content -Path (Join-Path $fixtureProject "src/main/resources/db/migration/V1__cleanup.sql") -Value "DELETE FROM users WHERE 1=1;" -Encoding utf8
if (Test-HasOutput -ChangeDir $d1 -MatchPattern "hard_delete_without_approval") {
    Write-Host "  ✅ PASS" -ForegroundColor Green; $passed++ 
} else { Write-Host "  ❌ FAIL" -ForegroundColor Red; $failed++ }

# Scenario 2: clean change
Write-Host "Test: clean-change" -ForegroundColor Cyan
$d2 = Join-Path $tempRoot "clean"
New-Item -ItemType Directory -Path $d2 -Force | Out-Null
Set-Content -Path (Join-Path $d2 "TASKS.md") -Value "write_files:`n  - src/main/resources/db/migration/V2__add_column.sql" -Encoding utf8
Set-Content -Path (Join-Path $fixtureProject "src/main/resources/db/migration/V2__add_column.sql") -Value "ALTER TABLE users ADD x VARCHAR(255);" -Encoding utf8
if (-not (Test-HasOutput -ChangeDir $d2 -MatchPattern "BLOCKED:")) {
    Write-Host "  ✅ PASS (no violation)" -ForegroundColor Green; $passed++
} else { Write-Host "  ❌ FAIL" -ForegroundColor Red; $failed++ }

# Cleanup
if (-not $KeepTemp) { Remove-Item -Recurse -Force $tempRoot -ErrorAction SilentlyContinue }

Write-Host "`nResult: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0){"Green"}else{"Red"})
exit $failed
