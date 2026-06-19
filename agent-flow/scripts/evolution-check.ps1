<#
.SYNOPSIS
Run the evolution-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/evolution-check.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")

function Get-KeyValue {
    param([string]$Text, [string]$Key)
    $pattern = "(?im)^\s*$([regex]::Escape($Key))\s*:\s*(.+?)\s*$"
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return ""
}

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$flow = Get-FlowLevel -Dir $ChangeDir
$path = Join-Path $ChangeDir "EVOLUTION.md"
if (-not (Test-Path -LiteralPath $path)) {
    if ($flow -eq "Light") {
        Write-Host "SKIP: Light change has no EVOLUTION.md."
        exit 0
    }
    Write-Host "Evolution check failed:"
    Write-Host " - Missing EVOLUTION.md"
    Write-Host " - HINT: Run 'agent-flow/scripts/evolution-suggest.ps1 -ChangeDir <change> -Output <change>/EVOLUTION.md' to generate a draft."
    exit 2
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $path
$issues = @()
$required = @(Get-RuleList -Name "evolution.keys")

foreach ($key in $required) {
    $content = Get-KeyValue -Text $text -Key $key
    if (-not (Test-Meaningful -Value $content)) {
        $issues += "EVOLUTION.md key '$key' is missing or still empty."
    }
}

if ($text -notmatch "(?i)knowledge|ADR|gate|template|script|none|no change") {
    $issues += "EVOLUTION.md must record either concrete upgrades or explicit no-change decisions."
}

if ($issues.Count -gt 0) {
    Write-Host "Evolution check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Evolution check passed for $flow change."



