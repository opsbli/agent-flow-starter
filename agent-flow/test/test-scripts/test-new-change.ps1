<#
.SYNOPSIS
Smoke test for new-change.ps1 using the minimal-project fixture.

.DESCRIPTION
Tests that new-change creates the expected files for each flow level.
Runs inside the fixture directory, not the real project.
#>

$ErrorActionPreference = "Stop"

$testRoot = Split-Path -Parent $PSScriptRoot
$fixtureDir = Join-Path $testRoot "fixtures/minimal-project"
$scriptsDir = Join-Path (Split-Path -Parent $testRoot) "scripts"

# === Setup: install agent-flow into fixture ===
Write-Host "=== Smoke test: new-change.ps1 ==="
Write-Host "Fixture: $fixtureDir"

# Create agent-flow directory structure in fixture
$fixtureAf = Join-Path $fixtureDir "agent-flow"
if (-not (Test-Path -LiteralPath $fixtureAf)) {
    & (Join-Path $scriptsDir "install-agent-flow.ps1") -Target $fixtureDir -StarterRoot (Resolve-Path (Join-Path $scriptsDir "..\..")) -Force
}

function Get-ChangeDirBySuffix {
    param(
        [string]$ChangesRoot,
        [string]$Suffix
    )
    $match = Get-ChildItem -LiteralPath $ChangesRoot -Directory |
        Where-Object { $_.Name -like "*$Suffix" } |
        Sort-Object LastWriteTimeUtc |
        Select-Object -Last 1
    if (-not $match) {
        Write-Host "FAIL: Change directory with suffix '$Suffix' was not created."
        exit 1
    }
    return $match.FullName
}

# === Test 1: Light change ===
Write-Host ""
Write-Host "Test 1: Light change"
$changesRoot = Join-Path $fixtureAf "changes"

# Clean up any previous test
Get-ChildItem -LiteralPath $changesRoot -Directory | Where-Object { $_.Name -like "*test-light" } | Remove-Item -Recurse -Force

& (Join-Path $scriptsDir "new-change.ps1") -Name "test-light" -Flow Light -ChangesRoot $changesRoot -Force
$changeDir = Get-ChangeDirBySuffix -ChangesRoot $changesRoot -Suffix "test-light"

$expectedLight = @("STATE.md", "CHANGE.md", "CODE_SCAN.md", "VERIFY.md", "REPORT.md")
$missing = $expectedLight | Where-Object { -not (Test-Path -LiteralPath (Join-Path $changeDir $_)) }
if ($missing.Count -gt 0) {
    Write-Host "FAIL: Light change missing files: $($missing -join ', ')"
    exit 1
}

# Verify flow level marker in CHANGE.md
$changeContent = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md")
if ($changeContent -notmatch "\[x\]\s+Light") {
    Write-Host "FAIL: Light change marker not set in CHANGE.md"
    exit 1
}
Write-Host "PASS: Light change created $($expectedLight.Count) files, marker correct"

# Clean up
Remove-Item -Recurse -Force -LiteralPath $changeDir

# === Test 2: Standard change ===
Write-Host ""
Write-Host "Test 2: Standard change"

Get-ChildItem -LiteralPath $changesRoot -Directory | Where-Object { $_.Name -like "*test-standard" } | Remove-Item -Recurse -Force

& (Join-Path $scriptsDir "new-change.ps1") -Name "test-standard" -Flow Standard -ChangesRoot $changesRoot -Force
$changeDir = Get-ChangeDirBySuffix -ChangesRoot $changesRoot -Suffix "test-standard"

$expectedStd = @("STATE.md", "CHANGE.md", "REQUIREMENT.md", "CODE_SCAN.md", "DESIGN.md", "TASKS.md", "VERIFY.md", "REPORT.md", "EVOLUTION.md")
$missing = $expectedStd | Where-Object { -not (Test-Path -LiteralPath (Join-Path $changeDir $_)) }
if ($missing.Count -gt 0) {
    Write-Host "FAIL: Standard change missing files: $($missing -join ', ')"
    exit 1
}

$changeContent = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md")
if ($changeContent -notmatch "\[x\]\s+Standard") {
    Write-Host "FAIL: Standard change marker not set in CHANGE.md"
    exit 1
}
Write-Host "PASS: Standard change created $($expectedStd.Count) files, marker correct"
Remove-Item -Recurse -Force -LiteralPath $changeDir

# === Test 3: Heavy change ===
Write-Host ""
Write-Host "Test 3: Heavy change"

Get-ChildItem -LiteralPath $changesRoot -Directory | Where-Object { $_.Name -like "*test-heavy" } | Remove-Item -Recurse -Force

& (Join-Path $scriptsDir "new-change.ps1") -Name "test-heavy" -Flow Heavy -ChangesRoot $changesRoot -Force
$changeDir = Get-ChangeDirBySuffix -ChangesRoot $changesRoot -Suffix "test-heavy"

$expectedHeavy = @("STATE.md", "CHANGE.md", "REQUIREMENT.md", "CODE_SCAN.md", "DESIGN.md", "PLAN.md", "TASKS.md", "VERIFY.md", "REVIEW.md", "REPORT.md", "AUDIT.md", "EVOLUTION.md")
$missing = $expectedHeavy | Where-Object { -not (Test-Path -LiteralPath (Join-Path $changeDir $_)) }
if ($missing.Count -gt 0) {
    Write-Host "FAIL: Heavy change missing files: $($missing -join ', ')"
    exit 1
}

$changeContent = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md")
if ($changeContent -notmatch "\[x\]\s+Heavy") {
    Write-Host "FAIL: Heavy change marker not set in CHANGE.md"
    exit 1
}
Write-Host "PASS: Heavy change created $($expectedHeavy.Count) files, marker correct"
Remove-Item -Recurse -Force -LiteralPath $changeDir

# === Test 4: Slug generation ===
Write-Host ""
Write-Host "Test 4: Slug generation from name"
Get-ChildItem -LiteralPath $changesRoot -Directory | Where-Object { $_.Name -like "*anonymous-conversation" } | Remove-Item -Recurse -Force

& (Join-Path $scriptsDir "new-change.ps1") -Name "Anonymous Conversation" -Flow Light -ChangesRoot $changesRoot -Force
$changeDir = Get-ChangeDirBySuffix -ChangesRoot $changesRoot -Suffix "anonymous-conversation"

if (-not (Test-Path -LiteralPath (Join-Path $changeDir "CHANGE.md"))) {
    Write-Host "FAIL: Change not created for name 'Anonymous Conversation'"
    exit 1
}
Write-Host "PASS: Slug generation correct: anonymous-conversation"
Remove-Item -Recurse -Force -LiteralPath $changeDir

# === All tests passed ===
Write-Host ""
Write-Host "=== All smoke tests passed ==="
exit 0
