<#
.SYNOPSIS
Apply fatigue recommendations — auto-skip or advisory-mode fatigued gates.

.DESCRIPTION
Reads the gate-fatigue-check report and marks fatigued gates as advisory
for specified flow levels. Advisory gates warn but don't block.

.PARAMETER ChangeDir
Path to the change directory.

.PARAMETER ChangesRoot
Root directory for changes (default: agent-flow/changes).

.PARAMETER Threshold
Consecutive passes threshold (default: 8).

.PARAMETER Apply
Actually apply the changes (default: dry-run).

.EXAMPLE
agent-flow/scripts/fatigue-action.ps1 -ChangesRoot agent-flow/changes -Threshold 8 -Apply
#>

param(
    [string]$ChangeDir = "",
    [string]$ChangesRoot = "agent-flow/changes",
    [int]$Threshold = 8,
    [switch]$Apply
)

$ErrorActionPreference = "Stop"
$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
$changesDir = Join-Path $root $ChangesRoot

# ── Scan gate results across changes ──
if (-not (Test-Path $changesDir)) {
    Write-Host "No changes directory found." -ForegroundColor Yellow
    exit 0
}

$fatiguedGates = @{}
$gateContexts = @{}  # gate_name -> @{flow_levels_used_in = @()}
$dirs = Get-ChildItem -Directory -LiteralPath $changesDir | Sort-Object Name

foreach ($dir in $dirs) {
    $checkPath = Join-Path $dir.FullName "CHECK_RESULT.json"
    if (-not (Test-Path $checkPath)) { continue }

    try {
        $check = Get-Content -Raw -Encoding utf8 -LiteralPath $checkPath | ConvertFrom-Json
        if ($check.gates) {
            # Detect flow level
            $changeDirObj = $dir.FullName
            $flow = "unknown"
            $changeFile = Join-Path $changeDirObj "CHANGE.md"
            if (Test-Path $changeFile) {
                $changeText = Get-Content -Raw -Encoding utf8 -LiteralPath $changeFile
                if ($changeText -match '(?i)\[x\]\s+Light') { $flow = "Light" }
                elseif ($changeText -match '(?i)\[x\]\s+Standard') { $flow = "Standard" }
                elseif ($changeText -match '(?i)\[x\]\s+Heavy') { $flow = "Heavy" }
                elseif ($changeText -match '(?i)\[x\]\s+Emergency') { $flow = "Emergency" }
            }

            foreach ($g in $check.gates.PSObject.Properties) {
                $gName = $g.Name
                $gResult = $g.Value.result

                if (-not $gateContexts.ContainsKey($gName)) {
                    $gateContexts[$gName] = @{ total = 0; pass = 0; fail = 0; consecutive_pass = 0; last_result = ""; flows = @{} }
                }
                $ctx = $gateContexts[$gName]
                $ctx.total++
                if ($gResult -eq "pass") { $ctx.pass++; $ctx.consecutive_pass++ }
                else { $ctx.fail++; $ctx.consecutive_pass = 0 }
                $ctx.last_result = $gResult
                if (-not $ctx.flows.ContainsKey($flow)) { $ctx.flows[$flow] = 0 }
                $ctx.flows[$flow]++
            }
        }
    } catch { }
}

# ── Identify fatigued gates with context ──
$recommendations = @()

foreach ($entry in $gateContexts.GetEnumerator()) {
    $gName = $entry.Key
    $data = $entry.Value

    if ($data.consecutive_pass -ge $Threshold -and $data.fail -eq 0 -and $data.total -ge $Threshold) {
        # Determine which flow levels this gate is fatigued in
        $fatiguedLevels = @()
        foreach ($f in $data.flows.Keys) {
            $fatiguedLevels += $f
        }

        $recommendations += @{
            gate = $gName
            consecutive = $data.consecutive_pass
            total = $data.total
            flows = ($fatiguedLevels -join ", ")
            action = "advisory-for-light"
            description = "Set to advisory-only for Light changes (warn but don't block)"
        }

        if ($fatiguedLevels -contains "Standard" -and $fatiguedLevels -notcontains "Heavy") {
            $recommendations += @{
                gate = $gName
                consecutive = $data.consecutive_pass
                total = $data.total
                flows = "Standard"
                action = "advisory-for-standard"
                description = "Set to advisory-only for Standard changes (warn but don't block)"
            }
        }

        if ($fatiguedLevels.Count -eq 1 -and $fatiguedLevels[0] -eq "Heavy") {
            $recommendations += @{
                gate = $gName
                consecutive = $data.consecutive_pass
                total = $data.total
                flows = "Heavy"
                action = "review"
                description = "Fatigued in Heavy — review if gate still provides value"
            }
        }
    }
}

# ── Report ──
Write-Host "Fatigue Action Report" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor DarkGray
Write-Host "Threshold: $Threshold consecutive passes"
Write-Host "Changes scanned: $($dirs.Count)"
Write-Host ""

if ($recommendations.Count -eq 0) {
    Write-Host "✅ No fatigued gates found (threshold = $Threshold)." -ForegroundColor Green
    exit 0
}

Write-Host "Fatigued gates and recommended actions:" -ForegroundColor Yellow

# Group by action type
$advisoryGates = $recommendations | Where-Object { $_.action -like "advisory*" }
$reviewGates = $recommendations | Where-Object { $_.action -eq "review" }

if ($advisoryGates.Count -gt 0) {
    Write-Host "`n🟡 Advisory gates (warn but don't block):" -ForegroundColor Yellow
    foreach ($r in $advisoryGates) {
        Write-Host "  $($r.gate): $($r.description)" -ForegroundColor White
        Write-Host "    → $($r.consecutive) consecutive passes across $($r.total) runs (flows: $($r.flows))" -ForegroundColor Gray
    }
}

if ($reviewGates.Count -gt 0) {
    Write-Host "`n🔴 Gates needing review:" -ForegroundColor Red
    foreach ($r in $reviewGates) {
        Write-Host "  $($r.gate): $($r.description)" -ForegroundColor White
    }
}

# ── Apply changes ──
if ($Apply) {
    Write-Host "`nApplying recommendations..." -ForegroundColor Cyan

    # Create/update .gates-config.json in agent-flow/
    $configPath = Join-Path $root "agent-flow/.gates-config.json"
    $config = @{}
    if (Test-Path $configPath) {
        $config = Get-Content -Raw -Encoding utf8 -LiteralPath $configPath | ConvertFrom-Json -AsHashtable
    }

    foreach ($r in $recommendations) {
        if ($r.action -like "advisory*") {
            if (-not $config.ContainsKey("advisory")) { $config["advisory"] = @() }
            $config["advisory"] = @($config["advisory"] | Where-Object { $_ -ne $r.gate }) + $r.gate
            Write-Host "  ✅ $($r.gate) → advisory mode" -ForegroundColor Green
        }
        if ($r.action -eq "review") {
            if (-not $config.ContainsKey("review")) { $config["review"] = @() }
            $config["review"] = @($config["review"] | Where-Object { $_ -ne $r.gate }) + $r.gate
            Write-Host "  ⏳ $($r.gate) → marked for review" -ForegroundColor Yellow
        }
    }

    $config | ConvertTo-Json | Set-Content -Encoding utf8 -LiteralPath $configPath
    Write-Host "`nConfiguration written to: agent-flow/.gates-config.json" -ForegroundColor Gray
    Write-Host "Run 'check-change' with -Advisory flag to enable advisory mode." -ForegroundColor Cyan
} else {
    Write-Host "`nDry-run mode. Use -Apply to persist changes." -ForegroundColor Gray
    Write-Host "  fatigue-action.ps1 -Apply" -ForegroundColor Cyan
}
