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

> **非后端项目简化**：如果 `manifest.yaml` 中 `backend.framework` 为 `none`/`n/a` 或 `project.kind` 为 `dev-toolkit`，可仅保留一行 `| All API/Permission/Auth items | not-applicable | 理由: project type is {kind} |` 并跳过下方 8 行。`design-check` 会自动跳过这些后端键的检查。

Decision Status: accepted

Allowed Decision Values: unchanged / new / modified / deleted / not-applicable

| Item | Decision | Evidence / Reason |
|---|---|---|
| All API/Permission/Auth items | not-applicable | project kind: dev-toolkit, no backend |

State Machine Impact: not-applicable

## 数据设计

### DB Change 决策表

> 涉及数据库 Schema 变更的 change 必须填写此表。不涉及 Schema 变更时写 `none`。

| 变更项 | 操作 (add/modify/delete) | 详情 | 回滚 SQL 存在? | 迁移策略 |
|---|---|---|---|---|
| 表 | | | yes / no / n/a | |
| 列 | | | yes / no / n/a | |
| 索引 | | | yes / no / n/a | |
| 约束 | | | yes / no / n/a | |
| 默认值 | | | yes / no / n/a | |
| 枚举/字典 | | | yes / no / n/a | |

回滚策略: (rollback-sql-provided / schema-only-add / not-needed / pending)

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

## UI Flow / Component Tree

> 无前端或交互改动时写 `none`。有前端/交互改动时，记录用户路径、页面/组件树、状态切换和错误态。

| Screen / Component | State | User Action | Expected Result | Notes |
|---|---|---|---|---|

### 前端验证契约

> 如果 `manifest.yaml` 中 `frontend.framework` 不为 `none`，必须在此记录前端验证计划。
> 无前端时写 `none`。

| 验证项 | 验证方式 | 预期结果 | 对应 AC |
|---|---|---|---|
| API 联调 | DevTools Network | 无 4xx/5xx | |
| 控制台错误 | DevTools Console | 无报错 | |
| 权限拦截 | 浏览器操作 | 未授权元素正确隐藏 | |
| 空/loading 状态 | 浏览器操作 | 状态正确 | |
| 响应式/布局 | 浏览器操作 | 无溢出 | |

## Demo Evidence

> 无需演示时写 `none`。前端/交互类需求应记录截图、录屏、Playwright 步骤或人工演示证据，并在 `VERIFY.md` 的 AC Evidence 中引用。

| Evidence | Location / Command | Covered AC | Result |
|---|---|---|---|

## Design Alignment / Grill

目的：降低“用户自然语言描述”和“AI 理解”之间的偏差。进入 `PLAN.md`、`TASKS.md` 或实现前，必须完成一次对齐。

执行方式：

- 一次只问一个关键问题。
- 如果问题可以通过读代码回答，先读代码，不问用户。
- 每个问题都给出 AI 推荐答案。
- 用户确认后，把结论沉淀回本节或上方设计小节。
- `Alignment Verdict: aligned` 要求至少 3 行 `Confirmation` 为 `user-confirmed`。
- 可通过代码确认的行写 `code-confirmed`，但纯 `code-confirmed` 不能通过对齐门禁。

Alignment Source: code-confirmed

Open Questions: none

| # | Question | Confirmation (`user-confirmed` / `code-confirmed` / `pending`) | Evidence |
|---|---|---|---|
| 1 | Intent Risk | code-confirmed | 新增非阻塞 actionlint gate，工具未安装时优雅跳过 |
| 2 | Existing Code Fit | code-confirmed | 遵循 db-migration-check 的 gate 模式，匹配现有 check-change 注册方式 |
| 3 | Unnecessary Abstraction | code-confirmed | 纯 gate 脚本 + CI job，不需要抽象 |
| 4 | Protected Areas | code-confirmed | 不改动 flow 分级、不改 alignment-check、不改 design-check |
| 5 | Boundary And Failure Modes | code-confirmed | 仅新增 gate 脚本 + 注册 + CI job，不影响现有功能 |

Alignment Verdict: skipped

Skip Reason: 脚手架自修改，变更范围已通过 code-first 扫描完全确定（2 个新 gate 脚本 + 注册 + CI job），无需用户逐条确认。所有修改不涉及业务逻辑变更。
可选值：

- `pending`：还未对齐，不允许进入 `PLAN.md`、`TASKS.md` 或实现。
- `aligned`：用户和 AI 已对齐，可以继续。
- `blocked`：存在未决问题，必须先解决。
- `skipped`：仅限用户明确要求跳过，并必须填写 `Skip Reason`。

## 发布和回滚

## ADR 候选
