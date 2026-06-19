# Tasks

## 执行原则

- 每个任务 5-30 分钟内可完成
- 每个任务必须有 `Status` 和 `read_files/write_files`
- 未在 `write_files` 中声明的文件不得修改

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel | conflict_warning |
|---|---|---|---|---|---|---|---|
| T001 | completed | AC-01, AC-02, AC-03 | UserSettingsController.java | UserSettingsController.java, UserSettingsServiceImpl.java | `mvn test -pl user -am -q` | no | |
| T002 | completed | AC-01 | settings page | notification-preference.js | 页面加载检查 | yes | |
| T003 | completed | AC-01, AC-02, AC-03 | UserSettingsControllerTest.java | UserSettingsControllerTest.java | `mvn test -pl user -am -q` | yes | |

## write_files 汇总

write_files:
  - src/main/java/com/app/user/controller/UserSettingsController.java
  - src/main/java/com/app/user/service/impl/UserSettingsServiceImpl.java
  - src/main/resources/static/js/settings/notification-preference.js
  - src/test/java/com/app/user/controller/UserSettingsControllerTest.java

### T001 - 后端：通知偏好读写接口

状态：completed

目标：在 UserSettingsController 中新增通知偏好字段的读写，在 Service 层实现偏好存储。

AC：AC-01, AC-02, AC-03

read_files：
  - src/main/java/com/app/user/controller/UserSettingsController.java
  - src/main/java/com/app/user/model/UserProfile.java

write_files：
  - src/main/java/com/app/user/controller/UserSettingsController.java
  - src/main/java/com/app/user/service/impl/UserSettingsServiceImpl.java

步骤：
1. UserProfile 中确认 notification_flags 字段
2. GET /api/user/settings 返回 email_notification_enabled
3. PUT /api/user/settings 接收 email_notification_enabled

验证：`mvn test -pl user -am -q`

### T002 - 前端：通知偏好 UI

状态：completed

目标：在设置页面添加通知偏好区域，包含邮件通知开关。

AC：AC-01

read_files：
  - src/main/resources/static/js/settings/（现有页面代码）

write_files：
  - src/main/resources/static/js/settings/notification-preference.js

步骤：
1. 在设置页面添加 "通知偏好" 区块
2. 添加邮件通知开关组件
3. 绑定 GET/PUT 接口

验证：页面加载时通知偏好区域可见

### T003 - 测试

状态：completed

目标：为通知偏好接口和 UI 组件编写测试。

AC：AC-01, AC-02, AC-03

read_files：
  - src/test/java/com/app/user/controller/UserSettingsControllerTest.java

write_files：
  - src/test/java/com/app/user/controller/UserSettingsControllerTest.java

步骤：
1. 编写 GET 接口测试（AC-01）
2. 编写 PUT 关闭通知测试（AC-02）
3. 编写 PUT 开启通知测试（AC-03）

验证：`mvn test -pl user -am -q`
