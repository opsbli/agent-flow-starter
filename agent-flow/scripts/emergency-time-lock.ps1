<#
.SYNOPSIS
Emergency time-lock check: prevents same-module Emergency within 7 days.
Extracted from agent-flow/flows/emergency.md.

.DESCRIPTION
Part of the agent-flow scaffold toolchain.
Checks whether the same module has had an Emergency change within the last 7 days.

.PARAMETER ChangeDir
Path to the new change directory.

.PARAMETER ChangesRoot
Root directory for changes (default: agent-flow/changes).

.EXAMPLE
agent-flow/scripts/emergency-time-lock.ps1 -ChangeDir agent-flow/changes/my-hotfix
#>

param(
    [string]$ChangeDir,
    [string]$ChangesRoot = "agent-flow/changes"
)

if (-not $ChangeDir) {
    Write-Host "Usage: emergency-time-lock.ps1 -ChangeDir <change-dir> [-ChangesRoot <path>]" -ForegroundColor Yellow
    exit 2
}

if (-not (Test-Path $ChangeDir)) {
    Write-Host "Change directory not found: $ChangeDir" -ForegroundColor Red
    exit 1
}

$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
$changesDir = Join-Path $root $ChangesRoot
$changeName = Split-Path $ChangeDir -Leaf

# Extract module name
$changeFile = Join-Path $ChangeDir "CHANGE.md"
$moduleName = $changeName
if (Test-Path $changeFile) {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $changeFile
    if ($text -match "(?s)## 影响范围.*?\n(.+?)$") {
        $firstLine = $matches[1].Trim()
        if ($firstLine) { $moduleName = $firstLine }
    }
}

$now = Get-Date

# Scan recent Emergency changes
$dirs = Get-ChildItem -Directory -LiteralPath $changesDir | Where-Object { $_.Name -ne $changeName }
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

    if ($otherModule -ne $moduleName) { continue }

    # Get date from directory name
    $dateMatch = [regex]::Match($dir.Name, '^(\d{4})(\d{2})(\d{2})')
    if (-not $dateMatch.Success) { continue }

    try {
        $changeDate = Get-Date -Year $dateMatch.Groups[1].Value -Month $dateMatch.Groups[2].Value -Day $dateMatch.Groups[3].Value
        $diffDays = ($now - $changeDate).Days
        if ($diffDays -lt 7) {
            Write-Host "⛔ Time lock active for module '$moduleName' (last Emergency: $($dir.Name), ${diffDays} day(s) ago). Use Heavy process instead." -ForegroundColor Red
            exit 1
        }
    } catch { }
}

Write-Host "✅ No time-lock conflict for module '$moduleName'." -ForegroundColor Green
exit 0
