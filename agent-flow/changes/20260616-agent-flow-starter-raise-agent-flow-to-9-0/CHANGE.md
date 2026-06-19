# Change: 20260616-agent-flow-starter-raise-agent-flow-to-9-0

## 一句话需求
再次从开发流程、门禁、模板、跨平台、安装升级、知识沉淀和可维护性等维度评分 agent-flow，并判断是否还需要按优先级修复到 9.0。

## 背景
仓库已有两轮治理和 hardening 记录：

- `20260615-agent-flow-starter-agent-flow-governance-9plus` 将评分从约 8.5 提升到约 9.1。
- `20260616-agent-flow-starter-agent-flow-9-0-hardening` 补齐安装洁净度、alignment 语义、bash init parity、closure 聚合和 CI workflow ownership，并记录 9.0 baseline。

本次目标是重新从当前 live scaffold 验证评分，而不是重复上一轮修复。

## 流程级别

- [ ] Light
- [ ] Standard
- [x] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由
Heavy。评估对象是 `agent-flow` 流程和 starter 契约本身，若需要修复会触碰 workflow/gate/template 公共契约。

## 目标
- 给出多维度当前评分。
- 基于 live scripts/docs/tests 识别强项和剩余优化项。
- 只在当前评分低于 9.0 或发现阻断性回归时修改 tracked scaffold 文件。
- 记录本次验证证据。

## 非目标
- 不重做上一轮已完成的 9.0 hardening。
- 不新增流程级别。
- 不为冲 9.5+ 引入新依赖或大范围重构。

## 影响范围
- `agent-flow/` 流程文档、门禁脚本、模板和知识库的评估。
- 根级 starter self-test 的评估。
- 本次 change 文档。

## 关联前端

- [ ] 否
- [ ] 是：`none`

## 风险
- 当前评分已经达到 9.0 以上时，继续修改核心脚本可能带来无收益回归。
- 评分必须以 live verification 为准，不能只沿用历史报告。

## 需要用户确认的问题
无阻断问题。本次不进入 tracked scaffold 实现；若后续要冲 9.5+，建议单独开 change 做 JSON/golden-output parity。

## Emergency（仅 Emergency 流程填写）

- Level: P0 / P1
- Approved by:
- Bypass reason:
- Backfill deadline:
- Backfill status: pending / done / waived

## 工件索引

- State: `STATE.md`
- Requirement: `REQUIREMENT.md`
- Code Scan: `CODE_SCAN.md`
- Design: not needed for no-op assessment result
- Tasks: not needed for no-op assessment result
- Verify: `VERIFY.md`
- Report: `REPORT.md`
- Evolution: `EVOLUTION.md`

