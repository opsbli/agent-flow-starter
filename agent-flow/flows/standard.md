# Standard 流程

适合单模块、低到中风险功能。

## 步骤

1. 建立 change，并创建 `STATE.md`。
2. 执行 `grill-with-docs` 对本次需求进行结构化追问：
   - 明确每个业务名词的精确定义。
   - 对照现有代码和文档验证假设。
   - 每次只问一个关键问题，给出 AI 推荐答案。
   - 用户确认后，把结论写回 `REQUIREMENT.md` 或 `agent-flow/knowledge/`。
   - 遇到不可逆取舍，创建 ADR 到 `agent-flow/decisions/`。
3. 需求澄清，写 `REQUIREMENT.md`（包含 grill 对齐结论）。
4. 代码优先扫描，写 `CODE_SCAN.md`。
5. 运行 `scan-check`。
6. 技术设计，写 `DESIGN.md`，运行 `design-check`。
7. 执行 `Design Alignment / Grill`，把对齐结论写回 `DESIGN.md`，运行 `alignment-check`。
8. 拆任务，写 `TASKS.md`，每个任务必须有状态、AC、read_files、write_files、验证命令。
9. 运行 `task-check`。
10. 按任务实现，每个任务有 verify，并更新任务状态。
11. 汇总验证，写 `VERIFY.md`。
12. 写 `REPORT.md`。
13. 写 `EVOLUTION.md`，运行 `evolution-check`。
14. 更新 `STATE.md`。

## Grill 环节说明

Standard 需求有两次 Grill 环节：

1. **步骤 2（前置 Grill）** — 在需求澄清前，用 `grill-with-docs` 对齐术语、挑战假设、沉淀知识。产物写回 `REQUIREMENT.md` 或 `agent-flow/knowledge/`。
2. **步骤 7（Design Alignment）** — 在设计完成后，做一次轻量对齐确认设计正确。产物写回 `DESIGN.md`。

### Design Alignment / Grill

Standard 需求也必须做一次轻量对齐：

- 一次只问一个关键问题。
- 如果问题可以通过读代码回答，先读代码。
- 每个问题给出 AI 推荐答案。
- 用户确认后，把结论写回 `DESIGN.md`。
- `Alignment Verdict` 必须是 `aligned`，或用户明确接受 `skipped` 且填写 `Skip Reason`。

## 标准完成线

- 所有 AC 都有验证证据。
- `scan-check` 已通过。
- `design-check` 已通过。
- `alignment-check` 已通过。
- `task-check` 已通过。
- `task-boundary-check` 已通过或记录跳过原因。
- `manifest-check` 已通过。
- `evolution-check` 已通过。
- 模块编译通过。
- 相关测试通过或记录不可自动化原因。
- 知识/决策已沉淀。
