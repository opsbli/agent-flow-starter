# Code Scan

## 扫描时间

YYYY-MM-DD 10:00

## Machine Check

scan_time: YYYY-MM-DD 10:00
related_modules: document, permission, approval(new)
similar_implementations: src/main/java/com/app/document/service/DocumentService.java
reusable_abstractions: src/main/java/com/app/common/BaseController.java, Result.java, PageRequest.java
standards_snapshot: docs/standards/不存在，从代码提取：模块按业务分包，Controller-Service-Repository 三层
test_baseline: mvn test -pl document -am -q
read_files: src/main/java/com/app/document/, src/main/java/com/app/permission/
write_files: src/main/java/com/app/approval/ (新模块), src/main/java/com/app/document/model/Document.java
open_questions: 审批人角色定义需要和架构组确认

## 相关模块

- 模块：document
- 新模块：approval
- 入口：src/main/java/com/app/document/controller/DocumentController.java

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| 文档基础 CRUD | DocumentService.java | 复用已有文档查询 |
| 权限校验 | PermissionService.java | 复用审批人角色判断 |

## 可复用抽象

- BaseController、Result<T>：所有 Controller 复用
- PageRequest：审批列表分页复用
- BaseEntity：审批记录继承

## Standards Snapshot

- Standards source: 代码提取
- 本次沿用: 三层架构、Lombok、MapStruct
- 冲突或缺口: 无

## 数据库扫描

- 现有表：document（需新增 status 字段）
- 新增表：approval_record（审批记录）
- 索引：approval_record(approver_id, status) 作为查询索引

## 权限扫描

- 新增审批人角色：APPROVER
- 审批人查询关联用户-部门关系表

## API / 路由扫描

- 新增 POST /api/approval/submit
- 新增 GET /api/approval/tasks
- 新增 POST /api/approval/{id}/approve
- 新增 POST /api/approval/{id}/reject

## read_files

read_files:
  - src/main/java/com/app/document/
  - src/main/java/com/app/permission/
  - src/main/resources/db/migration/

## write_files

write_files:
  - src/main/java/com/app/approval/
  - src/main/java/com/app/document/model/Document.java
  - src/main/resources/db/migration/V20260601__add_approval_tables.sql

## 未决问题

- 审批人角色定义需确认
