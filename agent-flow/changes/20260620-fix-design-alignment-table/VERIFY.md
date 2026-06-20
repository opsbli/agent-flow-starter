# Verify

## 验证环境

- OS: Ubuntu (GitHub CI) / Windows (local)
- Shell: bash 5.x / pwsh 7.x
- agent-flow VERSION: 0.2.0

## 命令记录

| 命令 | 结果 | 证据 |
|---|---|---|
| `bash agent-flow/scripts/scaffold-health.sh` | pass | scaffold health check passed. |
| `bash agent-flow/scripts/template-check.sh` | pass | Template check passed. Schema version: 1.0 |
| `bash agent-flow/scripts/manifest-check.sh` | pass | Manifest check passed. |
| `bash agent-flow/scripts/alignment-check.sh --change-dir agent-flow/changes/20260620-fix-design-alignment-table` | pass (skipped) | alignment-check passed: skipped with explicit reason. |
| `bash agent-flow/scripts/design-check.sh --change-dir agent-flow/changes/20260620-fix-design-alignment-table` | pass | design-check passed. |
| `bash agent-flow/scripts/scan-check.sh --change-dir agent-flow/changes/20260620-fix-design-alignment-table --project-root . --strict` | pass | Scan check passed for Standard change (strict). |

## AC 覆盖

| AC | 证据 | 状态 |
|---|---|---|
| AC-01 | templates/DESIGN.md 列头改为 `| # | Question | Confirmation | Evidence |` | ✅ |
| AC-02 | generate-design.sh 输出正确列头 | ✅ |
| AC-03 | generate-design.ps1 输出正确列头 | ✅ |
| AC-04 | test fixture template 列头正确 | ✅ |
| AC-05 | test-gate-smoke.sh 使用正确列头 | ✅ |
| AC-06 | test-gate-smoke.ps1 使用正确列头 | ✅ |
| AC-07 | test-check-change.sh 使用正确列头 | ✅ |
| AC-08 | test-check-change.ps1 使用正确列头 | ✅ |
| AC-09 | scaffold-health 通过 | ✅ |

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | templates/DESIGN.md 列头修正 | command | `grep -n "| # | Question | Confirmation | Evidence |" agent-flow/templates/DESIGN.md` | pass | none |
| AC-02 | generate-design.sh 列头修正 | command | `grep -n "| # | Question | Confirmation | Evidence |" agent-flow/scripts/generate-design.sh` | pass | none |
| AC-03 | generate-design.ps1 列头修正 | command | `grep -n "| # | Question | Confirmation | Evidence |" agent-flow/scripts/generate-design.ps1` | pass | none |
| AC-04 | test fixture 模板修正 | command | `grep -n "| # | Question | Confirmation | Evidence |" agent-flow/test/fixtures/minimal-project/agent-flow/templates/DESIGN.md` | pass | none |
| AC-05 | test-gate-smoke.sh 修正 | command | `grep -n "| # | Question | Confirmation | Evidence |" agent-flow/test/test-scripts/test-gate-smoke.sh` | pass | none |
| AC-06 | test-gate-smoke.ps1 修正 | command | `grep -n "| # | Question | Confirmation | Evidence |" agent-flow/test/test-scripts/test-gate-smoke.ps1` | pass | none |
| AC-07 | test-check-change.sh 修正 | command | `grep -n "| # | Question | Confirmation | Evidence |" agent-flow/test/test-scripts/test-check-change.sh` | pass | none |
| AC-08 | test-check-change.ps1 修正 | command | `grep -n "| # | Question | Confirmation | Evidence |" agent-flow/test/test-scripts/test-check-change.ps1` | pass | none |
| AC-09 | scaffold-health 通过 | command | `bash agent-flow/scripts/scaffold-health.sh` → pass | pass | none |

## Coverage Summary

| Metric | Source | Value | Result | Notes |
|---|---|---|---|---|
| AC Coverage | grep 确认每个文件列头 | 9/9 | pass | 所有 AC 已验证 |
| Test Coverage | N/A | N/A | skipped | 模板列名变更，无需测试覆盖 |

## Drift 检查

| 类型 | 结果 | 说明 |
|---|---|---|
| schema | N/A | 不涉及 |
| route | N/A | 不涉及 |
| permission | N/A | 不涉及 |
| pom | N/A | 不涉及 |
| scan-check | pass | 扫描完整性通过 |
| design-check | pass | 设计检查通过 |
| alignment-check | pass (skipped) | 脚手架自修改，明确跳过 |
| task-check | N/A | 未创建 TASKS.md 级任务（纯模板修复） |
| plan-check | N/A | Standard 流程，无需 Plan Audit |
| task-boundary-check | N/A | 无实现代码 |
| manifest-check | pass | Manifest 检查通过 |
| blocked-check | N/A | 不涉及危险操作 |
| evolution-check | pass | EVOLUTION.md 已填写 |
| closure-check | N/A | Standard 流程，无需 Closure Audit |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scaffold-health | all | pass | `bash agent-flow/scripts/scaffold-health.sh` | 0 | 2026-06-20 | scaffold health check passed |
| template-check | template change | pass | `bash agent-flow/scripts/template-check.sh` | 0 | 2026-06-20 | Template check passed |
| manifest-check | all closure | pass | `bash agent-flow/scripts/manifest-check.sh` | 0 | 2026-06-20 | Manifest check passed |
| scan-check | Standard | pass | `bash agent-flow/scripts/scan-check.sh --change-dir ... --strict` | 0 | 2026-06-20 | Scan check passed |
| design-check | Standard | pass | `bash agent-flow/scripts/design-check.sh --change-dir ...` | 0 | 2026-06-20 | design-check passed |
| alignment-check | Standard | skipped | `bash agent-flow/scripts/alignment-check.sh --change-dir ...` | 0 | 2026-06-20 | skipped with explicit reason |

## 跳过项

| 项 | 原因 | 风险 |
|---|---|---|
| task-check | 纯模板列名修复，无 TASKS.md | 无 |
| plan-check | Standard 流程，只有单个文件修改级任务 | 无 |
| blocked-check | 不涉及 manifest.yaml blocked_if 规则 | 无 |
| closure-check | Standard 流程，无需 Closure Audit | 无 |
| code-drift-check | Standard 流程，无实现代码 | 无 |
| coverage-check 测试覆盖率 | 模板列名变更，没有需要测试覆盖的逻辑代码 | 无 |

## 结论

通过。所有 8 个文件的列头已统一修正，scaffold-health/template-check/manifest-check/design-check/scan-check 均通过。

## Known-Good Baseline 更新

- [x] 不适用
- [ ] 已更新 `agent-flow/knowledge/known-good-baselines.md`
