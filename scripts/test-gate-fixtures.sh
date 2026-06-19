#!/usr/bin/env bash
#
# Run gate fixture tests for blocked-check.
# Creates temp change directories with known-violating content.
#
# Usage: bash scripts/test-gate-fixtures.sh
#

set -euo pipefail

starter_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temp_parent="$(mktemp -d)"
temp_root="$temp_parent/gate-fixture-test"
project_root="$temp_root/project"
passed=0
failed=0
mkdir -p "$project_root/agent-flow"
cp "$starter_root/agent-flow/manifest.yaml" "$project_root/agent-flow/manifest.yaml"

cleanup() {
  rm -rf "$temp_parent" 2>/dev/null || true
}
trap cleanup EXIT

test_case() {
  local name="$1" expected_match="$2" should_fail="$3"
  local change_dir="$temp_root/$(echo "$name" | tr ' /' '-')"
  mkdir -p "$change_dir"

  echo "Test: $name"

  # Call the setup function (passed via eval)
  if ! eval "setup_$(echo "$name" | tr ' /' '_')"; then
    echo "  ❌ SETUP FAILED"
    failed=$((failed + 1))
    return
  fi

  local output
  set +e
  output="$("$starter_root/agent-flow/scripts/blocked-check.sh" \
    --change-dir "$change_dir" \
    --project-root "$project_root" \
    --manifest "agent-flow/manifest.yaml" 2>&1)"
  local exit_code=$?
  set -e

  if [ "$should_fail" = true ]; then
    if echo "$output" | grep -q "$expected_match"; then
      echo "  ✅ PASS: blocked-check detected '$expected_match'"
      passed=$((passed + 1))
    else
      echo "  ❌ FAIL: Expected '$expected_match' but got exit $exit_code:"
      echo "$output" | sed 's/^/     /'
      failed=$((failed + 1))
    fi
  else
    if [ "$exit_code" -eq 0 ]; then
      echo "  ✅ PASS: blocked-check passed (exit 0)"
      passed=$((passed + 1))
    else
      echo "  ❌ FAIL: Expected pass but got exit $exit_code:"
      echo "$output" | sed 's/^/     /'
      failed=$((failed + 1))
    fi
  fi
}

# --- Scenario 1: hard_delete_without_approval ---
setup_hard-delete-detection() {
  cat > "$change_dir/TASKS.md" << 'EOF'
# Tasks
## Task Matrix
| Task | Status | AC | read_files | write_files | Verify | Parallel |
|------|--------|----|------------|-------------|--------|----------|
| T001 | pending | AC-01 | none | src/main/resources/db/migration/V1__cleanup.sql | manual | no |
write_files:
  - src/main/resources/db/migration/V1__cleanup.sql
EOF
  mkdir -p "$project_root/src/main/resources/db/migration"
  cat > "$project_root/src/main/resources/db/migration/V1__cleanup.sql" << 'EOF'
DELETE FROM users WHERE deleted_at IS NOT NULL;
EOF
}

# --- Scenario 2: clean change ---
setup_clean-change() {
  cat > "$change_dir/TASKS.md" << 'EOF'
# Tasks
## Task Matrix
| Task | Status | AC | read_files | write_files | Verify | Parallel |
|------|--------|----|------------|-------------|--------|----------|
| T001 | pending | AC-01 | none | src/main/resources/db/migration/V2__add_column.sql | manual | no |
write_files:
  - src/main/resources/db/migration/V2__add_column.sql
EOF
  mkdir -p "$project_root/src/main/resources/db/migration"
  cat > "$project_root/src/main/resources/db/migration/V2__add_column.sql" << 'EOF'
ALTER TABLE users ADD COLUMN display_name VARCHAR(255);
EOF
}

echo "=== blocked-check Gate Fixture Tests ==="
echo ""
test_case "hard-delete-detection" "hard_delete_without_approval" true
test_case "clean-change" "" false
echo ""
echo "=============================="
echo "Results: $passed passed, $failed failed"
[ "$failed" -eq 0 ] && echo "All gate fixture tests passed." || exit "$failed"
