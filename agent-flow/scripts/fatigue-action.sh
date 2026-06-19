#!/usr/bin/env bash
# Apply fatigue recommendations — auto-skip or advisory-mode fatigued gates.
# Usage: bash agent-flow/scripts/fatigue-action.sh [--threshold 8] [--apply]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHANGES_DIR="$ROOT/agent-flow/changes"
THRESHOLD=8
APPLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --threshold) THRESHOLD="$2"; shift 2 ;;
    --apply) APPLY=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; GRAY='\033[0;90m'; NC='\033[0m'

[ -d "$CHANGES_DIR" ] || { echo "No changes directory found"; exit 0; }

echo -e "${CYAN}Fatigue Action Report${NC}"
echo "============================================================"
echo "Threshold: $THRESHOLD consecutive passes"

# Scan gate results
ADVISORY=""
REVIEW=""
CHANGE_COUNT=0

for change_dir in "$CHANGES_DIR"/*/; do
  [ ! -d "$change_dir" ] && continue
  CHECK_JSON="$change_dir/CHECK_RESULT.json"
  [ ! -f "$CHECK_JSON" ] && continue
  CHANGE_COUNT=$((CHANGE_COUNT + 1))
done

echo "Changes scanned: $CHANGE_COUNT"

# Simplified analysis: run gate-fatigue-check and parse output
FATIGUE_OUTPUT=$(bash "$SCRIPT_DIR/gate-fatigue-check.sh" --threshold "$THRESHOLD" 2>/dev/null || true)

# Extract fatigued gate names from the report
FATIGUED_GATES=$(echo "$FATIGUE_OUTPUT" | grep '|.*|[0-9]\+.*|[0-9]\+.*|[0-9]\+.*|' | grep -v 'Gate\|------' | awk -F'|' '{print $2}' | xargs || true)

if [ -z "$FATIGUED_GATES" ]; then
  echo -e "\n${GREEN}✅ No fatigued gates found (threshold = $THRESHOLD).${NC}"
  exit 0
fi

echo -e "\n${YELLOW}Fatigued gates:${NC}"
for g in $FATIGUED_GATES; do
  echo -e "  ${WHITE}$g${NC}"
  ADVISORY="$ADVISORY $g"
done

echo -e "\n${YELLOW}Recommended actions:${NC}"
for g in $FATIGUED_GATES; do
  echo -e "  $g → advisory for Light changes (warn but don't block)"
done

if [ "$APPLY" = true ]; then
  echo -e "\n${CYAN}Applying recommendations...${NC}"
  CONFIG_FILE="$ROOT/agent-flow/.gates-config.json"
  if [ -f "$CONFIG_FILE" ]; then
    # Read existing config and append
    python3 -c "
import json
with open('$CONFIG_FILE') as f:
    config = json.load(f)
advisory = config.get('advisory', [])
for g in '$FATIGUED_GATES'.split():
    if g not in advisory:
        advisory.append(g)
config['advisory'] = advisory
with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
print('Updated advisory list')
" 2>/dev/null || {
    # Fallback: write new file
    echo "{ \"advisory\": [$(for g in $FATIGUED_GATES; do echo -n "\"$g\","; done | sed 's/,$//')] }" > "$CONFIG_FILE"
  }
  for g in $FATIGUED_GATES; do
    echo -e "  ${GREEN}✅ $g → advisory mode${NC}"
  done
  echo -e "\nConfiguration written to: agent-flow/.gates-config.json"
else
  echo -e "\n${GRAY}Dry-run mode. Use --apply to persist changes.${NC}"
  echo -e "${CYAN}  bash agent-flow/scripts/fatigue-action.sh --apply${NC}"
fi
