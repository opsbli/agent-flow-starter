<#
.SYNOPSIS
Generate improvement suggestions and auto-fill EVOLUTION.md drafts.

.DESCRIPTION
Two modes:
  1. --change-dir: analyze a specific change and generate an EVOLUTION.md draft
  2. --project-root: project-wide improvement suggestions

.PARAMETER ChangeDir
Path to the change directory to analyze.

.PARAMETER ProjectRoot
Project root path (default: current directory).

.PARAMETER Output
Output file path for the generated EVOLUTION.md draft.
#>

param(
    [string]$ChangeDir = "",
    [string]$ProjectRoot = ".",
    [string]$Output = ""
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $PSCommandPath
. (Join-Path $scriptDir "_common.ps1")

# --- Mode 1: Change-specific analysis ---
if ($ChangeDir -and (Test-Path $ChangeDir)) {
    $flow = Get-FlowLevel -Dir $ChangeDir
    $changeName = Split-Path $ChangeDir -Leaf

    $problems = @()
    $knowledgeSuggestions = @()
    $adrSuggestions = @()
    $gateSuggestions = @()
    $templateSuggestions = @()
    $noChangeReason = ""

    # 1. Scan REQUIREMENT.md for new terms
    $reqFile = Join-Path $ChangeDir "REQUIREMENT.md"
    if (Test-Path $reqFile) {
        $content = Get-Content -Raw -Encoding utf8 $reqFile
        if ($content -match '(?s)## 术语.*?(?=## )') {
            $termsTable = $matches[0]
            $rows = $termsTable -split "`n" | Where-Object { $_ -match '^\|' -and $_ -notmatch '术语.*定义|是否已沉淀' }
            $newTerms = @()
            foreach ($row in $rows) {
                $cells = $row -split '\|' | ForEach-Object { $_.Trim() }
                if ($cells.Count -ge 5 -and $cells[1] -and $cells[4] -notmatch '是') {
                    $newTerms += $cells[1]
                }
            }
            if ($newTerms.Count -gt 0) {
                $knowledgeSuggestions += "New terms from requirements that are not yet in glossary: $($newTerms -join ', ')"
                $problems += "Requirements introduced new terminology without glossary deposition."
            }
        }
    }

    # 2. Scan CODE_SCAN.md for patterns
    $scanFile = Join-Path $ChangeDir "CODE_SCAN.md"
    if (Test-Path $scanFile) {
        $scanContent = Get-Content -Raw -Encoding utf8 $scanFile
        if ($scanContent -match '(?i)reusable' -and $scanContent -notmatch '(?i)none') {
            $knowledgeSuggestions += "Reusable abstractions found — consider updating reuse-map.md"
        }
        if ($scanContent -match '(?i)冲突|缺口') {
            $problems += "Standards gaps or conflicts recorded in CODE_SCAN."
        }
    }

    # 3. Check DESIGN.md for ADR candidates
    $designFile = Join-Path $ChangeDir "DESIGN.md"
    if (Test-Path $designFile) {
        $designContent = Get-Content -Raw -Encoding utf8 $designFile
        if ($designContent -match '(?s)## ADR 候选.*?(?=## )' -and $matches[0] -notmatch 'none|无') {
            $adrSuggestions += "ADR candidates found in DESIGN.md — consider creating ADR entries."
        }
    }

    # 4. Check CHANGE.md for protected areas
    $changeFile = Join-Path $ChangeDir "CHANGE.md"
    if (Test-Path $changeFile) {
        $changeContent = Get-Content -Raw -Encoding utf8 $changeFile
        if ($changeContent -match '(?i)schema|database|migration') {
            $gateSuggestions += "Schema change — verify db-migration-check coverage."
        }
        if ($changeContent -match '(?i)permission|auth|role') {
            $gateSuggestions += "Auth/permission change — verify api-compatibility-check coverage."
        }
        if ($changeContent -match '(?i)state.machine|workflow|status') {
            $gateSuggestions += "State machine change — verify code-drift-check coverage."
        }
    }

    if (-not $problems -and -not $knowledgeSuggestions -and -not $adrSuggestions -and -not $gateSuggestions -and -not $templateSuggestions) {
        $noChangeReason = "No issues or improvement opportunities detected for this change."
    }

    # --- Build output ---
    $outputLines = @(
        "# Evolution",
        "",
        "## Machine Check",
        "",
        "problem: $(if ($problems.Count -gt 0) { $problems[0] } else { 'none' })",
        "knowledge: $(if ($knowledgeSuggestions.Count -gt 0) { $knowledgeSuggestions[0] -replace ':.*', '' } else { 'none' })",
        "adr: $(if ($adrSuggestions.Count -gt 0) { $adrSuggestions[0] -replace ':.*', '' } else { 'none' })",
        "gate: $(if ($gateSuggestions.Count -gt 0) { $gateSuggestions[0] -replace ':.*', '' } else { 'none' })",
        "template: $(if ($templateSuggestions.Count -gt 0) { $templateSuggestions[0] -replace ':.*', '' } else { 'none' })",
        "no_change_reason: $(if ($noChangeReason) { $noChangeReason } else { 'none' })",
        "",
        "## 本次 change 暴露的问题",
        "",
        $(if ($problems.Count -gt 0) { $problems | ForEach-Object { "- $_" } } else { "- 无" }),
        "",
        "## 应写入 knowledge 的内容",
        "",
        $(if ($knowledgeSuggestions.Count -gt 0) { $knowledgeSuggestions | ForEach-Object { "- $_" } } else { "- 无" }),
        "",
        "## 应新增或修改的 ADR",
        "",
        $(if ($adrSuggestions.Count -gt 0) { $adrSuggestions | ForEach-Object { "- $_" } } else { "- 无" }),
        "",
        "## 应新增的 gate",
        "",
        $(if ($gateSuggestions.Count -gt 0) { $gateSuggestions | ForEach-Object { "- $_" } } else { "- 无" }),
        "",
        "## 应调整的模板",
        "",
        $(if ($templateSuggestions.Count -gt 0) { $templateSuggestions | ForEach-Object { "- $_" } } else { "- 无" }),
        "",
        "## Improvement Tracker 更新",
        "",
        "- [ ] 不需要跟踪，原因：",
        "- [ ] 已新增或更新 `agent-flow/knowledge/improvement-tracker.md`",
        "",
        "## 本次不调整的原因",
        "",
        $(if ($noChangeReason) { $noChangeReason } else { "无" })
    )

    $outputText = ($outputLines | Where-Object { $_ -ne $null }) -join "`r`n"

    if ($Output) {
        $outputText | Set-Content -Path $Output -Encoding utf8
        Write-Host "Wrote EVOLUTION.md draft to: $Output"
    } else {
        Write-Host $outputText
    }
    return
}

# --- Mode 2: Project-wide suggestions ---
$afDir = Join-Path $ProjectRoot "agent-flow"
$changesDir = Join-Path $afDir "changes"

$total = 0; $completed = 0
if (Test-Path $changesDir) {
    Get-ChildItem -Directory $changesDir | Where-Object { $_.Name -ne '.gitkeep' } | ForEach-Object {
        $total++
        if (Test-Path (Join-Path $_.FullName "REPORT.md")) { $completed++ }
    }
}

$kCount = 0
$knowledgeDir = Join-Path $afDir "knowledge"
if (Test-Path $knowledgeDir) { $kCount = (Get-ChildItem -File $knowledgeDir | Where-Object { $_.Name -ne '.gitkeep' }).Count }

$adrCount = 0
$decisionsDir = Join-Path $afDir "decisions"
if (Test-Path $decisionsDir) { $adrCount = (Get-ChildItem -Filter "ADR-*" $decisionsDir).Count }

$suggestions = @()
if ($total -gt 0 -and $completed -eq 0) { $suggestions += "[HIGH] [Process] No completed changes yet." }
if ($kCount -le 2 -and $total -gt 0) { $suggestions += "[MEDIUM] [Knowledge] Only $kCount files for $total changes." }
if ($adrCount -eq 0 -and $total -gt 2) { $suggestions += "[MEDIUM] [Decisions] No ADRs recorded." }

# ── Improvement Tracker scan ──
$trackerPath = Join-Path $afDir "knowledge/improvement-tracker.md"
if (Test-Path $trackerPath) {
    $trackerText = Get-Content -Raw -Encoding utf8 -LiteralPath $trackerPath

    # Count pending items (not implemented/rejected)
    $pendingCount = 0
    $pendingLines = @()
    $lines = $trackerText -split "`n"
    foreach ($line in $lines) {
        if ($line -match '^\|.*\|(accepted|deferred|proposed)\s*\|') {
            $pendingCount++
            $pendingLines += $line.Trim()
        }
    }

    if ($pendingCount -gt 0) {
        $suggestions += "[HIGH] [Improvement] $pendingCount pending items in improvement-tracker — consider addressing:"
        foreach ($pl in ($pendingLines | Select-Object -First 3)) {
            # Extract ID and recommendation
            if ($pl -match '\|\s*(\S+)\s*\|') {
                $impId = $matches[1]
                $parts = $pl -split '\|'
                $rec = if ($parts.Count -ge 4) { $parts[3].Trim() } else { "unknown" }
                $suggestions += "  -> ${impId}: $rec"
            }
        }
        if ($pendingCount -gt 3) { $suggestions += "  → ... and $($pendingCount - 3) more items" }
    } else {
        $suggestions += "[LOW] [Improvement] No pending items in improvement-tracker. All caught up."
    }

    # Check for stale items (deferred >30 days without owner)
    $staleCount = 0
    foreach ($line in $lines) {
        if ($line -match '^\|.*\|deferred\s*\|.*\|') {
            $parts = $line -split '\|'
            $dateStr = if ($parts.Count -ge 7) { $parts[6].Trim() } else { "" }
            if ($dateStr -match '(\d{4})-(\d{2})-(\d{2})') {
                try {
                    $itemDate = Get-Date -Year $matches[1] -Month $matches[2] -Day $matches[3]
                    if ((Get-Date) - $itemDate -gt [TimeSpan]::FromDays(30)) {
                        $staleCount++
                    }
                } catch { }
            }
        }
    }
    if ($staleCount -gt 0) {
        $suggestions += "[MEDIUM] [Improvement] $staleCount deferred items older than 30 days — review or reassign."
    }
}

if (-not $suggestions) { $suggestions += "No suggestions at this time. Project is in good shape." }

Write-Host @"
# Evolution Suggestions

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')

## Summary

| Metric | Value |
|--------|-------|
| Total Changes | $total |
| Completed | $completed |
| Knowledge Files | $kCount |
| ADRs | $adrCount |

## Improvement Suggestions

$($suggestions -join "`n")

---
*Generated by evolution-suggest.ps1 — use -ChangeDir for change-specific EVOLUTION.md drafting*
"@
