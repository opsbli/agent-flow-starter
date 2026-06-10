<#
.SYNOPSIS
Smoke test for new-change.ps1 using the minimal-project fixture.

.DESCRIPTION
Tests that new-change creates the expected files for each flow level.
Runs inside the fixture directory, not the real project.
#>

$ErrorActionPreference = "Stop"

$testRoot = Split-Path -Parent $PSScriptRoot
$fixtureDir = Join-Path $testRoot "fixtures/minimal-project"
$scriptsDir = Join-Path (Split-Path -Parent $testRoot) "scripts"

# === Setup: install agent-flow into fixture ===
Write-Host "=== Smoke test: new-change.ps1 ==="
Write-Host "Fixture: $fixtureDir"

# Create agent-flow directory structure in fixture
$fixtureAf = Join-Path $fixtureDir "agent-flow"
if (-not (Test-Path -LiteralPath $fixtureAf)) {
    & (Join-Path $scriptsDir "install-agent-flow.ps1") -Target $fixtureDir -StarterRoot (Resolve-Path (Join-Path $scriptsDir "..\..")) -Force
}

# === Test 1: Light change ===
Write-Host ""
Write-Host "Test 1: Light change"
$changeDir = Join-Path $fixtureAf "changes/test-light"

# Clean up any previous test
if (Test-Path -LiteralPath $changeDir) { Remove-Item -Recurse -Force -LiteralPath $changeDir }

& (Join-Path $scriptsDir "new-change.ps1") -Name "test-light" -Flow Light -ChangesRoot (Join-Path $fixtureAf "changes") -Force

$expectedLight = @("STATE.md", "CHANGE.md", "CODE_SCAN.md", "VERIFY.md", "REPORT.md")
$missing = $expectedLight | Where-Object { -not (Test-Path -LiteralPath (Join-Path $changeDir $_)) }
if ($missing.Count -gt 0) {
    Write-Host "FAIL: Light change missing files: $($missing -join ', ')"
    exit 1
}

# Verify flow level marker in CHANGE.md
$changeContent = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md")
if ($changeContent -notmatch "\[x\]\s+Light") {
    Write-Host "FAIL: Light change marker not set in CHANGE.md"
    exit 1
}
Write-Host "PASS: Light change created $($expectedLight.Count) files, marker correct"

# Clean up
Remove-Item -Recurse -Force -LiteralPath $changeDir

# === Test 2: Standard change ===
Write-Host ""
Write-Host "Test 2: Standard change"
$changeDir = Join-Path $fixtureAf "changes/test-standard"

if (Test-Path -LiteralPath $changeDir) { Remove-Item -Recurse -Force -LiteralPath $changeDir }

& (Join-Path $scriptsDir "new-change.ps1") -Name "test-standard" -Flow Standard -ChangesRoot (Join-Path $fixtureAf "changes") -Force

$expectedStd = @("STATE.md", "CHANGE.md", "REQUIREMENT.md", "CODE_SCAN.md", "DESIGN.md", "TASKS.md", "VERIFY.md", "REPORT.md", "EVOLUTION.md")
$missing = $expectedStd | Where-Object { -not (Test-Path -LiteralPath (Join-Path $changeDir $_)) }
if ($missing.Count -gt 0) {
    Write-Host "FAIL: Standard change missing files: $($missing -join ', ')"
    exit 1
}

$changeContent = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md")
if ($changeContent -notmatch "\[x\]\s+Standard") {
    Write-Host "FAIL: Standard change marker not set in CHANGE.md"
    exit 1
}
Write-Host "PASS: Standard change created $($expectedStd.Count) files, marker correct"
Remove-Item -Recurse -Force -LiteralPath $changeDir

# === Test 3: Heavy change ===
Write-Host ""
Write-Host "Test 3: Heavy change"
$changeDir = Join-Path $fixtureAf "changes/test-heavy"

if (Test-Path -LiteralPath $changeDir) { Remove-Item -Recurse -Force -LiteralPath $changeDir }

& (Join-Path $scriptsDir "new-change.ps1") -Name "test-heavy" -Flow Heavy -ChangesRoot (Join-Path $fixtureAf "changes") -Force

$expectedHeavy = @("STATE.md", "CHANGE.md", "REQUIREMENT.md", "CODE_SCAN.md", "DESIGN.md", "PLAN.md", "TASKS.md", "VERIFY.md", "REVIEW.md", "REPORT.md", "AUDIT.md", "EVOLUTION.md")
$missing = $expectedHeavy | Where-Object { -not (Test-Path -LiteralPath (Join-Path $changeDir $_)) }
if ($missing.Count -gt 0) {
    Write-Host "FAIL: Heavy change missing files: $($missing -join ', ')"
    exit 1
}

$changeContent = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md")
if ($changeContent -notmatch "\[x\]\s+Heavy") {
    Write-Host "FAIL: Heavy change marker not set in CHANGE.md"
    exit 1
}
Write-Host "PASS: Heavy change created $($expectedHeavy.Count) files, marker correct"
Remove-Item -Recurse -Force -LiteralPath $changeDir

# === Test 4: Slug generation ===
Write-Host ""
Write-Host "Test 4: Slug generation from name"
$changeDir = Join-Path $fixtureAf "changes/anonymous-conversation"
if (Test-Path -LiteralPath $changeDir) { Remove-Item -Recurse -Force -LiteralPath $changeDir }

& (Join-Path $scriptsDir "new-change.ps1") -Name "Anonymous Conversation" -Flow Light -ChangesRoot (Join-Path $fixtureAf "changes") -Force

if (-not (Test-Path -LiteralPath (Join-Path $changeDir "CHANGE.md"))) {
    Write-Host "FAIL: Change not created for name 'Anonymous Conversation'"
    exit 1
}
Write-Host "PASS: Slug generation correct: anonymous-conversation"
Remove-Item -Recurse -Force -LiteralPath $changeDir

# === All tests passed ===
Write-Host ""
Write-Host "=== All smoke tests passed ==="
exit 0
