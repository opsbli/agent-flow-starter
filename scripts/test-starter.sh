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
current_stage: requirement
blocked: false
next_action: Complete REQUIREMENT.md with AC-01 style acceptance criteria.
EOF

  local output
  output="$(bash "$target_root/agent-flow/scripts/next-step.sh" --change-dir "$change_dir")"
  printf '%s\n' "$output" | grep -q "\"stage\": \"$expected_stage\""
  printf '%s\n' "$output" | grep -q '"state_current_stage":'
  printf '%s\n' "$output" | grep -q "\"next_prompt\":"
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
  printf '# Requirement\n\n- AC-01: Demo criterion.\n' > "$change_dir/REQUIREMENT.md"
  printf '# Design\n\nNo schema, permission, auth, workflow, or status change.\n' > "$change_dir/DESIGN.md"
  printf '# Tasks\n\nwrite_files:\n  - README.md\n' > "$change_dir/TASKS.md"

  if bash "$target_root/agent-flow/scripts/ac-check.sh" --change-dir "$change_dir" --test-root "$change_dir"; then
    echo "ac-check passed using REQUIREMENT.md as self-evidence." >&2
    exit 1
  fi

  printf '# Verify\n\nAC-01 evidence: checked.\n' > "$change_dir/VERIFY.md"
  bash "$target_root/agent-flow/scripts/ac-check.sh" --change-dir "$change_dir" --test-root "$change_dir"
  bash "$target_root/agent-flow/scripts/blocked-check.sh" --change-dir "$change_dir" --project-root "$target_root"
  bash "$target_root/agent-flow/scripts/code-drift-check.sh" --change-dir "$change_dir" --project-root "$target_root"
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
assert_path "$empty_target/agent-flow/scripts/state-check.ps1"
assert_path "$empty_target/agent-flow/scripts/state-check.sh"
assert_path "$empty_target/agent-flow/scripts/new-change.ps1"
assert_path "$empty_target/agent-flow/scripts/new-change.sh"
assert_path "$empty_target/agent-flow/scripts/alignment-check.ps1"
assert_path "$empty_target/agent-flow/scripts/alignment-check.sh"
bash "$empty_target/agent-flow/scripts/init-project.sh" --target "$empty_target"
bash "$empty_target/agent-flow/scripts/run-verify.sh" --all
assert_next_stage "$empty_target" "requirement"
assert_design_alignment_stage "$empty_target"
assert_new_change_and_alignment "$empty_target"
assert_gate_scripts "$empty_target"

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
