<#
.SYNOPSIS
Emergency abuse detection: hard-lock module after 3+ Emergency uses in 30 days.
Extracted from agent-flow/flows/emergency.md.

.DESCRIPTION
Part of the agent-flow scaffold toolchain.

.PARAMETER ChangesRoot
Root directory for changes (default: agent-flow/changes).

.PARAMETER Module
Module name to check.

.PARAMETER Threshold
Emergency count threshold (default: 3).

.PARAMETER WindowDays
Time window in days (default: 30).

.EXAMPLE
agent-flow/scripts/emergency-abuse-check.ps1 -ChangesRoot agent-flow/changes -Module login-module
#>

param(
    [string]$ChangesRoot = "agent-flow/changes",
    [string]$Module = "",
    [int]$Threshold = 3,
    [int]$WindowDays = 30
)

if (-not $Module) {
    Write-Host "Usage: emergency-abuse-check.ps1 -ChangesRoot <path> -Module <name>" -ForegroundColor Yellow
    exit 2
}

$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
$changesDir = Join-Path $root $ChangesRoot

if (-not (Test-Path $changesDir)) {
    Write-Host "Changes directory not found: $changesDir" -ForegroundColor Red
    exit 1
}

$now = Get-Date
$count = 0

$dirs = Get-ChildItem -Directory -LiteralPath $changesDir
foreach ($dir in $dirs) {
    $cf = Join-Path $dir.FullName "CHANGE.md"
    if (-not (Test-Path $cf)) { continue }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $cf
    if ($text -notmatch '(?i)\[x\]\s+Emergency') { continue }

    # Extract module
    $otherModule = $dir.Name
    if ($text -match "(?s)## 影响范围.*?\n(.+?)$") {
        $fl = $matches[1].Trim()
        if ($fl) { $otherModule = $fl }
    }

    if ($otherModule -ne $Module) { continue }

    # Get date from directory name
    $dateMatch = [regex]::Match($dir.Name, '^(\d{4})(\d{2})(\d{2})')
    if (-not $dateMatch.Success) { continue }

    try {
        $changeDate = Get-Date -Year $dateMatch.Groups[1].Value -Month $dateMatch.Groups[2].Value -Day $dateMatch.Groups[3].Value
        $diffDays = ($now - $changeDate).Days
        if ($diffDays -le $WindowDays) { $count++ }
    } catch { }
}

if ($count -ge $Threshold) {
    Write-Host "🔴 Module '$Module' has $count Emergency changes in $WindowDays days (threshold: $Threshold)." -ForegroundColor Red
    Write-Host "   Recommend: hard-lock for 30 days, architecture review, and ADR creation." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Module '$Module' has $count Emergency changes in $WindowDays days (below threshold $Threshold)." -ForegroundColor Green
exit 0
