# Evolution

## Machine Check

problem: gate registry drift and starter run-history leakage were not fully guarded
knowledge: agent-flow/rules/gates.txt is the formal public script registry
adr: none
gate: manifest-check now validates public script registry completeness
template: known-good-baselines reset to reusable starter template
no_change_reason: flow levels unchanged because current routing remains effective

## 本次 change 暴露的问题

- `init-project` was another gate-list writer and needed to consume `gates.txt`.
- Root setup scripts should be included in syntax checks because they affect starter adoption quality.
- Windows PowerShell can misparse non-BOM `.ps1` files containing non-ASCII text.

## 应写入 knowledge 的内容

- `agent-flow/rules/gates.txt` is the public script registry.
- Starter must not track real run-history files under `agent-flow/changes`, `agent-flow/logs`, or `agent-flow/reports`.

## 应新增或修改的 ADR

- none

## 应新增的 gate

- No new separate gate. `manifest-check` absorbed the registry drift rule.

## 应调整的模板

- `known-good-baselines.md` reset to a generic template.

## 应更新的标准

- Root PowerShell setup scripts should stay ASCII unless saved with a BOM and explicitly tested under Windows PowerShell.

## 本次不调整的原因

- No routing-level changes were needed to cross 9.0.
