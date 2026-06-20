# Report

## Change

context-aware-design-decisions — 为 DESIGN.md 设计决策表增加非后端项目上下文感知能力。

## 完成内容

| 修改 | 文件 | 说明 |
|---|---|---|
| 路径修复 | `agent-flow/scripts/design-check.sh` | project_root 检测改为循环尝试 `../..` 和 `../../..` |
| 路径修复 | `agent-flow/scripts/design-check.ps1` | 同上 |
| 模板注释 | `agent-flow/templates/DESIGN.md` | API/Permission/Auth 节增加非后端项目简化指引 |
| 模板注释 | `agent-flow/test/fixtures/.../templates/DESIGN.md` | 同步更新 |
| State Machine Impact 跳过 | `agent-flow/scripts/design-check.sh` | 非后端项目跳过 State Machine Impact 检查 |
| State Machine Impact 跳过 | `agent-flow/scripts/design-check.ps1` | 同上 |

## 验证证据

- scaffold-health: pass
- template-check: pass
- manifest-check: pass
- design-check: pass
- scan-check (strict): pass
- alignment-check: pass (skipped with reason)

## 未完成事项

无

## 风险和回滚

- 低风险。路径修复增加 fallback，不影响正常流程。

## 知识沉淀

- design-check.sh/ps1 的 project_root 检测依赖 change_dir 深度。`agent-flow/changes/xxx` 需要 `../../..` 到达项目根目录。
- 修改 design-check 的 context-aware 逻辑时需要同时更新 backend_keys 列表和 State Machine Impact 跳过逻辑。

## 决策沉淀

无新 ADR。

## 后续建议

- **Phase 3**: 新增 actionlint gate 验证 CI YAML workflow 语法
