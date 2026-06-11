<#
.SYNOPSIS
Generate emergency CANCEL.md and ROLLBACK.md with auto-filled timestamps.
.DESCRIPTION
Auto-fills emergency templates with change info and timestamps.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)
$ErrorActionPreference = "Stop"
$now = Get-Date -Format 'yyyy-MM-dd HH:mm'
$today = Get-Date -Format 'yyyy-MM-dd'
$changeMd = Join-Path $ChangeDir "CHANGE.md"
$changeDesc = "Emergency change"
if (Test-Path $changeMd) {
    $c = Get-Content $changeMd -Raw -Encoding utf8 -ErrorAction SilentlyContinue
    if ($c -match "(?s)description[:：]\s*(.+?)[\r\n]") { $changeDesc = $Matches[1].Trim() }
}
$changeId = Split-Path $ChangeDir -Leaf
$cancelOut = Join-Path $ChangeDir "CANCEL.md"
$rollbackOut = Join-Path $ChangeDir "ROLLBACK.md"
if (-not (Test-Path $cancelOut)) {
    @"
# Cancel / Abandon

## Change
- Change ID: $changeId
- Flow: Emergency
- Started: $now
- Cancelled: (fill)

## Reason for Cancellation
(fill)

## What Was Done
| Stage | Status | Notes |
|-------|--------|-------|
| Intake | (fill) | |
| Code Scan | (fill) | |
| Design | (fill) | |
| Implementation | (fill) | |
| Verification | (fill) | |

## Salvageable Artifacts
(fill)

## Approval
- Cancelled by: (fill)
- Date: $today
"@ | Set-Content $cancelOut -Encoding utf8
    Write-Host "CANCEL.md generated: $cancelOut" -ForegroundColor Green
}
if (-not (Test-Path $rollbackOut)) {
    @"
# Rollback Plan

## Change
- Change ID: $changeId
- Description: $changeDesc
- Rollback requested by: (fill)
- Date: $today

## Scope of Rollback
- [ ] Full rollback (revert all files)
- [ ] Partial rollback (revert specific files/modules)

## Files to Revert
| File | Revert Strategy | Risk |
|------|----------------|------|
| (fill) | (fill) | (fill) |

## Data / Schema Rollback
- [ ] No schema change
- [ ] Migration rollback: (command)
- [ ] Data fix: (description)

## Verification After Rollback
- [ ] Compile passed
- [ ] Tests passed
- [ ] Schema reverted
- [ ] Manual smoke test passed

## Rollback History
| Date | Action | By |
|------|--------|-----|
| $today | (fill) | (fill) |
"@ | Set-Content $rollbackOut -Encoding utf8
    Write-Host "ROLLBACK.md generated: $rollbackOut" -ForegroundColor Green
}
if ((Test-Path $cancelOut) -and (Test-Path $rollbackOut)) {
    Write-Host "✅ Emergency templates ready for: $changeId" -ForegroundColor Green
    Write-Host "  Edit CANCEL.md and ROLLBACK.md with actual details"
}
