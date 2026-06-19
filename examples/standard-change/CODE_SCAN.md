# Code Scan

## 扫描时间

YYYY-MM-DD 10:00

## Machine Check

scan_time: YYYY-MM-DD 10:00
related_modules: user, settings
similar_implementations: src/main/java/com/app/user/controller/UserSettingsController.java
reusable_abstractions: src/main/java/com/app/common/BaseController.java
standards_snapshot: docs/standards/不存在，从代码中提取：Controller 使用 @RestController + @RequestMapping，Service 层接口+实现分离
test_baseline: mvn test -pl user -am -q
read_files: src/main/java/com/app/user/
write_files: src/main/java/com/app/user/controller/, src/main/java/com/app/user/service/, src/main/resources/static/js/settings/
open_questions: 无

## 相关模块

- 模块：user
- 入口：src/main/java/com/app/user/controller/

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| 用户偏好查询 | `UserSettingsController.java` | 已有 GET /api/user/settings 接口 |
| 用户偏好更新 | `UserSettingsController.java` | 已有 PUT /api/user/settings 接口 |

## 可复用抽象

- BaseController：统一异常处理和响应封装
- Result<T>：通用 API 响应体

## Standards Snapshot

- Standards source: 代码提取（无 docs/standards/）
- 本次沿用: Controller 使用 @RestController，Service 接口+Impl 模式
- 冲突或缺口: 无

## 测试基线

- 现有测试：`user/src/test/` 有 ControllerTest 基类
- 可复用命令：`mvn test -pl user -am -q`

## read_files

read_files:
  - src/main/java/com/app/user/model/UserProfile.java
  - src/main/java/com/app/user/controller/UserSettingsController.java
  - src/main/java/com/app/user/service/UserSettingsService.java

## write_files

write_files:
  - src/main/java/com/app/user/controller/UserSettingsController.java
  - src/main/java/com/app/user/service/UserSettingsService.java
  - src/main/java/com/app/user/service/impl/UserSettingsServiceImpl.java
  - src/main/resources/static/js/settings/notification-preference.js
  - src/test/java/com/app/user/controller/UserSettingsControllerTest.java

## 未决问题

无
