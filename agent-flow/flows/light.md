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
5. 明确 `write_files`。
6. 实现。
7. 运行最小验证，写 `VERIFY.md`。
8. 写 `REPORT.md`。
9. 更新 `STATE.md`。
10. 如有新坑，更新 `agent-flow/knowledge/pitfalls.md`。

## 禁止

- 不允许跳过代码扫描。
- 不允许顺手重构无关文件。
- 不允许把 Light 扩大成跨模块修改。
