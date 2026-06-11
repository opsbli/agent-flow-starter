<#
.SYNOPSIS
Detect unused agent-flow scripts, templates, and knowledge files.
.DESCRIPTION
Reports files that appear to be unused based on staleness and reference analysis.
#>
param(
    [string]$ProjectRoot = "."
)
$ErrorActionPreference = "Stop"
$afDir = Join-Path $ProjectRoot "agent-flow"
$report = @()
# Scripts — check if they've been referenced in GO.md or change dirs
$scriptsDir = Join-Path $afDir "scripts"
$goMd = Join-Path $afDir "GO.md"
$goContent = if (Test-Path $goMd) { Get-Content $goMd -Raw -Encoding utf8 -ErrorAction SilentlyContinue } else { "" }
$changeDirs = Join-Path $afDir "changes"
$allChangeContent = ""
if (Test-Path $changeDirs) {
    $allChangeContent = Get-ChildItem $changeDirs -Recurse -File -Filter "*.md" | ForEach-Object { Get-Content $_.FullName -Raw -Encoding utf8 -ErrorAction SilentlyContinue } | Out-String
}
if (Test-Path $scriptsDir) {
    Get-ChildItem $scriptsDir -File | Where-Object { $_.Name -notmatch '^_' } | ForEach-Object {
        $scriptName = $_.Name
        # Check if referenced in GO.md or ANY change artifact
        $referenced = $goContent -match [regex]::Escape($scriptName) -or $allChangeContent -match [regex]::Escape($scriptName)
        # Check if it's a core script (always preserved)
        $isCore = $scriptName -match '^(install-agent-flow|scaffold-health|init-project|manifest-check|check-change)'
        if (-not $referenced -and -not $isCore) {
            $report += @{type="Script"; name=$scriptName; status="UNUSED"; note="Never referenced in GO.md or change artifacts"}
        }
    }
}
# Templates — check if any template files are never used
$templatesDir = Join-Path $afDir "templates"
if (Test-Path $templatesDir) {
    Get-ChildItem $templatesDir -File | ForEach-Object {
        $tplName = $_.Name
        $referenced = $goContent -match [regex]::Escape($tplName) -or $allChangeContent -match [regex]::Escape($tplName)
        $isCore = $tplName -match '^(AGENTS|STATE|CHANGE|CODE_SCAN|DESIGN|TASKS|VERIFY|REPORT|REQUIREMENT|EVOLUTION|PLAN|AUDIT|REVIEW)'
        if (-not $referenced -and -not $isCore) {
            $report += @{type="Template"; name=$tplName; status="UNUSED"; note="Never referenced in GO.md or change artifacts"}
        }
    }
}
# Knowledge files — check size/staleness
$knowledgeDir = Join-Path $afDir "knowledge"
if (Test-Path $knowledgeDir) {
    Get-ChildItem $knowledgeDir -File | Where-Object { $_.Name -ne '.gitkeep' } | ForEach-Object {
        $lines = (Get-Content $_.FullName -ErrorAction SilentlyContinue).Count
        $updated = $_.LastWriteTime
        $staleDays = (Get-Date) - $updated
        if ($lines -le 3 -and $_.Name -ne '.gitkeep') {
            $report += @{type="Knowledge"; name=$_.Name; status="EMPTY"; note="Only $lines lines — may need content"}
        } elseif ($staleDays.TotalDays -gt 90) {
            $report += @{type="Knowledge"; name=$_.Name; status="STALE"; note="Last updated $($staleDays.Days) days ago"}
        }
    }
}
# Output
Write-Host "=== agent-flow Cleanup Scan ===" -ForegroundColor Cyan
if ($report.Count -eq 0) {
    Write-Host "  ✅ No unused files detected." -ForegroundColor Green
} else {
    Write-Host "  Found $($report.Count) items:" -ForegroundColor Yellow
    $report | ForEach-Object {
        Write-Host "  [$($_.type)] $($_.name): $($_.status) — $($_.note)" -ForegroundColor $(if ($_.status -eq "UNUSED") { "Yellow" } elseif ($_.status -eq "EMPTY") { "Magenta" } else { "Gray" })
    }
    Write-Host ""
    Write-Host "Suggested actions:" -ForegroundColor Cyan
    $hasUnused = $report | Where-Object { $_.status -eq "UNUSED" }
    if ($hasUnused) { Write-Host "  - Review UNUSED files and either archive or delete them" }
    $hasEmpty = $report | Where-Object { $_.status -eq "EMPTY" }
    if ($hasEmpty) { Write-Host "  - Fill EMPTY knowledge files or delete them" }
}
