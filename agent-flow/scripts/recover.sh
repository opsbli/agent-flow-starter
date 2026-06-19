#!/usr/bin/env bash
# Smart error recovery assistant for agent-flow gate failures.
# Usage: bash agent-flow/scripts/recover.sh --gate <gate-name> [--change-dir <path>] [--auto-fix] [--list-gates]

set -euo pipefail

GATE=""
CHANGE_DIR=""
AUTO_FIX=false
LIST_GATES=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --gate) GATE="$2"; shift 2 ;;
    --change-dir) CHANGE_DIR="$2"; shift 2 ;;
    --auto-fix) AUTO_FIX=true; shift ;;
    --list-gates) LIST_GATES=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; GRAY='\033[0;90m'; NC='\033[0m'

# ── Known gate recovery strategies ──
if [ "$LIST_GATES" = true ]; then
  echo -e "${CYAN}Known gates with recovery strategies:${NC}"
  for g in alignment-check scan-check task-check plan-check code-drift-check evolution-check; do
    echo -e "  ${WHITE}$g${NC}"
  done
  echo ""
  echo -e "${CYAN}Usage: recover.sh --gate <gate-name> --change-dir <path> [--auto-fix]${NC}"
  exit 0
fi

if [ -z "$GATE" ]; then
  echo -e "${YELLOW}Specify a gate: recover.sh --gate <gate-name> --change-dir <path>${NC}"
  echo -e "${CYAN}Use --list-gates to see available gates.${NC}"
  exit 1
fi

echo -e "${CYAN}Recover: $GATE${NC}"
echo "================================================"

case "$GATE" in
  alignment-check)
    echo -e "${YELLOW}Design Alignment requires ≥3 user-confirmed questions${NC}"
    if [ -n "$CHANGE_DIR" ] && [ -d "$CHANGE_DIR" ]; then
      DESIGN_FILE="$CHANGE_DIR/DESIGN.md"
      if [ -f "$DESIGN_FILE" ]; then
        VERDICT=$(grep -Eim1 "Alignment Verdict:" "$DESIGN_FILE" | sed 's/.*Verdict:[[:space:]]*//i' || echo "missing")
        CONFIRMED=$(grep -c "user-confirmed" "$DESIGN_FILE" || echo 0)
        echo -e "${CYAN}Diagnosis:${NC} Verdict: $VERDICT | user-confirmed: $CONFIRMED"
      else
        echo -e "${RED}DESIGN.md not found${NC}"
      fi
    fi
    echo -e "${CYAN}Recovery:${NC} Open DESIGN.md and ensure ≥3 questions have 'user-confirmed'. Then re-run alignment-check."
    ;;

  scan-check)
    echo -e "${YELLOW}Code scan validation${NC}"
    if [ -n "$CHANGE_DIR" ] && [ -d "$CHANGE_DIR" ]; then
      SCAN_FILE="$CHANGE_DIR/CODE_SCAN.md"
      if [ -f "$SCAN_FILE" ]; then
        echo -e "${CYAN}Diagnosis:${NC} CODE_SCAN.md exists. Check read_files and write_files sections."
      else
        echo -e "${RED}CODE_SCAN.md not found${NC}"
      fi
    fi
    echo -e "${CYAN}Recovery:${NC} Ensure CODE_SCAN.md has read_files, write_files, and similar modules sections."
    ;;

  task-check)
    echo -e "${YELLOW}Task Matrix validation${NC}"
    if [ -n "$CHANGE_DIR" ] && [ -d "$CHANGE_DIR" ]; then
      TASKS_FILE="$CHANGE_DIR/TASKS.md"
      if [ -f "$TASKS_FILE" ]; then
        TASK_COUNT=$(grep -cE '^\|\s*[0-9]+\s+\|' "$TASKS_FILE" || echo 0)
        echo -e "${CYAN}Diagnosis:${NC} Tasks found: $TASK_COUNT"
      else
        echo -e "${RED}TASKS.md not found${NC}"
      fi
    fi
    echo -e "${CYAN}Recovery:${NC} Each task needs: status, AC mapping, read_files, write_files, verify command."
    ;;

  plan-check)
    echo -e "${YELLOW}Plan Audit required before implementation${NC}"
    if [ -n "$CHANGE_DIR" ] && [ -d "$CHANGE_DIR" ]; then
      [ -f "$CHANGE_DIR/AUDIT.md" ] && echo -e "${CYAN}AUDIT.md:${NC} exists" || echo -e "${RED}AUDIT.md: missing${NC}"
      [ -f "$CHANGE_DIR/PLAN.md" ] && echo -e "${CYAN}PLAN.md:${NC} exists" || echo -e "${RED}PLAN.md: missing${NC}"
    fi
    echo -e "${CYAN}Recovery:${NC} Complete PLAN.md, then run Plan Audit to get 'accept' verdict."
    ;;

  code-drift-check)
    echo -e "${YELLOW}Design vs code drift${NC}"
    echo -e "${CYAN}Recovery:${NC} Compare actual code changes with DESIGN.md declarations. Update either the design or the code."
    ;;

  evolution-check)
    echo -e "${YELLOW}EVOLUTION.md required${NC}"
    if [ -n "$CHANGE_DIR" ] && [ -d "$CHANGE_DIR" ]; then
      EVO_FILE="$CHANGE_DIR/EVOLUTION.md"
      if [ -f "$EVO_FILE" ]; then
        echo -e "${CYAN}Diagnosis:${NC} EVOLUTION.md exists"
      else
        echo -e "${YELLOW}EVOLUTION.md not found. Auto-generating...${NC}"
        SUGGEST_SCRIPT="$SCRIPT_DIR/evolution-suggest.sh"
        if [ -f "$SUGGEST_SCRIPT" ]; then
          bash "$SUGGEST_SCRIPT" --change-dir "$CHANGE_DIR" --output "$EVO_FILE" 2>/dev/null || \
            echo -e "${YELLOW}Could not auto-generate. Create EVOLUTION.md manually.${NC}"
        else
          echo -e "${YELLOW}Create EVOLUTION.md manually.${NC}"
        fi
      fi
    fi
    ;;

  *)
    echo -e "${RED}Unknown gate: $GATE${NC}"
    echo -e "${CYAN}Use --list-gates to see supported gates.${NC}"
    exit 1
    ;;
esac

echo ""
if [ "$AUTO_FIX" = true ]; then
  echo -e "${GREEN}Auto-fix attempted where supported.${NC}"
fi
echo -e "${CYAN}After fixing, re-run: bash agent-flow/scripts/${GATE}.sh --change-dir ${CHANGE_DIR:-<path>}${NC}"
