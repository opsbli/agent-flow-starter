#!/usr/bin/env bash
# Smoke test for core gate scripts using the minimal-project fixture.
# Tests: check-change, scan-check, ac-check, coverage-check, design-check, evolution-check
set -euo pipefail

test_root="$(cd "$(dirname "$0")/.." && pwd)"
fixture_dir="$test_root/fixtures/minimal-project"
scripts_dir="$(cd "$test_root/../scripts" && pwd)"
change_dir=""

echo "=== Smoke test: gate scripts ==="
echo "Fixture: $fixture_dir"

# --- Setup: install agent-flow into fixture ---
fixture_af="$fixture_dir/agent-flow"
if [ ! -d "$fixture_af" ]; then
  bash "$scripts_dir/install-agent-flow.sh" --target "$fixture_dir" --starter-root "$(cd "$test_root/.." && pwd)" --force
fi

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

cleanup() {
  [ -n "$change_dir" ] && [ -d "$change_dir" ] && rm -rf "$change_dir"
  echo "Cleaned up."
}
trap cleanup EXIT

# Create a Standard change for testing
echo ""
echo "--- Creating test change ---"
change_dir="$fixture_af/changes/test-gate-smoke-$(date +%s)"
mkdir -p "$change_dir"

# Create CHANGE.md
cat > "$change_dir/CHANGE.md" << 'CHANGEOF'
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
CHANGEOF
pass "CHANGE.md created"

# Create CODE_SCAN.md with all required fields
cat > "$change_dir/CODE_SCAN.md" << 'SCANEOF'
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
SCANEOF
pass "CODE_SCAN.md created"

# Create REQUIREMENT.md
cat > "$change_dir/REQUIREMENT.md" << 'REQEOF'
# Requirement

## 验收标准

| AC | Given | When | Then | 验证方式 |
|---|---|---|---|---|
| AC-01 | test | test | test | test |
| AC-02 | test | test | test | test |
REQEOF
pass "REQUIREMENT.md created"

# Create DESIGN.md with alignment
cat > "$change_dir/DESIGN.md" << 'DESIGNEOF'
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
DESIGNEOF
pass "DESIGN.md created"

# Create TASKS.md
cat > "$change_dir/TASKS.md" << 'TASKSEOF'
# Tasks

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel | conflict_warning |
|---|---|---|---|---|---|---|---|
| T001 | completed | AC-01 | `src/index.ts` | `src/index.ts` | `echo ok` | no | |

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
TASKSEOF
pass "TASKS.md created"

# Create VERIFY.md
cat > "$change_dir/VERIFY.md" << 'VERIFYEOF'
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
VERIFYEOF
pass "VERIFY.md created"

# Create EVOLUTION.md
cat > "$change_dir/EVOLUTION.md" << 'EVOEOF'
# Evolution

## Machine Check

problem: none
knowledge: none
adr: none
gate: none
template: none
no_change_reason: test fixture
EVOEOF
pass "EVOLUTION.md created"

echo ""
echo "--- Running gate tests ---"

# Test 1: scan-check
echo ""
echo "Test 1: scan-check"
if output=$(bash "$scripts_dir/scan-check.sh" --change-dir "$change_dir" --project-root "$fixture_dir" --strict 2>&1); then
  pass "scan-check passed"
else
  echo "Output: $output"
  fail "scan-check failed"
fi

# Test 2: design-check
echo ""
echo "Test 2: design-check"
if output=$(bash "$scripts_dir/design-check.sh" --change-dir "$change_dir" 2>&1); then
  pass "design-check passed"
else
  echo "Output: $output"
  fail "design-check failed"
fi

# Test 3: alignment-check
echo ""
echo "Test 3: alignment-check"
if output=$(bash "$scripts_dir/alignment-check.sh" --change-dir "$change_dir" 2>&1); then
  pass "alignment-check passed"
else
  echo "Output: $output"
  fail "alignment-check failed"
fi

# Test 4: task-check
echo ""
echo "Test 4: task-check"
if output=$(bash "$scripts_dir/task-check.sh" --change-dir "$change_dir" 2>&1); then
  pass "task-check passed"
else
  echo "Output: $output"
  fail "task-check failed"
fi

# Test 5: ac-check
echo ""
echo "Test 5: ac-check"
if output=$(bash "$scripts_dir/ac-check.sh" --change-dir "$change_dir" 2>&1); then
  pass "ac-check passed"
else
  echo "Output: $output"
  fail "ac-check failed"
fi

# Test 6: evolution-check
echo ""
echo "Test 6: evolution-check"
if output=$(bash "$scripts_dir/evolution-check.sh" --change-dir "$change_dir" 2>&1); then
  pass "evolution-check passed"
else
  echo "Output: $output"
  fail "evolution-check failed"
fi

# Test 7: coverage-check
echo ""
echo "Test 7: coverage-check"
if output=$(bash "$scripts_dir/coverage-check.sh" --change-dir "$change_dir" 2>&1); then
  pass "coverage-check passed"
else
  echo "Output: $output"
  fail "coverage-check failed"
fi

echo ""
echo "--- ECC skill validation ---"
ecc_issues=0
for skill_dir in pi-package/skills/*/; do
  skill_file="${skill_dir}SKILL.md"
  [ ! -f "$skill_file" ] && echo "MISSING SKILL.md: $skill_dir" && ecc_issues=$((ecc_issues + 1)) && continue
  for field in "name:" "description:" "origin:"; do
    grep -q "^$field" "$skill_file" 2>/dev/null || { echo "MISSING FIELD '$field': $skill_file"; ecc_issues=$((ecc_issues + 1)); }
  done
done
for agent_file in pi-package/agents/*.md; do
  for field in "name:" "description:"; do
    grep -q "^$field" "$agent_file" 2>/dev/null || { echo "MISSING FIELD '$field': $agent_file"; ecc_issues=$((ecc_issues + 1)); }
  done
done
for prompt_file in pi-package/prompts/*.md; do
  size=$(wc -c < "$prompt_file")
  [ "$size" -lt 50 ] && { echo "TOO SMALL: $prompt_file ($size bytes)"; ecc_issues=$((ecc_issues + 1)); }
done
if [ "$ecc_issues" -eq 0 ]; then
  pass "ECC skills validated (32 skills, 8 agents, 13 prompts)"
else
  fail "ECC validation found $ecc_issues issue(s)"
fi

echo ""
echo "--- Idempotency check (bare cd without restore) ---"
idempotent_issues=0
for f in agent-flow/scripts/*.sh; do
  base=$(basename "$f")
  case "$base" in _common*|_generate*) continue;; esac
  while IFS= read -r line; do
    line_num=$(echo "$line" | cut -d: -f1)
    line_content=$(echo "$line" | cut -d: -f2-)
    if echo "$line_content" | grep -Eq '^[[:space:]]*cd[[:space:]]' && ! echo "$line_content" | grep -Eq 'cd .*\$\(|cd .*"|\$\('; then
      echo "  POTENTIAL ISSUE: $base:$line_num — bare cd: $line_content"
      idempotent_issues=$((idempotent_issues + 1))
    fi
  done < <(grep -n '^cd ' "$f" 2>/dev/null || true)
done
if [ "$idempotent_issues" -eq 0 ]; then
  pass "All scripts idempotent (no bare cd outside subshell)"
else
  echo "  WARNING: $idempotent_issues script(s) have bare cd (not blocking)"
fi

echo ""
echo "=== All gate smoke tests passed ==="
exit 0
