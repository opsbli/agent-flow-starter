<#
.SYNOPSIS
Content quality gate — validates that artifacts have meaningful content,
not just TODO/TBD placeholders, and that design decisions reference code.

.DESCRIPTION
Part of the agent-flow scaffold toolchain.
Three checks per artifact:
  1. Existence: file exists
  2. Content: no TODO/TBD/placeholder text
  3. Evidence: AI-written decisions reference specific code locations

.PARAMETER ChangeDir
Path to the change directory.

.PARAMETER Strict
Fail on first issue found (vs report all issues).

.EXAMPLE
agent-flow/scripts/content-check.ps1 -ChangeDir agent-flow/changes/my-change
#>

param(
    [string]$ChangeDir,
    [switch]$Strict
)

$ErrorActionPreference = "Stop"

if (-not $ChangeDir) {
    Write-Host "Usage: content-check.ps1 -ChangeDir <path>" -ForegroundColor Yellow
    exit 1
}
if (-not (Test-Path $ChangeDir)) {
    Write-Host "Change directory not found: $ChangeDir" -ForegroundColor Red
    exit 1
}

. (Join-Path $PSScriptRoot "_common.ps1")

$issues = @()
$passCount = 0
$failCount = 0

function Check-File {
    param(
        [string]$Path,
        [string]$Label,
        [string[]]$RequiredPatterns = @(),
        [switch]$CheckEvidence
    )

    $path = Join-Path $Path $Label
    $result = @{ name = $Label; exists = $false; content = $false; evidence = $false }

    # Check 1: Existence
    if (-not (Test-Path $path)) {
        $result.exists = $false
        return $result
    }
    $result.exists = $true

    # Check 2: Content (meaningful)
    if (-not (Test-MeaningfulFile -Path $path -Placeholders @("TODO", "TBD", "path/to", "{module}", "example"))) {
        $result.content = $false
        return $result
    }
    $result.content = $true

    # Check 3: Evidence (design decisions reference code)
    if ($CheckEvidence) {
        $text = Get-Content -Raw -Encoding utf8 -LiteralPath $path
        # Count code references — lines containing backtick-quoted paths with line numbers
        $codeRefs = @([regex]::Matches($text, '`[^`]+\.(java|ts|py|go|rs|kt|cs|sql|yaml|json|xml|ps1|sh):\d+`')).Count
        $codeRefs += @([regex]::Matches($text, '`[^`]+\.(java|ts|py|go|rs|kt|cs|sql|yaml|json|xml|ps1|sh)`')).Count
        if ($codeRefs -ge 3) {
            $result.evidence = $true
        }
    }

    return $result
}

Write-Host "Content quality check for: $(Split-Path $ChangeDir -Leaf)" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor DarkGray

# ── Check CHANGE.md ──
$r = Check-File -Path $ChangeDir -Label "CHANGE.md" -CheckEvidence
if (-not $r.exists) { $issues += "CHANGE.md: missing"; $failCount++ }
elseif (-not $r.content) { $issues += "CHANGE.md: contains TODO/TBD placeholder"; $failCount++ }
else { $passCount++; Write-Host "  ✅ CHANGE.md" -ForegroundColor Green }

# ── Check CODE_SCAN.md ──
$r = Check-File -Path $ChangeDir -Label "CODE_SCAN.md"
if ($r.exists) {
    if ($r.content) { $passCount++; Write-Host "  ✅ CODE_SCAN.md" -ForegroundColor Green }
    else { $issues += "CODE_SCAN.md: contains TODO/TBD placeholder"; $failCount++ }
}

# ── Check REQUIREMENT.md ──
$reqPath = Join-Path $ChangeDir "REQUIREMENT.md"
if (Test-Path $reqPath) {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $reqPath
    # AC number format check
    $acPattern = [regex]::Matches($text, 'AC-\d{2}')
    if ($acPattern.Count -eq 0) {
        $issues += "REQUIREMENT.md: no AC-XX formatted acceptance criteria found"
        $failCount++
    } else {
        $passCount++
        Write-Host "  ✅ REQUIREMENT.md ($($acPattern.Count) ACs)" -ForegroundColor Green
    }
    $r = Check-File -Path $ChangeDir -Label "REQUIREMENT.md"
    if (-not $r.content) { $issues += "REQUIREMENT.md: contains TODO/TBD placeholder"; $failCount++ }
}

# ── Check DESIGN.md (evidence focus) ──
$designPath = Join-Path $ChangeDir "DESIGN.md"
if (Test-Path $designPath) {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $designPath
    $codeRefs = @([regex]::Matches($text, '`[^`]+\.(java|ts|py|go|rs|kt|cs|sql|yaml|json|xml|ps1|sh)`')).Count
    if ($codeRefs -lt 3) {
        $issues += "DESIGN.md: only $codeRefs code reference(s) — need ≥3. Each decision should cite code."
        $failCount++
    } else {
        $passCount++
        Write-Host "  ✅ DESIGN.md ($codeRefs code refs)" -ForegroundColor Green
    }
}

# ── Check TASKS.md ──
$tasksPath = Join-Path $ChangeDir "TASKS.md"
if (Test-Path $tasksPath) {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $tasksPath
    # Check each task has write_files
    $taskRows = [regex]::Matches($text, '^\|\s*\d+\s+\|')
    $tasksWithWrite = @([regex]::Matches($text, 'write_files|write_file')).Count
    if ($taskRows.Count -gt 0 -and $tasksWithWrite -eq 0) {
        $issues += "TASKS.md: $($taskRows.Count) tasks found but no write_files column"
        $failCount++
    } else {
        $passCount++
        Write-Host "  ✅ TASKS.md ($($taskRows.Count) tasks)" -ForegroundColor Green
    }
}

# ── Check VERIFY.md ──
$verifyPath = Join-Path $ChangeDir "VERIFY.md"
if (Test-Path $verifyPath) {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $verifyPath
    $acRows = @([regex]::Matches($text, 'AC-\d{2}')).Count
    if ($acRows -eq 0) {
        $issues += "VERIFY.md: no AC evidence rows found"
        $failCount++
    } else {
        $passCount++
        Write-Host "  ✅ VERIFY.md ($acRows AC evidence entries)" -ForegroundColor Green
    }
}

# ── Summary ──
Write-Host ""
Write-Host "Results:" -ForegroundColor Cyan
Write-Host "  Passed: $passCount"
if ($failCount -gt 0) {
    Write-Host "  Failed: $failCount" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "    ❌ $issue" -ForegroundColor Red
    }
    if ($Strict) { exit 2 }
} else {
    Write-Host "  ✅ All content checks passed" -ForegroundColor Green
}
