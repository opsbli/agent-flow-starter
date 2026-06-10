# Standard 流程

适合单模块、低到中风险功能。

## 步骤

1. 建立 change，并创建 `STATE.md`。
2. 需求澄清，写 `REQUIREMENT.md`。
3. 代码优先扫描，写 `CODE_SCAN.md`。
4. 技术设计，写 `DESIGN.md`。
5. 执行 `Design Alignment / Grill`，把对齐结论写回 `DESIGN.md`。
6. 拆任务，写 `TASKS.md`。
7. 按任务实现，每个任务有 verify。
8. 汇总验证，写 `VERIFY.md`。
9. 写 `REPORT.md`。
10. 写 `EVOLUTION.md`。
11. 更新 `STATE.md`。

## Design Alignment / Grill

Standard 需求也必须做一次轻量对齐：

- 一次只问一个关键问题。
- 如果问题可以通过读代码回答，先读代码。
- 每个问题给出 AI 推荐答案。
- 用户确认后，把结论写回 `DESIGN.md`。
- `Alignment Verdict` 必须是 `aligned`，或用户明确接受 `skipped` 且填写 `Skip Reason`。

## 标准完成线

- 所有 AC 都有验证证据。
- `alignment-check` 已通过。
- 模块编译通过。
- 相关测试通过或记录不可自动化原因。
- 知识/决策已沉淀。
