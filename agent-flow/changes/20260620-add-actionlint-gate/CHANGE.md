# Change: add-actionlint-gate

## 一句话需求

新增 actionlint gate 验证 GitHub Actions workflow YAML 语法，并在 CI 中添加 actionlint job。

## 背景

EVOLUTION.md (20260620-add-shell-lint-ci) 建议：新增 CI YAML workflow 语法验证 gate（如 actionlint），在修改 `.github/workflows/*.yml` 时自动触发。当前依赖 GitHub Actions 自身的运行时解析。

## 流程级别

- [ ] Light
- [x] Standard
- [ ] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由

新增 gate 脚本和 CI job，但不改 schema/权限/API。属于 Standard。

## 目标

- 创建 `agent-flow/scripts/actionlint-check.sh` 和 `.ps1`
- 注册到 `manifest.yaml`、`gates.txt`、`check-change`
- `.github/workflows/scaffold-ci.yml` 新增 actionlint job

## 非目标

- 不修改现有 CI job
- 不安装本地 actionlint

## 影响范围

- `agent-flow/scripts/actionlint-check.sh`（新）
- `agent-flow/scripts/actionlint-check.ps1`（新）
- `agent-flow/manifest.yaml`
- `agent-flow/rules/gates.txt`
- `agent-flow/scripts/check-change.sh`
- `agent-flow/scripts/check-change.ps1`
- `.github/workflows/scaffold-ci.yml`

## 关联前端

- [x] 否

## 风险

- **低**：非阻塞模式，actionlint 未安装时优雅跳过

## Emergency（仅 Emergency 流程填写）

- Level: P0 / P1
- Approved by:
- Bypass reason:
- Backfill deadline:
- Backfill status: pending / done / waived

## 工件索引

- State:
- Requirement:
- Code Scan:
- Design:
- Tasks:
- Verify:
- Report:
- Evolution:
