<#
.SYNOPSIS
Run the task-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/task-check.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")

function Get-AcIds {
    param([string]$Text)
    [regex]::Matches($Text, "AC-\d{2}") | ForEach-Object { $_.Value } | Select-Object -Unique
}

function Test-VerifyEvidence {
    param(
        [string]$VerifyText,
        [string]$TaskId,
        [string[]]$AcIds
    )
    if ([string]::IsNullOrWhiteSpace($VerifyText)) { return $false }
    if ($VerifyText -match [regex]::Escape($TaskId)) { return $true }
    foreach ($ac in $AcIds) {
        if ($VerifyText -match [regex]::Escape($ac)) { return $true }
    }
    return $false
}

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$tasksPath = Join-Path $ChangeDir "TASKS.md"
if (-not (Test-Path -LiteralPath $tasksPath)) {
    Write-Host "Task check failed:"
    Write-Host " - Missing TASKS.md"
    exit 2
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $tasksPath
$verifyPath = Join-Path $ChangeDir "VERIFY.md"
$verifyText = if (Test-Path -LiteralPath $verifyPath) { Get-Content -Raw -Encoding utf8 -LiteralPath $verifyPath } else { "" }
$issues = @()
$allowedStatus = "pending|not_started|in_progress|completed|blocked|skipped"
$allowedParallel = "yes|no|true|false|allowed|blocked"

$taskRows = @()
foreach ($line in ($text -split "\r?\n")) {
    $trim = $line.Trim()
    if ($trim -match "^\|\s*T-?\d+[A-Za-z]*\s*\|") {
        $taskRows += $trim
    }
}

if ($taskRows.Count -gt 0) {
    foreach ($row in $taskRows) {
        $cells = @($row.Trim("|").Split("|") | ForEach-Object { $_.Trim() })
        if ($cells.Count -lt 7) {
            $issues += "Task Matrix row must have 7 columns: $row"
            continue
        }
        $taskId, $status, $ac, $readFiles, $writeFiles, $verify, $parallel = $cells[0..6]
        $acIds = @(Get-AcIds -Text $ac)
        if ($status -notmatch "^(?i)($allowedStatus)$") { $issues += "$taskId has invalid Status: $status" }
        if ($acIds.Count -eq 0) { $issues += "$taskId must map to at least one AC id." }
        if (-not (Test-Meaningful -Value $readFiles)) { $issues += "$taskId must declare read_files." }
        if (-not (Test-Meaningful -Value $writeFiles)) { $issues += "$taskId must declare write_files." }
        if (-not (Test-Meaningful -Value $verify)) { $issues += "$taskId must declare Verify." }
        if ($parallel -notmatch "^(?i)($allowedParallel)$") { $issues += "$taskId has invalid Parallel value: $parallel" }
        if ($status -match "^(?i)completed$" -and -not (Test-VerifyEvidence -VerifyText $verifyText -TaskId $taskId -AcIds $acIds)) {
            $issues += "$taskId is completed but VERIFY.md has no matching task id or AC evidence."
        }
    }
} else {
    $blocks = [regex]::Matches($text, "(?ims)^###\s+(T[-0-9A-Za-z]+).*?(?=^###\s+|\z)")
    if ($blocks.Count -eq 0) {
        $issues += "TASKS.md must contain a Task Matrix row or task detail sections."
    }
    foreach ($match in $blocks) {
        $taskId = $match.Groups[1].Value
        $block = $match.Value
        foreach ($label in @("Status", "Goal", "AC", "read_files", "write_files", "Verify", "Parallel")) {
            if ($block -notmatch "(?im)^$([regex]::Escape($label))\s*:\s*\S") {
                $issues += "$taskId missing non-empty '$label'."
            }
        }
        $acIds = @(Get-AcIds -Text $block)
        if ($acIds.Count -eq 0) { $issues += "$taskId must map to at least one AC id." }
        if ($block -match "(?im)^Status\s*:\s*completed\s*$" -and -not (Test-VerifyEvidence -VerifyText $verifyText -TaskId $taskId -AcIds $acIds)) {
            $issues += "$taskId is completed but VERIFY.md has no matching task id or AC evidence."
        }
    }
}

if ($text -notmatch "(?im)^\s*write_files\s*:") {
    $issues += "TASKS.md must include a machine-readable write_files: list for task-boundary-check."
}

if ($issues.Count -gt 0) {
    Write-Host "Task check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Task check passed."



