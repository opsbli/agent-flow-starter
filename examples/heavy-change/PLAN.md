# Plan

> Plan Status: completed
> Last Reviewed: YYYY-MM-DD
> Source: CHANGE.md

## Current Baseline

- Document 模块：已有 CRUD，文档状态为 DRAFT
- Permission 模块：已有用户-部门关系
- 无审批相关功能

## Goals

- 实现两级文档审批流程
- 新增 approval 模块
- 文档状态机扩展

## Non-Goals

- 审批超时自动处理
- 通知集成
- 会签/或签

## Execution Phases

### Phase 1 - 数据库迁移

Status: completed

Scope: 新增 approval_record 表，document 表新增 status 字段

write_files:
  - src/main/resources/db/migration/V20260601__add_approval_tables.sql
  - src/main/resources/db/migration/V20260602__add_document_status.sql

Exit Criteria: 迁移执行后 schema 变更生效

Verification: `mvn flyway:migrate`

### Phase 2 - 审批模块

Status: completed

Scope: 创建 approval 模块（实体、Repository、Service、Controller）

write_files:
  - src/main/java/com/app/approval/

Exit Criteria: 审批提交、批准、驳回接口可用

Verification: `mvn test -pl approval -am -q`

### Phase 3 - 文档状态机改造

Status: completed

Scope: 修改 Document 实体状态字段，新增状态流转逻辑

write_files:
  - src/main/java/com/app/document/model/Document.java
  - src/main/java/com/app/document/service/DocumentService.java

Exit Criteria: 文档状态随审批流转正确

Verification: `mvn test -pl document -am -q`

### Phase 4 - 权限集成

Status: completed

Scope: 新增审批人角色和权限校验

write_files:
  - src/main/java/com/app/permission/

Exit Criteria: 非审批人无法操作审批接口

Verification: `mvn test -pl permission -am -q`

### Phase 5 - 前端

Status: completed

Scope: 审批提交按钮、审批任务列表、审批操作界面

write_files:
  - src/main/resources/static/js/approval/
  - src/main/resources/templates/approval/

Exit Criteria: 用户可完成完整审批流程

Verification: 浏览器手工验证

## Closure Gates

- [x] CODE_SCAN complete
- [x] DESIGN reviewed
- [x] design-check passed
- [x] alignment-check passed
- [x] TASKS bounded by read/write files
- [x] Plan Audit completed and plan-check passed
- [x] Verification passed
- [x] AC evidence recorded
- [x] Drift checks passed
- [x] Closure audit acceptable
- [x] Knowledge/decision/log/baseline updated

## Protected Area Review

| Area | Touched | Approval / Reason |
|---|---|---|
| database schema | yes | 新增表+字段，有回滚 SQL |
| auth/permission | yes | 新增审批人角色 |
| public API | yes | 新增 /api/approval/* |

## Deferred But Adjudicated

| Item | Classification | Reason |
|---|---|---|
| 审批通知 | feature | 后续迭代，不影响审批流程 |
