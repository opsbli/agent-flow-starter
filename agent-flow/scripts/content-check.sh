#!/usr/bin/env bash
# Content quality gate — validates artifacts have meaningful content.
# Usage: bash agent-flow/scripts/content-check.sh --change-dir <path> [--strict]

set -euo pipefail

CHANGE_DIR=""
STRICT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --change-dir) CHANGE_DIR="$2"; shift 2 ;;
    --strict) STRICT=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

[ -n "$CHANGE_DIR" ] || { echo "Usage: $0 --change-dir <path>"; exit 1; }
[ -d "$CHANGE_DIR" ] || { echo "Directory not found: $CHANGE_DIR"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

PASS=0
FAIL=0
ISSUES=""

check_exists() {
  [ -f "$1" ] && return 0 || return 1
}

check_meaningful() {
  meaningful_file "$1" "TODO" "TBD" "path/to" "{module}"
}

check_code_refs() {
  local file="$1" min_refs="${2:-3}"
  local count
  count=$(grep -cE '`[^`]+\.(java|ts|py|go|rs|kt|cs|sql|yaml|json|xml|ps1|sh)`' "$file" 2>/dev/null || echo 0)
  [ "$count" -ge "$min_refs" ] && return 0 || return 1
}

echo -e "Content quality check for: $(basename "$CHANGE_DIR")"
echo "============================================================"

# CHANGE.md
if check_meaningful "$CHANGE_DIR/CHANGE.md"; then
  PASS=$((PASS + 1)); echo -e "  ${GREEN}✅ CHANGE.md${NC}"
else
  ISSUES="$ISSUES\n- CHANGE.md: missing or contains TODO/TBD"
  FAIL=$((FAIL + 1))
fi

# CODE_SCAN.md
[ -f "$CHANGE_DIR/CODE_SCAN.md" ] && {
  if check_meaningful "$CHANGE_DIR/CODE_SCAN.md"; then
    PASS=$((PASS + 1)); echo -e "  ${GREEN}✅ CODE_SCAN.md${NC}"
  else
    ISSUES="$ISSUES\n- CODE_SCAN.md: contains TODO/TBD"
    FAIL=$((FAIL + 1))
  fi
}

# REQUIREMENT.md
[ -f "$CHANGE_DIR/REQUIREMENT.md" ] && {
  AC_COUNT=$(grep -cE 'AC-[0-9]{2}' "$CHANGE_DIR/REQUIREMENT.md" 2>/dev/null || echo 0)
  if [ "$AC_COUNT" -gt 0 ]; then
    PASS=$((PASS + 1)); echo -e "  ${GREEN}✅ REQUIREMENT.md (${AC_COUNT} ACs)${NC}"
  else
    ISSUES="$ISSUES\n- REQUIREMENT.md: no AC-XX formatted criteria"
    FAIL=$((FAIL + 1))
  fi
}

# DESIGN.md (code evidence check)
[ -f "$CHANGE_DIR/DESIGN.md" ] && {
  REFS=$(grep -cE '`[^`]+\.(java|ts|py|go|rs|kt|cs|sql|yaml|json|xml|ps1|sh)`' "$CHANGE_DIR/DESIGN.md" 2>/dev/null || echo 0)
  if [ "$REFS" -ge 3 ]; then
    PASS=$((PASS + 1)); echo -e "  ${GREEN}✅ DESIGN.md (${REFS} code refs)${NC}"
  else
    ISSUES="$ISSUES\n- DESIGN.md: only ${REFS} code references (need ≥3)"
    FAIL=$((FAIL + 1))
  fi
}

# TASKS.md
[ -f "$CHANGE_DIR/TASKS.md" ] && {
  TASK_COUNT=$(grep -cE '^\|\s*[0-9]+\s+\|' "$CHANGE_DIR/TASKS.md" 2>/dev/null || echo 0)
  WRITE_FILES=$(grep -c 'write_files' "$CHANGE_DIR/TASKS.md" 2>/dev/null || echo 0)
  if [ "$TASK_COUNT" -gt 0 ] && [ "$WRITE_FILES" -eq 0 ]; then
    ISSUES="$ISSUES\n- TASKS.md: $TASK_COUNT tasks but no write_files"
    FAIL=$((FAIL + 1))
  else
    PASS=$((PASS + 1)); echo -e "  ${GREEN}✅ TASKS.md (${TASK_COUNT} tasks)${NC}"
  fi
}

# VERIFY.md
[ -f "$CHANGE_DIR/VERIFY.md" ] && {
  AC_EVIDENCE=$(grep -cE 'AC-[0-9]{2}' "$CHANGE_DIR/VERIFY.md" 2>/dev/null || echo 0)
  if [ "$AC_EVIDENCE" -gt 0 ]; then
    PASS=$((PASS + 1)); echo -e "  ${GREEN}✅ VERIFY.md (${AC_EVIDENCE} AC entries)${NC}"
  else
    ISSUES="$ISSUES\n- VERIFY.md: no AC evidence rows"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo -e "Results:"
echo "  Passed: $PASS"
if [ "$FAIL" -gt 0 ]; then
  echo -e "  Failed: $FAIL"
  echo -e "$ISSUES"
  [ "$STRICT" = true ] && exit 2
else
  echo -e "  ${GREEN}✅ All content checks passed${NC}"
fi
