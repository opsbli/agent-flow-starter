# Design

## 设计目标

在用户设置页面添加通知偏好开关，控制邮件通知的开启/关闭。

## 设计约束

none

## 模块边界

- User Controller：新增 GET/PUT 处理通知偏好
- User Service：通知偏好的读写逻辑
- User Model：user_profile.notification_flags 字段存储

## 复用现有抽象

- GET/PUT /api/user/settings 已有路由，复用
- BaseController、Result<T> 复用

## API / Permission / Auth Decisions

Decision Status: accepted

Allowed Decision Values: unchanged / new / modified / deleted / not-applicable

| Item | Decision | Evidence / Reason |
|---|---|---|
| REST Path | unchanged | 复用 /api/user/settings |
| HTTP Method | unchanged | 复用 GET/PUT |
| Permission Code | not-applicable | 设置页面向所有登录用户开放 |
| Anonymous Interface | not-applicable | 需要登录 |
| Login/Token | unchanged | 保持现有认证方式 |
| State Machine Impact | no | 不涉及状态机 |

## Design Alignment / Grill

Alignment Source: DESIGN.md

Open Questions: 已关闭

| Question | AI Recommended Answer | Confirmation | Final Decision |
|---|---|---|---|
| Intent Risk | 用户只想控制邮件通知类型，不需要细粒度开关 | code-confirmed | 只做邮件通知开关 |
| Existing Code Fit | UserSettingsController 已有 settings 端点 | code-confirmed | 复用 |
| Unnecessary Abstraction | 不需要独立的 NotificationPreference 对象 | user-confirmed | 用 boolean 字段 |

Alignment Verdict: aligned
