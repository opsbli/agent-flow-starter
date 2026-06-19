<#
.SYNOPSIS
Run the emergency-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/emergency-check.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")

function Get-Field {
    param(
        [string]$Text,
        [string]$Key
    )
    $pattern = "(?im)^\s*-?\s*$([regex]::Escape($Key))\s*:\s*(.+?)\s*$"
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return ""
}

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$flow = Get-FlowLevel -Dir $ChangeDir
if ($flow -ne "Emergency") {
    Write-Host "SKIP: emergency-check only applies to Emergency changes."
    exit 0
}

$changePath = Join-Path $ChangeDir "CHANGE.md"
if (-not (Test-Path -LiteralPath $changePath)) {
    Write-Host "Emergency check failed:"
    Write-Host " - Missing CHANGE.md"
    exit 2
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $changePath
$issues = @()

$level = Get-Field -Text $text -Key "Level"
$approvedBy = Get-Field -Text $text -Key "Approved by"
$bypassReason = Get-Field -Text $text -Key "Bypass reason"
$deadline = Get-Field -Text $text -Key "Backfill deadline"
$status = Get-Field -Text $text -Key "Backfill status"
$emergencyInvalid = "(?i)TODO|TBD|\{.+?\}|pending-user|your-name"

if ($level -notmatch "(?i)^(P0|P1)$") {
    $issues += "Emergency Level must be P0 or P1."
}
if (-not (Test-Meaningful -Value $approvedBy -InvalidPattern $emergencyInvalid)) {
    $issues += "Emergency Approved by must name an accountable approver."
}
if (-not (Test-Meaningful -Value $bypassReason -InvalidPattern $emergencyInvalid)) {
    $issues += "Emergency Bypass reason must explain why the full flow was skipped."
}
if (-not (Test-Meaningful -Value $deadline -InvalidPattern $emergencyInvalid)) {
    $issues += "Emergency Backfill deadline must be set."
}
if ($status -notmatch "^(?i)pending|done|waived$") {
    $issues += "Emergency Backfill status must be pending, done, or waived."
}

if ($status -match "^(?i)pending$" -and (Test-Meaningful -Value $deadline -InvalidPattern $emergencyInvalid)) {
    $parsedDeadline = [datetime]::MinValue
    if ([datetime]::TryParse($deadline, [ref] $parsedDeadline)) {
        if ($parsedDeadline -lt (Get-Date)) {
            $issues += "Emergency Backfill deadline ($deadline) has already passed but backfill status is still pending."
        }
    }
}

foreach ($file in @("CODE_SCAN.md", "TASKS.md", "VERIFY.md", "REPORT.md", "EVOLUTION.md")) {
    $path = Join-Path $ChangeDir $file
    if (-not (Test-Path -LiteralPath $path)) {
        $issues += "Emergency change must include $file."
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Emergency check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Emergency check passed."



