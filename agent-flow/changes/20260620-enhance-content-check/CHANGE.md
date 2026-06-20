# Change: enhance-content-check

## 一句话需求

增强 `content-check.sh/ps1`：新增 `--project-root` 模式扫描 `agent-flow/core/` 和 `agent-flow/rules/` 目录的占位符；注册到 `check-change.sh/ps1`。

## 背景

`content-check` 原仅检查 change 工件（CHANGE.md、DESIGN.md 等）的内容质量。`agent-flow/core/` 和 `rules/` 目录中的文档和规则文件从未被扫描，存在占位符/未填充内容漏检的风险。

## 流程级别

- [ ] Light
- [x] Standard
- [ ] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 影响范围

- `agent-flow/scripts/content-check.sh`
- `agent-flow/scripts/content-check.ps1`
- `agent-flow/scripts/check-change.sh`
- `agent-flow/scripts/check-change.ps1`

## 风险

- **低**：已有内容全部 21/21 通过

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
