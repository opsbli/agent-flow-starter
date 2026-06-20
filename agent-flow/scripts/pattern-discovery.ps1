<#
.SYNOPSIS
Discover recurring patterns across EVOLUTION.md files.

.DESCRIPTION
Scans completed change directories for EVOLUTION.md files, counts recurring
process and quality signals, and emits a markdown report.
#>

param(
    [string]$ChangesRoot = "agent-flow/changes",
    [string]$ProjectRoot = ".",
    [int]$MinOccurrences = 2,
    [string]$Output = ""
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($ProjectRoot)
$changesDir = Join-Path $root $ChangesRoot
$knowledgeDir = Join-Path $root "agent-flow/knowledge"

if (-not (Test-Path -LiteralPath $changesDir)) {
    Write-Host "No changes directory found at $changesDir"
    exit 0
}

$patterns = @(
    @{ Name = "documentation_gap"; Category = "knowledge"; Keywords = @("documentation", "missing doc", "unclear") },
    @{ Name = "test_coverage_gap"; Category = "gate"; Keywords = @("test coverage", "untested", "no test") },
    @{ Name = "boundary_violation"; Category = "gate"; Keywords = @("boundary", "write_files", "unauthorized") },
    @{ Name = "schema_risk"; Category = "audit"; Keywords = @("schema", "migration", "database") },
    @{ Name = "permission_risk"; Category = "audit"; Keywords = @("permission", "auth", "role") },
    @{ Name = "api_contract_break"; Category = "gate"; Keywords = @("api", "contract", "breaking") },
    @{ Name = "state_machine_complexity"; Category = "design"; Keywords = @("state machine", "workflow") },
    @{ Name = "knowledge_not_captured"; Category = "knowledge"; Keywords = @("knowledge", "glossary", "pitfall") },
    @{ Name = "template_gap"; Category = "process"; Keywords = @("template", "missing field", "artifact") },
    @{ Name = "process_bypass"; Category = "process"; Keywords = @("bypass", "skip process") }
)

$counts = @{}
$changesByPattern = @{}
$dirs = @(Get-ChildItem -Directory -LiteralPath $changesDir -ErrorAction SilentlyContinue | Sort-Object Name)
$evolutionFiles = 0

foreach ($dir in $dirs) {
    $evoPath = Join-Path $dir.FullName "EVOLUTION.md"
    if (-not (Test-Path -LiteralPath $evoPath)) { continue }

    $evolutionFiles++
    $text = (Get-Content -Raw -Encoding utf8 -LiteralPath $evoPath).ToLowerInvariant()

    foreach ($pattern in $patterns) {
        foreach ($keyword in $pattern.Keywords) {
            if ($text.Contains($keyword.ToLowerInvariant())) {
                $name = $pattern.Name
                $counts[$name] = 1 + [int]($counts[$name])
                if (-not $changesByPattern.ContainsKey($name)) { $changesByPattern[$name] = @() }
                $changesByPattern[$name] += $dir.Name
                break
            }
        }
    }
}

$existingPitfalls = ""
$pitfallsPath = Join-Path $knowledgeDir "pitfalls.md"
if (Test-Path -LiteralPath $pitfallsPath) {
    $existingPitfalls = Get-Content -Raw -Encoding utf8 -LiteralPath $pitfallsPath
}

$reportLines = @(
    "# Pattern Discovery Report",
    "",
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    "Min occurrences to flag: $MinOccurrences",
    "Changes scanned: $($dirs.Count)",
    "EVOLUTION.md files found: $evolutionFiles",
    ""
)

if ($counts.Count -eq 0) {
    $reportLines += "## No Patterns Detected"
    $reportLines += ""
    $reportLines += "No EVOLUTION.md files found or no patterns matched."
} else {
    $reportLines += "## All Detected Patterns"
    $reportLines += ""
    $reportLines += "| Pattern | Category | Occurrences | Affected Changes |"
    $reportLines += "|---------|----------|-------------|------------------|"

    foreach ($entry in $counts.GetEnumerator() | Sort-Object Value -Descending) {
        $pattern = $patterns | Where-Object { $_.Name -eq $entry.Key } | Select-Object -First 1
        $category = if ($pattern) { $pattern.Category } else { "unknown" }
        $changes = ($changesByPattern[$entry.Key] | Select-Object -Unique) -join ", "
        $name = if ($entry.Value -ge $MinOccurrences) { "**$($entry.Key)**" } else { $entry.Key }
        $count = if ($entry.Value -ge $MinOccurrences) { "**$($entry.Value)**" } else { $entry.Value }
        $reportLines += "| $name | $category | $count | $changes |"
    }

    $recurring = @($counts.GetEnumerator() | Where-Object { $_.Value -ge $MinOccurrences })
    if ($recurring.Count -gt 0) {
        $reportLines += ""
        $reportLines += "## Recurring Patterns"
        $reportLines += ""
        foreach ($entry in $recurring | Sort-Object Value -Descending) {
            $pattern = $patterns | Where-Object { $_.Name -eq $entry.Key } | Select-Object -First 1
            $category = if ($pattern) { $pattern.Category } else { "unknown" }
            $changes = ($changesByPattern[$entry.Key] | Select-Object -Unique) -join ", "
            $alreadyCaptured = $existingPitfalls -match [regex]::Escape($entry.Key)
            $capture = if ($alreadyCaptured) { "already captured" } else { "consider adding to knowledge/pitfalls.md" }

            $reportLines += "### $($entry.Key) ($($entry.Value) times)"
            $reportLines += ""
            $reportLines += "- Category: $category"
            $reportLines += "- Affected changes: $changes"
            $reportLines += "- Suggested action: $capture"
            $reportLines += ""
        }
    }
}

$reportLines += "---"
$reportLines += "*Generated by pattern-discovery.ps1*"

$reportText = $reportLines -join "`r`n"
if ($Output) {
    $reportText | Set-Content -Path $Output -Encoding utf8
    Write-Host "Report written to: $Output"
} else {
    Write-Host $reportText
}
