<#
.SYNOPSIS
CLI dashboard showing agent-flow change status and gate results.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root.
Reads all change directories in agent-flow/changes/ and displays
a formatted status overview with gate results and statistics.

.PARAMETER ChangesRoot
Root directory for changes (default: agent-flow/changes).

.PARAMETER ProjectRoot
Project root path (default: current directory).

.EXAMPLE
agent-flow/scripts/dashboard.ps1

.EXAMPLE
agent-flow/scripts/dashboard.ps1 -ChangesRoot agent-flow/changes | Out-String -Width 120
#>

param(
    [string]$ChangesRoot = "agent-flow/changes",
    [string]$ProjectRoot = "."
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $PSCommandPath
. (Join-Path $scriptDir "_common.ps1")

$root = [System.IO.Path]::GetFullPath((Join-Path $scriptDir "..\.."))
$changesDir = Join-Path $root $ChangesRoot

if (-not (Test-Path -LiteralPath $changesDir)) {
    Write-Host "No changes directory found at $changesDir" -ForegroundColor Yellow
    exit 0
}

$changeDirs = Get-ChildItem -Directory -LiteralPath $changesDir | Sort-Object Name

if ($changeDirs.Count -eq 0) {
    Write-Host "No changes found in $changesDir" -ForegroundColor Cyan
    exit 0
}

# ── Collect change information ──
$rows = @()
$gates = @{}  # gate_name -> @{pass=0, fail=0, pending=0}
$stats = @{ total = $changeDirs.Count; light = 0; standard = 0; heavy = 0; emergency = 0; unknown = 0; blocked = 0 }

foreach ($dir in $changeDirs) {
    $changeId = $dir.Name
    $change = @{ id = $changeId }

    # Flow level
    $flow = Get-FlowLevel -Dir $dir.FullName
    $change.flow = $flow

    # Update flow statistics
    $lower = $flow.ToLower()
    if ($stats.ContainsKey($lower)) { $stats[$lower]++ }

    # Stage detection from key artifacts
    $stage = "intake"
    $hasState = Test-Path (Join-Path $dir.FullName "STATE.md")
    $hasChange = Test-Path (Join-Path $dir.FullName "CHANGE.md")
    $hasReq = Test-Path (Join-Path $dir.FullName "REQUIREMENT.md")
    $hasScan = Test-Path (Join-Path $dir.FullName "CODE_SCAN.md")
    $hasDesign = Test-Path (Join-Path $dir.FullName "DESIGN.md")
    $hasPlan = Test-Path (Join-Path $dir.FullName "PLAN.md")
    $hasTasks = Test-Path (Join-Path $dir.FullName "TASKS.md")
    $hasVerify = Test-Path (Join-Path $dir.FullName "VERIFY.md")
    $hasReport = Test-Path (Join-Path $dir.FullName "REPORT.md")
    $hasEvolution = Test-Path (Join-Path $dir.FullName "EVOLUTION.md")
    $hasAudit = Test-Path (Join-Path $dir.FullName "AUDIT.md")

    if ($hasReport -and $hasVerify) { $stage = "done" }
    elseif ($hasEvolution) { $stage = "evolve" }
    elseif ($hasVerify) { $stage = "verify" }
    elseif ($hasTasks) { $stage = "implement" }
    elseif ($hasPlan) { $stage = "plan" }
    elseif ($hasAudit) { $stage = "audit" }
    elseif ($hasDesign) { $stage = "design" }
    elseif ($hasScan) { $stage = "code-scan" }
    elseif ($hasReq) { $stage = "requirements" }
    elseif ($hasChange) { $stage = "intake" }
    $change.stage = $stage

    # Blocked detection
    $blocked = $false
    # Check STATE.md for blocked status
    if ($hasState) {
        $stateText = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $dir.FullName "STATE.md")
        if ($stateText -match "(?im)^blocked:?\s*true") { $blocked = $true }
        if ($stateText -match "(?im)^status:\s*blocked") { $blocked = $true }
    }
    # Check CHECK_RESULT.json for failed gates
    $checkResultPath = Join-Path $dir.FullName "CHECK_RESULT.json"
    if (Test-Path $checkResultPath) {
        try {
            $check = Get-Content -Raw -Encoding utf8 -LiteralPath $checkResultPath | ConvertFrom-Json
            $allPassed = $true
            if ($check.gates) {
                foreach ($g in $check.gates.PSObject.Properties) {
                    $gName = $g.Name
                    $gResult = $g.Value.result
                    if ($gResult -eq "pass") { $gates[$gName] = @{ pass = ($gates[$gName].pass + 1); fail = ($gates[$gName].fail); pending = ($gates[$gName].pending) } }
                    elseif ($gResult -eq "fail") { $gates[$gName] = @{ pass = ($gates[$gName].pass); fail = ($gates[$gName].fail + 1); pending = ($gates[$gName].pending) }; $allPassed = $false }
                    else { $gates[$gName] = @{ pass = ($gates[$gName].pass); fail = ($gates[$gName].fail); pending = ($gates[$gName].pending + 1) }; $allPassed = $false }
                    if (-not $gates[$gName]) { $gates[$gName] = @{ pass = 0; fail = 0; pending = 0 } }
                }
            }
            if (-not $allPassed) { $blocked = $true }
        } catch { }
    }
    $change.blocked = $blocked
    if ($blocked) { $stats.blocked++ }

    $rows += $change
}

# ── Render dashboard ──
$totalWidth = 100
Write-Host "`n" ("=" * $totalWidth) -ForegroundColor Cyan
Write-Host "  agent-flow Dashboard" -ForegroundColor White
Write-Host "  Project: $(Split-Path -Leaf $root)  |  Changes: $($stats.total)  |  $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Gray
Write-Host ("=" * $totalWidth) -ForegroundColor Cyan

# ── Change Status Table ──
Write-Host "`nChanges:" -ForegroundColor Cyan
$header = "  {0,-40} {1,-10} {2,-12} {3,-8} {4}" -f "ID", "Flow", "Stage", "Blocked", "Next Action"
Write-Host $header -ForegroundColor White
Write-Host ("  " + ("-" * 92)) -ForegroundColor DarkGray

foreach ($r in $rows) {
    $flowColor = switch ($r.flow.ToLower()) {
        "light" { "Green" }
        "standard" { "Yellow" }
        "heavy" { "Red" }
        "emergency" { "Magenta" }
        default { "Gray" }
    }
    $blockedText = if ($r.blocked) { "⚠ Blocked" } else { "✓ Clear" }
    $blockedColor = if ($r.blocked) { "Red" } else { "Green" }

    $line = "  {0,-40} {1,-10} {2,-12} {3,-10} {4}" -f $r.id, $r.flow, $r.stage, $blockedText, ""
    # Write with colored segments
    Write-Host "  " -NoNewline
    Write-Host ("{0,-40}" -f $r.id) -NoNewline -ForegroundColor White
    Write-Host ("{0,-10}" -f $r.flow) -NoNewline -ForegroundColor $flowColor
    Write-Host ("{0,-12}" -f $r.stage) -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-10}" -f $blockedText) -NoNewline -ForegroundColor $blockedColor
    Write-Host ""
}

# ── Gate Status Summary ──
if ($gates.Count -gt 0) {
    Write-Host "`nGate Status (across all changes with CHECK_RESULT.json):" -ForegroundColor Cyan
    # Sort gates: failing first, then pending, then passing
    $sortedGates = $gates.GetEnumerator() | Sort-Object @{Expression={$_.Value.fail}; Descending=$true},
                                                         @{Expression={$_.Value.pending}; Descending=$true}
    foreach ($g in $sortedGates) {
        $icon = if ($g.Value.fail -gt 0) { "❌" } elseif ($g.Value.pending -gt 0) { "⚠️" } else { "✅" }
        $color = if ($g.Value.fail -gt 0) { "Red" } elseif ($g.Value.pending -gt 0) { "Yellow" } else { "Green" }
        $summary = "pass=$($g.Value.pass) fail=$($g.Value.fail) pending=$($g.Value.pending)"
        Write-Host "  $icon $($g.Key) ".PadRight(45) -NoNewline -ForegroundColor $color
        Write-Host $summary -ForegroundColor Gray
    }
}

# ── Statistics ──
Write-Host "`nStatistics:" -ForegroundColor Cyan
Write-Host "  Total changes : $($stats.total)"
Write-Host "  Light        : $($stats.light)" -ForegroundColor Green
Write-Host "  Standard     : $($stats.standard)" -ForegroundColor Yellow
Write-Host "  Heavy        : $($stats.heavy)" -ForegroundColor Red
Write-Host "  Emergency    : $($stats.emergency)" -ForegroundColor Magenta
Write-Host "  Unknown      : $($stats.unknown)" -ForegroundColor Gray
Write-Host "  Blocked      : $($stats.blocked)" -ForegroundColor $(if ($stats.blocked -gt 0) { "Red" } else { "Green" })

# ── Quick Commands ──
Write-Host "`nCommands:" -ForegroundColor Cyan
Write-Host "  open <id>     - agent-flow/scripts/next-step.ps1 -ChangeDir agent-flow/changes/<id>"
Write-Host "  gates <id>    - agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/<id>"
Write-Host ("=" * $totalWidth) -ForegroundColor DarkGray
Write-Host ""
