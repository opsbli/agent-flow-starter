# Report

## Change

gate-tiering-matrix — 创建门禁分级矩阵文档。

## 修改文件

- `agent-flow/rules/gate-tiers.md`（新）— 62 gates 的 Light/Standard/Heavy/Emergency 分级
- `agent-flow/scripts/scaffold-health.sh` — 注册 gate-tiers.md
- `agent-flow/scripts/scaffold-health.ps1` — 注册 gate-tiers.md
- `agent-flow/flows/light.md` — 增加 gate-tiers.md 引用
- `agent-flow/flows/standard.md` — 增加 gate-tiers.md 引用
- `agent-flow/flows/heavy.md` — 增加 gate-tiers.md 引用

## 验证证据

- scaffold-health: pass
- design-check: pass
- alignment-check: pass (skipped)
- scan-check (strict): pass
