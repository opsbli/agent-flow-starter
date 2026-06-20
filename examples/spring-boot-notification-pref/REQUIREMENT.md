# Requirement

## 背景

系统通知模块已上线 3 个月，运营反馈 20% 用户投诉通知过于频繁。当前系统不支持用户自行关闭通知，每次都需要客服后台操作，效率极低。

## 用户角色

- **普通用户**：希望自主控制是否接收系统通知
- **运营人员**：希望减少通知相关投诉工单

## 术语

| 术语 | 定义 | 是否已沉淀到 glossary |
|---|---|---|
| 通知偏好 | 用户是否接收系统通知的开关设置 | 新增 |
| opt-out | 默认开启，用户主动关闭的模式 | 新增 |

## 目标

- 用户能查询自己当前的通知接收状态
- 用户能开启/关闭自己的通知接收
- 默认新用户（及现有用户）通知为开启状态

## 非目标

- 不改变通知发送逻辑（通知模块读取此字段即可）
- 不提供管理员批量设置接口（后续运营需求）
- 不提供按通知类型的细分开关（如"系统通知"/"营销通知"分开控制）

## 非功能需求

| 维度 | 要求 (或 none) | 验证方式 | 优先级 |
|---|---|---|---|
| 性能 | GET 接口 P99 < 50ms | 压测 1000 QPS | P1 |
| 安全 | 仅能操作自身通知偏好 | 单元测试验证 userId 从 token 获取 | P0 |
| 可观测性 | none | — | — |
| 可用性 | none | — | — |

## 业务规则

| 编号 | 规则 |
|---|---|
| R-01 | 用户只能查询/更新自己的通知偏好，不能操作其他用户 |
| R-02 | 新注册用户默认开启通知（notification_enabled = 1） |
| R-03 | 关闭通知后，系统通知模块读取此字段将跳过该用户 |

## 验收标准

| AC | Given | When | Then | 验证方式 |
|---|---|---|---|---|
| AC-01 | 数据库存在 sys_user 表 | 执行迁移脚本 | notification_enabled 字段存在，默认值为 1 | `SHOW COLUMNS` / Flyway 校验 |
| AC-02 | 用户已登录（userId=1001） | GET /system/user/profile/notification | 返回 `{"notificationEnabled": true}`，HTTP 200 | MockMvc 集成测试 |
| AC-03 | 用户已登录（userId=1001） | PUT /system/user/profile/notification `{"notificationEnabled": false}` | HTTP 200，再次 GET 返回 false | MockMvc 集成测试 |
| AC-04 | 用户未登录 | GET /system/user/profile/notification | 返回 HTTP 401，Sa-Token 拦截 | 单元测试 |
| AC-05 | 用户 A（userId=1001）登录 | PUT 传入其他 userId=1002 | 实际更新的仍是 userId=1001（从 token 获取） | 单元测试验证 controller 未使用 request body 中的 userId |

## 异常和边界

- 用户不存在（token 有效但 userId 对应的记录被删除）→ 返回 404
- request body 格式错误（如 `{"notificationEnabled": "yes"}` 字符串）→ 返回 400

## 未决问题

- 无

## 用户确认记录

- 2025-07-15: 产品确认 opt-out 模式 + 权限复用 + 不涉及前端
