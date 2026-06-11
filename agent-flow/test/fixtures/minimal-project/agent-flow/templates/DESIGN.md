# Design

## 设计目标

## 设计约束

说明本次设计必须服从的硬约束，例如性能、延迟、并发、部署、第三方依赖、合规等。没有特殊约束时写 `none`。

## 模块边界

## 复用现有抽象

## 不复用的原因

## 非功能需求

| 维度 | 要求 / 无特殊要求 | 验证方式 |
|---|---|---|
| 性能 | | |
| 延迟 | | |
| 并发 | | |
| 可用性 | | |
| 安全 | | |
| 可观测性 | | |

## API 设计

| 方法 | 路径 | 权限 | 入参 | 出参 |
|---|---|---|---|---|

## API / Permission / Auth Decisions

必须明确记录，即使结论是 `unchanged` 或 `not-applicable`。

Decision Status: pending

Allowed Decision Values: unchanged / new / modified / deleted / not-applicable

| Item | Decision | Evidence / Reason |
|---|---|---|
| REST Path | pending | |
| HTTP Method | pending | |
| Permission Code | pending | |
| SaCheckPermission | pending | |
| Anonymous Interface | pending | |
| Login/Token | pending | |
| Tenant/Data Permission | pending | |
| State Machine Impact | pending | |

State Machine Impact: pending

## 数据设计

## State Machine

普通 CRUD 可写 `State Machine Impact: no`。涉及 workflow/status/state machine 的 change 必须补充下面三节。

### Status Vocabulary

| Status | Source | Meaning | New Write? | Frontend Display |
|---|---|---|---|---|

### Status Mapping

| Input / Legacy Status | Target Status | Usage Location | Compatibility Strategy |
|---|---|---|---|

### Legacy Compatibility

| Legacy Value | New Value | Query Compatibility | Write Compatibility | Migration Required |
|---|---|---|---|---|

## Service 编排

## 错误处理

## 幂等 / 限流 / 审计

## 安全和权限

## 测试策略

| AC | 测试文件 | 测试方法 | 类型 |
|---|---|---|---|

## Design Alignment / Grill

目的：降低“用户自然语言描述”和“AI 理解”之间的偏差。进入 `PLAN.md`、`TASKS.md` 或实现前，必须完成一次对齐。

执行方式：

- 一次只问一个关键问题。
- 如果问题可以通过读代码回答，先读代码，不问用户。
- 每个问题都给出 AI 推荐答案。
- 用户确认后，把结论沉淀回本节或上方设计小节。

Alignment Source: pending

Open Questions: pending

| Question | AI Recommended Answer | Confirmation | Final Decision |
|---|---|---|---|
| Intent Risk | | pending | |
| Existing Code Fit | | pending | |
| Unnecessary Abstraction | | pending | |
| Protected Areas | | pending | |
| Boundary And Failure Modes | | pending | |

Alignment Verdict: pending

Skip Reason:

可选值：

- `pending`：还未对齐，不允许进入 `PLAN.md`、`TASKS.md` 或实现。
- `aligned`：用户和 AI 已对齐，可以继续。
- `blocked`：存在未决问题，必须先解决。
- `skipped`：仅限用户明确要求跳过，并必须填写 `Skip Reason`。

## 发布和回滚

## ADR 候选
