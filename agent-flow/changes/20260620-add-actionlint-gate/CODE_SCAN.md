# Code Scan

> **Light 模式**：只需填写「扫描时间」「read_files」「write_files」「未决问题」四个字段。
> **Standard / Heavy 模式**：填写全部字段。

## 扫描时间

2026-06-20 19:00

## Machine Check

scan_time: 2026-06-20 19:00
related_modules: scripts/actionlint-check.sh, scripts/actionlint-check.ps1
similar_implementations: scripts/db-migration-check.sh/ps1 (gate 模式参考), scripts/check-change.sh/ps1 (注册方式参考)
reusable_abstractions: 使用 check-change 中的 run_gate/Invoke-Gate 模式
standards_snapshot: 使用非阻塞 gate 模式（continue-on-error: true），与 shellcheck/PSScriptAnalyzer CI job 一致
test_baseline: scaffold-health, manifest-check
read_files: agent-flow/scripts/db-migration-check.sh, agent-flow/scripts/db-migration-check.ps1, agent-flow/scripts/check-change.sh, agent-flow/scripts/check-change.ps1, agent-flow/manifest.yaml, agent-flow/rules/gates.txt, .github/workflows/scaffold-ci.yml
write_files: agent-flow/scripts/actionlint-check.sh, agent-flow/scripts/actionlint-check.ps1, agent-flow/manifest.yaml, agent-flow/rules/gates.txt, agent-flow/scripts/check-change.sh, agent-flow/scripts/check-change.ps1, .github/workflows/scaffold-ci.yml
open_questions: none

## 相关模块

- 模块：agent-flow scripts/gates, CI workflows
- 入口：agent-flow/scripts/actionlint-check.sh

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| Non-blocking CI gate | .github/workflows/scaffold-ci.yml 中 static-analysis (shellcheck) job | continue-on-error: true + Step Summary 输出 |
| Gate 注册模式 | agent-flow/scripts/db-migration-check.sh | --project-root 参数 + exit 0 |

## Standards Snapshot

- Standards source: 已有 shellcheck/PSScriptAnalyzer CI job 模式
- 本次沿用: 非阻塞、advisory-only、Step Summary 输出

## 测试基线

- 现有测试：scaffold-health, manifest-check, template-check
- 可复用命令：bash agent-flow/scripts/scaffold-health.sh, bash agent-flow/scripts/actionlint-check.sh

## read_files

read_files:
  - agent-flow/scripts/db-migration-check.sh
  - agent-flow/scripts/db-migration-check.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/check-change.ps1
  - agent-flow/manifest.yaml
  - agent-flow/rules/gates.txt
  - .github/workflows/scaffold-ci.yml

## write_files

write_files:
  - agent-flow/scripts/actionlint-check.sh (NEW)
  - agent-flow/scripts/actionlint-check.ps1 (NEW)
  - agent-flow/manifest.yaml
  - agent-flow/rules/gates.txt
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/check-change.ps1
  - .github/workflows/scaffold-ci.yml

## 破坏性变更

无

## 未决问题

无
