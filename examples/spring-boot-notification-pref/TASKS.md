# Tasks

## Task Matrix

| Task ID | Status | AC | Read Files | Write Files | Verify | Parallel |
|---------|--------|----|-----------|-------------|--------|----------|
| T-01 | completed | AC-01 | — | sql/V1.1__add_notification_enabled.sql | 手动执行 `SHOW COLUMNS FROM sys_user LIKE 'notification_enabled'` | no |
| T-02 | completed | AC-02, AC-04 | src/main/java/com/example/system/domain/SysUser.java | src/main/java/com/example/system/domain/SysUser.java, src/main/resources/mapper/system/SysUserMapper.xml | `mvn compile` 编译通过 | no |
| T-03 | completed | AC-02, AC-03, AC-04 | src/main/java/com/example/system/service/ISysUserService.java | src/main/java/com/example/system/service/ISysUserService.java, src/main/java/com/example/system/service/impl/SysUserServiceImpl.java | `mvn test -pl system -Dtest=SysUserServiceTest` | no |
| T-04 | completed | AC-02, AC-03, AC-05 | src/main/java/com/example/system/controller/SysUserController.java | src/main/java/com/example/system/controller/SysUserController.java | `mvn test -pl system -Dtest=SysUserControllerTest` | no |
| T-05 | completed | AC-01, AC-02, AC-03, AC-04, AC-05 | — | — | `mvn test -pl system` 全部测试；手动联调 curl 验证 | no |

## Task Details

### T-01: 数据库迁移 ✅

SQL 脚本：`sql/V1.1__add_notification_enabled.sql`
```sql
ALTER TABLE sys_user
  ADD COLUMN notification_enabled TINYINT(1) NOT NULL DEFAULT 1
  COMMENT '通知开关：1-开启，0-关闭',
  ALGORITHM=INPLACE, LOCK=NONE;
```

### T-02: 实体类更新 ✅

- `SysUser.java`: 新增 `private Boolean notificationEnabled;` 字段，`@TableField("notification_enabled")`
- `SysUserMapper.xml`: resultMap 新增 `<result column="notification_enabled" property="notificationEnabled"/>`

### T-03: Service 层实现 ✅

- `ISysUserService.java`: 新增 `Boolean getNotificationEnabled();` 和 `void updateNotificationEnabled(Boolean enabled);`
- `SysUserServiceImpl.java`: 
  - `getNotificationEnabled()`: 通过 `SecurityUtils.getUserId()` → `getById()` → 返回字段值
  - `updateNotificationEnabled()`: 通过 `LambdaUpdateWrapper` 更新当前用户字段

### T-04: Controller 层实现 ✅

- `GET /system/user/profile/notification`: 返回 `R<Map<String, Boolean>>` `{"notificationEnabled": true}`
- `PUT /system/user/profile/notification`: 接收 `@RequestBody Map<String, Boolean>` → 更新 → 返回成功
- 使用类级别已有 `@SaCheckPermission("system:user:profile")` 注解

### T-05: 验证 ✅

- 单元测试：`SysUserControllerTest.testGetNotification()` / `testUpdateNotification()`
- 集成测试：MockMvc 模拟已登录用户调用 GET/PUT
- AC 证据：见 VERIFY.md

write_files:
  - sql/V1.1__add_notification_enabled.sql
  - src/main/java/com/example/system/domain/SysUser.java
  - src/main/java/com/example/system/service/ISysUserService.java
  - src/main/java/com/example/system/service/impl/SysUserServiceImpl.java
  - src/main/java/com/example/system/controller/SysUserController.java
  - src/main/resources/mapper/system/SysUserMapper.xml
