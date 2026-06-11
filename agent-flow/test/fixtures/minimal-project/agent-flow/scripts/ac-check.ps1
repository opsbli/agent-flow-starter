<#
.SYNOPSIS
Run the ac-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.PARAMETER TestRoot
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/ac-check.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$TestRoot = "."
)

$ErrorActionPreference = "Stop"

function Normalize-AcId {
    param([string]$Value)
    $match = [regex]::Match($Value, "AC[-_ ]?\d{2,4}", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if (-not $match.Success) { return "" }
    return $match.Value.ToUpperInvariant().Replace("_", "-").Replace(" ", "-")
}

function Test-MeaningfulField {
    param(
        [string]$Value,
        [switch]$AllowNone
    )

    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    $trimmed = $Value.Trim()
    if ($trimmed -match "(?i)^(TODO|TBD|pending|\{.+?\}|path/to|example)$") { return $false }
    if (-not $AllowNone -and $trimmed -match "(?i)^(none|n/a|na|null)$") { return $false }
    return $true
}

function Get-Cells {
    param([string]$Line)

    $trimmed = $Line.Trim()
    $trimmed = $trimmed -replace "^\|", ""
    $trimmed = $trimmed -replace "\|$", ""
    return @($trimmed -split "\|" | ForEach-Object { $_.Trim() })
}

function Get-AcEvidenceRows {
    param([string]$VerifyText)

    $match = [regex]::Match($VerifyText, '(?ims)^\s*##\s+AC Evidence\s*$([\s\S]*?)(?=^\s*##\s+|\z)')
    if (-not $match.Success) { return @() }

    $rows = @()
    foreach ($line in ($match.Groups[1].Value -split "\r?\n")) {
        if ($line -notmatch "^\s*\|") { continue }
        $cells = @(Get-Cells -Line $line)
        if ($cells.Count -lt 6) { continue }
        if ($cells[0] -match "(?i)^AC$") { continue }
        if ($cells[0] -match "^-+$") { continue }

        $ac = Normalize-AcId -Value $cells[0]
        if ([string]::IsNullOrWhiteSpace($ac)) { continue }
        $rows += [pscustomobject]@{
            AC = $ac
            RequirementSummary = $cells[1]
            EvidenceType = $cells[2]
            EvidenceLocation = $cells[3]
            Result = $cells[4].ToLowerInvariant()
            ResidualRisk = $cells[5]
        }
    }
    return $rows
}

if (-not (Test-Path $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$requirement = Join-Path $ChangeDir "REQUIREMENT.md"
if (-not (Test-Path $requirement)) {
    throw "REQUIREMENT.md not found in $ChangeDir"
}

$content = Get-Content -Raw -Encoding utf8 $requirement
$acs = [regex]::Matches($content, "AC[-_ ]?\d{2,4}") | ForEach-Object { Normalize-AcId -Value $_.Value } | Sort-Object -Unique

if ($acs.Count -eq 0) {
    throw "No AC ids found in $requirement"
}

$verify = Join-Path $ChangeDir "VERIFY.md"
if (-not (Test-Path -LiteralPath $verify)) {
    Write-Host "AC check failed:"
    Write-Host " - VERIFY.md not found in $ChangeDir"
    exit 2
}

$verifyText = Get-Content -Raw -Encoding utf8 -LiteralPath $verify
$evidenceRows = @(Get-AcEvidenceRows -VerifyText $verifyText)
if ($evidenceRows.Count -eq 0) {
    Write-Host "AC check failed:"
    Write-Host " - VERIFY.md must include an AC Evidence table with one row per AC."
    exit 2
}

$issues = @()
foreach ($ac in $acs) {
    $rows = @($evidenceRows | Where-Object { $_.AC -eq $ac })
    if ($rows.Count -eq 0) {
        $issues += "Missing AC Evidence row for $ac."
        continue
    }
    if ($rows.Count -gt 1) {
        $issues += "Duplicate AC Evidence rows for $ac."
        continue
    }

    $row = $rows[0]
    if (-not (Test-MeaningfulField -Value $row.RequirementSummary -AllowNone)) {
        $issues += "$ac missing Requirement Summary."
    }
    if (-not (Test-MeaningfulField -Value $row.EvidenceType)) {
        $issues += "$ac missing Evidence Type."
    }
    if (-not (Test-MeaningfulField -Value $row.EvidenceLocation)) {
        $issues += "$ac missing Evidence Location."
    }
    if ($row.Result -notmatch "^(pass|fail|conditional|skipped)$") {
        $issues += "$ac has invalid Result '$($row.Result)'. Use pass/fail/conditional/skipped."
    } elseif ($row.Result -eq "fail") {
        $issues += "$ac Result is fail."
    }
    if (-not (Test-MeaningfulField -Value $row.ResidualRisk -AllowNone)) {
        $issues += "$ac missing Residual Risk. Use 'none' when there is no residual risk."
    }
}

if ($issues.Count -gt 0) {
    Write-Host "AC check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "AC check passed: $($acs.Count) AC ids have complete AC Evidence rows."



