# Design

## 设计目标
把 P0/P1 改进落入现有 agent-flow 表面：增强现有 gate，补充可追踪知识文件和索引，减少新增流程级别和额外模板。

## 设计约束

说明本次设计必须服从的硬约束，例如性能、延迟、并发、部署、第三方依赖、合规等。没有特殊约束时写 `none`。
none。不得引入外部依赖；ps1/sh 必须对等；内容必须保持通用。

## 模块边界
- Scripts：只改 canonical scripts 和 starter self-test。
- Templates：只补充通用字段，不引入业务示例。
- Knowledge/decisions：新增通用 tracker/index。
- Docs：README 快速入口和使用说明。

## 复用现有抽象
- 使用现有 `manifest-check` warnings 模式。
- 使用现有 `ac-check` 入口和 `VERIFY.md` AC Evidence 表。
- 使用现有 self-test 临时项目和 helper 函数。

## 不复用的原因
不新增 `coverage-check`、`REQUIREMENT_ALIGNED.md`、`DEMO_RECORD.md`，因为现有 `ac-check`、`DESIGN.md`、`VERIFY.md` 可承载这些职责。

## 非功能需求

| 维度 | 要求 / 无特殊要求 | 验证方式 |
|---|---|---|
| 性能 | 无特殊要求 | 脚本自测 |
| 延迟 | 无特殊要求 | 脚本自测 |
| 并发 | 无特殊要求 | 不涉及 |
| 可用性 | gate 输出必须可读 | 自测输出和手工检查 |
| 安全 | 不扩大 shell 执行面 | 代码检查 |
| 可观测性 | gate failure 必须指出缺失项 | 负例自测 |

## API 设计

| 方法 | 路径 | 权限 | 入参 | 出参 |
|---|---|---|---|---|
| not-applicable | not-applicable | not-applicable | not-applicable | not-applicable |

## API / Permission / Auth Decisions

必须明确记录，即使结论是 `unchanged` 或 `not-applicable`。

Decision Status: accepted

Allowed Decision Values: unchanged / new / modified / deleted / not-applicable

| Item | Decision | Evidence / Reason |
|---|---|---|
| REST Path | not-applicable | No API or route changes |
| HTTP Method | not-applicable | No API or route changes |
| Permission Code | not-applicable | No permission model changes |
| SaCheckPermission | not-applicable | No Java/controller auth changes |
| Anonymous Interface | not-applicable | No public interface changes |
| Login/Token | unchanged | No auth/session changes |
| Tenant/Data Permission | unchanged | No tenant/data scope changes |
| State Machine Impact | no | No runtime workflow/status changes |

State Machine Impact: no

## 数据设计
无数据结构修改。

## State Machine

普通 CRUD 可写 `State Machine Impact: no`。涉及 workflow/status/state machine 的 change 必须补充下面三节。
State Machine Impact: no

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
不涉及运行时 service 编排。

## 错误处理
- `manifest-check` 对 TODO 保持 warning/pass，避免 starter 安装在空项目后硬失败。
- `ac-check` 对缺失 `VERIFY.md`、缺失 AC Evidence 表、缺字段、失败结果给出明确错误。

## 幂等 / 限流 / 审计
不涉及。

## 安全和权限
不涉及。

## 测试策略

| AC | 测试文件 | 测试方法 | 类型 |
|---|---|---|---|
| AC-01 | `scripts/test-starter.ps1/.sh` | 初始化空项目后运行 manifest-check 并保留 TODO warning | integration |
| AC-02 | `scripts/test-starter.ps1/.sh` | 构造缺失/不完整 AC Evidence 负例，断言 ac-check 失败 | negative |
| AC-03 | `scripts/test-starter.ps1/.sh` | 构造完整 AC Evidence 正例，断言 ac-check 通过 | positive |
| AC-04 | `scripts/test-starter.ps1/.sh` | 增加 scan/design/alignment/code-drift/blocked/task-boundary 负例 | negative |
| AC-05 | 文件检查 | README/template/tracker/index 内容存在 | static |
| AC-06 | `scaffold-health.ps1/.sh` | 双平台健康检查 | integration |

## UI Flow / Component Tree

无前端改动。

## Demo Evidence

无 UI demo；以脚手架自测输出作为证据。

## Design Alignment / Grill

目的：降低“用户自然语言描述”和“AI 理解”之间的偏差。进入 `PLAN.md`、`TASKS.md` 或实现前，必须完成一次对齐。

执行方式：

- 一次只问一个关键问题。
- 如果问题可以通过读代码回答，先读代码，不问用户。
- 每个问题都给出 AI 推荐答案。
- 用户确认后，把结论沉淀回本节或上方设计小节。

Alignment Source: mixed

Open Questions: none

| Question | AI Recommended Answer | Confirmation | Final Decision |
|---|---|---|---|
| Intent Risk | Implement P0/P1 without adding Medium or enterprise-only features. | confirmed | Keep scope to P0/P1 list from review. |
| Existing Code Fit | Reuse current scripts/templates/self-test. | confirmed | Strengthen existing surfaces. |
| Unnecessary Abstraction | Avoid new coverage-check and extra alignment/demo templates. | confirmed | Extend ac-check and DESIGN/VERIFY instead. |
| Protected Areas | No runtime schema/auth/API/deploy protected areas touched. | confirmed | Proceed. |
| Boundary And Failure Modes | Main risk is stricter gates breaking self-test. | confirmed | Add positive and negative self-tests. |

Alignment Verdict: aligned

Skip Reason:

可选值：

- `pending`：还未对齐，不允许进入 `PLAN.md`、`TASKS.md` 或实现。
- `aligned`：用户和 AI 已对齐，可以继续。
- `blocked`：存在未决问题，必须先解决。
- `skipped`：仅限用户明确要求跳过，并必须填写 `Skip Reason`。

## 发布和回滚
发布：starter 文件更新后通过 install/self-test 分发到目标项目。

回滚：撤销本次脚本、模板、README、knowledge/decisions 新增文件和本 change 工件。

## ADR 候选
无需新增 ADR；本次是既有 scaffold 的增量质量改进。新增 ADR index 而非决策本身。

