<#
.SYNOPSIS
Check Emergency change backfill status — ensure 24h deadline is met.

.DESCRIPTION
Part of the agent-flow scaffold toolchain.
Checks that Emergency changes have their required backfill artifacts
completed within 24 hours.

.PARAMETER ChangeDir
Path to the change directory.

.PARAMETER Strict
Fail if any backfill artifact is missing (vs warn).

.EXAMPLE
agent-flow/scripts/emergency-backfill-check.ps1 -ChangeDir agent-flow/changes/hotfix-login
#>

param(
    [string]$ChangeDir,
    [switch]$Strict
)

$ErrorActionPreference = "Stop"

if (-not $ChangeDir) {
    Write-Host "Usage: emergency-backfill-check.ps1 -ChangeDir <path>" -ForegroundColor Yellow
    exit 1
}
if (-not (Test-Path $ChangeDir)) {
    Write-Host "Change directory not found: $ChangeDir" -ForegroundColor Red
    exit 1
}

$changeName = Split-Path $ChangeDir -Leaf
$changeFile = Join-Path $ChangeDir "CHANGE.md"
if (-not (Test-Path $changeFile)) {
    Write-Host "CHANGE.md not found — not an Emergency change?" -ForegroundColor Yellow
    exit 0
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $changeFile

# Verify this is an Emergency change
if ($text -notmatch '(?i)\[x\]\s+Emergency') {
    Write-Host "Not an Emergency change. Skipping." -ForegroundColor Gray
    exit 0
}

# Extract Emergency metadata
$level = ""
$deadline = ""
$status = ""

if ($text -match '(?im)Level:\s*(P[01])') { $level = $matches[1] }
if ($text -match '(?im)Backfill deadline:\s*(.+?)$') { $deadline = $matches[1].Trim() }
if ($text -match '(?im)Backfill status:\s*(\S+)') { $status = $matches[1].Trim() }

if ($status -eq "waived") {
    Write-Host "Backfill waived (explicitly noted in CHANGE.md)." -ForegroundColor Yellow
    exit 0
}

# Check deadline
if ($deadline) {
    try {
        $deadlineDate = [datetime]::Parse($deadline)
        $now = Get-Date
        if ($now -gt $deadlineDate -and $status -ne "done") {
            Write-Host "⛔ BACKFILL OVERDUE: Deadline was $deadline (status: $status)" -ForegroundColor Red
            if ($Strict) { exit 2 }
        } else {
            Write-Host "Deadline: $deadline — $(if($status -eq 'done'){'✅ done'}else{'pending, still within window'})" -ForegroundColor $(if($status -eq 'done'){'Green'}else{'Yellow'})
        }
    } catch {
        Write-Host "Cannot parse deadline: $deadline" -ForegroundColor Yellow
    }
} else {
    Write-Host "No deadline set in CHANGE.md. Defaulting to +24h from now." -ForegroundColor Yellow
}

# Required backfill artifacts
$requiredArtifacts = @(
    @{ name = "REQUIREMENT.md (完整)"; path = "REQUIREMENT.md" }
    @{ name = "CODE_SCAN.md (完整)"; path = "CODE_SCAN.md" }
    @{ name = "DESIGN.md (含 Design Alignment)"; path = "DESIGN.md" }
    @{ name = "REVIEW.md"; path = "REVIEW.md" }
    @{ name = "AUDIT.md (Closure Audit)"; path = "AUDIT.md" }
    @{ name = "EVOLUTION.md"; path = "EVOLUTION.md" }
)

$missing = @()
foreach ($art in $requiredArtifacts) {
    $artPath = Join-Path $ChangeDir $art.path
    if (-not (Test-Path $artPath)) {
        $missing += $art.name
    }
}

if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Host "Missing backfill artifacts:" -ForegroundColor Red
    foreach ($m in $missing) {
        Write-Host "  ❌ $m" -ForegroundColor Red
    }
    if ($Strict) { exit 2 }
} else {
    Write-Host ""
    Write-Host "✅ All backfill artifacts present." -ForegroundColor Green
}

# Check pitfalls.md update
$knowledgeDir = Join-Path (Split-Path $ChangeDir -Parent) "..\knowledge"
$pitfallsPath = Join-Path $knowledgeDir "pitfalls.md"
if (Test-Path $pitfallsPath) {
    $pitfallsText = Get-Content -Raw -Encoding utf8 -LiteralPath $pitfallsPath
    $lastWrite = (Get-Item $pitfallsPath).LastWriteTime
    $changeDate = (Get-Item $changeFile).LastWriteTime
    if ($lastWrite -lt $changeDate) {
        Write-Host "⚠️ pitfalls.md not updated since before the Emergency change. Review and update if applicable." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Backfill status: $status" -ForegroundColor $(if($status -eq 'done'){'Green'}else{'Yellow'})
exit 0
