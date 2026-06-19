# Evolution

## Machine Check

problem: none
knowledge: 新增 glossary 术语（审批流、一级审批、二级审批）
adr: ADR-0002 状态机 vs 工作流引擎
gate: none
template: none
no_change_reason: 无

## 本次 change 暴露的问题

状态变更在并发下需要乐观锁。这不是流程问题，是技术实现决策。

## 应写入 knowledge 的内容

- 审批流程相关术语
- 乐观锁在状态变更中的使用

## 应新增或修改的 ADR

ADR-0002：选择状态机模式而非引入 Activiti/Flowable 工作流引擎

## 应新增的 gate

审批相关的 code-drift-check 规则可考虑：检测新审批状态是否在设计文档中声明

## 应调整的模板

Heavy 流程模板中可考虑增加"状态机设计"的强制检查项（当前 DESIGN.md 已有，但可更突出）

## Improvement Tracker 更新

- [ ] 不需要跟踪，原因：
- [x] 已新增或更新 `agent-flow/knowledge/improvement-tracker.md`

## 本次不调整的原因

Heavy 流程完整覆盖了本次 change 的所有风险点，没有形式主义步骤。
