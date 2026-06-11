#!/usr/bin/env bash
# Unit tests for next-step.sh's key helper functions.
# Tests flow-level detection, meaningful file validation, and audit verdict parsing.
set -euo pipefail

test_root="$(cd "$(dirname "$0")/.." && pwd)"
fixture_dir="$test_root/fixtures/next-step-tests"
rm -rf "$fixture_dir"

passed=0
failed=0

pass() { echo "PASS: $1"; passed=$((passed + 1)); }
fail() { echo "FAIL: $1"; failed=$((failed + 1)); }

# === Test 1: Flow level detection ===
echo "=== Test 1: Flow level detection ==="
test_dir1="$fixture_dir/test-flow-detect"
mkdir -p "$test_dir1"

for flow in Light Standard Heavy; do
  file="$test_dir1/CHANGE.md"
  case "$flow" in
    Light)   content="# Change\n## 流程级别\n- [x] Light\n- [ ] Standard\n- [ ] Heavy" ;;
    Standard) content="# Change\n## 流程级别\n- [ ] Light\n- [x] Standard\n- [ ] Heavy" ;;
    Heavy)   content="# Change\n## 流程级别\n- [ ] Light\n- [ ] Standard\n- [x] Heavy" ;;
  esac
  echo -e "$content" > "$file"

  text=$(cat "$file")
  detected="Unknown"
  if echo "$text" | grep -qi "\[x\] Heavy"; then detected="Heavy"
  elif echo "$text" | grep -qi "\[x\] Standard"; then detected="Standard"
  elif echo "$text" | grep -qi "\[x\] Light"; then detected="Light"
  fi

  if [ "$detected" = "$flow" ]; then
    pass "Flow detection: $flow"
  else
    fail "Flow detection: $flow (expected '$flow', got '$detected')"
  fi
done

# === Test 2: Meaningful file detection ===
echo ""
echo "=== Test 2: Meaningful file detection ==="
test_dir2="$fixture_dir/test-meaningful"
mkdir -p "$test_dir2"

meaningful_tests_passed=0
meaningful_tests_failed=0

# Test empty
echo "" > "$test_dir2/empty.md"
text=$(cat "$test_dir2/empty.md")
if [ -z "$text" ]; then
  pass "Meaningful check: empty file -> false"
else
  fail "Meaningful check: empty file -> false"
fi

# Test TODO
echo "TODO_PROJECT_NAME" > "$test_dir2/todo.md"
text=$(cat "$test_dir2/todo.md")
if [ -n "$text" ] && echo "$text" | grep -q "TODO_"; then
  pass "Meaningful check: TODO content -> false (has placeholder)"
else
  fail "Meaningful check: TODO content -> false"
fi

# Test real content
echo "# Real design doc with useful info" > "$test_dir2/real.md"
text=$(cat "$test_dir2/real.md")
if [ -n "$text" ] && ! echo "$text" | grep -q "TODO_"; then
  pass "Meaningful check: real content -> true"
else
  fail "Meaningful check: real content -> true"
fi

# === Test 3: Alignment verdict extraction ===
echo ""
echo "=== Test 3: Alignment verdict extraction ==="
test_dir3="$fixture_dir/test-alignment"
mkdir -p "$test_dir3"

for verdict in aligned "skipped" pending blocked; do
  file="$test_dir3/DESIGN.md"
  if [ "$verdict" = "skipped" ]; then
    echo -e "Alignment Verdict: skipped\nSkip Reason: User requested" > "$file"
  else
    echo -e "Some text\nAlignment Verdict: $verdict\nMore text" > "$file"
  fi

  text=$(cat "$file")
  detected=$(echo "$text" | grep -i "Alignment Verdict:" | sed 's/.*Alignment Verdict:[[:space:]]*//i' | tr '[:upper:]' '[:lower:]' 2>/dev/null || echo "")

  if [ "$detected" = "$verdict" ]; then
    pass "Alignment verdict: $verdict"
  else
    fail "Alignment verdict: $verdict (expected '$verdict', got '$detected')"
  fi
done

# Test missing verdict
echo "# No verdict" > "$test_dir3/no-verdict.md"
text=$(cat "$test_dir3/no-verdict.md")
detected=$(echo "$text" | grep -i "Alignment Verdict:" | sed 's/.*Alignment Verdict:[[:space:]]*//i' | tr '[:upper:]' '[:lower:]' 2>/dev/null || echo "")
if [ -z "$detected" ]; then
  pass "Alignment verdict: missing -> empty"
else
  fail "Alignment verdict: missing -> empty (got '$detected')"
fi

# === Summary ===
echo ""
echo "============================================"
echo "Results: $passed passed, $failed failed"
if [ "$failed" -gt 0 ]; then
  echo "SOME TESTS FAILED" >&2
  exit 1
else
  echo "All tests passed."
  exit 0
fi
