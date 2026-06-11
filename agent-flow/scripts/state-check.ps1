<#
.SYNOPSIS
Run the state-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.PARAMETER ExpectedStage
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/state-check.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ExpectedStage = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$statePath = Join-Path $ChangeDir "STATE.md"
if (-not (Test-Path -LiteralPath $statePath)) {
    Write-Host "STATE.md not found in $ChangeDir"
    exit 2
}

$nextStep = Join-Path $PSScriptRoot "next-step.ps1"
if (-not (Test-Path -LiteralPath $nextStep)) {
    throw "next-step.ps1 not found next to state-check.ps1"
}

$json = & $nextStep -ChangeDir $ChangeDir
$result = $json | ConvertFrom-Json

$inferredStage = [string]$result.stage
$stateStage = [string]$result.state_current_stage

if ([string]::IsNullOrWhiteSpace($stateStage)) {
    Write-Host "STATE.md is missing current_stage."
    exit 2
}

if (-not [string]::IsNullOrWhiteSpace($ExpectedStage) -and $inferredStage -ne $ExpectedStage) {
    Write-Host "Expected inferred stage '$ExpectedStage', got '$inferredStage'."
    exit 2
}

if ($stateStage -ne $inferredStage) {
    Write-Host "STATE.md is out of sync."
    Write-Host " - current_stage: $stateStage"
    Write-Host " - next-step stage: $inferredStage"
    Write-Host "Update STATE.md after reading next-step output."
    exit 2
}

Write-Host "State check passed: STATE.md current_stage matches next-step stage '$inferredStage'."



