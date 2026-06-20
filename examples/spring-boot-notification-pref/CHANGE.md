# Change: 用户通知偏好设置

## 一句话需求

在用户表中新增 `notification_enabled` 字段，提供 REST API 供用户查询和更新自己的通知偏好。

## 背景

当前系统支持系统级通知发送，但用户无法控制是否接收。运营反馈部分用户投诉通知骚扰。需要让用户自行开关通知。

## 流程级别

- [ ] Light
- [ ] Standard
- [x] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由

CODE_SCAN 发现需要新增数据库字段（`notification_enabled`），涉及 schema 变更，触发 `risk_rules.heavy_if: schema_change`。从初始 Standard 判断升级为 Heavy。

## 目标

- `sys_user` 表新增 `notification_enabled`（TINYINT, default 1）
- `GET /system/user/profile/notification` — 查询当前用户通知偏好
- `PUT /system/user/profile/notification` — 更新当前用户通知偏好
- 复用现有 `system:user:profile` 权限码，不新增权限

## 非目标

- 不改变通知发送逻辑（通知发送时读取此字段即可，不在本次范围）
- 不提供管理员批量设置接口（运营需求后续另开 change）
- 不涉及前端页面（前端另行协作）

## 影响范围

- `sql/` — 新增迁移脚本
- `src/main/java/com/example/system/domain/SysUser.java` — 新增字段
- `src/main/java/com/example/system/service/ISysUserService.java` — 新增接口方法
- `src/main/java/com/example/system/service/impl/SysUserServiceImpl.java` — 新增实现
- `src/main/java/com/example/system/controller/SysUserController.java` — 新增接口
- `src/main/resources/mapper/system/SysUserMapper.xml` — 新增 resultMap 映射

## 关联前端

- [x] 否（前端单独协作，不在此 change 范围）
- [ ] 是：`TODO_FRONTEND_PATH`

## 风险

- **中**：ALTER TABLE 在生产环境有锁表风险。缓解：使用 `ALGORITHM=INPLACE`（MySQL 8.0 支持），在低峰期执行。
- **低**：默认值 `true`（opt-out）可能与产品预期不符。已通过 Design Alignment 确认。

## 工件索引

- State: STATE.md
- Requirement: REQUIREMENT.md
- Code Scan: CODE_SCAN.md
- Design: DESIGN.md
- Tasks: TASKS.md
- Verify: VERIFY.md
- Report: REPORT.md
- Evolution: EVOLUTION.md
