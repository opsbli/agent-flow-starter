# Code Scan

> **Light 模式**：只需填写「扫描时间」「read_files」「write_files」「未决问题」四个字段。
> **Standard / Heavy 模式**：填写全部字段。

## 扫描时间

2026-06-20 18:00

## Machine Check

scan_time: 2026-06-20 18:00
related_modules: templates/DESIGN.md, scripts/generate-design.sh, scripts/generate-design.ps1
similar_implementations: test/fixtures/minimal-project/agent-flow/templates/DESIGN.md (副本), test/test-scripts/test-gate-smoke.ps1/.sh (测试数据), test/test-scripts/test-check-change.ps1/.sh (测试数据)
reusable_abstractions: none — 纯列名修正，无抽象
standards_snapshot: 项目的 DESIGN.md 模板定义了 Alignment 表列头标准，alignment-check 脚本对其有硬性期望
test_baseline: scaffold-health.ps1/.sh, test-gate-smoke.ps1/.sh, test-check-change.ps1/.sh, template-check.ps1/.sh
read_files: agent-flow/templates/DESIGN.md, agent-flow/scripts/alignment-check.sh, agent-flow/scripts/alignment-check.ps1, agent-flow/scripts/generate-design.sh, agent-flow/scripts/generate-design.ps1, agent-flow/scripts/_common.sh, agent-flow/scripts/_common.ps1, agent-flow/rules/design-alignment.questions
write_files: agent-flow/templates/DESIGN.md, agent-flow/scripts/generate-design.sh, agent-flow/scripts/generate-design.ps1, agent-flow/test/fixtures/minimal-project/agent-flow/templates/DESIGN.md, agent-flow/test/test-scripts/test-gate-smoke.sh, agent-flow/test/test-scripts/test-gate-smoke.ps1, agent-flow/test/test-scripts/test-check-change.sh, agent-flow/test/test-scripts/test-check-change.ps1
open_questions: none

## 相关模块

- 模块：agent-flow templates, scripts generators, test fixtures, integration tests
- 入口：agent-flow/templates/DESIGN.md

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| Alignment 表列头 | agent-flow/templates/DESIGN.md | 所有副本需同步更新 |

## 可复用抽象

- 抽象：无
- 复用方式：无

## 禁止重复实现

- 不重复实现：无
- 原因：纯修复

## Standards Snapshot

- Standards source: agent-flow/scripts/alignment-check.sh (line 124) 和 agent-flow/scripts/alignment-check.ps1 (line 108) 中明确声明期望格式：`| # | Question | Confirmation | Evidence |`
- 本次沿用: 所有 templates/DESIGN.md 和相关生成脚本/测试中的列头统一为上述格式
- 冲突或缺口: 当前模板和生成脚本使用 `| Question | AI Recommended Answer | Confirmation | Final Decision |`，与 alignment-check 期望冲突

## 测试基线

- 现有测试：scaffold-health.ps1/.sh, test-gate-smoke.ps1/.sh, test-check-change.ps1/.sh, template-check.ps1/.sh
- 可复用命令：bash agent-flow/scripts/scaffold-health.sh

## read_files

read_files:
  - agent-flow/templates/DESIGN.md
  - agent-flow/scripts/alignment-check.sh
  - agent-flow/scripts/alignment-check.ps1
  - agent-flow/scripts/generate-design.sh
  - agent-flow/scripts/generate-design.ps1
  - agent-flow/rules/design-alignment.questions
  - agent-flow/test/test-scripts/test-gate-smoke.sh
  - agent-flow/test/test-scripts/test-gate-smoke.ps1
  - agent-flow/test/test-scripts/test-check-change.sh
  - agent-flow/test/test-scripts/test-check-change.ps1
  - agent-flow/test/fixtures/minimal-project/agent-flow/templates/DESIGN.md

## write_files

write_files:
  - agent-flow/templates/DESIGN.md
  - agent-flow/scripts/generate-design.sh
  - agent-flow/scripts/generate-design.ps1
  - agent-flow/test/fixtures/minimal-project/agent-flow/templates/DESIGN.md
  - agent-flow/test/test-scripts/test-gate-smoke.sh
  - agent-flow/test/test-scripts/test-gate-smoke.ps1
  - agent-flow/test/test-scripts/test-check-change.sh
  - agent-flow/test/test-scripts/test-check-change.ps1

## 破坏性变更

无

## 未决问题

无
