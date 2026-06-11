param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$nextStep = Join-Path $PSScriptRoot "next-step.ps1"
$json = & $nextStep -ChangeDir $ChangeDir
$result = $json | ConvertFrom-Json

$statePath = Join-Path $ChangeDir "STATE.md"
$changeId = Split-Path -Leaf $ChangeDir
$date = Get-Date -Format "yyyy-MM-dd"
$blocked = if ($result.blocked.Count -gt 0) { "true" } else { "false" }
$blockers = @($result.blocked)
if ($blockers.Count -eq 0) { $blockers = @("none") }
$blockerLines = ($blockers | ForEach-Object { "  - $_" }) -join "`n"

$tail = ""
if (Test-Path -LiteralPath $statePath) {
    $existing = Get-Content -Raw -Encoding utf8 -LiteralPath $statePath
    $match = [regex]::Match($existing, '(?s)## Stage History.*$')
    if ($match.Success) {
        $tail = $match.Value.TrimEnd()
    }
}

if ([string]::IsNullOrWhiteSpace($tail)) {
    $tail = @"
## Stage History

| Time | Stage | Actor | Notes |
|---|---|---|---|
| $date | $($result.stage) | sync-state | Synced from next-step. |

## Notes

- `STATE.md` is a lightweight navigation aid.
- Source-of-truth remains the actual artifacts.
- If `STATE.md` conflicts with the artifacts, update it after checking `next-step`.
"@
} elseif ($tail -notmatch [regex]::Escape("| $date | $($result.stage) | sync-state | Synced from next-step. |")) {
    $tail = $tail -replace '(\|---\|---\|---\|---\|\s*)', "`$1`n| $date | $($result.stage) | sync-state | Synced from next-step. |"
}

$content = @"
# State

change_id: $changeId
flow: $($result.flow)
current_stage: $($result.stage)
blocked: $blocked
blockers:
$blockerLines
next_action: $($result.next)
owner: unassigned
last_updated: $date

$tail
"@

Set-Content -Encoding utf8 -LiteralPath $statePath -Value $content
Write-Host "STATE.md synced to stage '$($result.stage)'."
