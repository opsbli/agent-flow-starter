<#
.SYNOPSIS
Collect and persist CI performance baseline data.
#>
param([string]$Gate, [int]$DurationMs, [string]$BaselineFile = "agent-flow/reports/performance-baseline.json")

if (-not $Gate) { throw "--Gate is required" }
if ($DurationMs -le 0) { throw "--DurationMs is required" }

$data = @{}
if (Test-Path $BaselineFile) {
    $data = Get-Content -Raw -Encoding utf8 $BaselineFile | ConvertFrom-Json -AsHashtable
}
$data[$Gate] = @{ duration_ms = $DurationMs; timestamp = (Get-Date -Format 'o'); threshold_ms = 5000 }
$data | ConvertTo-Json -Depth 3 | Set-Content -Path $BaselineFile -Encoding utf8
Write-Host "Recorded: $Gate = ${DurationMs}ms"
