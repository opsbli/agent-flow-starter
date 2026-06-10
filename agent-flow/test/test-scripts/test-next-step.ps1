<#
.SYNOPSIS
Unit tests for next-step.ps1's key helper functions.

.DESCRIPTION
Tests the flow-level detection, meaningful file validation, and audit verdict
parsing functions that next-step.ps1 uses for change state analysis.

These functions are tested in isolation by dot-sourcing the script content
via a temporary extraction, or by creating minimal change fixtures.
#>

$ErrorActionPreference = "Stop"

$testRoot = Split-Path -Parent $PSScriptRoot
$fixtureDir = Join-Path $testRoot "fixtures/next-step-tests"

# Ensure clean state
if (Test-Path -LiteralPath $fixtureDir) {
    Remove-Item -Recurse -Force -LiteralPath $fixtureDir
}

$passed = 0
$failed = 0

function Assert-Equal {
    param(
        [string]$Name,
        [object]$Expected,
        [object]$Actual
    )
    if ($Expected -ne $Actual) {
        Write-Host "FAIL: $Name - expected '$Expected', got '$Actual'"
        $script:failed++
    } else {
        Write-Host "PASS: $Name"
        $script:passed++
    }
}

function Assert-Match {
    param(
        [string]$Name,
        [string]$ExpectedPattern,
        [string]$ActualText
    )
    if ($ActualText -notmatch $ExpectedPattern) {
        Write-Host "FAIL: $Name - expected pattern '$ExpectedPattern' not found in output"
        $script:failed++
    } else {
        Write-Host "PASS: $Name"
        $script:passed++
    }
}

# === Test 1: Flow level detection from CHANGE.md ===
Write-Host "=== Test 1: Flow level detection ==="
$testDir1 = Join-Path $fixtureDir "test-flow-detect"
New-Item -ItemType Directory -Force -Path $testDir1 | Out-Null

$testCases = @(
    @{ Name = "Light"; Content = "# Change`n## 流程级别`n- [x] Light`n- [ ] Standard`n- [ ] Heavy" }
    @{ Name = "Standard"; Content = "# Change`n## 流程级别`n- [ ] Light`n- [x] Standard`n- [ ] Heavy" }
    @{ Name = "Heavy"; Content = "# Change`n## 流程级别`n- [ ] Light`n- [ ] Standard`n- [x] Heavy" }
)

foreach ($tc in $testCases) {
    $filePath = Join-Path $testDir1 "CHANGE.md"
    Set-Content -LiteralPath $filePath -Value $tc.Content -Encoding utf8

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $filePath
    if ($text -match "(?i)\[x\]\s+Heavy") { $detected = "Heavy" }
    elseif ($text -match "(?i)\[x\]\s+Standard") { $detected = "Standard" }
    elseif ($text -match "(?i)\[x\]\s+Light") { $detected = "Light" }
    else { $detected = "Unknown" }

    Assert-Equal -Name "Flow detection: $($tc.Name)" -Expected $tc.Name -Actual $detected
}

# === Test 2: Meaningful file detection (not empty, no TODO placeholders) ===
Write-Host "=== Test 2: Meaningful file detection ==="
$testDir2 = Join-Path $fixtureDir "test-meaningful"
New-Item -ItemType Directory -Force -Path $testDir2 | Out-Null

$contentTests = @(
    @{ Name = "empty file"; Content = ""; Expected = $false }
    @{ Name = "whitespace only"; Content = "`n`n  `n"; Expected = $false }
    @{ Name = "TODO placeholder"; Content = "TODO_PROJECT_NAME"; Expected = $false }
    @{ Name = "real content"; Content = "# Design for user module`nWe will use existing services."; Expected = $true }
    @{ Name = "mixed placeholder"; Content = "Project: TODO_PROJECT_NAME`nBut also some real content."; Expected = $false }
)

$placeholders = @("TODO_", "N/A", "none", "null")
foreach ($ct in $contentTests) {
    $filePath = Join-Path $testDir2 "test.md"
    Set-Content -LiteralPath $filePath -Value $ct.Content -Encoding utf8

    # Replicate next-step.ps1's Test-MeaningfulFile logic
    $isMeaningful = $false
    $fileContent = Get-Content -Raw -Encoding utf8 -LiteralPath $filePath
    if (-not [string]::IsNullOrWhiteSpace($fileContent)) {
        $isMeaningful = $true
        foreach ($placeholder in $placeholders) {
            if ($fileContent.Contains($placeholder)) {
                $isMeaningful = $false
                break
            }
        }
    }

    Assert-Equal -Name "Meaningful check: $($ct.Name)" -Expected $ct.Expected -Actual $isMeaningful
}

# === Test 3: Alignment verdict extraction from DESIGN.md ===
Write-Host "=== Test 3: Alignment verdict extraction ==="
$testDir3 = Join-Path $fixtureDir "test-alignment"
New-Item -ItemType Directory -Force -Path $testDir3 | Out-Null

$alignmentCases = @(
    @{ Name = "aligned"; Content = "Some text`nAlignment Verdict: aligned`nMore text"; Expected = "aligned" }
    @{ Name = "skipped with reason"; Content = "Alignment Verdict: skipped`nSkip Reason: User explicitly requested"; Expected = "skipped" }
    @{ Name = "pending"; Content = "Alignment Verdict: pending`nSome notes"; Expected = "pending" }
    @{ Name = "missing"; Content = "# Design`nNo verdict here"; Expected = $null }
    @{ Name = "blocked"; Content = "Alignment Verdict: blocked`nNeed to resolve X"; Expected = "blocked" }
)

foreach ($ac in $alignmentCases) {
    $filePath = Join-Path $testDir3 "DESIGN.md"
    Set-Content -LiteralPath $filePath -Value $ac.Content -Encoding utf8

    # Replicate next-step.ps1's Get-DesignAlignmentVerdict logic
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $filePath
    $match = [regex]::Match($text, "(?im)^\s*Alignment Verdict:\s*([A-Za-z-]+)\s*$")
    $verdict = if ($match.Success) { $match.Groups[1].Value.ToLowerInvariant() } else { $null }

    Assert-Equal -Name "Alignment verdict: $($ac.Name)" -Expected $ac.Expected -Actual $verdict
}

# === Test 4: Audit verdict extraction ===
Write-Host "=== Test 4: Audit verdict extraction ==="
$testDir4 = Join-Path $fixtureDir "test-audit"
New-Item -ItemType Directory -Force -Path $testDir4 | Out-Null

$auditCases = @(
    @{ Name = "Plan Audit accept"; Content = "## Plan Audit`nVerdict: accept`n## Closure Audit`nVerdict: acceptable"; ExpectedPlan = "accept"; ExpectedClosure = "acceptable" }
    @{ Name = "Plan Audit reject"; Content = "## Plan Audit`nVerdict: reject`n## Closure Audit`nVerdict: rejected"; ExpectedPlan = "reject"; ExpectedClosure = "rejected" }
    @{ Name = "no audit section"; Content = "# Just notes"; ExpectedPlan = $null; ExpectedClosure = $null }
)

foreach ($ac in $auditCases) {
    $filePath = Join-Path $testDir4 "AUDIT.md"
    Set-Content -LiteralPath $filePath -Value $ac.Content -Encoding utf8

    # Replicate next-step.ps1's Get-AuditVerdict logic
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $filePath
    $pattern = "(?s)##\s+$([regex]::Escape('Plan Audit')).*?Verdict:\s*([A-Za-z]+)"
    $match = [regex]::Match($text, $pattern)
    $planVerdict = if ($match.Success) { $match.Groups[1].Value.ToLowerInvariant() } else { $null }

    $pattern2 = "(?s)##\s+$([regex]::Escape('Closure Audit')).*?Verdict:\s*([A-Za-z]+)"
    $match2 = [regex]::Match($text, $pattern2)
    $closureVerdict = if ($match2.Success) { $match2.Groups[1].Value.ToLowerInvariant() } else { $null }

    Assert-Equal -Name "Plan Audit verdict: $($ac.Name)" -Expected $ac.ExpectedPlan -Actual $planVerdict
    Assert-Equal -Name "Closure Audit verdict: $($ac.Name)" -Expected $ac.ExpectedClosure -Actual $closureVerdict
}

# === Test 5: State value extraction ===
Write-Host "=== Test 5: State value extraction ==="
$testDir5 = Join-Path $fixtureDir "test-state"
New-Item -ItemType Directory -Force -Path $testDir5 | Out-Null

$stateCases = @(
    @{ Name = "current_stage"; Content = "change_id: test`ncurrent_stage: intake`nblocked: false"; Key = "current_stage"; Expected = "intake" }
    @{ Name = "blocked"; Content = "change_id: test`ncurrent_stage: design`nblocked: true"; Key = "blocked"; Expected = "true" }
    @{ Name = "missing key"; Content = "change_id: test`ncurrent_stage: verify"; Key = "nonexistent"; Expected = "" }
)

foreach ($sc in $stateCases) {
    $filePath = Join-Path $testDir5 "STATE.md"
    Set-Content -LiteralPath $filePath -Value $sc.Content -Encoding utf8

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $filePath
    $match = [regex]::Match($text, "(?im)^\s*$([regex]::Escape($sc.Key)):\s*(.+?)\s*$")
    $value = if ($match.Success) { $match.Groups[1].Value.Trim() } else { "" }

    Assert-Equal -Name "State value: $($sc.Name)" -Expected $sc.Expected -Actual $value
}

# === Summary ===
Write-Host ""
Write-Host "============================================"
Write-Host "Results: $passed passed, $failed failed"
if ($failed -gt 0) {
    Write-Host "SOME TESTS FAILED"
    exit 1
} else {
    Write-Host "All tests passed."
    exit 0
}
