# Light 流程

适合低风险小改动。

## 步骤

1. 执行 `grill-with-docs` 对本次改动进行快速追问和术语对齐。
   - 如果问题可以通过读代码回答，先读代码，不要问用户。
   - 每次只问一个关键问题，给出 AI 推荐答案。
   - 用户确认后，把结论写回 `CHANGE.md`，再继续下一步。
2. 建立 `STATE.md` 和 `CHANGE.md`（含 grill 对齐结论）。
3. 执行最小代码扫描，写 `CODE_SCAN.md`。
4. 运行 `scan-check`。
   > scan-check 在 Light 中为 warn 级别：未通过时记录但不阻塞。
   > 如果 scan-check 发现超出 Light 范围的风险，应考虑升级为 Standard。
5. 明确 `write_files`。推荐运行 `task-boundary-check` 确认边界：
   ```powershell
   agent-flow/scripts/task-boundary-check.ps1 -ChangeDir agent-flow/changes/<change-id>
   ```
6. 根据改动类型选择实现方式：

   **A. 极简模式（仅文案/注释/样式，无代码逻辑改动）**
   - 直接修改目标文件。
   - 运行最小验证，确认改动效果。
   - 不需要 TDD 三步。

   **B. TDD 模式（含代码逻辑改动）**
   - 🔴 **RED** — 先写失败测试，运行并确认测试失败（验证测试确实因缺少实现而失败）。
   - 🟢 **GREEN** — 写最小实现代码，运行测试并确认通过。
   - 🔵 **REFACTOR** — 重构代码，保持测试通过。
   - 将 RED 和 GREEN 的验证结果记录到 `CHANGE.md` 或 `VERIFY.md` 的 AC Evidence 中。
7. 运行最小验证，写 `VERIFY.md`。
8. 写 `REPORT.md`。
9. 更新 `STATE.md`。
10. 如有新坑，更新 `agent-flow/knowledge/pitfalls.md`。
11. 调用 `manage_plan clear` 清空计划面板，避免残留到下一轮对话。

## 禁止

- 不允许跳过代码扫描。
- 不允许顺手重构无关文件。
- 不允许把 Light 扩大成跨模块修改。
- 极简模式（文案/注释/样式）允许跳过 TDD，但如果改动涉及**任何代码逻辑变更**，必须走 TDD 模式。
