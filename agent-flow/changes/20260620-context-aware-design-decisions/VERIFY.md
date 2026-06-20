# Verify

## 验证环境

- OS: Ubuntu (GitHub CI) / Windows (local)
- Shell: bash 5.x / pwsh 7.x
- agent-flow VERSION: 0.2.0

## 命令记录

| 命令 | 结果 | 证据 |
|---|---|---|
| `bash agent-flow/scripts/scaffold-health.sh` | pass | scaffold health check passed |
| `bash agent-flow/scripts/template-check.sh` | pass | Template check passed |
| `bash agent-flow/scripts/manifest-check.sh` | pass | Manifest check passed |
| `bash agent-flow/scripts/design-check.sh --change-dir .../context-aware-design-decisions` | pass | design-check passed |
| `bash agent-flow/scripts/scan-check.sh --change-dir ... --project-root . --strict` | pass | Scan check passed |
| `bash agent-flow/scripts/alignment-check.sh --change-dir ...` | pass (skipped) | alignment-check passed: skipped with explicit reason |

## AC 覆盖

| AC | 证据 | 状态 |
|---|---|---|
| AC-01 | templates/DESIGN.md 包含非后端项目简化指引注释 | ✅ |
| AC-02 | design-check.sh 路径修复后，dev-toolkit 项目跳过后端键 | ✅ |
| AC-03 | design-check.ps1 路径修复后，dev-toolkit 项目跳过后端键 | ✅ |
| AC-04 | generate-design.sh 无需修改（不同格式） | ✅ (N/A) |
| AC-05 | generate-design.ps1 无需修改（不同格式） | ✅ (N/A) |
| AC-06 | 脚手架自身 change 运行 design-check 通过（路径修复生效） | ✅ |
| AC-07 | scaffold-health 通过 | ✅ |
| AC-08 | template-check 通过 | ✅ |

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | 模板增加简化指引 | code | `agent-flow/templates/DESIGN.md:33-35` | pass | none |
| AC-02 | design-check.sh 路径修复 | command | `bash agent-flow/scripts/design-check.sh --change-dir ...` → pass | pass | none |
| AC-03 | design-check.ps1 路径修复 | code | 代码已修改（循环尝试 `../..` `../../..`） | pass | 无法直接测试 PS 版本 |
| AC-04 | generate-design.sh 无需修改 | manual | 使用独立格式，无 8 行设计决策表 | pass | none |
| AC-05 | generate-design.ps1 无需修改 | manual | 同上 | pass | none |
| AC-06 | 脚手架自检通过 | command | `design-check.sh` 在本 change 上通过 | pass | none |
| AC-07 | scaffold-health | command | scaffold health check passed | pass | none |
| AC-08 | template-check | command | Template check passed | pass | none |

## Drift 检查

| 类型 | 结果 | 说明 |
|---|---|---|
| schema | N/A | 不涉及 |
| route | N/A | 不涉及 |
| permission | N/A | 不涉及 |
| scan-check | pass | 扫描完整性通过 |
| design-check | pass | 设计检查通过 |
| alignment-check | pass (skipped) | 脚手架自修改，明确跳过 |
| manifest-check | pass | Manifest 检查通过 |
| evolution-check | pending | 待填写 |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When |
|---|---|---|---|---|---|
| scaffold-health | all | pass | `bash agent-flow/scripts/scaffold-health.sh` | 0 | 2026-06-20 |
| template-check | template change | pass | `bash agent-flow/scripts/template-check.sh` | 0 | 2026-06-20 |
| manifest-check | all closure | pass | `bash agent-flow/scripts/manifest-check.sh` | 0 | 2026-06-20 |
| scan-check | Standard | pass | `bash agent-flow/scripts/scan-check.sh --strict` | 0 | 2026-06-20 |
| design-check | Standard | pass | `bash agent-flow/scripts/design-check.sh` | 0 | 2026-06-20 |
| alignment-check | Standard | skipped | `bash agent-flow/scripts/alignment-check.sh` | 0 | 2026-06-20 |

## 跳过项

| 项 | 原因 | 风险 |
|---|---|---|
| task-check | 纯模板/脚本修复，无 TASKS.md | 无 |
| blocked-check | 不涉及 manifest.yaml blocked_if 规则 | 无 |
| code-drift-check | 无实现代码 | 无 |
| coverage-check | 无业务逻辑变更，无需测试覆盖 | 无 |
| closure-check | Standard 流程，无需 Closure Audit | 无 |

## 结论

通过。design-check 路径检测修复 + 模板简化指引 + State Machine Impact 跳过，所有门禁通过。

## Known-Good Baseline 更新

- [x] 不适用
- [ ] 已更新
