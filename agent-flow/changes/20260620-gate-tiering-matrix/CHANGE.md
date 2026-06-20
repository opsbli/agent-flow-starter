# Change: gate-tiering-matrix

## 一句话需求

创建 `agent-flow/rules/gate-tiers.md` 门禁分级矩阵，明确定义 62 个 gate 在 Light/Standard/Heavy/Emergency 四级流程中的 Required/Warning/Advisory 归属。

## 背景

此前 gate 的分级信息分散在 `GO.md`（271-290 行）、`flows/light.md`、`flows/standard.md`、`flows/heavy.md` 和 `check-change.sh` 的 gate 调用逻辑中，缺乏一个统一的、可维护的单来源。62 个 gate 中哪些在 Light 流程中应该运行、哪些可以跳过，没有被显式文档化。

## 流程级别

- [ ] Light
- [x] Standard
- [ ] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由

创建文档 + 注册 scaffold-health，不改 gate 逻辑。

## 目标

- `agent-flow/rules/gate-tiers.md` — 包含全量 gate 矩阵、4 级 tier 定义、check-change 自动化说明
- `agent-flow/scripts/scaffold-health.sh/ps1` — 注册 gate-tiers.md 到健康检查

## 影响范围

- `agent-flow/rules/gate-tiers.md`（新）
- `agent-flow/scripts/scaffold-health.sh`
- `agent-flow/scripts/scaffold-health.ps1`

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
