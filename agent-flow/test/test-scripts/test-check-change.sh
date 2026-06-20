#!/usr/bin/env bash
# Integration test for check-change in an isolated git repository.
# Tests the full check-change flow without interference from starter repo state.
set -euo pipefail

test_root="$(cd "$(dirname "$0")/../.." && pwd)"
scripts_dir="$(cd "$test_root/scripts" && pwd)"
tmp_dir="$(mktemp -d)"
exit_code=0

cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

echo "=== Integration test: check-change ==="
echo "Isolated repo: $tmp_dir"

# --- Setup: init a minimal git project ---
mkdir -p "$tmp_dir/src"
cat > "$tmp_dir/src/index.ts" << 'EOF'
console.log("hello");
EOF

cat > "$tmp_dir/package.json" << 'EOF'
{ "name": "test-project", "scripts": { "test": "echo ok" } }
EOF

# Init git repo
cd "$tmp_dir"
git init
git add -A
git commit -m "Initial commit" --allow-empty 2>/dev/null || true

# Install agent-flow
bash "$scripts_dir/install-agent-flow.sh" --target "$tmp_dir" --starter-root "$(cd "$test_root/.." && pwd)" --force 2>/dev/null

# Init project
bash "$tmp_dir/agent-flow/scripts/init-project.sh" --target "$tmp_dir" 2>/dev/null

fail() {
  echo "FAIL: $1"
  exit_code=1
}

pass() {
  echo "PASS: $1"
}

# --- Create a Standard change with all artifacts ---
change_dir="$tmp_dir/agent-flow/changes/test-integration"
mkdir -p "$change_dir"

cat > "$change_dir/CHANGE.md" << 'EOF'
# Change: test-integration

## 流程级别

- [ ] Light
- [x] Standard
- [ ] Heavy

## 目标

Test check-change
EOF

cat > "$change_dir/CODE_SCAN.md" << 'EOF'
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
EOF

cat > "$change_dir/REQUIREMENT.md" << 'EOF'
# Requirement

## 验收标准

| AC | Given | When | Then | 验证方式 |
|---|---|---|---|---|
| AC-01 | test | test | test | test |
EOF

cat > "$change_dir/DESIGN.md" << 'EOF'
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
EOF

cat > "$change_dir/TASKS.md" << 'EOF'
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
EOF

cat > "$change_dir/VERIFY.md" << 'EOF'
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
EOF

cat > "$change_dir/EVOLUTION.md" << 'EOF'
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
EOF

# Commit the change files
cd "$tmp_dir"
git add -A
git commit -m "Add test change" 2>/dev/null || true

echo ""
echo "--- Running check-change in isolated repo ---"

# Run check-change (non-closure mode)
output=$(bash "$tmp_dir/agent-flow/scripts/check-change.sh" \
  --change-dir "$change_dir" \
  --output "$change_dir/CHECK_RESULT.json" 2>&1) || true

# Check if output contains "check-change summary" or the result file was created
if [ -f "$change_dir/CHECK_RESULT.json" ]; then
  pass "check-change produced CHECK_RESULT.json"
else
  echo "$output"
  fail "check-change did not produce CHECK_RESULT.json"
fi

# Run closure mode
output=$(bash "$tmp_dir/agent-flow/scripts/check-change.sh" \
  --change-dir "$change_dir" \
  --closure \
  --output "$change_dir/CHECK_RESULT_CLOSURE.json" 2>&1) || true

if [ -f "$change_dir/CHECK_RESULT_CLOSURE.json" ]; then
  pass "check-change --closure produced CHECK_RESULT_CLOSURE.json"
else
  echo "$output"
  fail "check-change --closure did not produce result"
fi

echo ""
echo "=== Integration test results ==="
if [ "$exit_code" -eq 0 ]; then
  echo "All integration tests passed."
else
  echo "Some integration tests failed."
fi
exit "$exit_code"
