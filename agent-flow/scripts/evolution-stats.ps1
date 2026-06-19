<#
.SYNOPSIS
Collect agent-flow usage statistics for data-driven evolution.
Can optionally update knowledge/INDEX.md process stats section.
.DESCRIPTION
Scans change directories, check results, and script run history to produce stats.
Use -UpdateIndex to automatically refresh the Process Statistics section in INDEX.md.
.PARAMETER ProjectRoot
Project root directory (default: current directory).
.PARAMETER UpdateIndex
If set, updates the Process Statistics table in agent-flow/knowledge/INDEX.md.
#>
param(
    [string]$ProjectRoot = ".",
    [switch]$UpdateIndex
)
$ErrorActionPreference = "Stop"
$afDir = Join-Path $ProjectRoot "agent-flow"
$changesDir = Join-Path $afDir "changes"
$logsDir = Join-Path $afDir "logs"
$scriptsDir = Join-Path $afDir "scripts"
$knowledgeDir = Join-Path $afDir "knowledge"
$decisionsDir = Join-Path $afDir "decisions"
$indexFile = Join-Path $knowledgeDir "INDEX.md"

$stats = @{
    total_changes = 0
    completed_changes = 0
    active_changes = 0
    heavy_changes = 0
    standard_changes = 0
    light_changes = 0
    emergency_changes = 0
    blocked_changes = 0
    scripts_run = @{}
    total_scripts = 0
    ac_total = 0
    ac_pass = 0
    knowledge_files = @{}
    decision_count = 0
    change_levels = @{}
}

# Count changes
if (Test-Path $changesDir) {
    $changes = Get-ChildItem $changesDir -Directory | Where-Object { $_.Name -ne '.gitkeep' -and $_.Name -ne '__pycache__' }
    $stats.total_changes = $changes.Count
    foreach ($c in $changes) {
        $verify = Join-Path $c.FullName "VERIFY.md"
        $report = Join-Path $c.FullName "REPORT.md"
        $changeMd = Join-Path $c.FullName "CHANGE.md"
        $hasVerify = Test-Path $verify
        $hasReport = Test-Path $report
        
        if ($hasReport) { $stats.completed_changes++ }
        if ($hasVerify -and -not $hasReport) { $stats.active_changes++ }
        
        # Detect change level from CHANGE.md
        if (Test-Path $changeMd) {
            $chContent = Get-Content $changeMd -Raw -Encoding utf8 -ErrorAction SilentlyContinue
            if ($chContent -match '(?i)process_level[/:]\s*(Light|light)') { $stats.light_changes++ }
            elseif ($chContent -match '(?i)process_level[/:]\s*(Standard|standard)') { $stats.standard_changes++ }
            elseif ($chContent -match '(?i)process_level[/:]\s*(Heavy|heavy)') { $stats.heavy_changes++ }
            elseif ($chContent -match '(?i)(Emergency|emergency|hotfix)') { $stats.emergency_changes++ }
            else { $stats.change_levels["uncategorized"] = ([int]$stats.change_levels["uncategorized"]) + 1 }
        }
        
        # Check if blocked (AUDIT.md present with reject verdict)
        $audit = Join-Path $c.FullName "AUDIT.md"
        if (Test-Path $audit) {
            $aContent = Get-Content $audit -Raw -Encoding utf8 -ErrorAction SilentlyContinue
            if ($aContent -match '(?i)verdict.*reject') { $stats.blocked_changes++ }
        }
        
        # Count ACs
        $tasks = Join-Path $c.FullName "TASKS.md"
        if (Test-Path $tasks) {
            $t = Get-Content $tasks -Raw -Encoding utf8 -ErrorAction SilentlyContinue
            $acs = [regex]::Matches($t, 'AC-\d+')
            $stats.ac_total += $acs.Count
            # Rough AC pass detection (VERIFY.md references the AC)
            $verifyFile = Join-Path $c.FullName "VERIFY.md"
            if (Test-Path $verifyFile) {
                $v = Get-Content $verifyFile -Raw -Encoding utf8 -ErrorAction SilentlyContinue
                foreach ($m in $acs) {
                    if ($v -match [regex]::Escape($m.Value)) { $stats.ac_pass++ }
                }
            }
        }
    }
}

# Count scripts
if (Test-Path $scriptsDir) {
    $scripts = Get-ChildItem $scriptsDir -Filter "*.ps1" | Where-Object { $_.Name -notmatch '^_' }
    $stats.total_scripts = $scripts.Count
}

# Count knowledge files
if (Test-Path $knowledgeDir) {
    $kFiles = Get-ChildItem $knowledgeDir -File | Where-Object { $_.Name -ne '.gitkeep' }
    foreach ($f in $kFiles) {
        $content = Get-Content $f.FullName -Raw -Encoding utf8 -ErrorAction SilentlyContinue
        $lineCount = ($content -split "`n").Count
        $stats.knowledge_files[$f.Name] = @{ lines = $lineCount; path = $f.FullName }
    }
}

# Count decisions
if (Test-Path $decisionsDir) {
    $stats.decision_count = (Get-ChildItem $decisionsDir -Filter "ADR-*").Count
}

# Build report
$completionRate = if ($stats.total_changes -gt 0) { "$([math]::Round($stats.completed_changes/$stats.total_changes*100, 1))%" } else { "N/A" }
$acFail = $stats.ac_total - $stats.ac_pass
if ($stats.ac_pass -gt $stats.ac_total) { $stats.ac_pass = $stats.ac_total; $acFail = 0 }
$acPassRate = if ($stats.ac_total -gt 0) { "$([math]::Round($stats.ac_pass/$stats.ac_total*100, 1))%" } else { "N/A" }
$blockRate = if ($stats.total_changes -gt 0) { "$([math]::Round($stats.blocked_changes/$stats.total_changes*100, 1))%" } else { "N/A" }

$report = @"
# Evolution Stats

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')

## Project Activity

| Metric | Value |
|--------|-------|
| Total Changes | $($stats.total_changes) |
| Completed | $($stats.completed_changes) |
| Active | $($stats.active_changes) |
| Completion Rate | $completionRate |
| Blocked Rate | $blockRate |

## Change Level Distribution

| Level | Count |
|-------|-------|
| Heavy | $($stats.heavy_changes) |
| Standard | $($stats.standard_changes) |
| Light | $($stats.light_changes) |
| Emergency | $($stats.emergency_changes) |
| Unclassified | $($stats.change_levels['uncategorized']) |

## Code Quality

| Metric | Value |
|--------|-------|
| Total ACs | $($stats.ac_total) |
| AC Verified | $($stats.ac_pass) |
| AC Not Verified | $acFail |
| AC Pass Rate | $acPassRate |
| Check Scripts | $($stats.total_scripts) |
| Decisions (ADRs) | $($stats.decision_count) |

## Knowledge Base

$(if ($stats.knowledge_files.Count -gt 0) {
    $stats.knowledge_files.GetEnumerator() | Sort-Object -Property Name | ForEach-Object {
        "| $($_.Key) | $($_.Value.lines) lines |"
    }
} else { "(No knowledge files yet)" })

---
*Generated by evolution-stats.ps1*
"@

# Output report
$report

# Update INDEX.md if requested
if ($UpdateIndex -and (Test-Path $indexFile)) {
    $now = Get-Date -Format 'yyyy-MM-dd'
    $statsBlock = @"

## Process Statistics (cumulative)

> Tracks aggregate health across changes. Auto-updated by evolution-stats.ps1 -UpdateIndex.

| Metric | Value | As Of |
|--------|-------|-------|
| Total changes completed | $($stats.completed_changes) | $now |
| Heavy changes | $($stats.heavy_changes) | $now |
| Standard changes | $($stats.standard_changes) | $now |
| Light changes | $($stats.light_changes) | $now |
| Emergency changes | $($stats.emergency_changes) | $now |
| Active / blocked changes | $($stats.active_changes) / $($stats.blocked_changes) | $now |
| AC pass rate | $acPassRate | $now |
| Knowledge files | $($stats.knowledge_files.Count) | $now |
| ADRs | $($stats.decision_count) | $now |
| Current scaffold version | 0.2.0 | $now |

## Over Time (by quarter)

> Populated as changes accumulate.

| Quarter | Changes | Heavy | Standard | Light | AC Pass Rate |
|---------|---------|-------|----------|-------|--------------|
| $(Get-Date -Format 'yyyy-Qq') | $($stats.total_changes) | $($stats.heavy_changes) | $($stats.standard_changes) | $($stats.light_changes) | $acPassRate |
"@

    $content = Get-Content $indexFile -Raw -Encoding utf8
    # Replace existing Process Statistics section
    if ($content -match '(?s)## Process Statistics.*?(?=## |\z)') {
        $content = $content -replace '(?s)## Process Statistics.*?(?=## |\z)', $statsBlock
    } else {
        $content = $content.TrimEnd() + $statsBlock
    }
    Set-Content $indexFile -Value $content -Encoding utf8 -NoNewline
    Write-Host "`n[evolution-stats] Updated INDEX.md Process Statistics section."
}
