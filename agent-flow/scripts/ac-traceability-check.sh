#!/usr/bin/env bash
# Verify AC traceability: each AC-XX from REQUIREMENT.md must appear in DESIGN.md,
# TASKS.md, VERIFY.md, and REPORT.md.
# Usage: bash agent-flow/scripts/ac-traceability-check.sh --change-dir <path> [--repair]
set -euo pipefail

CHANGE_DIR=""
REPAIR=false

while [ $# -gt 0 ]; do
  case "$1" in
    --change-dir) CHANGE_DIR="$2"; shift 2 ;;
    --repair) REPAIR=true; shift ;;
    -h|--help)
      echo "Usage: bash agent-flow/scripts/ac-traceability-check.sh --change-dir <path> [--repair]"
      exit 0
      ;;
    *) echo "Unknown: $1"; exit 2 ;;
  esac
done

if [ -z "$CHANGE_DIR" ]; then
  echo "Missing --change-dir" >&2
  exit 2
fi

# Files to check
REQ_FILE="$CHANGE_DIR/REQUIREMENT.md"
DSN_FILE="$CHANGE_DIR/DESIGN.md"
TASKS_FILE="$CHANGE_DIR/TASKS.md"
VERIFY_FILE="$CHANGE_DIR/VERIFY.md"
REPORT_FILE="$CHANGE_DIR/REPORT.md"

# 1. Extract ACs from REQUIREMENT.md
if [ ! -f "$REQ_FILE" ]; then
  echo "⚠️  REQUIREMENT.md not found — cannot verify AC traceability. Skipping."
  exit 0
fi

ACS=$(grep -o 'AC-[0-9]' "$REQ_FILE" | sort -u | tr '\n' ' ' 2>/dev/null || true)
AC_COUNT=$(echo "$ACS" | wc -w)

if [ "$AC_COUNT" -eq 0 ]; then
  echo "ℹ️  No AC-XX references found in REQUIREMENT.md. Traceability check not applicable."
  exit 0
fi

echo "🔍 AC Traceability Check"
echo "   Change: $CHANGE_DIR"
echo "   REQ ACs: $AC_COUNT ($ACS)"
echo ""

# 2. Check each artifact
TOTAL_MISSING=0
declare -A MISSING_MAP

check_file() {
  local label="$1"
  local path="$2"
  local missing_list=""

  if [ ! -f "$path" ]; then
    echo "   ⏭️  $label — not present (skipped)"
    return
  fi

  local content
  content=$(cat "$path" 2>/dev/null || true)

  for ac_id in $ACS; do
    if echo "$content" | grep -q "$ac_id"; then
      true # present
    else
      missing_list="$missing_list $ac_id"
    fi
  done

  local miss_count
  miss_count=$(echo "$missing_list" | wc -w)
  TOTAL_MISSING=$((TOTAL_MISSING + miss_count))

  if [ "$miss_count" -eq 0 ]; then
    echo "   ✅ $label — all ACs present ($AC_COUNT/$AC_COUNT)"
  else
    echo "   ❌ $label — missing $miss_count AC(s):$missing_list"
  fi

  MISSING_MAP["$label"]="$missing_list"
}

check_file "DESIGN.md" "$DSN_FILE"
check_file "TASKS.md"  "$TASKS_FILE"
check_file "VERIFY.md" "$VERIFY_FILE"
check_file "REPORT.md" "$REPORT_FILE"

# 3. Summary
echo ""
if [ "$TOTAL_MISSING" -eq 0 ]; then
  echo "✅ AC Traceability: PASS (all $AC_COUNT ACs traced through all artifacts)"
else
  echo "❌ AC Traceability: FAIL ($TOTAL_MISSING missing AC references)"
  echo ""
  echo "Traceability Matrix:"
  printf "%-20s" "AC ID"
  printf "%-15s" "DESIGN.md"
  printf "%-15s" "TASKS.md"
  printf "%-15s" "VERIFY.md"
  printf "%-15s" "REPORT.md"
  echo ""

  for ac in $ACS; do
    printf "%-20s" "$ac"
    for label in "DESIGN.md" "TASKS.md" "VERIFY.md" "REPORT.md"; do
      if echo "${MISSING_MAP[$label]:-}" | grep -q "$ac"; then
        printf "%-15s" "❌"
      else
        printf "%-15s" "✅"
      fi
    done
    echo ""
  done

  # 4. Repair mode
  if [ "$REPAIR" = true ] && [ -f "$VERIFY_FILE" ]; then
    echo ""
    echo "🔧 Repair mode: annotating missing ACs into VERIFY.md..."
    local_acs="${MISSING_MAP['VERIFY.md']:-}"
    if [ -n "$local_acs" ]; then
      echo "" >> "$VERIFY_FILE"
      echo "## AC Traceability (auto-annotated by ac-traceability-check)" >> "$VERIFY_FILE"
      echo "" >> "$VERIFY_FILE"
      echo "> The following ACs are defined in REQUIREMENT.md but not yet referenced in VERIFY.md." >> "$VERIFY_FILE"
      echo "> Fill in verification evidence before declaring completion." >> "$VERIFY_FILE"
      echo "" >> "$VERIFY_FILE"
      echo "| AC | Verification Evidence |" >> "$VERIFY_FILE"
      echo "|----|-----------------------|" >> "$VERIFY_FILE"
      for ac in $local_acs; do
        echo "| $ac | (TODO: add verification evidence) |" >> "$VERIFY_FILE"
      done
      echo "✅ VERIFY.md annotated with $(echo "$local_acs" | wc -w) missing AC(s)."
    fi
  fi
fi

echo ""
echo "💡 Tip: AC IDs must be consistent. Use AC-01, AC-02 format in all change artifacts."
