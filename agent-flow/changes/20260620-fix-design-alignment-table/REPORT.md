# Report

## Change

fix-design-alignment-table — 修复 DESIGN.md Alignment 表列头与 alignment-check 期望不匹配的问题。

## 完成内容

将 8 个文件中 Alignment / Grill 表的列头从 `| Question | AI Recommended Answer | Confirmation | Final Decision |` 统一修正为 `| # | Question | Confirmation | Evidence |`，数据行从无编号改为编号 1-5。

## 修改文件

| 文件 | 变更类型 |
|---|---|
| `agent-flow/templates/DESIGN.md` | 主模板列头修正 |
| `agent-flow/scripts/generate-design.sh` | 生成脚本列头修正 |
| `agent-flow/scripts/generate-design.ps1` | 生成脚本列头修正 |
| `agent-flow/test/fixtures/minimal-project/agent-flow/templates/DESIGN.md` | 测试 fixture 同步更新 |
| `agent-flow/test/test-scripts/test-gate-smoke.sh` | 测试数据同步更新 |
| `agent-flow/test/test-scripts/test-gate-smoke.ps1` | 测试数据同步更新 |
| `agent-flow/test/test-scripts/test-check-change.sh` | 测试数据同步更新 |
| `agent-flow/test/test-scripts/test-check-change.ps1` | 测试数据同步更新 |

## 验证证据

- scaffold-health: pass
- template-check: pass
- manifest-check: pass
- design-check: pass
- scan-check (strict): pass
- alignment-check: pass (skipped with reason)

## 未完成事项

无

## 风险和回滚

- 低风险。逐文件回滚即可恢复旧列头。

## 知识沉淀

- `agent-flow/templates/DESIGN.md` 的 Alignment 表列头必须与 `alignment-check.sh`/`.ps1` 的 header 检测（`#.*Question.*Confirmation`）一致。
- 修改模板时必须同步更新 `generate-design` 脚本和 `test/fixtures/minimal-project` 中的副本。

## 决策沉淀

无新 ADR。

## 日志和基线

- Log: agent-flow/logs/2026/06-20.md（如需）
- Known-Good Baseline: 无需更新

## 后续建议

- **Phase 2**: DESIGN.md 模板设计决策表上下文感知 — 非后端项目自动隐藏/简化 API/Permission 行
- **Phase 3**: 新增 actionlint gate 验证 CI YAML workflow 语法
