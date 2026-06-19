# Evolution

## Machine Check

problem: af-team-review identified remaining gaps in requirement completeness (8.5/10), frontend verification enforcement (deferred), and design review quality (no gate)
knowledge: none
adr: none
gate: added design-quality-check.ps1/.sh as optional advisory gate
template: added non-functional requirements table to REQUIREMENT.md
no_change_reason: conflict_warning and integration_test_command remain deferred as lower priority

## 本次发现

- REQUIREMENT.md 模板缺失非功能需求字段，导致需求阶段无法捕获性能/安全约束
- frontend_verify_required 开关从 deferred 推进到 implemented，完成前端验证增强的闭环
- design-quality-check 作为可选 advisory gate，平衡了设计质量检查与流程负担

## 应调整的模板

- REQUIREMENT.md 已增加非功能需求表

## Improvement Tracker 更新

- [x] 已新增或更新 `agent-flow/knowledge/improvement-tracker.md`

| Item | Tracker ID | Status | Owner / Next Step |
|---|---|---|---|
| frontend_verify_required toggle | IMP-0014 | implemented | 已完成 |
| REQUIREMENT.md 非功能需求 | IMP-0015 | implemented | 已完成 |
| design-quality-check gate | IMP-0016 | implemented | 已完成 |

## 本次不调整的原因

- conflict_warning 和 integration_test_command 优先级较低，留待后续
