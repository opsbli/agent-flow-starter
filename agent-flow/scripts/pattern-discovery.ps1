<#
.SYNOPSIS
Discover recurring patterns across EVOLUTION.md files and cross-reference with pitfalls.md.
Suggests new knowledge entries or gates for frequently occurring issues.

.DESCRIPTION
Scans all EVOLUTION.md in completed changes, extracts common themes
(problems, gate gaps, documentation needs), and cross-references with
existing pitfalls.md entries to find recurring patterns.

.PARAMETER ChangesRoot
Root directory for changes (default: agent-flow/changes).

.PARAMETER ProjectRoot
Project root path (default: current directory).

.PARAMETER MinOccurrences
Minimum occurrences to flag as a pattern (default: 2).

.PARAMETER Output
Output file path for the pattern report.

.EXAMPLE
agent-flow/scripts/pattern-discovery.ps1
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
    Write-Host "No changes directory found at $changesDir" -ForegroundColor Yellow
    exit 0
}

# ── Patterns to detect ──
$patternDefs = @(
    @{ name = "documentation_gap"; keywords = @("文档", "documentation", "缺文档", "缺注释", "missing doc", "unclear"); category = "knowledge" }
    @{ name = "test_coverage_gap"; keywords = @("测试覆盖", "test coverage", "缺测试", "缺少测试", "untested", "no test"); category = "gate" }
    @{ name = "boundary_violation"; keywords = @("越界", "越权", "边界", "boundary", "超出范围", "write_files", "unauthorized"); category = "gate" }
    @{ name = "schema_risk"; keywords = @("schema", "迁移", "migration", "数据库", "database", "数据模型"); category = "audit" }
    @{ name = "permission_risk"; keywords = @("权限", "permission", "auth", "认证", "角色", "role", "匿名"); category = "audit" }
    @{ name = "api_contract_break"; keywords = @("API", "接口", "contract", "契约", "破坏性", "breaking"); category = "gate" }
    @{ name = "state_machine_complexity"; keywords = @("状态机", "state machine", "工作流", "workflow", "状态流转"); category = "design" }
    @{ name = "knowledge_not_captured"; keywords = @("知识", "knowledge", "沉淀", "术语", "glossary", "坑点", "pitfall"); category = "knowledge" }
    @{ name = "template_gap"; keywords = @("模板", "template", "缺少字段", "missing field", "artifact"); category = "process" }
    @{ name = "process_bypass"; keywords = @("跳过", "bypass", "绕过", "跳过流程", "形式主义"); category = "process" }
)

# ── Scan EVOLUTION.md files ──
$allFindings = @()

$dirs = Get-ChildItem -Directory -LiteralPath $changesDir | Sort-Object Name
foreach ($dir in $dirs) {
    $evoPath = Join-Path $dir.FullName "EVOLUTION.md"
    if (-not (Test-Path $evoPath)) { continue }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $evoPath
    $changeName = $dir.Name

    foreach ($pd in $patternDefs) {
        foreach ($kw in $pd.keywords) {
            if ($text -match [regex]::Escape($kw)) {
                $allFindings += @{
                    change = $changeName
                    pattern = $pd.name
                    category = $pd.category
                    keyword = $kw
                }
                break  # One match per pattern per change
            }
        }
    }
}

# ── Read existing pitfalls ──
$existingPitfalls = @()
$pitfallsPath = Join-Path $knowledgeDir "pitfalls.md"
if (Test-Path $pitfallsPath) {
    $pitfallsText = Get-Content -Raw -Encoding utf8 -LiteralPath $pitfallsPath
    # Extract pitfall names
    $matches = [regex]::Matches($pitfallsText, '(?im)^###\s+(.+?)$')
    foreach ($m in $matches) { $existingPitfalls += $m.Groups[1].Value.Trim() }
}

# ── Aggregate patterns ──
$patternCounts = @{}
$patternChanges = @{}
foreach ($f in $allFindings) {
    $key = $f.pattern
    $patternCounts[$key] = ($patternCounts[$key] + 1)
    if (-not $patternChanges.ContainsKey($key)) { $patternChanges[$key] = @() }
    $patternChanges[$key] += $f.change
}

# ── Identify missing pitfalls ──
$missingPitfalls = @()
foreach ($entry in $patternCounts.GetEnumerator() | Sort-Object Value -Descending) {
    if ($entry.Value -ge $MinOccurrences) {
        $name = $entry.Key
        # Find the pattern def
        $def = $patternDefs | Where-Object { $_.name -eq $name } | Select-Object -First 1
        $category = if ($def) { $def.category } else { "unknown" }

        $inPitfalls = $false
        foreach ($ep in $existingPitfalls) {
            if ($ep -match [regex]::Escape($name) -or $name -match [regex]::Escape($ep)) {
                $inPitfalls = $true
                break
            }
        }

        if (-not $inPitfalls) {
            $missingPitfalls += @{
                pattern = $name
                count = $entry.Value
                category = $category
                changes = ($patternChanges[$name] | Select-Object -Unique) -join ", "
            }
        }
    }
}

# ── Build report ──
$reportLines = @(
    "# Pattern Discovery Report",
    "",
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    "Min occurrences to flag: $MinOccurrences",
    "Changes scanned: $($dirs.Count)",
    "EVOLUTION.md files found: $(@($dirs | Where-Object { Test-Path (Join-Path $_.FullName "EVOLUTION.md") }).Count)",
    ""
)

if ($allFindings.Count -eq 0) {
    $reportLines += "## No Patterns Detected"
    $reportLines += ""
    $reportLines += "No EVOLUTION.md files found or no patterns matched. Patterns will appear as more changes complete."
} else {
    # All detected patterns
    $reportLines += "## All Detected Patterns"
    $reportLines += ""
    $reportLines += "| Pattern | Category | Occurrences | Affected Changes |"
    $reportLines += "|---------|----------|-------------|------------------|"
    foreach ($entry in $patternCounts.GetEnumerator() | Sort-Object Value -Descending) {
        $def = $patternDefs | Where-Object { $_.name -eq $entry.Key } | Select-Object -First 1
        $cat = if ($def) { $def.category } else { "unknown" }
        $changes = ($patternChanges[$entry.Key] | Select-Object -Unique) -join ", "
        if ($entry.Value -ge $MinOccurrences) {
            $reportLines += "| **$($entry.Key)** | $cat | **$($entry.Value)** | $changes |"
        } else {
            $reportLines += "| $($entry.Key) | $cat | $($entry.Value) | $changes |"
        }
    }
    $reportLines += ""

    # Recurring patterns needing attention
    $recurring = @($patternCounts.GetEnumerator() | Where-Object { $_.Value -ge $MinOccurrences })
    if ($recurring.Count -gt 0) {
        $reportLines += "## ⚠️ Recurring Patterns (>= $MinOccurrences occurrences)"
        $reportLines += ""
        foreach ($entry in $recurring | Sort-Object Value -Descending) {
            $def = $patternDefs | Where-Object { $_.name -eq $entry.Key } | Select-Object -First 1
            $cat = if ($def) { $def.category } else { "unknown" }
            $changes = ($patternChanges[$entry.Key] | Select-Object -Unique) -join ", "

            $reportLines += "### $($entry.Key) ($($entry.Value) times)"
            $reportLines += ""
            $suggestion = switch ($cat) {
                "knowledge" { "Consider adding to \`pitfalls.md\` or \`glossary.md\`" }
                "gate" { "Consider adding a new gate script or enhancing existing checks" }
                "audit" { "Consider adding to audit checklist in \`AUDIT.md\` template" }
                "design" { "Consider adding to \`DESIGN.md\` template or design-check rules" }
                "process" { "Consider updating flow rules in \`GO.md\` or flow files" }
                default { "Consider documenting in \`knowledge/\`" }
            }
            $reportLines += "- **Category**: $cat"
            $reportLines += "- **Affected changes**: $changes"
            $reportLines += "- **Suggestion**: $suggestion"
            $reportLines += ""
        }
    }

    # Missing pitfalls
    if ($missingPitfalls.Count -gt 0) {
        $reportLines += "## 📝 Candidates for pitfalls.md"
        $reportLines += ""
        $reportLines += "These recurring patterns are not yet captured in \`pitfalls.md\`:"
        $reportLines += ""
        $reportLines += "| Pattern | Occurrences | Category | Example Changes | Suggested Entry |"
        $reportLines += "|---------|-------------|----------|-----------------|-----------------|"
        foreach ($mp in $missingPitfalls) {
            $suggestedEntry = "### $($mp.pattern)`n`- What: `n- Why it happens: `n- How to prevent: `n- Detection: "
            $reportLines += "| $($mp.pattern) | $($mp.count) | $($mp.category) | $($mp.changes) | Add to pitfalls.md |"
        }
        $reportLines += ""
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
