# Report

## Change

gate-tiering-matrix — 创建门禁分级矩阵文档。

## 修改文件

- `agent-flow/rules/gate-tiers.md`（新）— 62 gates 的 Light/Standard/Heavy/Emergency 分级
- `agent-flow/scripts/scaffold-health.sh` — 注册 gate-tiers.md
- `agent-flow/scripts/scaffold-health.ps1` — 注册 gate-tiers.md

## 验证证据

- scaffold-health: pass
- design-check: pass
- alignment-check: pass (skipped)
- scan-check (strict): pass
