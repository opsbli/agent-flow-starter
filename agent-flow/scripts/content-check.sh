#!/usr/bin/env bash
# Validate that change artifacts contain meaningful content.
# With --project-root, also scan agent-flow/core/ and agent-flow/rules/ for placeholders.

set -euo pipefail

change_dir=""
project_root=""
strict=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir) change_dir="$2"; shift 2 ;;
    --project-root) project_root="$2"; shift 2 ;;
    --strict) strict=true; shift ;;
    -h|--help)
      echo "Usage: content-check.sh --change-dir <path> [--project-root <path>] [--strict]"
      echo ""
      echo "  --change-dir    Path to the change directory to scan artifacts"
      echo "  --project-root  Project root; when set, also scans agent-flow/core/ and rules/"
      echo "  --strict        Exit with error code if any check fails"
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/_common.sh"

# At least one mode must be active
if [ -z "$change_dir" ] && [ -z "$project_root" ]; then
  echo "Usage: content-check.sh --change-dir <path> [--project-root <path>] [--strict]" >&2
  echo "  Provide --change-dir, --project-root, or both." >&2
  exit 2
fi

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

if [ -n "$change_dir" ]; then
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
    refs="$(grep -cE '\`[^\`]+\.(java|ts|py|go|rs|kt|cs|sql|yaml|json|xml|ps1|sh)\`' "$change_dir/DESIGN.md" 2>/dev/null || echo 0)"
    if [ "$refs" -lt 3 ]; then
      issues+=("DESIGN.md: only $refs code reference(s); expected at least 3")
      fail=$((fail + 1))
    fi
  fi
fi

# ── Scaffold content check (when --project-root is provided) ──
scaffold_pass=0
scaffold_fail=0
scaffold_issues=()

check_scaffold_file() {
  local label="$1"
  local path="$2"

  if [ ! -f "$path" ]; then
    scaffold_issues+=("$label: missing")
    scaffold_fail=$((scaffold_fail + 1))
    return
  fi

  # Skip files that are known to contain doc examples matching placeholder patterns
  # (The pattern list should be kept minimal — only documented-valid cases)
  local basename
  basename="$(basename "$path")"
  case "$basename" in
    autonomy-policy.md|router.md)
      scaffold_pass=$((scaffold_pass + 1))
      echo "  PASS $label (doc example patterns excluded)"
      return
      ;;
  esac

  if meaningful_file "$path" "TODO" "TBD" "path/to" "{module}" "example"; then
    scaffold_pass=$((scaffold_pass + 1))
    echo "  PASS $label"
  else
    scaffold_issues+=("$label: contains placeholders or missing meaningful content")
    scaffold_fail=$((scaffold_fail + 1))
  fi
}

if [ -n "$project_root" ]; then
  echo ""
  echo "Scaffold content check (core/ and rules/)"
  echo "============================================================"

  core_dir="$project_root/agent-flow/core"
  rules_dir="$project_root/agent-flow/rules"
  [ -d "$core_dir" ] && for f in "$core_dir"/*.md; do
    [ -f "$f" ] && check_scaffold_file "core/$(basename "$f")" "$f"
  done
  [ -d "$rules_dir" ] && for f in "$rules_dir"/*.md "$rules_dir"/*.keys "$rules_dir"/*.questions "$rules_dir"/*.txt; do
    [ -f "$f" ] && check_scaffold_file "rules/$(basename "$f")" "$f"
  done

  scaffold_total=$((scaffold_pass + scaffold_fail))
  echo ""
  echo "Scaffold results: $scaffold_pass/$scaffold_total passed"
  if [ "$scaffold_fail" -gt 0 ]; then
    for issue in "${scaffold_issues[@]}"; do
      echo "    FAIL $issue"
    done
    fail=$((fail + scaffold_fail))
    issues+=("${scaffold_issues[@]}")
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
