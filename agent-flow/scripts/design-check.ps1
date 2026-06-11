param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

function Get-FlowLevel {
    param([string]$Dir)

    $change = Join-Path $Dir "CHANGE.md"
    if (-not (Test-Path -LiteralPath $change)) {
        return "Unknown"
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $change
    if ($text -match "(?i)\[x\]\s+Heavy") { return "Heavy" }
    if ($text -match "(?i)\[x\]\s+Standard") { return "Standard" }
    if ($text -match "(?i)\[x\]\s+Light") { return "Light" }
    return "Unknown"
}

function Get-RuleList {
    param([string]$Name)

    $path = Join-Path (Split-Path -Parent $PSScriptRoot) "rules/$Name"
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Rule file not found: $path"
    }

    Get-Content -Encoding utf8 -LiteralPath $path |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") }
}

function Test-MeaningfulValue {
    param(
        [string]$Value,
        [switch]$AllowSlash
    )

    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value -match "(?i)TODO|TBD|pending|\{.+?\}") { return $false }
    if (-not $AllowSlash -and $Value -match "\s/\s") { return $false }
    return $true
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
if ($flow -eq "Light") {
    Write-Host "SKIP: design-check is not required for Light changes."
    exit 0
}

if ($flow -eq "Unknown") {
    throw "Cannot determine flow level from CHANGE.md. Mark one of Light / Standard / Heavy."
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
foreach ($key in Get-RuleList -Name "design-decision.keys") {
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

if ($issues.Count -gt 0) {
    Write-Host "design-check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "design-check passed."
