<#
.SYNOPSIS
Auto-suggest knowledge base updates based on pattern analysis and change history.

.DESCRIPTION
Part of the agent-flow scaffold toolchain.
Cross-references pattern-discovery results with existing knowledge files
and generates suggested updates for pitfalls.md, glossary.md, and reuse-map.md.

.PARAMETER ProjectRoot
Project root path (default: current directory).

.PARAMETER Output
Output file path for the suggestions report.

.EXAMPLE
agent-flow/scripts/knowledge-suggest.ps1
#>

param(
    [string]$ProjectRoot = ".",
    [string]$Output = ""
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($ProjectRoot)
$knowledgeDir = Join-Path $root "agent-flow/knowledge"
$changesDir = Join-Path $root "agent-flow/changes"

if (-not (Test-Path $knowledgeDir)) {
    Write-Host "No knowledge directory found" -ForegroundColor Yellow
    exit 0
}

# ── Read existing knowledge ──
$existingPitfalls = @()
$pitfallsPath = Join-Path $knowledgeDir "pitfalls.md"
if (Test-Path $pitfallsPath) {
    $pitfallsText = Get-Content -Raw -Encoding utf8 -LiteralPath $pitfallsPath
    $matches = [regex]::Matches($pitfallsText, '(?im)^###\s+(.+?)$')
    foreach ($m in $matches) { $existingPitfalls += $m.Groups[1].Value.Trim() }
}

$existingGlossary = @{}
$glossaryPath = Join-Path $knowledgeDir "glossary.md"
if (Test-Path $glossaryPath) {
    $glossaryText = Get-Content -Raw -Encoding utf8 -LiteralPath $glossaryPath
    $matches = [regex]::Matches($glossaryText, '(?im)^\|(.+?)\|(.+?)\|')
    foreach ($m in $matches) {
        $term = $m.Groups[1].Value.Trim()
        $def = $m.Groups[2].Value.Trim()
        if ($term -and $term -notmatch 'Term|术语|-----') {
            $existingGlossary[$term] = $def
        }
    }
}

# ── Scan recent changes for new terms and patterns ──
$newTerms = @{}
$newPitfallCandidates = @()
$newReuseCandidates = @()

if (Test-Path $changesDir) {
    $recentChanges = Get-ChildItem -Directory -LiteralPath $changesDir |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 10

    foreach ($changeDir in $recentChanges) {
        # Check REQUIREMENT.md for new terms
        $reqFile = Join-Path $changeDir.FullName "REQUIREMENT.md"
        if (Test-Path $reqFile) {
            $reqText = Get-Content -Raw -Encoding utf8 -LiteralPath $reqFile

            # Extract term tables
            if ($reqText -match '(?s)## 术语.*?(?=## )') {
                $termsSection = $matches[0]
                $rows = $termsSection -split "`n" | Where-Object { $_ -match '^\|' -and $_ -notmatch '术语.*定义|是否已沉淀|---' }
                foreach ($row in $rows) {
                    $cells = $row -split '\|' | ForEach-Object { $_.Trim() }
                    if ($cells.Count -ge 3 -and $cells[1] -and $cells[2]) {
                        $term = $cells[1]
                        $def = $cells[2]
                        $deposited = if ($cells.Count -ge 5) { $cells[4] } else { "" }
                        if (-not $existingGlossary.ContainsKey($term) -and $deposited -notmatch '是') {
                            if (-not $newTerms.ContainsKey($term)) {
                                $newTerms[$term] = @{ def = $def; source = $changeDir.Name }
                            }
                        }
                    }
                }
            }
        }

        # Check EVOLUTION.md for pitfalls
        $evoFile = Join-Path $changeDir.FullName "EVOLUTION.md"
        if (Test-Path $evoFile) {
            $evoText = Get-Content -Raw -Encoding utf8 -LiteralPath $evoFile
            $issueLines = [regex]::Matches($evoText, '(?im)^## 应新增的验证闸门|^## 应调整的模板|^## 本次 change 暴露的问题')
            if ($issueLines.Count -gt 0) {
                # Find bullet points under these sections
                $bullets = [regex]::Matches($evoText, '(?m)^-\s+(.+?)$')
                foreach ($b in $bullets) {
                    $candidate = $b.Groups[1].Value.Trim()
                    if ($candidate -and $candidate -notmatch '无|none') {
                        # Check if similar pitfall already exists
                        $exists = $false
                        foreach ($ep in $existingPitfalls) {
                            $similarity = 0
                            $cWords = $candidate -split '\s+'
                            $eWords = $ep -split '\s+'
                            foreach ($cw in $cWords) {
                                if ($cw.Length -gt 2 -and $eWords -contains $cw) { $similarity++ }
                            }
                            if ($similarity -ge 2) { $exists = $true; break }
                        }
                        if (-not $exists -and $candidate.Length -gt 10) {
                            $newPitfallCandidates += @{ text = $candidate; source = $changeDir.Name }
                        }
                    }
                }
            }
        }

        # Check CODE_SCAN.md for reuse candidates
        $scanFile = Join-Path $changeDir.FullName "CODE_SCAN.md"
        if (Test-Path $scanFile) {
            $scanText = Get-Content -Raw -Encoding utf8 -LiteralPath $scanFile
            if ($scanText -match '(?i)reusable|公共能力|可复用') {
                $newReuseCandidates += @{ text = $scanText; source = $changeDir.Name }
            }
        }
    }
}

# ── Build report ──
$reportLines = @(
    "# Knowledge Suggestion Report",
    "",
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    "Changes scanned: $(@(Get-ChildItem -Directory -LiteralPath $changesDir -ErrorAction SilentlyContinue).Count)",
    ""
)

if ($newTerms.Count -gt 0) {
    $reportLines += "## 📝 Suggested Glossary Additions"
    $reportLines += ""
    $reportLines += "| Term | Definition | Source Change |"
    $reportLines += "|------|------------|---------------|"
    foreach ($entry in $newTerms.GetEnumerator()) {
        $reportLines += "| $($entry.Key) | $($entry.Value.def) | $($entry.Value.source) |"
    }
    $reportLines += ""
} else {
    $reportLines += "## ✅ No New Glossary Terms"
    $reportLines += ""
    $reportLines += "All terms from recent changes are already deposited in glossary.md."
    $reportLines += ""
}

if ($newPitfallCandidates.Count -gt 0) {
    $reportLines += "## ⚠️ Suggested Pitfalls Additions"
    $reportLines += ""
    $reportLines += "| Suggested Pitfall | Source Change |"
    $reportLines += "|-------------------|---------------|"
    foreach ($pc in ($newPitfallCandidates | Select-Object -Unique)) {
        $reportLines += "| $($pc.text) | $($pc.source) |"
    }
    $reportLines += ""
    $reportLines += "Format to add to pitfalls.md:"
    $reportLines += ""
    $reportLines += '```markdown'
    $reportLines += "### [pitfall name]"
    $reportLines += ""
    $reportLines += "- **What**: [description]"
    $reportLines += "- **Why it happens**: [root cause]"
    $reportLines += "- **How to prevent**: [solution]"
    $reportLines += "- **Detection**: [how to check]"
    $reportLines += '```'
    $reportLines += ""
} else {
    $reportLines += "## ✅ No Recurring Pitfalls Detected"
    $reportLines += ""
}

if ($newReuseCandidates.Count -gt 0) {
    $reportLines += "## 🔄 Suggested Reuse Map Updates"
    $reportLines += ""
    foreach ($rc in $newReuseCandidates) {
        $reportLines += "- Reusable capability detected in '$($rc.source)'. Review and add to reuse-map.md."
    }
    $reportLines += ""
} else {
    $reportLines += "## ✅ No New Reuse Candidates Detected"
    $reportLines += ""
}

$reportLines += "## Recommendations"
$reportLines += ""
$reportLines += "- Review suggested glossary terms and add to \`glossary.md\`"
if ($newPitfallCandidates.Count -gt 0) {
    $reportLines += "- Review suggested pitfalls and add to \`pitfalls.md\`"
}
if ($newReuseCandidates.Count -gt 0) {
    $reportLines += "- Review reuse candidates and update \`reuse-map.md\`"
}
$reportLines += "- Run \`bash agent-flow/scripts/pattern-discovery.sh\` for deeper pattern analysis"
$reportLines += ""
$reportLines += "---"
$reportLines += "*Generated by knowledge-suggest.ps1*"

$reportText = $reportLines -join "`r`n"

if ($Output) {
    $reportText | Set-Content -Path $Output -Encoding utf8
    Write-Host "Report written to: $Output"
} else {
    Write-Host $reportText
}
