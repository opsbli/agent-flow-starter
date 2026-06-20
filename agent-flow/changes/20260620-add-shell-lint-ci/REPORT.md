# Report

## 变更概述

在 `.github/workflows/scaffold-ci.yml` 中新增两个静态分析 CI job：
- **static-analysis**（shellcheck）：扫描所有 `.sh` 脚本的代码质量问题
- **static-analysis-ps1**（PSScriptAnalyzer）：扫描所有 `.ps1` 脚本的代码质量问题

## AC 达成

| AC | 描述 | 状态 |
|----|------|------|
| AC-01 | shellcheck 对所有 .sh 文件执行 | ✅ |
| AC-02 | PSScriptAnalyzer 对所有 .ps1 文件执行 | ✅ |
| AC-03 | lint 发现不阻塞 CI（continue-on-error: true） | ✅ |
| AC-04 | 工具不可用时优雅跳过 | ✅ |

## 交付物

- `.github/workflows/scaffold-ci.yml`（+55 行，新增 2 个 job）

## 决策记录

| # | 决策 | 选择 |
|---|------|------|
| D-01 | shellcheck 失败策略 | continue-on-error: true（渐进式引入） |
| D-02 | PSScriptAnalyzer 安装方式 | Install-Module 在线安装 |
| D-03 | shellcheck severity | --severity=warning |
| D-04 | 扫描范围 | agent-flow/scripts + agent-flow/test/test-scripts |
| D-05 | Job 依赖 | needs: scaffold-health |

## 风险缓解

- continue-on-error: true 确保 CI 不因 lint 发现而阻塞
- Step Summary 输出 warning 计数，方便追踪质量趋势
- 分离 Linux/Win job，避免跨平台串扰

## 后续建议

- 积累 shellcheck/PSScriptAnalyzer 基线数据后，逐步修复 warning 并收紧为阻塞模式
- 可选添加 `.shellcheckrc` 抑制项目特定误报规则
