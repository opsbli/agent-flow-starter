<#
.SYNOPSIS
Integration test for check-change in an isolated git repository.
#>

$ErrorActionPreference = "Stop"
$testRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$scriptsDir = Join-Path $testRoot "scripts"
$tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "af-check-change-$(Get-Random)"
$exitCode = 0

function Cleanup {
    if (Test-Path $tmpDir) { Remove-Item -Recurse -Force $tmpDir }
}
trap { Cleanup }

Write-Host "=== Integration test: check-change ==="
Write-Host "Isolated repo: $tmpDir"

# Setup
New-Item -ItemType Directory -Path "$tmpDir/src" -Force | Out-Null
"console.log('hello');" | Set-Content -Path "$tmpDir/src/index.ts" -Encoding utf8
'{"name":"test-project","scripts":{"test":"echo ok"}}' | Set-Content -Path "$tmpDir/package.json" -Encoding utf8

# Init git
Push-Location $tmpDir
git init 2>$null
git add -A
git commit -m "Initial commit" --allow-empty 2>$null
Pop-Location

# Install agent-flow
$starterRoot = (Resolve-Path (Join-Path $testRoot "..")).Path
& $scriptsDir/install-agent-flow.ps1 -Target $tmpDir -starterRoot $starterRoot -Force 2>$null

# Init project
& "$tmpDir/agent-flow/scripts/init-project.ps1" -Target $tmpDir 2>$null

function fail($msg) { Write-Host "FAIL: $msg"; $script:exitCode = 1 }
function pass($msg) { Write-Host "PASS: $msg" }

# Create change artifacts
$changeDir = "$tmpDir/agent-flow/changes/test-integration"
New-Item -ItemType Directory -Path $changeDir -Force | Out-Null

@"
# Change: test-integration

## 流程级别

- [ ] Light
- [x] Standard
- [ ] Heavy

## 目标

Test check-change
"@ | Set-Content -Path "$changeDir/CHANGE.md" -Encoding utf8

@"
# Code Scan

## Machine Check

scan_time: 2026-06-19 12:00
related_modules: test
similar_implementations: none
reusable_abstractions: none
standards_snapshot: test
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
"@ | Set-Content -Path "$changeDir/CODE_SCAN.md" -Encoding utf8

@"
# Requirement

## 验收标准

| AC | Given | When | Then | 验证方式 |
|---|---|---|---|---|
| AC-01 | test | test | test | test |
"@ | Set-Content -Path "$changeDir/REQUIREMENT.md" -Encoding utf8

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

| # | Question | Confirmation | Evidence |
|---|---|---|---|
| 1 | Intent Risk | test | user-confirmed | test |
| 2 | Existing Code Fit | test | user-confirmed | test |
| 3 | Unnecessary Abstraction | test | user-confirmed | test |
| 4 | Protected Areas | test | user-confirmed | test |
| 5 | Boundary And Failure Modes | test | user-confirmed | test |

Alignment Verdict: aligned
"@ | Set-Content -Path "$changeDir/DESIGN.md" -Encoding utf8

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
"@ | Set-Content -Path "$changeDir/TASKS.md" -Encoding utf8

@"
# Verify

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | test | command | echo ok | pass | none |

## Coverage Summary

| Metric | Source | Value | Result | Notes |
|---|---|---|---|---|
| AC Coverage | coverage-check | 1/1 | pass | |
| Test Coverage | N/A | skipped | skipped | test |
"@ | Set-Content -Path "$changeDir/VERIFY.md" -Encoding utf8

@"
# Evolution

## Machine Check

problem: none
knowledge: none
adr: none
gate: none
template: none
no_change_reason: test

## 本次 change 暴露的问题

无
"@ | Set-Content -Path "$changeDir/EVOLUTION.md" -Encoding utf8

# Commit
Push-Location $tmpDir
git add -A
git commit -m "Add test change" 2>$null
Pop-Location

Write-Host ""
Write-Host "--- Running check-change in isolated repo ---"

$output = & "$tmpDir/agent-flow/scripts/check-change.ps1" -ChangeDir $changeDir -OutputPath "$changeDir/CHECK_RESULT.json" 2>&1
if ((Test-Path "$changeDir/CHECK_RESULT.json")) { pass "check-change produced CHECK_RESULT.json" }
else { Write-Host $output; fail "check-change did not produce CHECK_RESULT.json" }

$output = & "$tmpDir/agent-flow/scripts/check-change.ps1" -ChangeDir $changeDir -Closure -OutputPath "$changeDir/CHECK_RESULT_CLOSURE.json" 2>&1
if ((Test-Path "$changeDir/CHECK_RESULT_CLOSURE.json")) { pass "check-change --closure produced result" }
else { Write-Host $output; fail "check-change --closure did not produce result" }

Cleanup

Write-Host ""
if ($exitCode -eq 0) { Write-Host "All integration tests passed." }
else { Write-Host "Some integration tests failed." }
exit $exitCode
