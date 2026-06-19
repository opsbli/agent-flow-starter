# Evolution

## Machine Check

problem: Light/no-op assessment completion line and evolution/statistics gates need tightening
knowledge: agent-flow/knowledge/improvement-tracker.md
adr: none
gate: next-step, check-change, evolution-check, evolution-stats, emergency-check
template: CHANGE.md, REPORT.md, EVOLUTION.md
no_change_reason: assessment-only change; implementation should happen in a dedicated upgrade change

## 本次 change 暴露的问题

- `GO.md` 声明所有路径完成线含 `EVOLUTION.md`，但 Light scaffold 默认不生成 EVOLUTION，且 `evolution-check` 对 Light 缺失直接 skip。
- 新建 Light change 的占位工件可能被 `next-step` 判断为 ready/complete-or-review，而 `scan-check -Strict` 会失败。
- PowerShell 与 bash `evolution-stats` 输出不一致，bash 出现 AC pass rate 134%，降低数据驱动演进可信度。
- `evolution-suggest.sh` 输出出现字面 `\n`，说明跨端输出格式缺少等价测试。
- `check-change`、`blocked-check`、`code-drift-check`、`coverage-check` 仍较依赖文本启发式，需要更强 fixture 和结构化语义。

## 应写入 knowledge 的内容

- 建议写入 `agent-flow/knowledge/improvement-tracker.md`：
  - 统一 Light/no-op/assessment 完成线。
  - 修复 next-step 对占位 Light 工件的 ready 误判。
  - 修复 evolution-stats 双端统计不一致。
  - 新增 evolution-tracker-check 或强化 evolution-check 反查 tracker/knowledge/ADR/gate/template。

## 应新增或修改的 ADR

- 无。当前建议未改变根本架构决策。

## 应新增的 gate

- 可考虑新增 `evolution-tracker-check`：
  - 从所有 `EVOLUTION.md` 反查 `improvement-tracker.md`。
  - implemented 项必须引用实现 change 和验证证据。
  - problem 非 none 时必须有 tracker 行或 rejected/deferred reason。

## 应调整的模板

- `REPORT.md`: no-op assessment 应要求证据位置和下一个触发条件为机器可检查字段。
- `EVOLUTION.md`: 可增加 tracker target/status 字段，降低建议悬空概率。
- `CHANGE.md`: assessment / no-op 可作为明确类型，而不是仅依赖 Light。

## Improvement Tracker 更新

- [x] 不需要跟踪，原因：本次是 assessment-only change；建议在专门 upgrade change 中更新 `agent-flow/knowledge/improvement-tracker.md`
- [ ] 已新增或更新 `agent-flow/knowledge/improvement-tracker.md`

| Item | Tracker ID | Status | Owner / Next Step |
|---|---|---|---|
| 统一 Light/no-op/assessment 完成线 | not-created | proposed | Open dedicated upgrade change |
| 修复 next-step Light 占位误判 | not-created | proposed | Open dedicated upgrade change |
| 修复 evolution-stats 双端统计不一致 | not-created | proposed | Open dedicated upgrade change |
| 强化 evolution tracker 反查 | not-created | proposed | Open dedicated upgrade change |

## 应调整的流程分级

- 无直接调整。建议新增 assessment/no-op 子类型或明确 Light assessment 规则，但应在专门 upgrade change 中确认。

## Source of Truth / Autonomy 调整

- 无直接调整。建议后续增加 source-of-truth 执行型检查，验证 CODE_SCAN 是否引用相关 decisions/knowledge。

## Audit / Baseline 调整

- 无直接调整。建议后续让 Standard closure 也强制校验 Machine Gate Summary 的关键 gate 证据。

## 本次不调整的原因

- 不调整项：流程实现、脚本、模板、knowledge tracker、ADR。
- 原因：用户请求是多角色评分评估；直接修改流程会把 assessment 和 upgrade 混在一起，违反 starter 外科式修改原则。
