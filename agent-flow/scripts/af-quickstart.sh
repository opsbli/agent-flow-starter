#!/usr/bin/env bash
# One-command agent-flow quickstart. Initializes project and creates a demo change.
# Usage: bash agent-flow/scripts/af-quickstart.sh [--target /path/to/project] [--demo-name hello-agent-flow]

set -euo pipefail

TARGET="."
DEMO_NAME="hello-agent-flow"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --demo-name) DEMO_NAME="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

ROOT="$(cd "$TARGET" && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; GRAY='\033[0;90m'; NC='\033[0m'

echo -e "\n${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   agent-flow Quickstart                 ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}\n"

# ── Step 1: Scaffold health ──
echo -e "${YELLOW}Step 1/4: Checking scaffold health...${NC}"
HEALTH_SCRIPT="$ROOT/agent-flow/scripts/scaffold-health.sh"
if [ -f "$HEALTH_SCRIPT" ]; then
  if bash "$HEALTH_SCRIPT"; then
    echo -e "  ${GREEN}✅ Scaffold healthy${NC}"
  else
    echo -e "${RED}Scaffold health check failed. Run init-wizard first:${NC}"
    echo -e "${CYAN}  bash agent-flow/scripts/init-wizard.sh${NC}"
    exit 1
  fi
else
  echo -e "${YELLOW}  ⚠️ scaffold-health.sh not found. Is agent-flow installed?${NC}"
  exit 1
fi
echo ""

# ── Step 2: Verify manifest ──
echo -e "${YELLOW}Step 2/4: Checking manifest configuration...${NC}"
MANIFEST_FILE="$ROOT/agent-flow/manifest.yaml"
MANIFEST_CHECK="$ROOT/agent-flow/scripts/manifest-check.sh"
if [ -f "$MANIFEST_CHECK" ]; then
  bash "$MANIFEST_CHECK" || true
elif [ -f "$MANIFEST_FILE" ]; then
  echo -e "  ${GREEN}✅ manifest.yaml exists${NC}"
else
  echo -e "  ${YELLOW}⚠️ No manifest.yaml found. Run init-wizard:${NC}"
  echo "    bash agent-flow/scripts/init-wizard.sh"
fi
echo ""

# ── Step 3: Create demo change ──
echo -e "${YELLOW}Step 3/4: Creating demo change '$DEMO_NAME'...${NC}"
NEW_CHANGE="$ROOT/agent-flow/scripts/new-change.sh"
if [ -f "$NEW_CHANGE" ]; then
  bash "$NEW_CHANGE" --name "$DEMO_NAME" --flow Light || true
  CHANGE_DIR="$ROOT/agent-flow/changes/$DEMO_NAME"
  if [ -d "$CHANGE_DIR" ]; then
    CHANGE_FILE="$CHANGE_DIR/CHANGE.md"
    if [ -f "$CHANGE_FILE" ]; then
      cat > "$CHANGE_FILE" <<EOF
# Change: $DEMO_NAME

## 一句话需求

初次使用 agent-flow 的演示 change。

## 流程级别

- [x] Light
- [ ] Standard
- [ ] Heavy
- [ ] Emergency

## 分级理由

演示用途，不涉及代码修改。

## 目标

- 完成 agent-flow 的首次完整使用流程

## 非目标

- 无实际代码修改

## 影响范围

- 无
EOF
    fi
    echo -e "  ${GREEN}✅ Demo change created: $DEMO_NAME${NC}"
  fi
else
  echo -e "  ${YELLOW}⚠️ new-change.sh not found${NC}"
fi
echo ""

# ── Step 4: Show next steps ──
echo -e "${YELLOW}Step 4/4: Next steps guide${NC}"
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   ✅ Quickstart Complete!                ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}Your demo change is ready at:${NC}"
echo "  agent-flow/changes/$DEMO_NAME/"
echo ""
echo -e "${CYAN}Recommended learning path:${NC}"
echo -e "${GRAY}  Phase 1 (5 min) : Read docs/learning-path.md${NC}"
echo "  Phase 2 (15 min): Complete this Light change"
echo "  Phase 3 (30 min): Try a Standard change"
echo "  Phase 4 (45 min): Try a Heavy change"
echo ""
echo -e "${CYAN}To continue this change, run:${NC}"
echo "  bash agent-flow/scripts/next-step.sh --change-dir agent-flow/changes/$DEMO_NAME"
echo ""
echo -e "${CYAN}Or tell your AI:${NC}"
echo -e "  ${WHITE}'继续 agent-flow change: $DEMO_NAME'${NC}"
echo ""
echo -e "${CYAN}Quick commands:${NC}"
echo "  Dashboard  : bash agent-flow/scripts/dashboard.sh"
echo "  Suggestions: bash agent-flow/scripts/evolution-suggest.sh --project-root ."
echo "  All gates  : bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/$DEMO_NAME"
echo ""
