# Design

## 设计概述

在 `sys_user` 表新增 `notification_enabled TINYINT(1) DEFAULT 1` 字段，通过现有 `SysUser` 实体、`ISysUserService`、`SysUserController` 提供 GET/PUT 两个接口。

## 关键决策

| # | 决策点 | 选项 A | 选项 B | 选择 | 理由 | 代码引用 |
|---|--------|--------|--------|------|------|---------|
| D-01 | Schema 变更方式 | ALTER TABLE 新增列 | 新建 user_notification_pref 表 | **A — ALTER TABLE** | 通知偏好是用户的一对一属性，无需独立表。独立表增加 JOIN 开销和代码复杂度 | — |
| D-02 | 默认值 | `DEFAULT 1`（opt-out） | `DEFAULT 0`（opt-in） | **A — opt-out** | 用户调研显示 80% 用户希望收到通知；opt-out 不改变现有用户体验 | — |
| D-03 | REST 路径 | `GET/PUT /system/user/profile/notification` | `GET/PUT /system/user/notification` | **A — profile 子资源** | 与现有 `GET /system/user/profile` 一致，清晰表达"通知偏好是用户 profile 的一部分" | `SysUserController.java:45 GET /system/user/profile` |
| D-04 | Service 方法设计 | 新增独立方法 | 复用 `updateById` | **A — 新增独立方法** | `updateUserNotification(Boolean enabled)` 封装 `SecurityUtils.getUserId()`，避免 Controller 层获取 userId 再传给通用 updateById，降低调用方误用风险 | `SysUserController.java:69-92` 已有类似模式 |
| D-05 | 响应格式 | `{ "notificationEnabled": true }` | `{ "userId": 1, "notificationEnabled": true }` | **A — 仅返回开关值** | 调用方只需知道开关状态，userId 从 token 已知。与前端协定的最小数据原则一致 | `SysUserController.java:50 R<SysUser>` 返回完整实体（不同场景，profile 需要完整信息） |
| D-06 | REST Path | `/system/user/profile/notification` | — | **new** | 新增接口路径 | — |
| D-07 | HTTP Method | GET, PUT | — | **new** | GET 查询，PUT 更新（幂等） | — |
| D-08 | Permission Code | `system:user:profile` | — | **unchanged** | 复用现有权限码，无需申请新码 | `SysUserController.java:46 @SaCheckPermission("system:user:profile")` |
| D-09 | SaCheckPermission | `@SaCheckPermission("system:user:profile")` | — | **unchanged** | 复用现有权限注解 | — |
| D-10 | Anonymous Interface | — | — | **not-applicable** | 通知偏好是登录用户自身操作 | — |
| D-11 | Login/Token | 从 Sa-Token 自动获取 userId | — | **unchanged** | 接口无需传 userId，通过 `SecurityUtils.getUserId()` 自动获取 | `SysUserController.java:77 SecurityUtils.getUserId()` |
| D-12 | Tenant/Data Permission | — | — | **not-applicable** | 用户操作自身数据，无租户隔离需求 | — |
| D-13 | State Machine Impact | — | — | **not-applicable** | 无状态流转 | — |

Decision Status: accepted

State Machine Impact: not-applicable

## Design Alignment / Grill

Alignment Source: user-confirmed

Open Questions: none

| # | Question | Confirmation | Evidence |
|---|---------|-------------|----------|
| Intent Risk | 默认值 opt-out 是否与产品预期一致？建议：**是**，80% 用户调研反馈期望收到通知。 | user-confirmed | 产品需求文档 v2.3 第 4.2 节"通知偏好默认开启" |
| Existing Code Fit | 新增字段和接口是否符合项目现有模式？建议：**是**，完全遵循 SysUser 实体风格（TINYINT boolean, @TableField），Controller 路径沿用 profile 子资源模式。 | code-confirmed | `SysUser.java:15-60` 实体字段定义风格；`SysUserController.java:45-92` profile 接口模式 |
| Unnecessary Abstraction | 是否引入了不必要的抽象？建议：**否**。不新增 Service/Controller 类，仅扩展现有类，零新增抽象。 | code-confirmed | 所有变更均在现有 SysUser*/ISysUserService 类中 |
| Protected Areas | 是否触碰了受保护区域？建议：**是**。ALTER TABLE 属于 schema 变更，需要 DBA 审批 + 低峰期执行计划。 | user-confirmed | `risk_rules.heavy_if: schema_change` 触发 Heavy 流程 |
| Boundary And Failure Modes | 边界条件和失败模式是否已评估？建议：**已评估**。(a) 并发 PUT 无冲突（更新自身数据）；(b) 用户不存在时 GET 返回 404；(c) 未登录时 Sa-Token 返回 401。 | user-confirmed | Sa-Token 自动处理未登录；`SecurityUtils.getUserId()` 在无登录态时抛 `NotLoginException` |
| default-value-choice | 默认值 `true`(opt-out) 还是 `false`(opt-in) 确认？建议：**opt-out**，不改变现有用户体验。 | user-confirmed | 产品决策记录 ADR-0003"通知策略" |
| migration-strategy | 生产数据库迁移策略确认？建议：**低峰期（凌晨 3:00）执行**，使用 `ALGORITHM=INPLACE, LOCK=NONE`。 | user-confirmed | MySQL 8.0 官方文档：TINYINT 列新增支持 INPLACE |

Alignment Verdict: aligned

## State Machine Impact

本次变更不影响任何状态机流转。

## API / Permission / Auth Impact

- **API**: 新增 `GET/PUT /system/user/profile/notification` — 获取/更新当前用户通知偏好
- **Permission**: 复用现有 `system:user:profile` 权限码，无新增
- **Auth**: 接口需要登录态，由 Sa-Token 自动处理

## 风险评估

| 风险 | 概率 | 影响 | 缓解 |
|------|------|------|------|
| ALTER TABLE 锁表 | 低 | 高（阻塞所有写操作） | 使用 ALGORITHM=INPLACE, LOCK=NONE；低峰期执行；预检 50 万行 × 1 字段 ≈ 3s 完成 |
| 前端未及时适配 | 中 | 低 | 本次为后端先行，接口独立不影响现有功能 |
| 缓存不一致 | 低 | 低 | 如有 Redis 缓存 `SysUser`，更新后需清除对应 key。已在 TASKS.md 标注 |

## 实现路径

1. 编写数据库迁移 SQL（`sql/V1.1__add_notification_enabled.sql`）
2. `SysUser.java` 实体新增 `notificationEnabled` 字段
3. `ISysUserService.java` 新增 `getNotificationEnabled()` / `updateNotificationEnabled()` 方法声明
4. `SysUserServiceImpl.java` 实现新增方法
5. `SysUserController.java` 新增 GET/PUT 接口
6. 单元测试 + AC 验证
