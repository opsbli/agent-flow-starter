#!/usr/bin/env bash
# Validate that change artifacts contain meaningful content.

set -euo pipefail

change_dir=""
strict=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir) change_dir="$2"; shift 2 ;;
    --strict) strict=true; shift ;;
    -h|--help)
      echo "Usage: content-check.sh --change-dir <path> [--strict]"
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

[ -n "$change_dir" ] || { echo "Usage: content-check.sh --change-dir <path>" >&2; exit 1; }
[ -d "$change_dir" ] || { echo "Directory not found: $change_dir" >&2; exit 1; }

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/_common.sh"

pass=0
fail=0
issues=()

check_artifact() {
  local name="$1"
  local required="${2:-false}"
  local path="$change_dir/$name"

  if [ ! -f "$path" ]; then
    if [ "$required" = true ]; then
      issues+=("$name: missing")
      fail=$((fail + 1))
    fi
    return
  fi

  if meaningful_file "$path" "TODO" "TBD" "path/to" "{module}" "example"; then
    pass=$((pass + 1))
    echo "  PASS $name"
  else
    issues+=("$name: missing meaningful content or contains placeholders")
    fail=$((fail + 1))
  fi
}

echo "Content quality check for: $(basename "$change_dir")"
echo "============================================================"

check_artifact "CHANGE.md" true
check_artifact "CODE_SCAN.md"
check_artifact "REQUIREMENT.md"
check_artifact "DESIGN.md"
check_artifact "TASKS.md"
check_artifact "VERIFY.md"

if [ -f "$change_dir/REQUIREMENT.md" ] && ! grep -Eq 'AC-[0-9]{2}' "$change_dir/REQUIREMENT.md"; then
  issues+=("REQUIREMENT.md: no AC-XX acceptance criteria found")
  fail=$((fail + 1))
fi

if [ -f "$change_dir/VERIFY.md" ] && ! grep -Eq 'AC-[0-9]{2}' "$change_dir/VERIFY.md"; then
  issues+=("VERIFY.md: no AC evidence rows found")
  fail=$((fail + 1))
fi

if [ -f "$change_dir/DESIGN.md" ]; then
  refs="$(grep -cE '`[^`]+\.(java|ts|py|go|rs|kt|cs|sql|yaml|json|xml|ps1|sh)`' "$change_dir/DESIGN.md" 2>/dev/null || echo 0)"
  if [ "$refs" -lt 3 ]; then
    issues+=("DESIGN.md: only $refs code reference(s); expected at least 3")
    fail=$((fail + 1))
  fi
fi

echo
echo "Results:"
echo "  Passed: $pass"
if [ "$fail" -gt 0 ]; then
  echo "  Failed: $fail"
  for issue in "${issues[@]}"; do
    echo "    FAIL $issue"
  done
  [ "$strict" = true ] && exit 2
else
  echo "  All content checks passed"
fi
