#!/usr/bin/env bash
# Smoke test for new-change.sh using the minimal-project fixture.
# Tests that new-change creates the expected files for each flow level.
set -euo pipefail

test_root="$(cd "$(dirname "$0")/.." && pwd)"
fixture_dir="$test_root/fixtures/minimal-project"
scripts_dir="$(cd "$test_root/../scripts" && pwd)"

echo "=== Smoke test: new-change.sh ==="
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

change_dir_by_suffix() {
  local suffix="$1" match
  match="$(find "$fixture_af/changes" -maxdepth 1 -type d -name "*$suffix" | sort | tail -n 1)"
  [ -n "$match" ] || fail "Change directory with suffix '$suffix' was not created"
  printf '%s' "$match"
}

# --- Test 1: Light change ---
echo ""
echo "Test 1: Light change"
find "$fixture_af/changes" -maxdepth 1 -type d -name "*test-light" -exec rm -rf {} +

bash "$scripts_dir/new-change.sh" --name "test-light" --flow Light --changes-root "$fixture_af/changes" --force
change_dir="$(change_dir_by_suffix test-light)"

for f in "STATE.md" "CHANGE.md" "CODE_SCAN.md" "VERIFY.md" "REPORT.md"; do
  [ -f "$change_dir/$f" ] || fail "Light change missing $f"
done

grep -q "\[x\] Light" "$change_dir/CHANGE.md" || fail "Light change marker not set"
pass "Light change created 5 files, marker correct"
rm -rf "$change_dir"

# --- Test 2: Standard change ---
echo ""
echo "Test 2: Standard change"
find "$fixture_af/changes" -maxdepth 1 -type d -name "*test-standard" -exec rm -rf {} +

bash "$scripts_dir/new-change.sh" --name "test-standard" --flow Standard --changes-root "$fixture_af/changes" --force
change_dir="$(change_dir_by_suffix test-standard)"

for f in "STATE.md" "CHANGE.md" "REQUIREMENT.md" "CODE_SCAN.md" "DESIGN.md" "TASKS.md" "VERIFY.md" "REPORT.md" "EVOLUTION.md"; do
  [ -f "$change_dir/$f" ] || fail "Standard change missing $f"
done

grep -q "\[x\] Standard" "$change_dir/CHANGE.md" || fail "Standard change marker not set"
pass "Standard change created 9 files, marker correct"
rm -rf "$change_dir"

# --- Test 3: Heavy change ---
echo ""
echo "Test 3: Heavy change"
find "$fixture_af/changes" -maxdepth 1 -type d -name "*test-heavy" -exec rm -rf {} +

bash "$scripts_dir/new-change.sh" --name "test-heavy" --flow Heavy --changes-root "$fixture_af/changes" --force
change_dir="$(change_dir_by_suffix test-heavy)"

for f in "STATE.md" "CHANGE.md" "REQUIREMENT.md" "CODE_SCAN.md" "DESIGN.md" "PLAN.md" "TASKS.md" "VERIFY.md" "REVIEW.md" "REPORT.md" "AUDIT.md" "EVOLUTION.md"; do
  [ -f "$change_dir/$f" ] || fail "Heavy change missing $f"
done

grep -q "\[x\] Heavy" "$change_dir/CHANGE.md" || fail "Heavy change marker not set"
pass "Heavy change created 12 files, marker correct"
rm -rf "$change_dir"

# --- Test 4: Slug generation ---
echo ""
echo "Test 4: Slug generation"
find "$fixture_af/changes" -maxdepth 1 -type d -name "*anonymous-conversation" -exec rm -rf {} +

bash "$scripts_dir/new-change.sh" --name "Anonymous Conversation" --flow Light --changes-root "$fixture_af/changes" --force
change_dir="$(change_dir_by_suffix anonymous-conversation)"

[ -f "$change_dir/CHANGE.md" ] || fail "Change not created for 'Anonymous Conversation'"
pass "Slug generation correct: anonymous-conversation"
rm -rf "$change_dir"

# --- All tests passed ---
echo ""
echo "=== All smoke tests passed ==="
exit 0
