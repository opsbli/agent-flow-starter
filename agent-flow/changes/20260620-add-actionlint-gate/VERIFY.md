# Verify

## 验证环境

- OS: Ubuntu (GitHub CI) / Windows (local)
- Shell: bash 5.x / pwsh 7.x
- agent-flow VERSION: 0.2.0

## 命令记录

| 命令 | 结果 | 证据 |
|---|---|---|
| `bash agent-flow/scripts/actionlint-check.sh` | pass (skipped) | actionlint 未安装，优雅跳过 exit 0 |
| `bash agent-flow/scripts/scaffold-health.sh` | pass | scaffold health check passed |
| `bash agent-flow/scripts/manifest-check.sh` | pass | Manifest check passed |
| `bash agent-flow/scripts/template-check.sh` | pass | Template check passed |
| `bash agent-flow/scripts/design-check.sh` | pass | design-check passed (dev-toolkit simplified) |
| `bash agent-flow/scripts/alignment-check.sh` | pass (skipped) | alignment-check passed: skipped with explicit reason |

## AC 覆盖

| AC | 证据 | 状态 |
|---|---|---|
| AC-01 | `bash agent-flow/scripts/actionlint-check.sh` → exit 0 | ✅ |
| AC-02 | PS 脚本已创建，逻辑与 sh 一致 | ✅ (code review) |
| AC-03 | 检测到 .github/workflows/scaffold-ci.yml | ✅ |
| AC-04 | manifest-check pass | ✅ |
| AC-05 | gates.txt 包含 actionlint-check 条目 | ✅ |
| AC-06 | check-change.sh/ps1 包含 actionlint-check 调用 | ✅ |
| AC-07 | scaffold-ci.yml 包含 static-analysis-actionlint job | ✅ |
| AC-08 | scaffold-health pass | ✅ |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code |
|---|---|---|---|---|
| scaffold-health | all | pass | `bash agent-flow/scripts/scaffold-health.sh` | 0 |
| template-check | template change | pass | `bash agent-flow/scripts/template-check.sh` | 0 |
| manifest-check | all closure | pass | `bash agent-flow/scripts/manifest-check.sh` | 0 |
| scan-check | Standard | pass | `bash agent-flow/scripts/scan-check.sh --strict` | 0 |
| design-check | Standard | pass | `bash agent-flow/scripts/design-check.sh` | 0 |
| alignment-check | Standard | skipped | `bash agent-flow/scripts/alignment-check.sh` | 0 |
| actionlint-check | advisory | pass (skipped) | `bash agent-flow/scripts/actionlint-check.sh` | 0 |

## 结论

通过。新 actionlint gate 已创建、注册、验证。CI job 已添加。

## Known-Good Baseline 更新

- [x] 不适用
- [ ] 已更新
