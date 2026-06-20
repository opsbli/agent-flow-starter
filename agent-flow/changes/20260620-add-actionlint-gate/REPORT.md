# Report

## Change

add-actionlint-gate — 新增 actionlint gate 验证 GitHub Actions workflow YAML 语法。

## 完成内容

| 修改 | 文件 | 说明 |
|---|---|---|
| 新 gate | `agent-flow/scripts/actionlint-check.sh` | 验证 .github/workflows/*.yml，非阻塞 |
| 新 gate | `agent-flow/scripts/actionlint-check.ps1` | PS 版本 |
| 注册 | `agent-flow/manifest.yaml` | script_registry.gates + gates 各新增 2 条目 |
| 注册 | `agent-flow/rules/gates.txt` | 新增 2 条目 |
| 注册 | `agent-flow/scripts/check-change.sh` | 新增 actionlint-check gate 调用 |
| 注册 | `agent-flow/scripts/check-change.ps1` | 新增 actionlint-check gate 调用 |
| CI job | `.github/workflows/scaffold-ci.yml` | 新增 static-analysis-actionlint job |

## 验证证据

- scaffold-health: pass
- template-check: pass
- manifest-check: pass
- design-check: pass
- scan-check (strict): pass
- alignment-check: pass (skipped)
- actionlint-check: pass (skipped, tool not installed)

## 未完成事项

无

## 风险和回滚

- 低。逐文件回滚即可。gate 非阻塞，不影响 CI 通过。

## 知识沉淀

- actionlint 是 GitHub Actions workflow YAML 验证工具。gate 使用非阻塞模式，工具未安装时优雅跳过。

## 后续建议

- 积累 actionlint 基线数据后，考虑是否需要在特定条件下切换为阻塞模式
