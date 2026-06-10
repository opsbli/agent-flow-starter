# Design

## 设计目标

## 模块边界

## 复用既有抽象

## 不复用的原因

## API 设计

| 方法 | 路径 | 权限 | 入参 | 出参 |
|---|---|---|---|---|

## API / Permission / Auth 决策

必须明确记录，即使结论是“不变”。

| 项 | 决策 | 说明 |
|---|---|---|
| REST 路径 | 不变 / 新增 / 修改 / 删除 | |
| HTTP Method | 不变 / 新增 / 修改 / 删除 | |
| 权限码 | 不新增 / 新增 / 修改 / 删除 | |
| `@SaCheckPermission` | 不变 / 新增 / 修改 / 删除 | |
| 匿名接口 | 不新增 / 新增 / 修改 / 删除 | |
| 登录态 / Token | 不变 / 修改 | |
| 租户 / 数据权限 | 不变 / 修改 | |

## 数据设计

## 状态机

普通 CRUD 可写“不涉及状态机”。涉及 workflow/status/state machine 的 change 必须补充：

### Status Vocabulary

| 状态 | 来源 | 含义 | 是否新写入 | 前端展示 |
|---|---|---|---|---|

### Status Mapping

| 输入/旧状态 | 目标状态 | 使用位置 | 兼容策略 |
|---|---|---|---|

### Legacy Compatibility

| 旧值 | 新值 | 查询兼容 | 写入兼容 | 是否迁移 |
|---|---|---|---|---|

## Service 编排

## 错误处理

## 幂等 / 限流 / 审计

## 安全和权限

## 测试策略

| AC | 测试文件 | 测试方法 | 类型 |
|---|---|---|---|

## Design Alignment / Grill

目的：降低“用户自然语言描述”和“AI 理解”之间的偏差。进入 `PLAN.md` 或 `TASKS.md` 前，必须完成一次对齐。

执行方式：

- 一次只问一个关键问题。
- 如果问题可以通过读代码回答，先读代码，不要问用户。
- 每个问题都给出 AI 推荐答案。
- 用户确认后，把结论沉淀回本节或上方设计小节。

必问检查：

| 问题 | AI 推荐答案 | 用户确认 | 最终结论 |
|---|---|---|---|
| 这个设计最可能误解用户意图的地方是什么？ | | pending / confirmed | |
| 有没有更贴近现有代码的实现方式？ | | pending / confirmed | |
| 是否新增了不必要的抽象、状态或配置？ | | pending / confirmed | |
| 是否触碰 protected areas？ | | pending / confirmed | |
| 哪些需求边界、失败场景或非目标仍可能歧义？ | | pending / confirmed | |

Alignment Verdict: pending

Skip Reason:

可选值：

- `pending`：还未对齐，不允许进入 `PLAN.md` 或 `TASKS.md`。
- `aligned`：用户和 AI 已对齐，可以继续。
- `blocked`：存在未决问题，必须先解决。
- `skipped`：仅限用户明确要求跳过，并必须填写 `Skip Reason`。

## 发布和回滚

## ADR 候选
