# Change: fix-design-alignment-table

## 一句话需求

修复 DESIGN.md 模板的 Design Alignment / Grill 表格列头，使之与 `alignment-check` 门禁期望的 `| # | Question | Confirmation | Evidence |` 一致。

## 背景

`agent-flow/templates/DESIGN.md` 中 Alignment 表的列头为 `| Question | AI Recommended Answer | Confirmation | Final Decision |`，但 `alignment-check.sh` 和 `alignment-check.ps1` 期望的列头是 `| # | Question | Confirmation | Evidence |`。

当前情况：
- alignment-check 的 header 检测（查找 `#` 和 `Question`）无法匹配模板，column-count 检测被静默跳过
- 数据行恰好列数相同，功能上暂能通过，但列头语义不匹配
- `generate-design` 脚本、test fixtures、smoke/integration tests 中也使用了同样的错误列头

## 流程级别

- [ ] Light
- [x] Standard
- [ ] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由

单模板修复，涉及多个文件（模板、脚本、测试），但不改 schema/权限/API。属于 Standard。

## 目标

- `agent-flow/templates/DESIGN.md` 的 Alignment 表使用 `| # | Question | Confirmation | Evidence |`
- `generate-design.ps1/.sh` 输出正确列头
- 所有 test fixtures 和 smoke/integration tests 同步更新
- alignment-check 的 header 检测能正确识别模板

## 非目标

- 不改动 alignment-check 脚本的检测逻辑
- 不改动 design-alignment.questions 的内容
- 不改动其他模板或流程文档

## 影响范围

- `agent-flow/templates/DESIGN.md`（主模板）
- `agent-flow/scripts/generate-design.ps1`
- `agent-flow/scripts/generate-design.sh`
- `agent-flow/test/fixtures/minimal-project/agent-flow/templates/DESIGN.md`
- `agent-flow/test/test-scripts/test-gate-smoke.sh`
- `agent-flow/test/test-scripts/test-gate-smoke.ps1`
- `agent-flow/test/test-scripts/test-check-change.sh`
- `agent-flow/test/test-scripts/test-check-change.ps1`

## 关联前端

- [x] 否

## 风险

- **低**：模板列名改动，不影响逻辑。测试修改后需通过所有 gate。
- 如果测试 fixture 未同步更新，smoke test 可能因 alignment-check 检测新列头而失败。

## 需要用户确认的问题

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
