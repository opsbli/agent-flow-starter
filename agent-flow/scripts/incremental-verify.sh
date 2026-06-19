#!/usr/bin/env bash
# Run incremental verification: only checks relevant to recently changed files
set -euo pipefail

project_root="${1:-.}"
(
cd "$project_root"

changed_files=""
if [ -d ".git" ]; then
  changed_files="$(git diff --name-only && git diff --cached --name-only 2>/dev/null || true)"
fi

changed_count="$(printf '%s\n' "$changed_files" | grep -c . 2>/dev/null || echo 0)"
echo "Incremental Verify: $changed_count changed files"
[ -n "$changed_files" ] && printf '%s\n' "$changed_files" | sed 's/^/  /'

has_ts="$(printf '%s\n' "$changed_files" | grep -cE '\.(ts|tsx)$' 2>/dev/null || echo 0)"
has_js="$(printf '%s\n' "$changed_files" | grep -cE '\.(js|jsx)$' 2>/dev/null || echo 0)"
has_go="$(printf '%s\n' "$changed_files" | grep -cE '\.go$' 2>/dev/null || echo 0)"
has_rs="$(printf '%s\n' "$changed_files" | grep -cE '\.rs$' 2>/dev/null || echo 0)"
has_py="$(printf '%s\n' "$changed_files" | grep -cE '\.py$' 2>/dev/null || echo 0)"
has_config="$(printf '%s\n' "$changed_files" | grep -cE '(package\.json|tsconfig|eslint)' 2>/dev/null || echo 0)"

passed=0
failed=0

run_check() {
  local name="$1"; shift
  echo "  Running $name..."
  if "$@" 2>/dev/null; then
    echo "  [PASS] $name"
    passed=$((passed + 1))
  else
    echo "  [FAIL] $name"
    failed=$((failed + 1))
  fi
}

if [ "$has_ts" -gt 0 ] || [ "$has_config" -gt 0 ]; then
  [ -f tsconfig.json ] && run_check "TypeScript Check" npx tsc --noEmit
fi

if [ "$has_ts" -gt 0 ] || [ "$has_js" -gt 0 ]; then
  if ls .eslintrc* >/dev/null 2>&1; then
    run_check "ESLint" npx eslint --quiet $changed_files || true
  fi
fi

if [ "$has_go" -gt 0 ]; then
  run_check "Go Vet" go vet ./...
  run_check "Go Build" go build ./...
fi

if [ "$has_rs" -gt 0 ]; then
  run_check "Cargo Check" cargo check
fi

if [ "$has_py" -gt 0 ]; then
  py_check() {
    local ok=0 f
    for f in $changed_files; do
      python -m py_compile "$f" 2>/dev/null || ok=1
    done
    return "$ok"
  }
  run_check "Python Syntax" py_check
fi

if [ -n "$changed_files" ]; then
  sec_result="$(grep -lE 'sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{36,}|-----BEGIN.*PRIVATE KEY-----' $changed_files 2>/dev/null || true)"
  if [ -z "$sec_result" ]; then
    echo "  [PASS] Secrets Check"
    passed=$((passed + 1))
  else
    echo "  [FAIL] Secrets Check: found in: $sec_result"
    failed=$((failed + 1))
  fi
fi

echo
echo "=== Incremental Verify Results ==="
echo "  $passed passed, $failed failed"
if [ "$failed" -gt 0 ]; then
  echo "  [FAIL] Some checks failed. Fix before committing."
else
  echo "  [PASS] All checks passed."
fi
)
