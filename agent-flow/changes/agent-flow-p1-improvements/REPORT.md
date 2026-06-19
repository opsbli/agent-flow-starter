# Report

## Delivered

### AC-01: api-compatibility-check gate (P1)

### AC-02: db-migration-check gate (P2)

### AC-03: Gate registration

### AC-04: frontend-fit.md enhancement (P1)

### AC-05: DESIGN.md template enhancement (P2)

### P1 — 运行时契约/权限自动化检查
- **新增 `api-compatibility-check.ps1` + `.sh`**：解析 DESIGN.md 的 API 设计表和 Permission/Auth 决策表，扫描项目源码中的路径引用和权限码。默认输出 warning（非阻塞），可通过 manifest.yaml 的 `strict_compatibility: true` 升级为 fail。
- 注册到 `check-change.ps1`、`check-change.sh`、`manifest.yaml`、`gates.txt`

### P2 — 数据库迁移验证
- **新增 `db-migration-check.ps1` + `.sh`**：检查 Heavy/Standard change 的 TASKS.md write_files 中是否包含迁移脚本的回滚文件。支持 `rollback: not-needed` 在 CHANGE.md 中显式豁免。非阻塞输出 warning。
- 注册到 `check-change.ps1`、`check-change.sh`、`manifest.yaml`、`gates.txt`

### P1 — 前后端联调和前端自动化验证增强
- **增强 `frontend-fit.md`**：增加 Chrome DevTools 联调检查清单（Network/Console/Elements/Application 四个面板）；增加交付前检查的强制声明（含前端项目必须执行基础检查）；增加联调结果记录指引。
- **增强 `DESIGN.md` 模板**：增加 "DB Change 决策表"（表/列/索引/约束/默认值/枚举的回滚策略）；增加 "前端验证契约" 表。

## Verification

- `agent-flow/scripts/scaffold-health.ps1` — ✅ pass
- `agent-flow/scripts/template-check.ps1` — ✅ pass
- PowerShell syntax check — ✅ pass (all 4 new scripts)
- Bash syntax check (`bash -n`) — ✅ pass (both .sh scripts)
- Gate registration grep — ✅ confirmed in 4 registration points each

## Residual Risks

| Risk | Mitigation |
|------|-----------|
| api-compatibility-check 是启发式检查，可能漏报或误报 | 默认非阻塞（warning 级别），人工确认仍为最终保障 |
| db-migration-check 无法区分 additive 和 destructive schema 变更 | 支持 CHANGE.md 显式豁免 `rollback: schema-only-add` |
| 前端验证清单目前是参考指引，非强制 | 后续可在 manifest.yaml 增加 `frontend_verify_required: true` 开关 |

## Rollback

1. Delete: `agent-flow/scripts/api-compatibility-check.ps1/.sh`
2. Delete: `agent-flow/scripts/db-migration-check.ps1/.sh`
3. Revert: `agent-flow/scripts/check-change.ps1` — remove 4 lines
4. Revert: `agent-flow/scripts/check-change.sh` — remove 4 lines
5. Revert: `agent-flow/manifest.yaml` — remove 4 entries from gates list
6. Revert: `agent-flow/rules/gates.txt` — remove 4 lines
7. Revert: `agent-flow/core/frontend-fit.md` — remove DevTools checklist section
8. Revert: `agent-flow/templates/DESIGN.md` — remove DB Change table and frontend verification section

## Knowledge

- agent-flow 自身也可以作为被管理的项目走 agent-flow 流程
- 新增 Gate 需要注册到 4 个位置：manifest.yaml、gates.txt、check-change.ps1、check-change.sh

## Log

- Log: agent-flow/logs/2026/06-16.md (update)
- Known-Good Baseline: Updated with new gate files
