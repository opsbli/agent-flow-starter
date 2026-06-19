<#
.SYNOPSIS
Smoke test for core gate scripts using the minimal-project fixture.
Tests: check-change, scan-check, ac-check, coverage-check, design-check, evolution-check
#>

$ErrorActionPreference = "Stop"
$testRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$fixtureDir = Join-Path $testRoot "fixtures/minimal-project"
$scriptsDir = Join-Path $testRoot "scripts"

Write-Host "=== Smoke test: gate scripts ==="
Write-Host "Fixture: $fixtureDir"

# Setup: install agent-flow into fixture
$fixtureAf = Join-Path $fixtureDir "agent-flow"
if (-not (Test-Path $fixtureAf)) {
    $starterRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $installScript = Join-Path $scriptsDir "install-agent-flow.ps1"
    & $installScript -Target $fixtureDir -starterRoot $starterRoot -Force
}

$changeDir = Join-Path $fixtureAf "changes/test-gate-smoke-$([DateTime]::Now.Ticks)"

function fail($msg) {
    Write-Host "FAIL: $msg"
    exit 1
}

function pass($msg) {
    Write-Host "PASS: $msg"
}

try {
    Write-Host ""
    Write-Host "--- Creating test change ---"
    New-Item -ItemType Directory -Path $changeDir -Force | Out-Null

    # Create CHANGE.md
@"
# Change: test-gate-smoke

## 流程级别

- [ ] Light
- [x] Standard
- [ ] Heavy

## 目标

Test gate scripts

## 非目标

None

## 影响范围

test

## 风险

None
"@ | Set-Content -Path (Join-Path $changeDir "CHANGE.md") -Encoding utf8
    pass "CHANGE.md created"

    # Create CODE_SCAN.md
@"
# Code Scan

## 扫描时间

2026-06-19 12:00

## Machine Check

scan_time: 2026-06-19 12:00
related_modules: test
similar_implementations: none (test fixture)
reusable_abstractions: none
standards_snapshot: test fixture
test_baseline: echo ok
read_files: src/index.ts
write_files: src/index.ts
open_questions: none

## read_files

read_files:
  - src/index.ts

## write_files

write_files:
  - src/index.ts

## 未决问题

无
"@ | Set-Content -Path (Join-Path $changeDir "CODE_SCAN.md") -Encoding utf8
    pass "CODE_SCAN.md created"

    # Create REQUIREMENT.md
@"
# Requirement

## 验收标准

| AC | Given | When | Then | 验证方式 |
|---|---|---|---|---|
| AC-01 | test | test | test | test |
| AC-02 | test | test | test | test |
"@ | Set-Content -Path (Join-Path $changeDir "REQUIREMENT.md") -Encoding utf8
    pass "REQUIREMENT.md created"

    # Create DESIGN.md
@"
# Design

## API / Permission / Auth Decisions

Decision Status: accepted

| Item | Decision | Evidence / Reason |
|---|---|---|
| REST Path | unchanged | test |
| HTTP Method | unchanged | test |
| Permission Code | unchanged | test |
| SaCheckPermission | unchanged | test |
| Anonymous Interface | unchanged | test |
| Login/Token | unchanged | test |
| Tenant/Data Permission | unchanged | test |
| State Machine Impact | not-applicable | test |

State Machine Impact: no

## Design Alignment / Grill

Alignment Source: mixed

Open Questions: none

| Question | AI Recommended Answer | Confirmation | Final Decision |
|---|---|---|---|
| Intent Risk | test | user-confirmed | test |
| Existing Code Fit | test | user-confirmed | test |
| Unnecessary Abstraction | test | user-confirmed | test |
| Protected Areas | test | user-confirmed | test |
| Boundary And Failure Modes | test | user-confirmed | test |

Alignment Verdict: aligned
"@ | Set-Content -Path (Join-Path $changeDir "DESIGN.md") -Encoding utf8
    pass "DESIGN.md created"

    # Create TASKS.md
@"
# Tasks

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel | conflict_warning |
|---|---|---|---|---|---|---|---|
| T001 | completed | AC-01 | src/index.ts | src/index.ts | echo ok | no | |

## write_files 汇总

write_files:
  - src/index.ts

### T001 - Test

状态：completed
目标：Test
AC：AC-01
read_files：src/index.ts
write_files：src/index.ts
验证：echo ok
可并行：no
"@ | Set-Content -Path (Join-Path $changeDir "TASKS.md") -Encoding utf8
    pass "TASKS.md created"

    # Create VERIFY.md
@"
# Verify

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | test | command | echo ok | pass | none |
| AC-02 | test | skipped | test fixture | skipped | test fixture |

## Coverage Summary

| Metric | Source | Value | Result | Notes |
|---|---|---|---|---|
| AC Coverage | coverage-check | 2/2 | pass | |
| Test Coverage | N/A | skipped | skipped | test fixture |
"@ | Set-Content -Path (Join-Path $changeDir "VERIFY.md") -Encoding utf8
    pass "VERIFY.md created"

    # Create EVOLUTION.md
@"
# Evolution

## Machine Check

problem: none
knowledge: none
adr: none
gate: none
template: none
no_change_reason: test fixture
"@ | Set-Content -Path (Join-Path $changeDir "EVOLUTION.md") -Encoding utf8
    pass "EVOLUTION.md created"

    # --- Run gate tests ---
    Write-Host ""
    Write-Host "--- Running gate tests ---"

    # Test 1: scan-check
    Write-Host ""
    Write-Host "Test 1: scan-check"
    $output = & "$scriptsDir/scan-check.ps1" -ChangeDir $changeDir -ProjectRoot $fixtureDir -Strict 2>&1
    if ($LASTEXITCODE -eq 0) { pass "scan-check passed" } else { Write-Host $output; fail "scan-check failed" }

    # Test 2: design-check
    Write-Host ""
    Write-Host "Test 2: design-check"
    $output = & "$scriptsDir/design-check.ps1" -ChangeDir $changeDir 2>&1
    if ($LASTEXITCODE -eq 0) { pass "design-check passed" } else { Write-Host $output; fail "design-check failed" }

    # Test 3: ac-check
    Write-Host ""
    Write-Host "Test 3: ac-check"
    $output = & "$scriptsDir/ac-check.ps1" -ChangeDir $changeDir 2>&1
    if ($LASTEXITCODE -eq 0) { pass "ac-check passed" } else { Write-Host $output; fail "ac-check failed" }

    # Test 4: evolution-check
    Write-Host ""
    Write-Host "Test 4: evolution-check"
    $output = & "$scriptsDir/evolution-check.ps1" -ChangeDir $changeDir 2>&1
    if ($LASTEXITCODE -eq 0) { pass "evolution-check passed" } else { Write-Host $output; fail "evolution-check failed" }

    # Test 5: coverage-check
    Write-Host ""
    Write-Host "Test 5: coverage-check"
    $output = & "$scriptsDir/coverage-check.ps1" -ChangeDir $changeDir 2>&1
    if ($LASTEXITCODE -eq 0) { pass "coverage-check passed" } else { Write-Host $output; fail "coverage-check failed" }

} finally {
    # Cleanup
    if (Test-Path $changeDir) { Remove-Item -Recurse -Force $changeDir }
    Write-Host "Cleaned up."
}

Write-Host ""
Write-Host "=== All gate smoke tests passed ==="
