<#
.SYNOPSIS
Validate that change artifacts contain meaningful content.
#>

param(
    [string]$ChangeDir,
    [switch]$Strict
)

$ErrorActionPreference = "Stop"

if (-not $ChangeDir) {
    Write-Host "Usage: content-check.ps1 -ChangeDir <path>"
    exit 1
}
if (-not (Test-Path -LiteralPath $ChangeDir)) {
    Write-Host "Change directory not found: $ChangeDir"
    exit 1
}

. (Join-Path $PSScriptRoot "_common.ps1")

$issues = @()
$passCount = 0

function Add-Issue {
    param([string]$Message)
    $script:issues += $Message
}

function Test-ArtifactContent {
    param(
        [string]$Name,
        [switch]$Required
    )

    $path = Join-Path $ChangeDir $Name
    if (-not (Test-Path -LiteralPath $path)) {
        if ($Required) { Add-Issue "${Name}: missing" }
        return
    }

    if (-not (Test-MeaningfulFile -Path $path -Placeholders @("TODO", "TBD", "path/to", "{module}", "example"))) {
        Add-Issue "${Name}: missing meaningful content or contains placeholders"
        return
    }

    $script:passCount++
    Write-Host "  PASS $Name"
}

Write-Host "Content quality check for: $(Split-Path $ChangeDir -Leaf)"
Write-Host "============================================================"

Test-ArtifactContent -Name "CHANGE.md" -Required
Test-ArtifactContent -Name "CODE_SCAN.md"
Test-ArtifactContent -Name "REQUIREMENT.md"
Test-ArtifactContent -Name "DESIGN.md"
Test-ArtifactContent -Name "TASKS.md"
Test-ArtifactContent -Name "VERIFY.md"

$reqPath = Join-Path $ChangeDir "REQUIREMENT.md"
if (Test-Path -LiteralPath $reqPath) {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $reqPath
    if (@([regex]::Matches($text, "AC-\d{2}")).Count -eq 0) {
        Add-Issue "REQUIREMENT.md: no AC-XX acceptance criteria found"
    }
}

$verifyPath = Join-Path $ChangeDir "VERIFY.md"
if (Test-Path -LiteralPath $verifyPath) {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $verifyPath
    if (@([regex]::Matches($text, "AC-\d{2}")).Count -eq 0) {
        Add-Issue "VERIFY.md: no AC evidence rows found"
    }
}

$designPath = Join-Path $ChangeDir "DESIGN.md"
if (Test-Path -LiteralPath $designPath) {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $designPath
    $codeRefs = @([regex]::Matches($text, '`[^`]+\.(java|ts|py|go|rs|kt|cs|sql|yaml|json|xml|ps1|sh)`')).Count
    if ($codeRefs -lt 3) {
        Add-Issue "DESIGN.md: only $codeRefs code reference(s); expected at least 3"
    }
}

Write-Host ""
Write-Host "Results:"
Write-Host "  Passed: $passCount"
if ($issues.Count -gt 0) {
    Write-Host "  Failed: $($issues.Count)"
    foreach ($issue in $issues) { Write-Host "    FAIL $issue" }
    if ($Strict) { exit 2 }
} else {
    Write-Host "  All content checks passed"
}
