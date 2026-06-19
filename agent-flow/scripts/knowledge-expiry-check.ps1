<#
.SYNOPSIS
Check for stale or expired knowledge entries in agent-flow/knowledge/.

.DESCRIPTION
Scans all files in agent-flow/knowledge/ and checks:
  1. File age (last modified > N days ago)
  2. Whether the file is referenced in recent CHANGELOG.md or change documents
  3. Whether the file still has TODO/TBD placeholders

.PARAMETER KnowledgeRoot
Root directory for knowledge files (default: agent-flow/knowledge).

.PARAMETER ProjectRoot
Project root path (default: current directory).

.PARAMETER MaxAgeDays
Maximum file age before flagging as stale (default: 90).

.PARAMETER Output
Output file path for the report.

.EXAMPLE
agent-flow/scripts/knowledge-expiry-check.ps1

.EXAMPLE
agent-flow/scripts/knowledge-expiry-check.ps1 -MaxAgeDays 30
#>

param(
    [string]$KnowledgeRoot = "agent-flow/knowledge",
    [string]$ProjectRoot = ".",
    [int]$MaxAgeDays = 90,
    [string]$Output = ""
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($ProjectRoot)
$knowledgeDir = Join-Path $root $KnowledgeRoot

if (-not (Test-Path -LiteralPath $knowledgeDir)) {
    Write-Host "No knowledge directory found at $knowledgeDir" -ForegroundColor Yellow
    exit 0
}

# ── Collect reference sources ──
$referenceSources = @()

# Changes that reference knowledge
$changesDir = Join-Path $root "agent-flow/changes"
if (Test-Path $changesDir) {
    $recentChanges = Get-ChildItem -Directory -LiteralPath $changesDir | Sort-Object Name -Descending | Select-Object -First 10
    foreach ($changeDir in $recentChanges) {
        foreach ($file in @("CHANGE.md", "REQUIREMENT.md", "DESIGN.md", "EVOLUTION.md", "REPORT.md")) {
            $path = Join-Path $changeDir.FullName $file
            if (Test-Path $path) {
                $text = Get-Content -Raw -Encoding utf8 -LiteralPath $path
                if ($text -match '(?i)knowledge|pitfall|glossary|module.map|reuse.map|improvement') {
                    $referenceSources += @{
                        type = "change"
                        name = $changeDir.Name
                        file = $file
                    }
                }
            }
        }
    }
}

# Check CHANGELOG references
$changelogPath = Join-Path $root "CHANGELOG.md"
if (Test-Path $changelogPath) {
    $changelogText = Get-Content -Raw -Encoding utf8 -LiteralPath $changelogPath
}

# Check AGENTS.md references
$agentsPath = Join-Path $root "AGENTS.md"
if (Test-Path $agentsPath) {
    $agentsText = Get-Content -Raw -Encoding utf8 -LiteralPath $agentsPath
}

# ── Scan knowledge files ──
$results = @()
$now = Get-Date

$files = Get-ChildItem -File -LiteralPath $knowledgeDir | Where-Object { $_.Name -ne '.gitkeep' -and $_.Name -ne 'INDEX.md' }
foreach ($file in $files) {
    $info = @{
        name = $file.Name
        path = $file.FullName
        lastModified = $file.LastWriteTime
        ageDays = ($now - $file.LastWriteTime).Days
        sizeKB = [math]::Round($file.Length / 1KB, 1)
        hasTODOs = $false
        referencedInRecent = $false
        referenceSources = @()
        issues = @()
    }

    # Check content for TODO/TBD
    $content = Get-Content -Raw -Encoding utf8 -LiteralPath $file.FullName
    if ($content -match '(?i)TODO|TBD|path/to|尚未|待补充') {
        $info.hasTODOs = $true
        $info.issues += "Contains placeholder text (TODO/TBD)"
    }

    # Check if referenced in recent changes
    $refs = $referenceSources | Where-Object {
        $sourcePath = Join-Path (Join-Path $changesDir $_.name) $_.file
        if (Test-Path $sourcePath) {
            $srcText = Get-Content -Raw -Encoding utf8 -LiteralPath $sourcePath
            return $srcText -match [regex]::Escape($file.Name) -or $srcText -match [regex]::Escape($file.BaseName)
        }
        return $false
    }
    if ($refs.Count -gt 0) {
        $info.referencedInRecent = $true
        $info.referenceSources = $refs | ForEach-Object { "$($_.name)/$($_.file)" }
    }

    # Check if referenced in AGENTS.md
    if ($agentsText -and $agentsText -match [regex]::Escape($file.Name)) {
        $info.referencedInRecent = $true
    }

    # Determine staleness
    if ($info.ageDays -gt $MaxAgeDays -and -not $info.referencedInRecent) {
        $info.issues += "Not referenced in $MaxAgeDays+ days (last modified $($info.ageDays) days ago)"
    }
    if ($info.hasTODOs) {
        $info.issues += "Contains unresolved placeholders"
    }

    $results += $info
}

# ── Build report ──
$staleCount = @($results | Where-Object { $_.issues.Count -gt 0 }).Count
$freshCount = $results.Count - $staleCount

$reportLines = @(
    "# Knowledge Expiry Report",
    "",
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    "Max age before flagging: $MaxAgeDays days",
    "Knowledge files scanned: $($results.Count)",
    "Fresh files: $freshCount",
    "Files with issues: $staleCount",
    ""
)

$staleEntries = $results | Where-Object { $_.issues.Count -gt 0 } | Sort-Object ageDays -Descending
if ($staleEntries.Count -gt 0) {
    $reportLines += "## ⚠️ Files With Issues"
    $reportLines += ""
    $reportLines += "| File | Age (days) | Size | Issues | References |"
    $reportLines += "|------|-----------|------|--------|-------------|"
    foreach ($entry in $staleEntries) {
        $issues = ($entry.issues | Select-Object -Unique) -join "; "
        $refs = if ($entry.referenceSources.Count -gt 0) { ($entry.referenceSources -join "; ") } else { "None in recent changes" }
        $reportLines += "| $($entry.name) | $($entry.ageDays) | $($entry.sizeKB) KB | $issues | $refs |"
    }
    $reportLines += ""
}

$freshEntries = $results | Where-Object { $_.issues.Count -eq 0 }
if ($freshEntries.Count -gt 0) {
    $reportLines += "## ✅ Healthy Files"
    $reportLines += ""
    $reportLines += "| File | Age (days) | Last Modified |"
    $reportLines += "|------|-----------|---------------|"
    foreach ($entry in $freshEntries) {
        $reportLines += "| $($entry.name) | $($entry.ageDays) | $($entry.lastModified.ToString('yyyy-MM-dd')) |"
    }
    $reportLines += ""
}

$reportLines += "## Recommendations"
$reportLines += ""
if ($staleEntries.Count -gt 0) {
    $reportLines += "1. Review stale files and either update them with current information or mark them as archived."
    $reportLines += "2. Remove or resolve TODO/TBD placeholders in knowledge files."
    $reportLines += "3. If a file is no longer relevant, consider archiving it with a note about its replacement."
} else {
    $reportLines += "All knowledge files are current and referenced. No action needed."
}
$reportLines += ""
$reportLines += "---"
$reportLines += "*Generated by knowledge-expiry-check.ps1*"

$reportText = $reportLines -join "`r`n"

if ($Output) {
    $reportText | Set-Content -Path $Output -Encoding utf8
    Write-Host "Report written to: $Output"
} else {
    Write-Host $reportText
}
