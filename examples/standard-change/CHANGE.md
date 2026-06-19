# Change: user-notification-preference

## 一句话需求

用户可以在设置页面中选择是否接收邮件通知。

## 背景

目前系统对所有用户发送操作通知邮件，部分用户反馈邮件过多。需要提供一个通知偏好设置页面，让用户控制通知开关。

## 流程级别

- [ ] Light
- [x] Standard
- [ ] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由

单模块功能（User 模块），不涉及 schema 变更、权限改造或公共 API 契约变更。

## 目标

- 用户设置页面新增「通知偏好」区域
- 支持开关「邮件通知」
- 默认开启
- 偏好设置保存到现有 user_profile 表

## 非目标

- 不新增数据库表或字段（复用已有 user_profile.notification_flags）
- 不修改通知发送逻辑（只做开关读取）
- 不做 WebSocket/实时推送

## 影响范围

- User 模块：Controller、Service、前端页面
- 用户设置页面

## 关联前端

- [ ] 否
- [x] 是：`src/pages/settings/`

## 工件索引

- State: `STATE.md`
- Requirement: `REQUIREMENT.md`
- Code Scan: `CODE_SCAN.md`
- Design: `DESIGN.md`
- Tasks: `TASKS.md`
- Verify: `VERIFY.md`
- Report: `REPORT.md`
- Evolution: `EVOLUTION.md`
