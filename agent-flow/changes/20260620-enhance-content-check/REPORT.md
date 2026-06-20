# Report

## Change

enhance-content-check — 增强 content-check 以扫描 agent-flow/core/ 和 rules/ 目录。

## 修改文件

- `agent-flow/scripts/content-check.sh` — 新增 `--project-root` 模式
- `agent-flow/scripts/content-check.ps1` — 新增 `-ProjectRoot` 参数
- `agent-flow/scripts/check-change.sh` — 注册 content-check scaffold 扫描
- `agent-flow/scripts/check-change.ps1` — 注册 content-check scaffold 扫描

## 验证证据

- content-check --project-root: 21/21 通过
- scaffold-health: pass
- design-check: pass
- alignment-check: pass (skipped)
- scan-check (strict): pass
