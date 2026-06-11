<#
.SYNOPSIS
新电脑一键安装：pi + agent-flow-starter + ECC 必要技能

.DESCRIPTION
在新电脑上完成以下安装：
  1. 安装 pi（如未安装）
  2. 安装 ECC 技能包（pi install npm:ecc-universal）
  3. 安装 agent-flow-starter 集成文件（扩展、agent、prompt 模板）
  4. 安装 agent-flow 到目标项目

.PARAMETER Target
目标项目目录（必填）

.PARAMETER StarterRepo
agent-flow-starter 仓库 URL 或本地路径（默认：当前目录）

.PARAMETER NoPi
跳过 pi 安装（如果已安装）

.PARAMETER NoEcc
跳过 ECC 安装（如果已安装）

.EXAMPLE
# 全新安装（推荐）
scripts/setup-new-pc.ps1 -Target D:\Projects\my-app

# 从 GitHub 克隆 starter 并安装
scripts/setup-new-pc.ps1 -Target D:\Projects\my-app -StarterRepo https://github.com/your/agent-flow-starter
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [string]$StarterRepo,
    [switch]$NoPi,
    [switch]$NoEcc
)

$ErrorActionPreference = "Stop"

# ─── Color helpers ───
function Write-Step($text) { Write-Host "`n==> $text" -ForegroundColor Cyan }
function Write-Ok($text) { Write-Host "  [OK] $text" -ForegroundColor Green }
function Write-Skip($text) { Write-Host "  [SKIP] $text" -ForegroundColor Yellow }
function Write-Warn($text) { Write-Host "  [!] $text" -ForegroundColor Magenta }

# ─── Resolve paths ───
$starterRoot = if ($StarterRepo) {
    # Clone or use local path
    if (Test-Path -LiteralPath $StarterRepo -PathType Container) {
        Resolve-Path $StarterRepo
    } else {
        $cloneDir = Join-Path $env:TMP "agent-flow-starter-install"
        if (Test-Path $cloneDir) { Remove-Item -Recurse -Force $cloneDir }
        Write-Step "Cloning agent-flow-starter from $StarterRepo..."
        git clone --depth 1 $StarterRepo $cloneDir
        $cloneDir
    }
} else {
    # Use current directory (assume we're in agent-flow-starter)
    Split-Path -Parent $PSScriptRoot
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  agent-flow + ECC 新电脑一键安装" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starter root: $starterRoot"
Write-Host "Target project: $Target"
Write-Host ""

# ═══════════════════════════════════════════════
# Step 1: 检查/安装 pi
# ═══════════════════════════════════════════════
if (-not $NoPi) {
    Write-Step "Step 1/4: 检查 pi..."
    $piPath = Get-Command "pi" -ErrorAction SilentlyContinue
    if (-not $piPath) {
        Write-Host "  pi 未安装，正在安装..."
        npm install -g --ignore-scripts @earendil-works/pi-coding-agent
        if ($LASTEXITCODE -ne 0) { throw "pi 安装失败" }
        Write-Ok "pi 已安装"
    } else {
        Write-Ok "pi 已就绪：$($piPath.Source)"
    }
} else {
    Write-Skip "跳过 pi 安装（-NoPi）"
}

# ═══════════════════════════════════════════════
# Step 2: 安装 ECC 技能包
# ═══════════════════════════════════════════════
if (-not $NoEcc) {
    Write-Step "Step 2/4: 安装 ECC 技能包（轻量版，32 个核心技能）..."
    $bundleDir = Join-Path $starterRoot "pi-package\skills"
    $targetSkillsDir = "$env:USERPROFILE\.pi\agent\skills"
    if (-not (Test-Path $targetSkillsDir)) {
        New-Item -ItemType Directory -Force -Path $targetSkillsDir | Out-Null
    }
    if (Test-Path $bundleDir) {
        $count = 0
        $skillDirs = Get-ChildItem $bundleDir -Directory
        foreach ($dir in $skillDirs) {
            $src = Join-Path $dir.FullName "SKILL.md"
            if (Test-Path $src) {
                $dstDir = Join-Path $targetSkillsDir $dir.Name
                if (-not (Test-Path $dstDir)) {
                    New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
                }
                Copy-Item $src (Join-Path $dstDir "SKILL.md") -Force
                $count++
            }
        }
        Write-Ok "轻量技能包已安装：$count 个核心技能（335 KB）"
    } else {
        Write-Warn "技能包未找到：$bundleDir"
        Write-Host "  尝试从 ECC 全量包安装..."
        & pi install npm:ecc-universal
        if ($LASTEXITCODE -eq 0) { Write-Ok "ECC 已安装（197 个技能）" }
    }
} else {
    Write-Skip "跳过 ECC 安装（-NoEcc）"
}

# ═══════════════════════════════════════════════
# Step 3: 安装集成文件
# ═══════════════════════════════════════════════
Write-Step "Step 3/4: 安装 agent-flow + ECC 集成文件..."

# 确保 pi 目录存在
$piAgentDir = "$env:USERPROFILE\.pi\agent"
$extDir = "$piAgentDir\extensions"
$agentsDir = "$piAgentDir\agents"
$promptsDir = "$piAgentDir\prompts"
foreach ($d in @($extDir, $agentsDir, $promptsDir)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
}

# 3a. 复制 ecc-bridge 扩展
$bridgeExt = Join-Path $starterRoot "pi-package\extensions\ecc-bridge.ts"
if (Test-Path $bridgeExt) {
    Copy-Item $bridgeExt "$extDir\ecc-bridge.ts" -Force
    Write-Ok "扩展：ecc-bridge.ts（安全钩子 + 10 个 /ecc-* 命令）"
} else {
    Write-Warn "ecc-bridge.ts 未在 starter 中找到"
}

# 3b. 复制 agent 文件
$agentFiles = @(
    "ecc-architect.md", "ecc-build.md", "ecc-explorer.md",
    "ecc-perf.md", "ecc-planner.md", "ecc-reviewer.md",
    "ecc-security.md", "ecc-tdd.md"
)
$agentSourceDir = Join-Path $starterRoot "pi-package\agents"
if (Test-Path $agentSourceDir) {
    foreach ($f in $agentFiles) {
        $src = Join-Path $agentSourceDir $f
        if (Test-Path $src) {
            Copy-Item $src "$agentsDir\$f" -Force
        }
    }
    $count = 0
    foreach ($f in $agentFiles) {
        $src = Join-Path $agentSourceDir $f
        if (Test-Path $src) {
            Copy-Item $src "$agentsDir\$f" -Force
            $count++
        }
    }
    Write-Ok "Agents：$count 个 ECC agent（审查、架构、安全、TDD 等）"
} else {
    Write-Warn "agent 文件未在 starter 中找到"
}

# 3c. 复制 prompt 模板
$templateFiles = @(
    "af-go.md", "af-scan.md", "af-design.md", "af-verify.md",
    "ecc-build.md", "ecc-checkpoint.md", "ecc-docs.md",
    "ecc-plan.md", "ecc-quality.md", "ecc-refactor.md",
    "ecc-review.md", "ecc-security.md", "ecc-tdd.md"
)
$tplSourceDir = Join-Path $starterRoot "pi-package\prompts"
if (Test-Path $tplSourceDir) {
    $count = 0
    foreach ($f in $templateFiles) {
        $src = Join-Path $tplSourceDir $f
        if (Test-Path $src) {
            Copy-Item $src "$promptsDir\$f" -Force
            $count++
        }
    }
    Write-Ok "Templates：$count 个 prompt 模板（/af-* 和 /ecc-*）"
} else {
    Write-Warn "prompt 模板未在 starter 中找到"
}

# ═══════════════════════════════════════════════
# Step 4: 安装 agent-flow 到目标项目
# ═══════════════════════════════════════════════
Write-Step "Step 4/4: 安装 agent-flow 到目标项目..."

$afInstaller = Join-Path $starterRoot "agent-flow\scripts\install-agent-flow.ps1"
if (Test-Path $afInstaller) {
    & $afInstaller -Target $Target -StarterRoot $starterRoot -Force
    Write-Ok "agent-flow 已安装到 $Target"
} else {
    Write-Warn "agent-flow 安装脚本未找到：$afInstaller"
}

# ═══════════════════════════════════════════════
# 完成
# ═══════════════════════════════════════════════
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✅ 安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  已安装："
Write-Host "  - pi（AI 编码助手）"
Write-Host "  - ECC 轻量技能包（32 个核心技能，专为 agent-flow 精选）"
Write-Host "  - ECC 安全扩展（4 类自动保护钩子）"
Write-Host "  - 8 个 ECC Agent（审查、架构、安全、TDD 等）"
Write-Host "  - 13 个 prompt 模板（/ecc-* 和 /af-*）"
Write-Host "  - agent-flow 流程框架（已安装到目标项目）"
Write-Host ""
Write-Host "  快速开始："
Write-Host "    cd $Target"
Write-Host "    pi"
Write-Host "    # 在 pi 中输入：按 agent-flow 流程处理这个需求：<需求内容>"
Write-Host ""
Write-Host "  在开发中可用的快捷命令："
Write-Host "    /af-go <需求>     — 完整流程一站式执行"
Write-Host "    /af-scan <需求>   — 代码优先扫描"
Write-Host "    /af-design <功能> — 架构设计"
Write-Host "    /af-verify        — 验证门禁"
Write-Host "    /ecc-review       — 代码审查"
Write-Host "    /ecc-security     — 安全扫描"
Write-Host "    /ecc-quality      — 质量门禁"
Write-Host "    /ecc-plan         — 生成计划"
Write-Host ""
Write-Host "  更多用法见：agent-flow/ecc-integration.md"
Write-Host ""
