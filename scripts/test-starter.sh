#!/usr/bin/env bash
set -euo pipefail

keep_temp=false
if [ "${1:-}" = "--keep-temp" ]; then
  keep_temp=true
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
starter_root="$(cd "$script_dir/.." && pwd)"
temp_root="$(mktemp -d)"
empty_target="$temp_root/empty-project"
update_target="$temp_root/update-project"

cleanup() {
  if [ "$keep_temp" = true ]; then
    echo "Temp kept: $temp_root"
  else
    rm -rf "$temp_root"
  fi
}
trap cleanup EXIT

assert_path() {
  if [ ! -e "$1" ]; then
    echo "Expected path not found: $1" >&2
    exit 1
  fi
}

assert_clean_history_dirs() {
  local target_root="$1"
  local name dir unexpected
  for name in changes logs reports; do
    dir="$target_root/agent-flow/$name"
    assert_path "$dir"
    assert_path "$dir/.gitkeep"
    unexpected="$(
      find "$dir" -mindepth 1 -maxdepth 1 ! -name .gitkeep -print
    )"
    if [ -n "$unexpected" ]; then
      echo "Installed $name directory contains starter history:" >&2
      printf '%s\n' "$unexpected" >&2
      exit 1
    fi
  done
}

expect_failure() {
  local label="$1"
  local pattern="$2"
  shift 2
  local output code
  set +e
  output="$("$@" 2>&1)"
  code=$?
  set -e
  if [ "$code" -eq 0 ]; then
    echo "$label was expected to fail, but passed. Output: $output" >&2
    exit 1
  fi
  if [ -n "$pattern" ] && ! printf '%s' "$output" | grep -Eq "$pattern"; then
    echo "$label failed, but output did not match '$pattern'. Output: $output" >&2
    exit 1
  fi
}

demo_design() {
  local verdict="${1:-aligned}"
  local source="${2:-mixed}"
  local open_questions="${3:-none}"
  local confirmation="${4:-user-confirmed}"
  cat <<EOF
# Design

## API / Permission / Auth Decisions

Decision Status: accepted

| Item | Decision | Evidence / Reason |
|---|---|---|
| REST Path | unchanged | README.md documents no public API change |
| HTTP Method | unchanged | No endpoint behavior changes |
| Permission Code | not-applicable | No permission model touched |
| SaCheckPermission | not-applicable | No controller permission annotation touched |
| Anonymous Interface | not-applicable | No anonymous interface change |
| Login/Token | unchanged | No auth/session behavior change |
| Tenant/Data Permission | unchanged | No tenant/data scope change |
| State Machine Impact | no | No workflow/status transition touched |

State Machine Impact: no

## Design Alignment / Grill

Alignment Source: $source

Open Questions: $open_questions

| Question | AI Recommended Answer | Confirmation | Final Decision |
|---|---|---|---|
| Intent Risk | Demo intent is limited to README evidence. | $confirmation | Keep scope limited. |
| Existing Code Fit | Reuse README and existing scripts. | $confirmation | No new abstraction. |
| Unnecessary Abstraction | No abstraction is needed. | $confirmation | Do not add one. |
| Protected Areas | No protected area is touched. | $confirmation | Continue. |
| Boundary And Failure Modes | Failure is limited to test fixture behavior. | $confirmation | Verify with scripts. |

Alignment Verdict: $verdict

Skip Reason:

## AC Trace

| AC | Coverage |
|---|---|
| AC-01 | Demo design covers the README-only change. |
EOF
}

demo_plan() {
  cat <<'EOF'
# Plan

> Plan Status: planned
> Last Reviewed: 2026-06-10
> Source: agent-flow/changes/demo-closure/CHANGE.md

## Current Baseline

README.md and existing agent-flow scripts are the baseline.

## Goals

- Prove the gate chain can close a demo Heavy change.

## Non-Goals

- No production code behavior changes.

## Execution Phases

### Phase 1 - Demo verification

Status: planned

Scope:

- Update only declared demo files.

read_files:

- README.md

write_files:

- README.md

Exit Criteria:

- AC-01 has evidence.

Verification:

- Run check-change.

## Closure Gates

- [x] CODE_SCAN complete
- [x] DESIGN reviewed
- [x] design-check passed
- [x] alignment-check passed or explicitly skipped
- [x] TASKS bounded by read/write files
- [x] Plan Audit completed and plan-check passed
- [x] Verification passed
- [x] AC evidence recorded
- [x] Drift checks passed or adjudicated
- [x] Closure audit acceptable
- [x] Knowledge/decision/log/baseline updated

## Risks

- Test-only fixture risk.

## Protected Area Review

| Area | Touched | Approval / Reason |
|---|---|---|
| API/Auth/Permission | no | not-applicable |

## Deferred But Adjudicated

| Item | Classification | Reason |
|---|---|---|
| none | not-applicable | no deferred item |
EOF
}

demo_audit() {
  cat <<'EOF'
# Audit

## Plan Audit

Verdict: accept

Reviewer: self-test

Date: 2026-06-10

Checklist:

- [x] Current baseline checked against live code
- [x] Goals and Non-Goals clear
- [x] Code scan complete
- [x] Design check passed
- [x] Design Alignment completed
- [x] Protected areas identified
- [x] read_files/write_files bounded
- [x] Exit criteria verifiable
- [x] Risks mitigated

Findings:

- Plan accepted for self-test.

## Closure Audit

Verdict: acceptable

Reviewer: self-test

Date: 2026-06-10

Checklist:

- [x] Closure gates passed
- [x] Verification evidence recorded
- [x] AC coverage has evidence
- [x] scan-check completed
- [x] design-check completed
- [x] alignment-check completed
- [x] task-check completed
- [x] plan-check completed for Heavy changes
- [x] Drift checks completed
- [x] No undeclared files modified
- [x] task-boundary-check completed
- [x] manifest-check completed
- [x] emergency-check completed or explicitly skipped
- [x] blocked-check completed
- [x] evolution-check completed
- [x] closure-check completed
- [x] Knowledge/decision/log/baseline updated

Findings:

- Closure accepted for self-test.
EOF
}

assert_next_stage() {
  local target_root="$1"
  local expected_stage="$2"
  local change_dir="$target_root/agent-flow/changes/demo-next-step"
  mkdir -p "$change_dir"
  cat > "$change_dir/CHANGE.md" <<'EOF'
# Change

- [ ] Light
- [x] Standard
- [ ] Heavy

## Summary

Demo change for next-step self-test.
EOF
  cat > "$change_dir/CODE_SCAN.md" <<'EOF'
# Code Scan

Relevant code was scanned for the demo change.
EOF
  cat > "$change_dir/STATE.md" <<'EOF'
# State

change_id: demo-next-step
flow: Standard
current_stage: intake
blocked: false
next_action: Complete REQUIREMENT.md with AC-01 style acceptance criteria.
EOF

  local output
  output="$(bash "$target_root/agent-flow/scripts/next-step.sh" --change-dir "$change_dir")"
  printf '%s\n' "$output" | grep -q "\"stage\": \"$expected_stage\""
  printf '%s\n' "$output" | grep -q '"state_current_stage":'
  printf '%s\n' "$output" | grep -q "\"next_prompt\":"
  bash "$target_root/agent-flow/scripts/sync-state.sh" --change-dir "$change_dir"
  bash "$target_root/agent-flow/scripts/state-check.sh" --change-dir "$change_dir" --expected-stage "$expected_stage"
}

assert_design_alignment_stage() {
  local target_root="$1"
  local change_dir="$target_root/agent-flow/changes/demo-design-alignment"
  mkdir -p "$change_dir"
  cat > "$change_dir/CHANGE.md" <<'EOF'
# Change

- [ ] Light
- [x] Standard
- [ ] Heavy

## Summary

Demo change for design alignment self-test.
EOF
  printf '# Code Scan\n\nRelevant code was scanned.\n' > "$change_dir/CODE_SCAN.md"
  printf '# Requirement\n\n## Acceptance Criteria\n\n- AC-01: Demo criterion.\n' > "$change_dir/REQUIREMENT.md"
  demo_design pending pending pending pending > "$change_dir/DESIGN.md"

  local output
  output="$(bash "$target_root/agent-flow/scripts/next-step.sh" --change-dir "$change_dir")"
  printf '%s\n' "$output" | grep -q '"stage": "design-alignment"'
  printf '%s\n' "$output" | grep -q 'Design Alignment'
}

assert_new_change_and_alignment() {
  local target_root="$1"
  local change_root="$target_root/agent-flow/changes"
  bash "$target_root/agent-flow/scripts/new-change.sh" \
    --name "Demo Heavy Change" \
    --flow Heavy \
    --changes-root "$change_root" \
    --template-root "$target_root/agent-flow/templates"

  local change_dir
  change_dir="$(find "$change_root" -maxdepth 1 -type d -name '*demo-heavy-change' | sort | tail -n 1)"
  [ -n "$change_dir" ] || fail "new-change did not create a demo-heavy-change directory."
  assert_path "$change_dir/STATE.md"
  assert_path "$change_dir/CHANGE.md"
  assert_path "$change_dir/REVIEW.md"
  assert_path "$change_dir/AUDIT.md"
  grep -Eq '\[x\][[:space:]]+Heavy' "$change_dir/CHANGE.md"

  demo_design > "$change_dir/DESIGN.md"
  bash "$target_root/agent-flow/scripts/design-check.sh" --change-dir "$change_dir"
  bash "$target_root/agent-flow/scripts/alignment-check.sh" --change-dir "$change_dir"
}

assert_gate_scripts() {
  local target_root="$1"
  local change_dir="$target_root/agent-flow/changes/demo-gates"
  mkdir -p "$change_dir"
  printf '# Change\n\n- [ ] Light\n- [x] Standard\n- [ ] Heavy\n' > "$change_dir/CHANGE.md"
  cat > "$change_dir/CODE_SCAN.md" <<'EOF'
# Code Scan

## 扫描时间
2026-06-10 10:00

## Machine Check
scan_time: 2026-06-10 10:00
related_modules: README.md
similar_implementations: README.md
reusable_abstractions: README contract
test_baseline: scripts/test-starter.sh
read_files: README.md
write_files: README.md
open_questions: none

## 相关模块
- README.md

## 相似实现
| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| demo | `README.md` | existing entry pattern |

## 可复用抽象
- README contract.

## 禁止重复实现
- No duplicate entry module.

## 测试基线
- scripts/test-starter.sh

## read_files
read_files:
  - README.md

## write_files
write_files:
  - README.md

## 未决问题
- none
EOF
  printf '# Requirement\n\n- AC-01: Demo criterion.\n' > "$change_dir/REQUIREMENT.md"
  demo_design > "$change_dir/DESIGN.md"
  cat > "$change_dir/TASKS.md" <<'EOF'
# Tasks

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel |
|---|---|---|---|---|---|---|
| T001 | pending | AC-01 | `src/index.ts` | `README.md` | manual review | no |

## write_files 汇总

write_files:
  - README.md
EOF

  bash "$target_root/agent-flow/scripts/scan-check.sh" --change-dir "$change_dir"
  bash "$target_root/agent-flow/scripts/task-check.sh" --change-dir "$change_dir"
  bash "$target_root/agent-flow/scripts/design-check.sh" --change-dir "$change_dir"
  bash "$target_root/agent-flow/scripts/alignment-check.sh" --change-dir "$change_dir"

  local negative_scan="$target_root/agent-flow/changes/demo-negative-scan"
  mkdir -p "$negative_scan"
  printf '# Change\n\n- [ ] Light\n- [x] Standard\n- [ ] Heavy\n' > "$negative_scan/CHANGE.md"
  printf '# Code Scan\n\nscan_time: 2026-06-10 10:00\nread_files: README.md\n' > "$negative_scan/CODE_SCAN.md"
  expect_failure "scan-check negative case" "write_files" \
    bash "$target_root/agent-flow/scripts/scan-check.sh" --change-dir "$negative_scan"

  local negative_design="$target_root/agent-flow/changes/demo-negative-design"
  mkdir -p "$negative_design"
  printf '# Change\n\n- [ ] Light\n- [x] Standard\n- [ ] Heavy\n' > "$negative_design/CHANGE.md"
  demo_design | sed 's/Decision Status: accepted/Decision Status: pending/' > "$negative_design/DESIGN.md"
  expect_failure "design-check negative case" "Decision Status" \
    bash "$target_root/agent-flow/scripts/design-check.sh" --change-dir "$negative_design"

  local negative_alignment="$target_root/agent-flow/changes/demo-negative-alignment"
  mkdir -p "$negative_alignment"
  printf '# Change\n\n- [ ] Light\n- [x] Standard\n- [ ] Heavy\n' > "$negative_alignment/CHANGE.md"
  demo_design pending pending pending pending > "$negative_alignment/DESIGN.md"
  expect_failure "alignment-check negative case" "Alignment Verdict" \
    bash "$target_root/agent-flow/scripts/alignment-check.sh" --change-dir "$negative_alignment"

  local legacy_alignment="$target_root/agent-flow/changes/demo-legacy-alignment"
  mkdir -p "$legacy_alignment"
  printf '# Change\n\n- [ ] Light\n- [x] Standard\n- [ ] Heavy\n' > "$legacy_alignment/CHANGE.md"
  demo_design aligned mixed none confirmed > "$legacy_alignment/DESIGN.md"
  expect_failure "alignment-check legacy confirmation negative case" "user-confirmed" \
    bash "$target_root/agent-flow/scripts/alignment-check.sh" --change-dir "$legacy_alignment"

  local code_only_alignment="$target_root/agent-flow/changes/demo-code-only-alignment"
  mkdir -p "$code_only_alignment"
  printf '# Change\n\n- [ ] Light\n- [x] Standard\n- [ ] Heavy\n' > "$code_only_alignment/CHANGE.md"
  demo_design aligned code-confirmed none code-confirmed > "$code_only_alignment/DESIGN.md"
  expect_failure "alignment-check code-only negative case" "at least 3 user-confirmed" \
    bash "$target_root/agent-flow/scripts/alignment-check.sh" --change-dir "$code_only_alignment"

  mkdir -p "$change_dir/empty-evidence"
  expect_failure "ac-check missing VERIFY negative case" "VERIFY.md" \
    bash "$target_root/agent-flow/scripts/ac-check.sh" --change-dir "$change_dir" --test-root "$change_dir/empty-evidence"

  cat > "$change_dir/VERIFY.md" <<'EOF'
# Verify

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | Demo criterion | manual | | pass | none |
EOF
  expect_failure "ac-check incomplete evidence negative case" "Evidence Location" \
    bash "$target_root/agent-flow/scripts/ac-check.sh" --change-dir "$change_dir" --test-root "$change_dir"

  cat > "$change_dir/VERIFY.md" <<'EOF'
# Verify

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | Demo criterion | manual | VERIFY.md | pass | none |

## Coverage Summary

| Metric | Source | Value | Result | Notes |
|---|---|---|---|---|
| AC Coverage | coverage-check | auto | pass | self-test |
| Test Coverage | N/A | N/A | skipped | self-test has no product coverage target |
EOF
  bash "$target_root/agent-flow/scripts/ac-check.sh" --change-dir "$change_dir" --test-root "$change_dir"
  bash "$target_root/agent-flow/scripts/coverage-check.sh" --change-dir "$change_dir"
  bash "$target_root/agent-flow/scripts/blocked-check.sh" --change-dir "$change_dir" --project-root "$target_root"
  bash "$target_root/agent-flow/scripts/code-drift-check.sh" --change-dir "$change_dir" --project-root "$target_root"

  local negative_drift="$target_root/agent-flow/changes/demo-negative-drift"
  mkdir -p "$negative_drift" "$target_root/schema"
  printf '# Design\n\nCREATE TABLE missing_agent_flow_demo (id int);\n' > "$negative_drift/DESIGN.md"
  printf 'CREATE TABLE existing_demo (id int);\n' > "$target_root/schema/existing.sql"
  expect_failure "code-drift-check negative case" "SCHEMA_DRIFT" \
    bash "$target_root/agent-flow/scripts/code-drift-check.sh" --change-dir "$negative_drift" --project-root "$target_root"

  local negative_blocked="$target_root/agent-flow/changes/demo-negative-blocked"
  mkdir -p "$negative_blocked"
  printf '# Tasks\n\nwrite_files:\n  - README.md\n' > "$negative_blocked/TASKS.md"
  printf '# Design\n\nDELETE FROM users WHERE id = 1;\n' > "$negative_blocked/DESIGN.md"
  expect_failure "blocked-check negative case" "hard_delete_without_approval" \
    bash "$target_root/agent-flow/scripts/blocked-check.sh" --change-dir "$negative_blocked" --project-root "$target_root"

  local rule_id_only="$target_root/agent-flow/changes/demo-rule-id-only"
  mkdir -p "$rule_id_only"
  printf '# Tasks\n\nwrite_files:\n  - README.md\n' > "$rule_id_only/TASKS.md"
  printf '# Design\n\nThe manifest keeps a payment_bypass blocked rule.\n' > "$rule_id_only/DESIGN.md"
  bash "$target_root/agent-flow/scripts/blocked-check.sh" --change-dir "$rule_id_only" --project-root "$target_root" >/dev/null

  local guard_script_only="$target_root/agent-flow/changes/demo-guard-script-only"
  mkdir -p "$guard_script_only"
  printf '# Tasks\n\nwrite_files:\n  - agent-flow/scripts/blocked-check.sh\n' > "$guard_script_only/TASKS.md"
  printf '# Design\n\nUpdate blocked-check guard patterns.\n' > "$guard_script_only/DESIGN.md"
  bash "$target_root/agent-flow/scripts/blocked-check.sh" --change-dir "$guard_script_only" --project-root "$target_root" >/dev/null

  cat > "$change_dir/EVOLUTION.md" <<'EOF'
# Evolution

## Machine Check
problem: none
knowledge: none
adr: none
gate: none
template: none
no_change_reason: no change needed

## 本次 change 暴露的问题
- none

## 应写入 knowledge 的内容
- none

## 应新增或修改的 ADR
- none

## 应新增的 gate
- none

## 应调整的模板
- none

## 本次不调整的原因
- no change needed
EOF
  bash "$target_root/agent-flow/scripts/evolution-check.sh" --change-dir "$change_dir"
}

assert_task_boundary() {
  local target_root="$1"
  (
    cd "$target_root"
    git init -q
    git config user.email "agent-flow@example.invalid"
    git config user.name "agent-flow test"
    git config core.autocrlf false
    git add -A >/dev/null
    git commit -m "baseline" >/dev/null
  )

  local change_dir="$target_root/agent-flow/changes/demo-boundary"
  mkdir -p "$change_dir"
  printf '# Tasks\n\nwrite_files:\n  - README.md\n' > "$change_dir/TASKS.md"
  printf '\nDeclared change.\n' >> "$target_root/README.md"
  bash "$target_root/agent-flow/scripts/task-boundary-check.sh" --change-dir "$change_dir" --project-root "$target_root"

  printf '\n' >> "$target_root/package.json"
  if bash "$target_root/agent-flow/scripts/task-boundary-check.sh" --change-dir "$change_dir" --project-root "$target_root" >/dev/null 2>&1; then
    echo "task-boundary-check did not reject undeclared package.json change." >&2
    exit 1
  fi
  (
    cd "$target_root"
    git add -A >/dev/null
    git commit -m "after boundary smoke" >/dev/null
  )
}

assert_closure_check() {
  local target_root="$1"
  local change_dir="$target_root/agent-flow/changes/demo-closure"
  mkdir -p "$change_dir"
  printf '# Change\n\n- [ ] Light\n- [ ] Standard\n- [x] Heavy\n' > "$change_dir/CHANGE.md"
  printf '# State\n\nchange_id: demo-closure\nflow: Heavy\ncurrent_stage: closure-audit\nblocked: false\nnext_action: Run Closure Audit.\n' > "$change_dir/STATE.md"
  cat > "$change_dir/CODE_SCAN.md" <<'EOF'
# Code Scan

## 扫描时间
2026-06-10 10:00

## Machine Check
scan_time: 2026-06-10 10:00
related_modules: README.md
similar_implementations: README.md
reusable_abstractions: README contract
test_baseline: scripts/test-starter.sh
read_files: README.md
write_files: README.md
open_questions: none

## 相关模块
- README.md

## 相似实现
| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| demo | `README.md` | existing entry pattern |

## 可复用抽象
- README contract.

## 禁止重复实现
- No duplicate entry module.

## 测试基线
- scripts/test-starter.sh

## read_files
read_files:
  - README.md

## write_files
write_files:
  - README.md

## 未决问题
- none
EOF
  printf '# Requirement\n\n- AC-01: Demo.\n' > "$change_dir/REQUIREMENT.md"
  demo_design > "$change_dir/DESIGN.md"
  demo_plan > "$change_dir/PLAN.md"
  cat > "$change_dir/TASKS.md" <<'EOF'
# Tasks

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel |
|---|---|---|---|---|---|---|
| T001 | completed | AC-01 | `README.md` | `README.md` | manual review | no |

## write_files 汇总

write_files:
  - README.md
EOF
  cat > "$change_dir/VERIFY.md" <<'EOF'
# Verify

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | Demo | manual | VERIFY.md | pass | none |

## Coverage Summary

| Metric | Source | Value | Result | Notes |
|---|---|---|---|---|
| AC Coverage | coverage-check.sh | auto | pass | AC-01 has evidence |
| Test Coverage | N/A | N/A | skipped | self-test has no product coverage target |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scan-check | Heavy | pass | scan-check.sh --strict | 0 | 2026-06-10 10:00 | strict scan passed |
| design-check | Heavy | pass | design-check.sh | 0 | 2026-06-10 10:00 | decisions accepted |
| alignment-check | Heavy | pass | alignment-check.sh | 0 | 2026-06-10 10:00 | alignment confirmed |
| task-check | Heavy | pass | task-check.sh | 0 | 2026-06-10 10:00 | T001 maps to AC-01 |
| plan-check | Heavy | pass | plan-check.sh | 0 | 2026-06-10 10:00 | plan audit accepted |
| ac-check | Heavy | pass | ac-check.sh | 0 | 2026-06-10 10:00 | AC-01 evidence present |
| coverage-check | Heavy | pass | coverage-check.sh | 0 | 2026-06-10 10:00 | AC coverage 1/1; Test Coverage skipped with reason |
| code-drift-check | Heavy | pass | code-drift-check.sh | 0 | 2026-06-10 10:00 | no drift |
| blocked-check | Heavy | pass | blocked-check.sh | 0 | 2026-06-10 10:00 | no blocked operations |
| task-boundary-check | Heavy | pass | task-boundary-check.sh | 0 | 2026-06-10 10:00 | only change folder modified |
| manifest-check | all closure | pass | manifest-check.sh | 0 | 2026-06-10 10:00 | manifest valid |
| emergency-check | Heavy closure summary | skipped | emergency-check.sh | 0 | 2026-06-10 10:00 | not an Emergency change |
| evolution-check | Heavy | pass | evolution-check.sh | 0 | 2026-06-10 10:00 | no change needed recorded |
EOF
  printf '# Review\n\nReviewed.\n' > "$change_dir/REVIEW.md"
  printf '# Report\n\nDone. AC-01 is covered by the demo closure evidence.\n' > "$change_dir/REPORT.md"
  cat > "$change_dir/EVOLUTION.md" <<'EOF'
# Evolution

## Machine Check
problem: none
knowledge: none
adr: none
gate: none
template: none
no_change_reason: no change needed

## 本次 change 暴露的问题
- none

## 应写入 knowledge 的内容
- none

## 应新增或修改的 ADR
- none

## 应新增的 gate
- none

## 应调整的模板
- none

## 本次不调整的原因
- no change needed
EOF
  demo_audit > "$change_dir/AUDIT.md"
  bash "$target_root/agent-flow/scripts/closure-check.sh" --change-dir "$change_dir" --project-root "$target_root"
  local check_result="$change_dir/CHECK_RESULT.json"
  bash "$target_root/agent-flow/scripts/check-change.sh" --change-dir "$change_dir" --project-root "$target_root" --closure --output "$check_result"
  grep -q '"passed": true' "$check_result"
  grep -q '"gate":"emergency-check"' "$check_result"

  local missing_closure="$target_root/agent-flow/changes/demo-missing-closure"
  mkdir -p "$missing_closure"
  printf '# Change\n\n- [ ] Light\n- [ ] Standard\n- [x] Heavy\n' > "$missing_closure/CHANGE.md"
  printf '# State\n\nchange_id: demo-missing-closure\nflow: Heavy\ncurrent_stage: closure-audit\nblocked: false\nnext_action: Run Closure Audit.\n' > "$missing_closure/STATE.md"
  printf '# Code Scan\n\nscan_time: 2026-06-10 10:00\nrelated_modules: README.md\nsimilar_implementations: README.md\nreusable_abstractions: README.md\ntest_baseline: manual\nread_files: README.md\nwrite_files: README.md\nopen_questions: none\n' > "$missing_closure/CODE_SCAN.md"
  printf '# Verify\n\n## AC Evidence\n' > "$missing_closure/VERIFY.md"
  printf '# Report\n' > "$missing_closure/REPORT.md"
  expect_failure "check-change closure required artifact negative case" "closure-required-artifacts" \
    bash "$target_root/agent-flow/scripts/check-change.sh" --change-dir "$missing_closure" --project-root "$target_root" --closure
}

echo "== scaffold health =="
bash "$starter_root/agent-flow/scripts/scaffold-health.sh"
bash "$starter_root/agent-flow/scripts/template-check.sh"
if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -File "$starter_root/agent-flow/scripts/scaffold-health.ps1"
  pwsh -NoProfile -File "$starter_root/agent-flow/scripts/template-check.ps1"
fi

echo "== syntax =="
find "$starter_root/agent-flow/scripts" "$starter_root/scripts" -name '*.sh' -print0 | xargs -0 -n1 bash -n

echo "== install empty target =="
mkdir -p "$empty_target"
bash "$starter_root/scripts/install-agent-flow.sh" --target "$empty_target"
assert_path "$empty_target/AGENTS.md"
assert_path "$empty_target/agent-flow/GO.md"
assert_path "$empty_target/agent-flow/scripts/next-step.ps1"
assert_path "$empty_target/agent-flow/scripts/next-step.sh"
assert_path "$empty_target/agent-flow/scripts/sync-state.ps1"
assert_path "$empty_target/agent-flow/scripts/sync-state.sh"
assert_path "$empty_target/agent-flow/scripts/state-check.ps1"
assert_path "$empty_target/agent-flow/scripts/state-check.sh"
assert_path "$empty_target/agent-flow/scripts/scan-check.ps1"
assert_path "$empty_target/agent-flow/scripts/scan-check.sh"
assert_path "$empty_target/agent-flow/scripts/task-check.ps1"
assert_path "$empty_target/agent-flow/scripts/task-check.sh"
assert_path "$empty_target/agent-flow/scripts/task-boundary-check.ps1"
assert_path "$empty_target/agent-flow/scripts/task-boundary-check.sh"
assert_path "$empty_target/agent-flow/scripts/manifest-check.ps1"
assert_path "$empty_target/agent-flow/scripts/manifest-check.sh"
assert_path "$empty_target/agent-flow/scripts/emergency-check.ps1"
assert_path "$empty_target/agent-flow/scripts/emergency-check.sh"
assert_path "$empty_target/agent-flow/scripts/evolution-check.ps1"
assert_path "$empty_target/agent-flow/scripts/evolution-check.sh"
assert_path "$empty_target/agent-flow/scripts/closure-check.ps1"
assert_path "$empty_target/agent-flow/scripts/closure-check.sh"
assert_path "$empty_target/agent-flow/scripts/check-change.ps1"
assert_path "$empty_target/agent-flow/scripts/check-change.sh"
assert_path "$empty_target/agent-flow/scripts/coverage-check.ps1"
assert_path "$empty_target/agent-flow/scripts/coverage-check.sh"
assert_path "$empty_target/agent-flow/scripts/template-check.ps1"
assert_path "$empty_target/agent-flow/scripts/template-check.sh"
assert_path "$empty_target/agent-flow/scripts/knowledge-search.ps1"
assert_path "$empty_target/agent-flow/scripts/knowledge-search.sh"
assert_path "$empty_target/agent-flow/scripts/new-change.ps1"
assert_path "$empty_target/agent-flow/scripts/new-change.sh"
assert_path "$empty_target/agent-flow/scripts/alignment-check.ps1"
assert_path "$empty_target/agent-flow/scripts/alignment-check.sh"
assert_clean_history_dirs "$empty_target"
bash "$empty_target/agent-flow/scripts/init-project.sh" --target "$empty_target"
bash "$empty_target/agent-flow/scripts/manifest-check.sh" --project-root "$empty_target"
for placeholder in TODO_BACKEND_ENTRY TODO_COMMON_CODE_PATH TODO_BUSINESS_MODULE_PATH TODO_TEST_PATH TODO_SQL_PATH; do
  if ! grep -q "$placeholder" "$empty_target/agent-flow/manifest.yaml"; then
    echo "Expected bash init manifest placeholder missing: $placeholder" >&2
    exit 1
  fi
done
printf "Write-Host 'unregistered'\n" > "$empty_target/agent-flow/scripts/unregistered-demo.ps1"
printf '#!/usr/bin/env bash\necho unregistered\n' > "$empty_target/agent-flow/scripts/unregistered-demo.sh"
expect_failure "manifest-check public script registry negative case" "Public script missing from gate registry" \
  bash "$empty_target/agent-flow/scripts/manifest-check.sh" --project-root "$empty_target"
rm -f "$empty_target/agent-flow/scripts/unregistered-demo.ps1" "$empty_target/agent-flow/scripts/unregistered-demo.sh"
bash "$empty_target/agent-flow/scripts/manifest-check.sh" --project-root "$empty_target"
bash "$empty_target/agent-flow/scripts/run-verify.sh" --all
assert_next_stage "$empty_target" "requirement"
assert_design_alignment_stage "$empty_target"
assert_new_change_and_alignment "$empty_target"
assert_gate_scripts "$empty_target"
assert_task_boundary "$empty_target"
assert_closure_check "$empty_target"

echo "== update existing AGENTS.md =="
mkdir -p "$update_target"
cat > "$update_target/AGENTS.md" <<'EOF'
# Existing Rules

keep me

<!-- agent-flow:start -->
old block
<!-- agent-flow:end -->
EOF
bash "$starter_root/scripts/install-agent-flow.sh" --target "$update_target"
grep -q "keep me" "$update_target/AGENTS.md"
if grep -q "old block" "$update_target/AGENTS.md"; then
  echo "Old agent-flow block was not replaced." >&2
  exit 1
fi
grep -q "agent-flow/GO.md" "$update_target/AGENTS.md"

echo "== residue scan =="
if rg -n "ops-pilot|RuoYi|ruoyi|ops-ai|ops-flow|ops-asset|ops-monitor|ops-workflow|inbound|入库|BusinessStatusEnum|wf_business_status" "$starter_root" --glob "!scripts/test-starter.*"; then
  echo "Project-specific residue found." >&2
  exit 1
fi

tracked_history="$(git -C "$starter_root" ls-files -- agent-flow/changes agent-flow/logs agent-flow/reports)"
unexpected_history="$(
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    case "$path" in
      agent-flow/changes/.gitkeep|agent-flow/logs/.gitkeep|agent-flow/reports/.gitkeep) continue ;;
    esac
    if [ -e "$starter_root/$path" ]; then
      printf '%s\n' "$path"
    fi
  done <<EOF
$tracked_history
EOF
)"
if [ -n "$unexpected_history" ]; then
  echo "Starter must not track run-history files outside .gitkeep:" >&2
  printf '%s\n' "$unexpected_history" >&2
  exit 1
fi

echo "== docs/examples =="
assert_path "$starter_root/docs/ADOPTION.md"
assert_path "$starter_root/docs/PROMPTS.md"
assert_path "$starter_root/docs/TROUBLESHOOTING.md"
assert_path "$starter_root/examples/sample-change/VERIFY.md"
assert_path "$starter_root/.github/workflows/scaffold-ci.yml"
if [ -e "$starter_root/.github/workflows/agent-flow-starter-check.yml" ]; then
  echo "Duplicate starter self-test workflow should not exist." >&2
  exit 1
fi

echo "agent-flow starter self-test passed."
