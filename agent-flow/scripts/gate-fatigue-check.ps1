<#
.SYNOPSIS
Detect gate fatigue — gates that consistently pass without finding issues.
Suggests downgrading or removing fatigued gates.

.DESCRIPTION
Scans CHECK_RESULT.json across all completed changes.
Tracks consecutive passes for each gate.
If a gate passes N times (default: 5) without failure, it's flagged as fatigued.

.PARAMETER ChangesRoot
Root directory for changes (default: agent-flow/changes).

.PARAMETER ProjectRoot
Project root path (default: current directory).

.PARAMETER Threshold
Consecutive passes threshold (default: 5).

.PARAMETER Output
Output file path for the fatigue report.

.EXAMPLE
agent-flow/scripts/gate-fatigue-check.ps1

.EXAMPLE
agent-flow/scripts/gate-fatigue-check.ps1 -Threshold 3
#>

param(
    [string]$ChangesRoot = "agent-flow/changes",
    [string]$ProjectRoot = ".",
    [int]$Threshold = 5,
    [string]$Output = ""
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($ProjectRoot)
$changesDir = Join-Path $root $ChangesRoot

if (-not (Test-Path -LiteralPath $changesDir)) {
    Write-Host "No changes directory found at $changesDir" -ForegroundColor Yellow
    exit 0
}

# ── Collect gate results across all changes ──
$gateResults = @{}  # gate_name -> @{total=0; pass=0; fail=0; consecutive_pass=0; last_result=""}
$changeOrder = @()

$dirs = Get-ChildItem -Directory -LiteralPath $changesDir | Sort-Object Name
foreach ($dir in $dirs) {
    $checkPath = Join-Path $dir.FullName "CHECK_RESULT.json"
    if (-not (Test-Path $checkPath)) { continue }

    try {
        $check = Get-Content -Raw -Encoding utf8 -LiteralPath $checkPath | ConvertFrom-Json
        if ($check.gates) {
            $changeOrder += $dir.Name
            foreach ($g in $check.gates.PSObject.Properties) {
                $gName = $g.Name
                $gResult = $g.Value.result

                if (-not $gateResults.ContainsKey($gName)) {
                    $gateResults[$gName] = @{ total = 0; pass = 0; fail = 0; consecutive_pass = 0; last_result = "" }
                }

                $gateResults[$gName].total++
                if ($gResult -eq "pass") {
                    $gateResults[$gName].pass++
                    if ($gateResults[$gName].last_result -eq "pass") {
                        $gateResults[$gName].consecutive_pass++
                    } else {
                        $gateResults[$gName].consecutive_pass = 1
                    }
                } else {
                    $gateResults[$gName].fail++
                    $gateResults[$gName].consecutive_pass = 0
                }
                $gateResults[$gName].last_result = $gResult
            }
        }
    } catch { }
}

# ── Identify fatigued gates ──
$fatiguedGates = @()
$healthyGates = @()
$neverFailedGates = @()

foreach ($entry in $gateResults.GetEnumerator() | Sort-Object Key) {
    $gName = $entry.Key
    $data = $entry.Value

    if ($data.consecutive_pass -ge $Threshold -and $data.fail -eq 0) {
        $fatiguedGates += @{
            name = $gName
            consecutive_pass = $data.consecutive_pass
            total = $data.total
            pass = $data.pass
            fail = $data.fail
        }
    } elseif ($data.fail -gt 0) {
        $healthyGates += @{
            name = $gName
            total = $data.total
            pass = $data.pass
            fail = $data.fail
        }
    } else {
        $neverFailedGates += @{
            name = $gName
            consecutive_pass = $data.consecutive_pass
            total = $data.total
            pass = $data.pass
        }
    }
}

# ── Build report ──
$reportLines = @(
    "# Gate Fatigue Report",
    "",
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    "Threshold: $Threshold consecutive passes without failure",
    "Changes scanned: $($changeOrder.Count)",
    "Gates analyzed: $($gateResults.Count)",
    ""
)

if ($fatiguedGates.Count -gt 0) {
    $reportLines += "## ⚠️ Fatigued Gates (No failures detected)"
    $reportLines += ""
    $reportLines += "These gates have passed $Threshold+ times without detecting any issue."
    $reportLines += "Consider: reviewing whether they still add value, or downgrading for low-risk changes."
    $reportLines += ""
    $reportLines += "| Gate | Consecutive Passes | Total Runs | Total Passes |"
    $reportLines += "|------|-------------------|------------|--------------|"
    foreach ($fg in ($fatiguedGates | Sort-Object -Property consecutive_pass -Descending)) {
        $reportLines += "| $($fg.name) | $($fg.consecutive_pass) | $($fg.total) | $($fg.pass) |"
    }
    $reportLines += ""
} else {
    $reportLines += "## ✅ No Fatigued Gates"
    $reportLines += ""
    $reportLines += "All gates have detected at least one issue, or have not yet reached the threshold."
    $reportLines += ""
}

if ($healthyGates.Count -gt 0) {
    $reportLines += "## ✅ Healthy Gates (Have detected failures)"
    $reportLines += ""
    $reportLines += "| Gate | Total Runs | Passes | Failures |"
    $reportLines += "|------|------------|--------|----------|"
    foreach ($hg in ($healthyGates | Sort-Object -Property fail -Descending)) {
        $reportLines += "| $($hg.name) | $($hg.total) | $($hg.pass) | $($hg.fail) |"
    }
    $reportLines += ""
}

if ($neverFailedGates.Count -gt 0) {
    $reportLines += "## 🔍 Gates Below Fatigue Threshold"
    $reportLines += ""
    $reportLines += "| Gate | Consecutive Passes | Total Runs |"
    $reportLines += "|------|-------------------|------------|"
    foreach ($ng in ($neverFailedGates | Sort-Object -Property consecutive_pass -Descending)) {
        $reportLines += "| $($ng.name) | $($ng.consecutive_pass) | $($ng.total) |"
    }
    $reportLines += ""
}

$reportLines += "## Summary Statistics"
$reportLines += ""
$reportLines += "- Total gates tracked: $($gateResults.Count)"
$reportLines += "- Fatigued gates: $($fatiguedGates.Count)"
$reportLines += "- Healthy gates (detected failures): $($healthyGates.Count)"
$reportLines += "- Gates below threshold: $($neverFailedGates.Count)"
$reportLines += "- Changes with CHECK_RESULT.json: $($changeOrder.Count)"
$reportLines += ""
$reportLines += "---"
$reportLines += "*Generated by gate-fatigue-check.ps1*"

$reportText = $reportLines -join "`r`n"

if ($Output) {
    $reportText | Set-Content -Path $Output -Encoding utf8
    Write-Host "Report written to: $Output"
} else {
    Write-Host $reportText
}
