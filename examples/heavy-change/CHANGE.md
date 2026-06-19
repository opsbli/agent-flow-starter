# Change: document-approval-workflow

## 一句话需求

实现文档审批工作流：用户提交文档后，上级审批人可批准或驳回。

## 背景

公司内部文档系统需要正式的审批流程。目前文档提交后直接发布，缺少审核环节。需要引入两级审批（直接上级 + 部门负责人）和审批状态跟踪。

## 流程级别

- [ ] Light
- [ ] Standard
- [x] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由

涉及新模块（approval）、数据库 schema 变更（新增审批表）、状态机（文档状态扩展）、权限变更（审批人权限）。满足 Heavy 条件中的"新模块"+"schema 变更"+"状态机"+"权限"。

## 目标

- 新增文档审批流程
- 支持两级审批：直接上级 → 部门负责人
- 审批人可批准/驳回
- 文档状态随审批流转

## 非目标

- 不做会签/或签
- 不做审批超时自动处理
- 不做审批通知（后续迭代）

## 影响范围

- 新增 approval 模块
- Document 模块：状态机改造
- Permission 模块：新增审批人角色
- 数据库：新增审批记录表、文档表新增状态字段

## 关联前端

- [ ] 否
- [x] 是：`src/pages/document/`、`src/pages/approval/`

## 风险

- 数据库迁移需回滚计划
- 状态机变更影响现有文档查询
- 审批权限需确认角色树

## 工件索引

- State: `STATE.md`
- Requirement: `REQUIREMENT.md`
- Code Scan: `CODE_SCAN.md`
- Design: `DESIGN.md`
- Plan: `PLAN.md`
- Tasks: `TASKS.md`
- Verify: `VERIFY.md`
- Review: `REVIEW.md`
- Report: `REPORT.md`
- Audit: `AUDIT.md`
- Evolution: `EVOLUTION.md`
