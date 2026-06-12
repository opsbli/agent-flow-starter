<#
.SYNOPSIS
Compute AC coverage and verify test coverage evidence.

.DESCRIPTION
Reads REQUIREMENT.md and VERIFY.md. The script requires every AC id to have
an AC Evidence row and requires VERIFY.md to contain a Coverage Summary row for
test coverage. Automated test coverage may be pass, conditional, or skipped,
but skipped/conditional rows must explain why.

.PARAMETER ChangeDir
Path to agent-flow/changes/<change-id>.

.EXAMPLE
agent-flow/scripts/coverage-check.ps1 -ChangeDir agent-flow/changes/my-change
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"

function Normalize-AcId {
    param([string]$Value)
    $match = [regex]::Match($Value, "AC[-_ ]?\d{2,4}", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if (-not $match.Success) { return "" }
    return $match.Value.ToUpperInvariant().Replace("_", "-").Replace(" ", "-")
}

function Get-Cells {
    param([string]$Line)
    $trimmed = $Line.Trim()
    $trimmed = $trimmed -replace "^\|", ""
    $trimmed = $trimmed -replace "\|$", ""
    return @($trimmed -split "\|" | ForEach-Object { $_.Trim() })
}

function Get-SectionLines {
    param(
        [string]$Text,
        [string]$Heading
    )
    $escaped = [regex]::Escape($Heading)
    $pattern = '(?ims)^\s*##\s+' + $escaped + '\s*$([\s\S]*?)(?=^\s*##\s+|\z)'
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) { return @() }
    return @($match.Groups[1].Value -split "\r?\n")
}

function Test-Meaningful {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    return ($Value.Trim() -notmatch "(?i)^(TODO|TBD|pending|\{.+?\}|path/to|example)$")
}

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$requirementPath = Join-Path $ChangeDir "REQUIREMENT.md"
$verifyPath = Join-Path $ChangeDir "VERIFY.md"
if (-not (Test-Path -LiteralPath $requirementPath)) {
    Write-Host "Coverage check failed:"
    Write-Host " - REQUIREMENT.md not found in $ChangeDir"
    exit 2
}
if (-not (Test-Path -LiteralPath $verifyPath)) {
    Write-Host "Coverage check failed:"
    Write-Host " - VERIFY.md not found in $ChangeDir"
    exit 2
}

$requirementText = Get-Content -Raw -Encoding utf8 -LiteralPath $requirementPath
$verifyText = Get-Content -Raw -Encoding utf8 -LiteralPath $verifyPath
$acs = @([regex]::Matches($requirementText, "AC[-_ ]?\d{2,4}") | ForEach-Object { Normalize-AcId -Value $_.Value } | Sort-Object -Unique)
$issues = @()

if ($acs.Count -eq 0) {
    $issues += "No AC ids found in REQUIREMENT.md."
}

$evidenceByAc = @{}
foreach ($line in (Get-SectionLines -Text $verifyText -Heading "AC Evidence")) {
    if ($line -notmatch "^\s*\|") { continue }
    $cells = @(Get-Cells -Line $line)
    if ($cells.Count -lt 6) { continue }
    if ($cells[0] -match "(?i)^AC$" -or $cells[0] -match "^-+$") { continue }
    $ac = Normalize-AcId -Value $cells[0]
    if ([string]::IsNullOrWhiteSpace($ac)) { continue }
    $evidenceByAc[$ac] = [pscustomobject]@{
        Result = $cells[4].ToLowerInvariant()
        EvidenceLocation = $cells[3]
    }
}

$covered = 0
foreach ($ac in $acs) {
    if (-not $evidenceByAc.ContainsKey($ac)) {
        $issues += "Missing AC Evidence row for $ac."
        continue
    }
    $row = $evidenceByAc[$ac]
    if ($row.Result -notmatch "^(pass|conditional|skipped)$") {
        $issues += "$ac evidence result must be pass, conditional, or skipped for coverage."
        continue
    }
    if (-not (Test-Meaningful -Value $row.EvidenceLocation)) {
        $issues += "$ac evidence must include Evidence Location."
        continue
    }
    $covered++
}

$coveragePercent = if ($acs.Count -gt 0) { [math]::Round(($covered / $acs.Count) * 100, 2) } else { 0 }

$coverageRows = @()
foreach ($line in (Get-SectionLines -Text $verifyText -Heading "Coverage Summary")) {
    if ($line -notmatch "^\s*\|") { continue }
    $cells = @(Get-Cells -Line $line)
    if ($cells.Count -lt 5) { continue }
    if ($cells[0] -match "(?i)^Metric$" -or $cells[0] -match "^-+$") { continue }
    $coverageRows += [pscustomobject]@{
        Metric = $cells[0]
        Source = $cells[1]
        Value = $cells[2]
        Result = $cells[3].ToLowerInvariant()
        Notes = $cells[4]
    }
}

if ($coverageRows.Count -eq 0) {
    $issues += "VERIFY.md must include a Coverage Summary table."
} else {
    $testRows = @($coverageRows | Where-Object { $_.Metric -match "(?i)test coverage|automated coverage|coverage" -and $_.Metric -notmatch "(?i)^AC Coverage$" })
    if ($testRows.Count -eq 0) {
        $issues += "Coverage Summary must include a Test Coverage row."
    } else {
        $testRow = $testRows[0]
        if ($testRow.Result -notmatch "^(pass|conditional|skipped)$") {
            $issues += "Test Coverage result must be pass, conditional, or skipped."
        }
        if ($testRow.Result -match "^(conditional|skipped)$" -and -not (Test-Meaningful -Value $testRow.Notes)) {
            $issues += "Skipped or conditional Test Coverage must include Notes explaining why."
        }
        if (-not (Test-Meaningful -Value $testRow.Source)) {
            $issues += "Test Coverage row must include Source."
        }
    }
}

Write-Host ("AC coverage: {0}/{1} ({2}%)" -f $covered, $acs.Count, $coveragePercent)

if ($issues.Count -gt 0) {
    Write-Host "Coverage check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Coverage check passed."
