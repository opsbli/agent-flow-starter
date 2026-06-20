# Code Scan

## 扫描时间

2026-06-20 15:00

## Machine Check

scan_time: 2026-06-20 15:00
related_modules: .github/workflows/scaffold-ci.yml
similar_implementations: syntax-check job (already in CI, bash -n + ParseFile)
reusable_abstractions: none (new CI job addition)
standards_snapshot: GitHub Actions workflow syntax v1
test_baseline: CI green on main branch (scaffold-health, smoke tests, unit tests)
read_files: .github/workflows/scaffold-ci.yml
write_files: .github/workflows/scaffold-ci.yml
open_questions: none

## 相关模块

- 模块：CI pipeline (.github/workflows/)
- 入口：`.github/workflows/scaffold-ci.yml` (全量 CI 定义)
- 关键 job：`syntax-check` (行130-172) 仅做语法检查，不做语义/模式检查

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| Bash 语法检查 | `.github/workflows/scaffold-ci.yml:130-149` | `bash -n` 遍历模式，可复用循环框架 |
| PS 语法检查 | `.github/workflows/scaffold-ci.yml:151-172` | `Get-ChildItem` + `ForEach-Object` 遍历模式 |
| 文件一致性 | `.github/workflows/scaffold-ci.yml:174-203` | ps1/sh 文件发现循环模式 |
| 性能基线记录 | `.github/workflows/scaffold-ci.yml:50-76` | Step Summary 输出模式 |

## 可复用抽象

- 抽象：`needs: scaffold-health` 依赖模式 — 所有质量 job 依赖基础健康检查先通过
- 复用方式：新 job 同样 `needs: scaffold-health`

## 禁止重复实现

- 不重复实现：文件遍历逻辑 — 直接使用 `shellcheck agent-flow/scripts/*.sh` 的 glob 支持
- 原因：shellcheck 原生支持 glob，不需要手动 `for` 循环收集文件路径

## Standards Snapshot

- Standards source: `.github/workflows/scaffold-ci.yml` 现有结构
- 本次沿用:
  - `runs-on: ubuntu-latest` / `runs-on: windows-latest` 分离 Linux/Win job
  - `needs: scaffold-health` 依赖链
  - Step Summary 性能基线格式
- 冲突或缺口:
  - 无

## 测试基线

- 现有测试：`scripts/test-starter.sh`, `agent-flow/test/test-scripts/test-gate-smoke.sh`
- 可复用命令：CI workflow_dispatch 手动触发验证

## read_files

read_files:
  - .github/workflows/scaffold-ci.yml

## write_files

write_files:
  - .github/workflows/scaffold-ci.yml

## 破坏性变更

- 无（新增 job，不修改已有逻辑）

## 未决问题

- 无
