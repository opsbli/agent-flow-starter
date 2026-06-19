# Verify

## 验证环境

本地开发环境，MySQL 8.0，JDK 17

## 命令记录

| 命令 | 结果 | 证据 |
|---|---|---|
| `mvn test -pl user -am -q` | pass | 12 tests passed, 0 failed |
| `agent-flow/scripts/ac-check.ps1` | pass | 3 AC ids have evidence |
| `agent-flow/scripts/coverage-check.ps1` | pass | AC coverage 3/3 |

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | 页面显示通知偏好区域，邮件通知开关默认开启 | test | `UserSettingsControllerTest.java:45` | pass | none |
| AC-02 | 用户关闭邮件通知，保存成功显示关闭 | test | `UserSettingsControllerTest.java:62` | pass | none |
| AC-03 | 用户重新打开邮件通知，保存成功显示开启 | test | `UserSettingsControllerTest.java:79` | pass | none |

## Coverage Summary

| Metric | Source | Value | Result | Notes |
|---|---|---|---|---|
| AC Coverage | `coverage-check` | 3/3 (100%) | pass | All ACs have evidence rows |
| Test Coverage | Maven Surefire | targeted | pass | Controller-level coverage for all AC paths |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scan-check | Standard | pass | `scan-check --change-dir ... --strict` | 0 | YYYY-MM-DD | paths validated |
| design-check | Standard | pass | `design-check --change-dir ...` | 0 | YYYY-MM-DD | decisions accepted |
| alignment-check | Standard | pass | `alignment-check --change-dir ...` | 0 | YYYY-MM-DD | 3 user-confirmed |
| task-check | Standard | pass | `task-check --change-dir ...` | 0 | YYYY-MM-DD | all tasks bounded |
| ac-check | Standard | pass | `ac-check --change-dir ...` | 0 | YYYY-MM-DD | 3 AC ids have evidence |
| coverage-check | Standard | pass | `coverage-check --change-dir ...` | 0 | YYYY-MM-DD | 3/3 AC, test coverage |
| evolution-check | Standard | pass | `evolution-check --change-dir ...` | 0 | YYYY-MM-DD | evolution recorded |

## 结论

Standard change 完成，所有 AC 有测试证据，设计对齐已确认。
