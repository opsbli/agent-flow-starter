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

## 两次对齐环节说明

Standard 需求有两个明确的检查点，不要混淆：

### 检查点 1 — Requirements Grill（步骤 2）

- **时机**：写 REQUIREMENT.md 之前
- **目的**：对齐术语、挑战需求假设、沉淀领域知识
- **工具**：`grill-with-docs` 技能
- **产物更新**：`REQUIREMENT.md` 或 `agent-flow/knowledge/`
- **核心问题**：
  - "这个术语在代码中是什么意思？"
  - "这个假设当前代码支持吗？"
  - "哪些场景明确不做？"
  - （每次只问一个关键问题，给出AI推荐答案）

### 检查点 2 — Design Alignment（步骤 7）

> **意图**：在设计方案写完、进入实现前，做一次设计正确性的轻量确认。

- **时机**：DESIGN.md 完成、implement 之前
- **目的**：确保设计方案与用户意图一致
- **工具**：`alignment-check` gate
- **产物更新**：`DESIGN.md` 的 `Design Alignment / Grill` 小节
- **核心约束**：
  - 一次只问一个关键问题
  - 如果问题能通过读代码回答，先读代码
  - 每个问题给出 AI 推荐答案
  - 用户确认后，把结论写回 `DESIGN.md`
  - `Alignment Verdict` 必须是 `aligned`，或用户明确接受 `skipped` 且填写 `Skip Reason`

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
