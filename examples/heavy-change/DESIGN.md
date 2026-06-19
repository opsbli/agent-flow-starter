# Design

## 设计目标

实现两级文档审批工作流，支持提交审批、批准、驳回和重新提交。

## 设计约束

- 状态变更必须有乐观锁防并发
- 审批记录不可修改（仅追加）
- 审批人从组织架构中推断

## 模块边界

- approval 模块：审批记录管理、审批流引擎
- document 模块：文档状态机改造
- permission 模块：审批人角色校验

## 复用现有抽象

- BaseEntity：approval_record 的实体基类
- BaseController + Result<T>：统一 API 响应

## API / Permission / Auth Decisions

Decision Status: accepted

| Item | Decision | Evidence / Reason |
|---|---|---|
| REST Path | new | 新增 /api/approval/* |
| HTTP Method | new | POST/submit, GET/tasks, POST/approve, POST/reject |
| Permission Code | new | approval:submit, approval:approve, approval:reject |
| Anonymous Interface | not-applicable | 全部需要登录 |
| Login/Token | unchanged | 复用现有 JWT |
| State Machine Impact | new | 文档状态新增待审批/已批准/已驳回 |

## 状态机

### Status Vocabulary

| Status | Source | Meaning | New Write? | Frontend Display |
|---|---|---|---|---|
| DRAFT | 已有 | 文档编辑中 | 不变 | 草稿 |
| PENDING_APPROVAL | 新增 | 已提交待审批 | 是 | 待审批 |
| APPROVED | 新增 | 审批通过 | 是 | 已批准 |
| REJECTED | 新增 | 审批驳回 | 是 | 已驳回 |

### Status Mapping

| Input Status | Target Status | Usage Location | Compatibility Strategy |
|---|---|---|---|
| DRAFT | PENDING_APPROVAL | 提交审批 | 已有文档可升级 |
| PENDING_APPROVAL | APPROVED | 审批通过 | 新增 |
| PENDING_APPROVAL | REJECTED | 审批驳回 | 新增 |
| REJECTED | PENDING_APPROVAL | 重新提交 | 新增 |

## 数据设计

### DB Change 决策表

| 变更项 | 操作 | 详情 | 回滚 SQL 存在? | 迁移策略 |
|---|---|---|---|---|
| 表 | add | approval_record | yes | 可回滚 |
| 列 | add | document.status | yes | 设置默认值 DRAFT |

## 测试策略

| AC | 测试文件 | 测试方法 | 类型 |
|---|---|---|---|
| AC-01 | ApprovalSubmitTest.java | 提交审批 | 单元+集成 |
| AC-02 | ApprovalApproveTest.java | 一级批准 | 单元+集成 |
| AC-03 | ApprovalApproveTest.java | 二级批准 | 单元+集成 |
| AC-04 | ApprovalRejectTest.java | 驳回 | 单元+集成 |
| AC-05 | ApprovalResubmitTest.java | 重新提交 | 单元+集成 |

## Design Alignment / Grill

| Question | AI Recommended Answer | Confirmation | Final Decision |
|---|---|---|---|
| Intent Risk | 两级审批满足当前需求，不需要更复杂的工作流 | user-confirmed | 两级审批 |
| Existing Code Fit | DocumentService 已有完整 CRUD，审批逻辑新增独立模块 | code-confirmed | 新模块 approval |
| Unnecessary Abstraction | 不引入工作流引擎，用状态机+表记录 | user-confirmed | 状态机模式 |
| Protected Areas | 数据库 schema 变更需回滚计划 | user-confirmed | 已包含回滚 SQL |
| Boundary And Failure Modes | 乐观锁防并发批准 | user-confirmed | 添加 version 字段 |

Alignment Verdict: aligned
