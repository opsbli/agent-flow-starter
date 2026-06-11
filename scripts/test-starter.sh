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
  printf '# Design\n\n## Design Alignment / Grill\n\nAlignment Verdict: pending\n' > "$change_dir/DESIGN.md"

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

  local change_dir="$change_root/demo-heavy-change"
  assert_path "$change_dir/STATE.md"
  assert_path "$change_dir/CHANGE.md"
  assert_path "$change_dir/REVIEW.md"
  assert_path "$change_dir/AUDIT.md"
  grep -Eq '\[x\][[:space:]]+Heavy' "$change_dir/CHANGE.md"

  sed -E 's/Alignment Verdict: pending/Alignment Verdict: aligned/' "$change_dir/DESIGN.md" > "$change_dir/DESIGN.md.tmp"
  mv "$change_dir/DESIGN.md.tmp" "$change_dir/DESIGN.md"
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
  printf '# Design\n\nNo schema, permission, auth, workflow, or status change.\n' > "$change_dir/DESIGN.md"
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

  mkdir -p "$change_dir/empty-evidence"
  if bash "$target_root/agent-flow/scripts/ac-check.sh" --change-dir "$change_dir" --test-root "$change_dir/empty-evidence"; then
    echo "ac-check passed using REQUIREMENT.md as self-evidence." >&2
    exit 1
  fi

  printf '# Verify\n\nAC-01 evidence: checked.\n' > "$change_dir/VERIFY.md"
  bash "$target_root/agent-flow/scripts/ac-check.sh" --change-dir "$change_dir" --test-root "$change_dir"
  bash "$target_root/agent-flow/scripts/blocked-check.sh" --change-dir "$change_dir" --project-root "$target_root"
  bash "$target_root/agent-flow/scripts/code-drift-check.sh" --change-dir "$change_dir" --project-root "$target_root"
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
  printf '# Design\n\nAlignment Verdict: aligned\n' > "$change_dir/DESIGN.md"
  printf '# Plan\n\nPlan.\n' > "$change_dir/PLAN.md"
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

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scan-check | Heavy | pass | scan-check.sh --strict | 0 | 2026-06-10 10:00 | strict scan passed |
| task-check | Heavy | pass | task-check.sh | 0 | 2026-06-10 10:00 | T001 maps to AC-01 |
| ac-check | Heavy | pass | ac-check.sh | 0 | 2026-06-10 10:00 | AC-01 evidence present |
| code-drift-check | Heavy | pass | code-drift-check.sh | 0 | 2026-06-10 10:00 | no drift |
| blocked-check | Heavy | pass | blocked-check.sh | 0 | 2026-06-10 10:00 | no blocked operations |
| task-boundary-check | Heavy | pass | task-boundary-check.sh | 0 | 2026-06-10 10:00 | only change folder modified |
| manifest-check | all closure | pass | manifest-check.sh | 0 | 2026-06-10 10:00 | manifest valid |
| emergency-check | Heavy closure summary | skipped | emergency-check.sh | 0 | 2026-06-10 10:00 | not an Emergency change |
| evolution-check | Heavy | pass | evolution-check.sh | 0 | 2026-06-10 10:00 | no change needed recorded |
EOF
  printf '# Review\n\nReviewed.\n' > "$change_dir/REVIEW.md"
  printf '# Report\n\nDone.\n' > "$change_dir/REPORT.md"
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
  printf '# Audit\n\n## Closure Audit\n\nVerdict: acceptable\n\nMachine Gate Summary accepted.\n' > "$change_dir/AUDIT.md"
  bash "$target_root/agent-flow/scripts/closure-check.sh" --change-dir "$change_dir" --project-root "$target_root"
  local check_result="$change_dir/CHECK_RESULT.json"
  bash "$target_root/agent-flow/scripts/check-change.sh" --change-dir "$change_dir" --project-root "$target_root" --closure --output "$check_result"
  grep -q '"passed": true' "$check_result"
  grep -q '"gate":"emergency-check"' "$check_result"
}

echo "== scaffold health =="
bash "$starter_root/agent-flow/scripts/scaffold-health.sh"
if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -File "$starter_root/agent-flow/scripts/scaffold-health.ps1"
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
assert_path "$empty_target/agent-flow/scripts/new-change.ps1"
assert_path "$empty_target/agent-flow/scripts/new-change.sh"
assert_path "$empty_target/agent-flow/scripts/alignment-check.ps1"
assert_path "$empty_target/agent-flow/scripts/alignment-check.sh"
bash "$empty_target/agent-flow/scripts/init-project.sh" --target "$empty_target"
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

echo "== docs/examples =="
assert_path "$starter_root/docs/ADOPTION.md"
assert_path "$starter_root/docs/PROMPTS.md"
assert_path "$starter_root/examples/sample-change/VERIFY.md"
assert_path "$starter_root/.github/workflows/scaffold-ci.yml"
assert_path "$starter_root/.github/workflows/agent-flow-starter-check.yml"

echo "agent-flow starter self-test passed."
