# Code Scan

> **Light 模式**：只需填写「扫描时间」「read_files」「write_files」「未决问题」四个字段。
> **Standard / Heavy 模式**：填写全部字段。

## 扫描时间

2026-06-20 18:30

## Machine Check

scan_time: 2026-06-20 18:30
related_modules: templates/DESIGN.md, scripts/design-check.sh, scripts/design-check.ps1, scripts/generate-design.sh, scripts/generate-design.ps1
similar_implementations: test/fixtures/minimal-project/agent-flow/templates/DESIGN.md, test/test-scripts/test-gate-smoke.ps1/.sh, test/test-scripts/test-check-change.ps1/.sh
reusable_abstractions: design-check 已有的 context-aware 跳过逻辑（可复用模式）
standards_snapshot: 模板设计决策表标准格式；generate-design 脚本生成格式
test_baseline: scaffold-health, template-check, design-check
read_files: agent-flow/templates/DESIGN.md, agent-flow/scripts/design-check.sh, agent-flow/scripts/design-check.ps1, agent-flow/scripts/generate-design.sh, agent-flow/scripts/generate-design.ps1, agent-flow/scripts/_common.sh, agent-flow/scripts/_common.ps1, agent-flow/rules/design-decision.keys, agent-flow/manifest.yaml
write_files: agent-flow/templates/DESIGN.md, agent-flow/scripts/design-check.sh, agent-flow/scripts/design-check.ps1, agent-flow/scripts/generate-design.sh, agent-flow/scripts/generate-design.ps1, agent-flow/test/fixtures/minimal-project/agent-flow/templates/DESIGN.md, agent-flow/test/test-scripts/test-gate-smoke.sh, agent-flow/test/test-scripts/test-gate-smoke.ps1, agent-flow/test/test-scripts/test-check-change.sh, agent-flow/test/test-scripts/test-check-change.ps1
open_questions: none

## 相关模块

- 模块：agent-flow templates, scripts/gates, scripts/generators, test fixtures, tests
- 入口：agent-flow/templates/DESIGN.md

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| design-check 已有 context-aware 逻辑 | agent-flow/scripts/design-check.sh:71-83 | 复用其 manifest.yaml 检测模式 |
| design-check 已有 context-aware 逻辑 (PS) | agent-flow/scripts/design-check.ps1:75-91 | 同上 |

##  Standards Snapshot

- Standards source: agent-flow/scripts/design-check.sh / .ps1 中已定义 project_root → manifest.yaml → kind/framework 检测模式
- 本次沿用: 相同的 manifest.yaml 检测模式
- 冲突或缺口: 当前 project_root 检测路径在脚手架自检时失效

## 测试基线

- 现有测试：scaffold-health, template-check, design-check, test-gate-smoke, test-check-change
- 可复用命令：bash agent-flow/scripts/scaffold-health.sh

## read_files

read_files:
  - agent-flow/templates/DESIGN.md
  - agent-flow/scripts/design-check.sh
  - agent-flow/scripts/design-check.ps1
  - agent-flow/scripts/generate-design.sh
  - agent-flow/scripts/generate-design.ps1
  - agent-flow/rules/design-decision.keys
  - agent-flow/manifest.yaml
  - agent-flow/test/test-scripts/test-gate-smoke.sh
  - agent-flow/test/test-scripts/test-gate-smoke.ps1
  - agent-flow/test/test-scripts/test-check-change.sh
  - agent-flow/test/test-scripts/test-check-change.ps1
  - agent-flow/test/fixtures/minimal-project/agent-flow/templates/DESIGN.md

## write_files

write_files:
  - agent-flow/templates/DESIGN.md
  - agent-flow/scripts/design-check.sh
  - agent-flow/scripts/design-check.ps1
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
