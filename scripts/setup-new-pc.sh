#!/usr/bin/env bash
# ==========================================
# 新电脑一键安装：pi + agent-flow-starter + ECC 必要技能
# ==========================================
# Usage:
#   bash scripts/setup-new-pc.sh --target /path/to/project
#   bash scripts/setup-new-pc.sh --target /path/to/project --starter-repo https://github.com/your/agent-flow-starter
#   bash scripts/setup-new-pc.sh --target /path/to/project --no-pi --no-ecc
# ==========================================

set -euo pipefail

# ─── Colors ───
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

step()  { echo -e "\n==> ${CYAN}$1${NC}"; }
ok()    { echo -e "  ${GREEN}[OK]${NC} $1"; }
skip()  { echo -e "  ${YELLOW}[SKIP]${NC} $1"; }
warn()  { echo -e "  ${MAGENTA}[!]${NC} $1"; }

# ─── Parse args ───
target=""
starter_repo=""
no_pi=false
no_ecc=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target|-Target) target="$2"; shift 2 ;;
    --starter-repo)   starter_repo="$2"; shift 2 ;;
    --no-pi)          no_pi=true; shift ;;
    --no-ecc)         no_ecc=true; shift ;;
    -h|--help)
      echo "Usage: $0 --target <project-dir> [--starter-repo <url>] [--no-pi] [--no-ecc]"
      exit 0 ;;
    *) echo "Unknown: $1"; exit 2 ;;
  esac
done

if [ -z "$target" ]; then
  echo "Error: --target is required" >&2
  exit 1
fi

# ─── Resolve starter root ───
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -n "$starter_repo" ]; then
  if [ -d "$starter_repo" ]; then
    starter_root="$starter_repo"
  else
    clone_dir="/tmp/agent-flow-starter-install"
    rm -rf "$clone_dir"
    step "Cloning agent-flow-starter from $starter_repo..."
    git clone --depth 1 "$starter_repo" "$clone_dir"
    starter_root="$clone_dir"
  fi
else
  starter_root="$(cd "$script_dir/.." && pwd)"
fi

echo "========================================"
echo "  agent-flow + ECC 新电脑一键安装"
echo "========================================"
echo "Starter root: $starter_root"
echo "Target project: $target"
echo ""

# ═══════════════════════════════════════════════
# Step 1: 检查/安装 pi
# ═══════════════════════════════════════════════
if [ "$no_pi" = false ]; then
  step "Step 1/4: 检查 pi..."
  if command -v pi &>/dev/null; then
    ok "pi 已就绪：$(which pi)"
  else
    echo "  pi 未安装，正在安装..."
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
    ok "pi 已安装"
  fi
else
  skip "跳过 pi 安装（--no-pi）"
fi

# ═══════════════════════════════════════════════
# Step 2: 安装 ECC 技能包
# ═══════════════════════════════════════════════
if [ "$no_ecc" = false ]; then
  step "Step 2/4: 安装 ECC 技能包（轻量版，32 个核心技能）..."
  bundle_dir="$starter_root/pi-package/skills"
  target_skills_dir="$HOME/.pi/agent/skills"
  mkdir -p "$target_skills_dir"
  if [ -d "$bundle_dir" ]; then
    count=0
    for dir in "$bundle_dir"/*/; do
      name="$(basename "$dir")"
      skill_md="$dir/SKILL.md"
      if [ -f "$skill_md" ]; then
        mkdir -p "$target_skills_dir/$name"
        cp "$skill_md" "$target_skills_dir/$name/SKILL.md"
        count=$((count + 1))
      fi
    done
    ok "轻量技能包已安装：$count 个核心技能（335 KB）"
  else
    warn "技能包未找到：$bundle_dir"
    echo "  尝试从 ECC 全量包安装..."
    pi install npm:ecc-universal && ok "ECC 已安装（197 个技能）"
  fi
else
  skip "跳过 ECC 安装（--no-ecc）"
fi

# ═══════════════════════════════════════════════
# Step 3: 安装集成文件
# ═══════════════════════════════════════════════
step "Step 3/4: 安装 agent-flow + ECC 集成文件..."

pi_agent_dir="$HOME/.pi/agent"
ext_dir="$pi_agent_dir/extensions"
agents_dir="$pi_agent_dir/agents"
prompts_dir="$pi_agent_dir/prompts"
mkdir -p "$ext_dir" "$agents_dir" "$prompts_dir"

# 3a. 复制 ecc-bridge 扩展
bridge_ext="$starter_root/pi-package/extensions/ecc-bridge.ts"
if [ -f "$bridge_ext" ]; then
  cp "$bridge_ext" "$ext_dir/ecc-bridge.ts"
  ok "扩展：ecc-bridge.ts（安全钩子 + 10 个 /ecc-* 命令）"
else
  warn "ecc-bridge.ts 未在 starter 中找到"
fi

# 3b. 复制 agent 文件
agent_source="$starter_root/pi-package/agents"
count=0
if [ -d "$agent_source" ]; then
  for f in ecc-architect.md ecc-build.md ecc-explorer.md ecc-perf.md \
           ecc-planner.md ecc-reviewer.md ecc-security.md ecc-tdd.md; do
    if [ -f "$agent_source/$f" ]; then
      cp "$agent_source/$f" "$agents_dir/$f"
      count=$((count + 1))
    fi
  done
  ok "Agents：$count 个 ECC agent（审查、架构、安全、TDD 等）"
else
  warn "agent 文件未在 starter 中找到"
fi

# 3c. 复制 prompt 模板
tpl_source="$starter_root/pi-package/prompts"
count=0
if [ -d "$tpl_source" ]; then
  for f in af-go.md af-scan.md af-design.md af-verify.md \
           ecc-build.md ecc-checkpoint.md ecc-docs.md ecc-plan.md \
           ecc-quality.md ecc-refactor.md ecc-review.md ecc-security.md ecc-tdd.md; do
    if [ -f "$tpl_source/$f" ]; then
      cp "$tpl_source/$f" "$prompts_dir/$f"
      count=$((count + 1))
    fi
  done
  ok "Templates：$count 个 prompt 模板（/af-* 和 /ecc-*）"
else
  warn "prompt 模板未在 starter 中找到"
fi

# ═══════════════════════════════════════════════
# Step 4: 安装 agent-flow 到目标项目
# ═══════════════════════════════════════════════
step "Step 4/4: 安装 agent-flow 到目标项目..."

af_installer="$starter_root/agent-flow/scripts/install-agent-flow.sh"
if [ -f "$af_installer" ]; then
  bash "$af_installer" --target "$target" --starter-root "$starter_root" --force
  ok "agent-flow 已安装到 $target"
else
  warn "agent-flow 安装脚本未找到：$af_installer"
fi

# ═══════════════════════════════════════════════
# 完成
# ═══════════════════════════════════════════════
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 安装完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  已安装："
echo "  - pi（AI 编码助手）"
echo "  - ECC 轻量技能包（32 个核心技能，专为 agent-flow 精选）"
echo "  - ECC 安全扩展（4 类自动保护钩子）"
echo "  - 8 个 ECC Agent（审查、架构、安全、TDD 等）"
echo "  - 13 个 prompt 模板（/ecc-* 和 /af-*）"
echo "  - agent-flow 流程框架（已安装到目标项目）"
echo ""
echo "  快速开始："
echo "    cd $target"
echo "    pi"
echo "    # 在 pi 中输入：按 agent-flow 流程处理这个需求：<需求内容>"
echo ""
echo "  在开发中可用的快捷命令："
echo "    /af-go <需求>     — 完整流程一站式执行"
echo "    /af-scan <需求>   — 代码优先扫描"
echo "    /af-design <功能> — 架构设计"
echo "    /af-verify        — 验证门禁"
echo "    /ecc-review       — 代码审查"
echo "    /ecc-security     — 安全扫描"
echo "    /ecc-quality      — 质量门禁"
echo "    /ecc-plan         — 生成计划"
echo ""
echo "  更多用法见：agent-flow/ecc-integration.md"
echo ""
