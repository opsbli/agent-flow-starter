---
description: agent-flow DESIGN — 架构设计，输出 DESIGN.md + ADR
argument-hint: "[模块/功能描述]"
---
# agent-flow Design

> 执行 agent-flow Standard/Heavy 的设计步骤

功能：$@

## 流程

1. 读取 CODE_SCAN.md 的扫描结果
2. 使用 @ecc-architect 设计架构方案
3. 参考对应语言/框架的 ECC skill 确保模式一致性
4. 写 DESIGN.md（含 Design Alignment / Grill）
5. 如需不可逆决策，写 ADR 到 `agent-flow/decisions/`
6. 运行 `design-check` 和 `alignment-check`

## 参考技能
- /skill:api-design — API 设计
- /skill:backend-patterns — 后端架构
- /skill:frontend-patterns — 前端架构
- /skill:database-migrations — 数据库设计
- /skill:error-handling — 错误处理
- /skill:security-review — 安全设计
