# Evolution

## Machine Check

problem: report recommendations needed durable tracking and stricter gates
knowledge: agent-flow/knowledge/improvement-tracker.md
adr: agent-flow/decisions/INDEX.md
gate: ac-check, manifest-check, starter self-test
template: DESIGN.md, EVOLUTION.md
no_change_reason: flow levels unchanged because Light/Standard/Heavy remain sufficient

## 本次 change 暴露的问题

- TODO 提示如果只给数量，用户不知道应该填路径、命令还是 none。
- AC 证据不能只靠全文出现 AC 编号。
- EVOLUTION 建议如果没有 tracker，容易停在报告里。
- ADR 文件夹缺索引时，状态和替代关系不容易扫描。

## 应写入 knowledge 的内容

- 已新增 `agent-flow/knowledge/improvement-tracker.md`。
- 已记录 IMP-0001 到 IMP-0005。

## 应新增或修改的 ADR

- 已新增 `agent-flow/decisions/INDEX.md`。
- 已更新 `agent-flow/decisions/README.md` 的状态生命周期说明。

## 应新增的 gate

- 不新增 gate。
- 已增强 `manifest-check` 和 `ac-check`。
- 已增强 starter self-test 的负例覆盖。

## 应调整的模板

- 已调整 `DESIGN.md`：新增 UI Flow / Component Tree 和 Demo Evidence。
- 已调整 `EVOLUTION.md`：新增 Improvement Tracker 更新区。

## Improvement Tracker 更新

- [ ] 不需要跟踪，原因：
- [x] 已新增或更新 `agent-flow/knowledge/improvement-tracker.md`

| Item | Tracker ID | Status | Owner / Next Step |
|---|---|---|---|
| Manifest TODO guidance | IMP-0001 | implemented | Done |
| AC Evidence strict check | IMP-0002 | implemented | Done |
| Gate negative tests | IMP-0003 | implemented | Done |
| EVOLUTION tracker | IMP-0004 | implemented | Done |
| ADR index | IMP-0005 | implemented | Done |

## 应调整的流程分级

- 无。Medium flow 暂不增加。

## Source of Truth / Autonomy 调整

- 无。根治理规则不需要变化。

## Audit / Baseline 调整

- 无 runtime baseline。

## 本次不调整的原因

- 不调整项：Medium flow、pre-commit hook、企业审批流、独立 demo template。
- 原因：它们会增加使用复杂度，且现有 Light/Standard/Heavy、`DESIGN.md`、`VERIFY.md` 已能承载当前需求。
