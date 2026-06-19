# Report

## Change

document-approval-workflow — Heavy

## 完成内容

- 新增 approval 模块，支持审批记录的创建和查询
- 新增文档审批流程：提交 → 一级审批 → 二级审批 → 批准/驳回
- 文档状态机扩展：DRAFT → PENDING_APPROVAL → APPROVED/REJECTED
- 数据库迁移（新增 approval_record 表、document.status 字段）
- 新增审批人角色和权限校验

## 修改文件

- 新模块：approval（实体、Repository、Service、Controller）
- Document 模块：状态字段 + 状态流转逻辑
- Permission 模块：新增审批人角色
- 数据库迁移文件 × 2
- 前端审批页面

## 验证证据

- 45 个测试全部通过
- 5 个 AC 均有测试证据
- 代码漂移检查通过
- 数据库迁移可回滚

## 未完成事项

无

## 风险和回滚

- 数据库迁移回滚：`flyway undo` 或手动执行回滚 SQL
- 代码回滚：revert 所有 write_files 修改

## 知识沉淀

- 新增术语到 glossary：审批流、一级审批、二级审批
- 新增坑点到 pitfalls：审批状态变更需要乐观锁

## 决策沉淀

新增 ADR-0002：选择状态机模式而非工作流引擎

## 审计

- Plan Audit: accept
- Closure Audit: acceptable

## 后续建议

- 加入审批通知（邮件/站内信）
- 加入审批超时自动处理
- 考虑审批人离职的 reassign 机制
