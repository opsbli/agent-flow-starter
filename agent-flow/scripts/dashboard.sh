#!/usr/bin/env bash
# CLI dashboard showing agent-flow change status and gate results.
# Usage: bash agent-flow/scripts/dashboard.sh [--changes-root agent-flow/changes]

set -euo pipefail

CHANGES_ROOT="agent-flow/changes"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --changes-root) CHANGES_ROOT="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHANGES_DIR="$ROOT/$CHANGES_ROOT"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; WHITE='\033[1;37m'
GRAY='\033[0;90m'; NC='\033[0m'

if [ ! -d "$CHANGES_DIR" ]; then
  echo -e "${YELLOW}No changes directory found at $CHANGES_DIR${NC}"
  exit 0
fi

CHANGE_DIRS=()
for d in "$CHANGES_DIR"/*/; do
  [ -d "$d" ] && CHANGE_DIRS+=("$(basename "$d")")
done

IFS=$'\n' CHANGE_DIRS=($(sort <<<"${CHANGE_DIRS[*]}")); unset IFS

if [ ${#CHANGE_DIRS[@]} -eq 0 ]; then
  echo -e "${CYAN}No changes found in $CHANGES_DIR${NC}"
  exit 0
fi

# ── Collect data ──
declare -A GATES  # gate_name -> pass,fail,pending
TOTAL=${#CHANGE_DIRS[@]}
LIGHT=0; STANDARD=0; HEAVY=0; EMERGENCY=0; UNKNOWN=0; BLOCKED=0

declare -a ROWS_ID ROWS_FLOW ROWS_STAGE ROWS_BLOCKED

for change_id in "${CHANGE_DIRS[@]}"; do
  change_dir="$CHANGES_DIR/$change_id"

  # Flow level
  flow=$(flow_level "$change_dir")
  case "${flow,,}" in
    light) LIGHT=$((LIGHT + 1));;
    standard) STANDARD=$((STANDARD + 1));;
    heavy) HEAVY=$((HEAVY + 1));;
    emergency) EMERGENCY=$((EMERGENCY + 1));;
    *) UNKNOWN=$((UNKNOWN + 1));;
  esac

  # Stage detection
  stage="intake"
  [ -f "$change_dir/REPORT.md" ] && [ -f "$change_dir/VERIFY.md" ] && stage="done"
  [ -f "$change_dir/EVOLUTION.md" ] && stage="evolve"
  [ -f "$change_dir/VERIFY.md" ] && stage="verify"
  [ -f "$change_dir/TASKS.md" ] && stage="implement"
  [ -f "$change_dir/PLAN.md" ] && stage="plan"
  [ -f "$change_dir/AUDIT.md" ] && stage="audit"
  [ -f "$change_dir/DESIGN.md" ] && stage="design"
  [ -f "$change_dir/CODE_SCAN.md" ] && stage="code-scan"
  [ -f "$change_dir/REQUIREMENT.md" ] && stage="requirements"
  [ -f "$change_dir/CHANGE.md" ] && stage="intake"

  # Blocked detection
  blocked=false
  if [ -f "$change_dir/STATE.md" ]; then
    if grep -Eqi '^blocked:\s*true' "$change_dir/STATE.md" || grep -Eqi '^status:\s*blocked' "$change_dir/STATE.md"; then
      blocked=true
    fi
  fi

  # Check CHECK_RESULT.json for gate failures
  CHECK_JSON="$change_dir/CHECK_RESULT.json"
  if [ -f "$CHECK_JSON" ]; then
    # Read gates from check result (simplified: check for any "fail" status)
    if grep -q '"result":\s*"fail"' "$CHECK_JSON"; then
      blocked=true
    fi
  fi

  $blocked && BLOCKED=$((BLOCKED + 1))

  ROWS_ID+=("$change_id")
  ROWS_FLOW+=("$flow")
  ROWS_STAGE+=("$stage")
  $blocked && ROWS_BLOCKED+=("true") || ROWS_BLOCKED+=("false")
done

# ── Render ──
echo -e "\n${CYAN}══════════════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "  ${WHITE}agent-flow Dashboard${NC}"
echo -e "  ${GRAY}Project: $(basename "$ROOT")  |  Changes: $TOTAL  |  $(date '+%Y-%m-%d %H:%M')${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════════════${NC}"

# ── Change Status Table ──
echo -e "\n${CYAN}Changes:${NC}"
printf "  %-40s %-10s %-12s %-10s\n" "ID" "Flow" "Stage" "Blocked"
echo -e "  ${GRAY}────────────────────────────────────────────────────────────────────────────────────${NC}"

for i in "${!ROWS_ID[@]}"; do
  id="${ROWS_ID[$i]}"
  flow="${ROWS_FLOW[$i]}"
  stage="${ROWS_STAGE[$i]}"
  blocked_flag="${ROWS_BLOCKED[$i]}"

  case "${flow,,}" in
    light) flow_color=$GREEN;;
    standard) flow_color=$YELLOW;;
    heavy) flow_color=$RED;;
    emergency) flow_color=$MAGENTA;;
    *) flow_color=$GRAY;;
  esac

  if [ "$blocked_flag" = true ]; then
    blocked_text="⚠ Blocked"
    blocked_color=$RED
  else
    blocked_text="✓ Clear"
    blocked_color=$GREEN
  fi

  printf "  %-40s" "$id"
  echo -e "${flow_color}$(printf "%-10s" "$flow")${NC}${CYAN}$(printf "%-12s" "$stage")${NC}${blocked_color}$(printf "%-10s" "$blocked_text")${NC}"
done

# ── Statistics ──
echo -e "\n${CYAN}Statistics:${NC}"
echo -e "  Total changes : $TOTAL"
echo -e "  ${GREEN}Light        : $LIGHT${NC}"
echo -e "  ${YELLOW}Standard     : $STANDARD${NC}"
echo -e "  ${RED}Heavy        : $HEAVY${NC}"
echo -e "  ${MAGENTA}Emergency    : $EMERGENCY${NC}"
echo -e "  ${GRAY}Unknown      : $UNKNOWN${NC}"
if [ "$BLOCKED" -gt 0 ]; then
  echo -e "  ${RED}Blocked      : $BLOCKED${NC}"
else
  echo -e "  ${GREEN}Blocked      : $BLOCKED${NC}"
fi

# ── Quick Commands ──
echo -e "\n${CYAN}Commands:${NC}"
echo -e "  open <id>     - bash agent-flow/scripts/next-step.sh --change-dir agent-flow/changes/<id>"
echo -e "  gates <id>    - bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<id>"
echo -e "${GRAY}══════════════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
