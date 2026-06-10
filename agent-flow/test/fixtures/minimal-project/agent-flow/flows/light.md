# Light 流程

适合低风险小改动。

## 步骤

1. 建立 `STATE.md` 和 `CHANGE.md`。
2. 执行最小代码扫描，写 `CODE_SCAN.md`。
3. 明确 `write_files`。
4. 实现。
5. 运行最小验证，写 `VERIFY.md`。
6. 写 `REPORT.md`。
7. 更新 `STATE.md`。
8. 如有新坑，更新 `agent-flow/knowledge/pitfalls.md`。

## 禁止

- 不允许跳过代码扫描。
- 不允许顺手重构无关文件。
- 不允许把 Light 扩大成跨模块修改。
