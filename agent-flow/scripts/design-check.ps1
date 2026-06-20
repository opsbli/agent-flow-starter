<#
.SYNOPSIS
Run the design-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/design-check.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

function Get-MarkdownRow {
    param(
        [string[]]$Lines,
        [string]$Key
    )

    $escaped = [regex]::Escape($Key)
    return $Lines |
        Where-Object { $_ -match "^\s*\|" -and $_ -match "\|\s*$escaped\s*\|" } |
        Select-Object -First 1
}

function Get-Cells {
    param([string]$Line)

    $trimmed = $Line.Trim()
    $trimmed = $trimmed -replace "^\|", ""
    $trimmed = $trimmed -replace "\|$", ""
    return @($trimmed -split "\|" | ForEach-Object { $_.Trim() })
}

$flow = Get-FlowLevel -Dir $ChangeDir
if ($flow -eq "Light" -or $flow -eq "Emergency") {
    Write-Host "SKIP: design-check is not required for $flow changes."
    exit 0
}

if ($flow -eq "Unknown") {
    throw "Cannot determine flow level from CHANGE.md. Mark one of Light / Standard / Heavy / Emergency."
}

$design = Join-Path $ChangeDir "DESIGN.md"
if (-not (Test-Path -LiteralPath $design)) {
    throw "DESIGN.md not found in $ChangeDir"
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $design
$issues = @()

$statusMatch = [regex]::Match($text, "(?im)^\s*Decision Status:\s*([A-Za-z-]+)\s*$")
if (-not $statusMatch.Success) {
    $issues += "Decision Status is missing. Use 'Decision Status: accepted' after API/Permission/Auth decisions are finalized."
} elseif ($statusMatch.Groups[1].Value.ToLowerInvariant() -ne "accepted") {
    $issues += "Decision Status must be accepted before planning or implementation."
}

$lines = @($text -split "\r?\n")

# Context-aware: skip backend-specific keys for non-backend projects
# Try multiple levels to find project root (handles agent-flow-starter self-check)
$projectRoot = $null
$manifestPath = $null
foreach ($levels in @("..\..", "..\..\..")) {
    $candidate = try { (Resolve-Path (Join-Path $ChangeDir $levels) -ErrorAction Stop).Path } catch { $null }
    if ($candidate -and (Test-Path (Join-Path $candidate "agent-flow/manifest.yaml"))) {
        $projectRoot = $candidate
        $manifestPath = Join-Path $projectRoot "agent-flow/manifest.yaml"
        break
    }
}
$backendKeys = @("REST Path", "HTTP Method", "Permission Code", "SaCheckPermission", "Anonymous Interface", "Login/Token", "Tenant/Data Permission", "State Machine Impact")
$skipBackendKeys = $false
if (Test-Path -LiteralPath $manifestPath) {
    try {
        $manifestText = Get-Content -Raw -Encoding utf8 -LiteralPath $manifestPath
        $kindMatch = [regex]::Match($manifestText, '(?m)^\s+kind:\s*(.+)$')
        $fwMatch = [regex]::Match($manifestText, '(?m)^\s+framework:\s*(.+)$')
        $kind = if ($kindMatch.Success) { $kindMatch.Groups[1].Value.Trim() } else { "" }
        $backendFw = if ($fwMatch.Success) { $fwMatch.Groups[1].Value.Trim() } else { "" }
        if ($kind -eq "dev-toolkit" -or $backendFw -in @("none", "n/a")) {
            $skipBackendKeys = $true
        }
    } catch { }
}

foreach ($key in Get-RuleList -Name "design-decision.keys") {
    if ($skipBackendKeys -and $key -in $backendKeys) { continue }
    $row = Get-MarkdownRow -Lines $lines -Key $key
    if ([string]::IsNullOrWhiteSpace($row)) {
        $issues += "Missing design decision row: $key"
        continue
    }

    $cells = Get-Cells -Line $row
    if ($cells.Count -lt 3) {
        $issues += "Design decision row for '$key' must have Item, Decision, and Evidence columns."
        continue
    }

    $decision = $cells[1]
    $evidence = $cells[2]
    if (-not (Test-MeaningfulValue -Value $decision)) {
        $issues += "Design decision '$key' has no final decision. Replace option lists with one value like unchanged/new/modified/deleted/not-applicable."
    }
    if (-not (Test-MeaningfulValue -Value $evidence -AllowSlash)) {
        $issues += "Design decision '$key' needs evidence or a reason."
    }
}

if (-not $skipBackendKeys) {
    $impact = [regex]::Match($text, "(?im)^\s*State Machine Impact:\s*(yes|no|not-applicable)\s*$")
    if (-not $impact.Success) {
        $issues += "State Machine Impact must be explicit: yes, no, or not-applicable."
    } elseif ($impact.Groups[1].Value.ToLowerInvariant() -eq "yes") {
        foreach ($section in @("Status Vocabulary", "Status Mapping", "Legacy Compatibility")) {
            if ($text -notmatch "(?im)^\s*#+\s*$([regex]::Escape($section))\s*$") {
                $issues += "State Machine Impact is yes, but section is missing: $section"
            }
        }
    }
}

if ($issues.Count -gt 0) {
    Write-Host "design-check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "design-check passed."



