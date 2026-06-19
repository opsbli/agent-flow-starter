# Tasks

## 执行原则

- 每个任务 5-30 分钟内可完成
- 未在 write_files 中声明的文件不得修改

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel | conflict_warning |
|---|---|---|---|---|---|---|---|
| T001 | completed | AC-01~AC-05 | migration/ | V20260601__add_approval_tables.sql | `mvn flyway:migrate` | no | |
| T002 | completed | AC-01 | DocumentService.java | DocumentService.java | `mvn test` | no | |

## write_files 汇总

write_files:
  - src/main/resources/db/migration/
  - src/main/java/com/app/approval/
  - src/main/java/com/app/document/model/Document.java
  - src/main/java/com/app/permission/

### T001 - 数据库迁移

状态：completed

目标：创建审批记录表和文档状态字段。

AC：AC-01~AC-05

write_files：
  - src/main/resources/db/migration/V20260601__add_approval_tables.sql

验证：`mvn flyway:migrate`
