# Evolution

## Machine Check

problem: agent-flow had gaps in frontend verification (5.0-6.5/10), runtime API/permission drift detection (7.5/10), and database migration rollback verification (6.5/10) identified by af-team-review
knowledge: 新增 Gate 需注册到 4 个位置 (manifest.yaml, gates.txt, check-change.ps1, check-change.sh) — 应写入 scripts/README.md 或 knowledge/pitfalls.md
adr: none
gate: added api-compatibility-check.ps1/.sh and db-migration-check.ps1/.sh as non-blocking warning-level gates
template: updated DESIGN.md with DB Change decision table and frontend verification contract section; updated frontend-fit.md with Chrome DevTools checklist
no_change_reason: manifest frontend_verify_required toggle and design-quality-check gate need their own design/alignment phase

## 本次 change 暴露的问题

- agent-flow 偏后端思维，前端验证依赖 Agent 自觉
- 新增 Gate 的注册流程分散在 4 个文件，容易遗漏
- 非阻塞式 warning gate 的设计需要更好的说明文档

## 应写入 knowledge 的内容

- `agent-flow/knowledge/pitfalls.md` 应增加：忘记在 gates.txt 中注册新 Gate 会导致 scaffold-health 报警
- `agent-flow/knowledge/glossary.md` 应增加：api-compatibility-check, db-migration-check 两个新术语

## 应新增或修改的 ADR

- 无

## 应新增的 gate

- 本次已新增 `api-compatibility-check` 和 `db-migration-check`
- 未来候选：`design-quality-check` (设计复用检查), `frontend-verify-check` (前端验证强制)

## 应调整的模板

- `DESIGN.md` 已增加 DB Change 决策表
- `DESIGN.md` 已增加前端验证契约表
- 未来：`VERIFY.md` 可增加前端验证标准化槽位

## Improvement Tracker 更新

- [x] 已新增或更新 `agent-flow/knowledge/improvement-tracker.md`

| Item | Tracker ID | Status | Owner / Next Step |
|---|---|---|---|
| 新增 api-compatibility-check 门禁 | IMP-0010 | implemented | 已完成 |
| 新增 db-migration-check 门禁 | IMP-0011 | implemented | 已完成 |
| frontend-fit.md Chrome DevTools 清单 | IMP-0012 | implemented | 已完成 |
| DESIGN.md DB 变更表和前端验证契约 | IMP-0013 | implemented | 已完成 |
| manifest.yaml frontend_verify_required 开关 | IMP-0014 | deferred | 后续独立 change |

## 应调整的流程分级

- 无

## Source of Truth / Autonomy 调整

- 无

## Audit / Baseline 调整

- 无

## 本次不调整的原因

- 不调整项：manifest.yaml frontend_verify_required 开关
- 原因：需要单独的 Design/Alignment 阶段，与本次 scope 分离
