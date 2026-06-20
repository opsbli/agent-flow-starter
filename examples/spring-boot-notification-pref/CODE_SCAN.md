# Code Scan

## 扫描时间

2025-07-15 10:30

## Machine Check

scan_time: 2025-07-15 10:30
related_modules: system
similar_implementations: src/main/java/com/example/system/（现有用户模块为唯一参考）
reusable_abstractions: BaseController (R<T> 响应封装), ISysUserService (现有接口风格), SaTokenPermission (权限注解)
standards_snapshot: 项目使用 MyBatis-Plus LambdaQueryWrapper, TINYINT 表示 boolean, REST 路径 /system/{module}/{resource}
test_baseline: mvn test -pl system
read_files: src/main/java/com/example/system/domain/SysUser.java, src/main/java/com/example/system/service/ISysUserService.java, src/main/java/com/example/system/controller/SysUserController.java
write_files: sql/V1.1__add_notification_enabled.sql, src/main/java/com/example/system/domain/SysUser.java, src/main/java/com/example/system/service/ISysUserService.java, src/main/java/com/example/system/service/impl/SysUserServiceImpl.java, src/main/java/com/example/system/controller/SysUserController.java, src/main/resources/mapper/system/SysUserMapper.xml
open_questions: 默认值 true(opt-out) vs false(opt-in) 待 Design Alignment 确认

## 相关模块

- 模块：`system`（系统管理模块）
- 入口：`SysUserController.java` — 现有用户接口；`SysUser.java` — 用户实体

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| 用户自身信息查询 | `SysUserController.java:45-67` `GET /system/user/profile` | 权限注解 `@SaCheckPermission("system:user:profile")`、`R<SysUser>` 响应包装 |
| 用户自身信息更新 | `SysUserController.java:69-92` `PUT /system/user/profile` | `SecurityUtils.getUserId()` 获取当前用户、`ISysUserService.updateById()` |
| 实体字段定义 | `SysUser.java:15-60` | `@TableField` 注解风格、TINYINT 用于 boolean、Lombok `@Data` |

## 可复用抽象

- 抽象：`BaseController` 的 `R<T>` 响应封装（位于 `com.example.common`）
- 复用方式：新接口直接返回 `R<Map<String, Boolean>>` 或 `R<Void>`
- 抽象：`SecurityUtils.getUserId()` 获取当前登录用户
- 复用方式：PUT 接口无需 `userId` 参数，从 token 自动获取

## 禁止重复实现

- 不重复实现：用户查询逻辑 — 已由 `ISysUserService.getById()` 提供
- 原因：通知偏好是 SysUser 的一个属性，无需独立 Service 或 Mapper
- 不重复实现：权限校验 — 复用现有 `system:user:profile` 权限码
- 原因：通知偏好属于用户自身 profile 的一部分

## Standards Snapshot

- Standards source: 现有 `SysUserController.java` 代码风格（无独立 `docs/standards/` 目录）
- 本次沿用:
  - REST 路径格式：`/system/user/profile/notification`（子资源嵌套）
  - 权限注解：`@SaCheckPermission("system:user:profile")`
  - 响应格式：`R<T>` — `{ "code": 200, "data": ..., "msg": "操作成功" }`
  - Service 接口方法命名：`getXxx()` / `updateXxx()`
  - 数据库字段：`notification_enabled TINYINT(1) DEFAULT 1 COMMENT '通知开关'`
- 冲突或缺口:
  - 无。新字段完全遵循现有 SysUser 实体风格

## Maven / 模块影响

- 仅影响 `system` 模块
- 无 pom.xml 变更（无新增依赖）

## 数据库扫描

- 目标表：`sys_user`（现有 ~50 万行数据）
- 现有字段：`user_id BIGINT PK`, `user_name VARCHAR`, `email VARCHAR`, `phonenumber VARCHAR`, `status CHAR(1)`, ...
- 索引：`idx_user_name`, `idx_email`
- 新增字段对现有索引无影响

## 权限扫描

- 现有权限码：`system:user:profile` — 用户查询/更新自身信息
- 本次复用此权限码，不新增。`SaCheckPermission` 注解已存在于 Controller 类级别

## API / 路由扫描

- 现有路由：`GET /system/user/profile`（查询自身信息）、`PUT /system/user/profile`（更新自身信息）
- 新增路由：`GET /system/user/profile/notification`、`PUT /system/user/profile/notification`
- 不与现有路由冲突

## 前端扫描

- 无（本次不涉及前端）

## 测试基线

- 现有测试：`src/test/java/com/example/system/controller/SysUserControllerTest.java`（MockMvc 集成测试）
- 可复用命令：`mvn test -pl system -Dtest=SysUserControllerTest`

## read_files

read_files:
  - src/main/java/com/example/system/domain/SysUser.java
  - src/main/java/com/example/system/service/ISysUserService.java
  - src/main/java/com/example/system/controller/SysUserController.java
  - src/main/resources/mapper/system/SysUserMapper.xml

## write_files

write_files:
  - sql/V1.1__add_notification_enabled.sql
  - src/main/java/com/example/system/domain/SysUser.java
  - src/main/java/com/example/system/service/ISysUserService.java
  - src/main/java/com/example/system/service/impl/SysUserServiceImpl.java
  - src/main/java/com/example/system/controller/SysUserController.java

## 破坏性变更

- **ALTER TABLE** 在生产执行有锁表风险 → 缓解：使用 `ALGORITHM=INPLACE, LOCK=NONE`（MySQL 8.0 支持）

## 未决问题

- 默认值 `true`（opt-out）还是 `false`（opt-in）— 待 Design Alignment 确认
