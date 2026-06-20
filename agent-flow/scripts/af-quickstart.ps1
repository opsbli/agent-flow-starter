<#
.SYNOPSIS
Run the shortest useful agent-flow onboarding path.

.DESCRIPTION
Checks the scaffold, initializes manifest context if needed, creates a Light
demo change, and prints one recommended next command.
#>

param(
    [string]$Target = ".",
    [string]$DemoName = "hello-agent-flow",
    [switch]$SkipDemo
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($Target)
if (-not (Test-Path -LiteralPath $root)) {
    throw "Target not found: $root"
}

function Run-Step {
    param(
        [string]$Label,
        [scriptblock]$Action
    )

    Write-Host ""
    Write-Host "== $Label =="
    & $Action
}

Write-Host "agent-flow quickstart"
Write-Host "Project: $root"

Run-Step "1. scaffold health" {
    $script = Join-Path $root "agent-flow/scripts/scaffold-health.ps1"
    if (-not (Test-Path -LiteralPath $script)) {
        throw "Missing $script. Install agent-flow first."
    }
    & $script
}

Run-Step "2. manifest check" {
    $script = Join-Path $root "agent-flow/scripts/manifest-check.ps1"
    if (-not (Test-Path -LiteralPath $script)) {
        throw "Missing $script. Run init-project after installation."
    }
    & $script
}

$changeDir = Join-Path $root "agent-flow/changes/$DemoName"
if (-not $SkipDemo) {
    Run-Step "3. demo change" {
        $script = Join-Path $root "agent-flow/scripts/new-change.ps1"
        if (-not (Test-Path -LiteralPath $script)) {
            throw "Missing $script."
        }
        if (-not (Test-Path -LiteralPath $changeDir)) {
            & $script -Name $DemoName -Flow Light
        }
        $changePath = Join-Path $changeDir "CHANGE.md"
        if (Test-Path -LiteralPath $changePath) {
            @"
# Change: $DemoName

## One-line Requirement
First agent-flow demo change.

## Flow Level

- [x] Light
- [ ] Standard
- [ ] Heavy
- [ ] Emergency

## Classification Reason

Demo only; no production code changes.

## Goal

- Learn the minimum agent-flow loop.

## Non-goals

- No application code changes.

## Impact

- none
"@ | Set-Content -Encoding utf8 -LiteralPath $changePath
        }
        Write-Host "Demo change ready: agent-flow/changes/$DemoName"
    }
}

$relativeChangeDir = "agent-flow/changes/$DemoName"
$nextCommand = if ($SkipDemo) {
    "agent-flow/scripts/new-change.ps1 -Name <change-id> -Flow Standard"
} else {
    "agent-flow/scripts/next-step.ps1 -ChangeDir $relativeChangeDir"
}

Write-Host ""
Write-Host "Recommended next command:"
Write-Host "  $nextCommand"
Write-Host ""
Write-Host "Useful follow-ups:"
Write-Host "  agent-flow/scripts/check-change.ps1 -ChangeDir $relativeChangeDir"
Write-Host "  agent-flow/scripts/dashboard.ps1"
Write-Host "  Get-Content -Raw agent-flow/READING.md"
