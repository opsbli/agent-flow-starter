# 路由

## Light

适用：

- 单文件低风险修复。
- 文案、注释、局部样式。
- 已有测试覆盖下的小行为修正。

最低产物：

- `CHANGE.md`
- `CODE_SCAN.md`
- `VERIFY.md`
- `REPORT.md`

## Standard

适用：

- 单模块功能。
- 标准 CRUD。
- 明确需求，无复杂状态机。
- 不改公共契约。

最低产物：

- `CHANGE.md`
- `REQUIREMENT.md`
- `CODE_SCAN.md`
- `DESIGN.md`
- `TASKS.md`
- `VERIFY.md`
- `REPORT.md`

## Heavy

适用：

- 老项目新增业务模块。
- 跨模块协作。
- 改数据库 schema。
- 改权限、认证、Token、限流、防重。
- 涉及 Redis、WebSocket、工作流、状态机。
- 前后端联动。
- 生产事故成本高。

最低产物：

- `CHANGE.md`
- `REQUIREMENT.md`
- `CODE_SCAN.md`
- `DESIGN.md`
- `TASKS.md`
- `VERIFY.md`
- `REVIEW.md`
- `REPORT.md`
- `EVOLUTION.md`
- 必要 ADR

## 降级三问

只有三问全部为“否”，才能从 Heavy 降级：

1. 是否跨模块、跨仓库或跨系统边界？
2. 是否修改 schema、状态机、权限、认证、公共 API 或外部副作用？
3. 出错后是否难以被普通测试或人工检查快速发现？

任一为“是”，保持 Heavy。
