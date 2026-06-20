# Requirement

## 背景

当前 CI（`.github/workflows/scaffold-ci.yml`）已有 `syntax-check` job 做 `bash -n` 语法检查和 `[System.Management.Automation.Language.Parser]::ParseFile` 语法检查，但仅限于语法正确性。18,224 行 shell/powershell 脚本缺乏结构化静态分析（代码异味、潜在 bug、安全风险）。

## 用户角色

- **CI 维护者**：希望自动发现脚本质量问题
- **贡献者**：希望在 PR 阶段获得即时反馈

## 术语

| 术语 | 定义 | 是否已沉淀到 glossary |
|---|---|---|
| shellcheck | Haskell 编写的 shell 静态分析工具，检查 bash/sh 脚本中的常见错误和陷阱 | no（新术语） |
| PSScriptAnalyzer | Microsoft 官方的 PowerShell 静态代码检查器 | no（新术语） |

## 目标

- 在 CI 中新增 `static-analysis` job，对 `agent-flow/scripts/*.sh` 和 `agent-flow/test/test-scripts/*.sh` 运行 `shellcheck`
- 在 CI 中新增 Windows runner 上的 `static-analysis-ps1` job，对 `agent-flow/scripts/*.ps1` 和 `agent-flow/test/test-scripts/*.ps1` 运行 `PSScriptAnalyzer`
- 使用合理 severity 阈值，避免初始运行时大量失败阻塞 CI
- 保持与现有 `syntax-check` 和 `file-consistency` job 的互补关系

## 非目标

- 不修改任何 `.sh` / `.ps1` 脚本内容使它们通过 lint（本次仅加检查器，修复为后续 change）
- 不替换现有的 `syntax-check` job
- 不在本地 pre-commit hook 中强制运行（仅 CI）

## 非功能需求

| 维度 | 要求 (或 none) | 验证方式 | 优先级 |
|---|---|---|---|
| 性能 | CI 增量耗时 < 60s | CI 计时 | P1 |
| 安全 | none | — | — |
| 可观测性 | lint 结果输出到 CI step summary | GitHub Step Summary | P2 |
| 可用性 | none | — | — |
| 延迟 | none | — | — |

## 业务规则

| 编号 | 规则 |
|---|---|
| R-01 | shellcheck 使用 `--severity=warning` 最低级别，仅报 warning 及以上 |
| R-02 | PSScriptAnalyzer 使用 `-Severity Warning` 过滤 |
| R-03 | 初始运行标记为 `continue-on-error: true`，不阻塞 CI（渐进式引入） |

## 验收标准

| AC | Given | When | Then | 验证方式 |
|---|---|---|---|---|
| AC-01 | CI 触发 push/PR | static-analysis job 运行 | shellcheck 对所有 `.sh` 文件执行完成，输出结果 | CI logs |
| AC-02 | CI 触发 push/PR | static-analysis-ps1 job 运行 | PSScriptAnalyzer 对所有 `.ps1` 文件执行完成，输出结果 | CI logs |
| AC-03 | 脚本存在已知问题 | 静态分析运行 | CI job 不因 lint 发现而失败（continue-on-error: true） | CI 状态仍为 pass |
| AC-04 | 无 shellcheck/PSScriptAnalyzer 可用 | static-analysis job 运行 | job 优雅跳过（使用 if: 或 fallback），不影响整体 CI | CI 状态仍为 pass |

## 异常和边界

- `ubuntu-latest` 镜像已预装 `shellcheck`（GitHub Actions 官方文档确认），无需额外安装
- `windows-latest` 镜像需通过 `Install-Module -Name PSScriptAnalyzer -Force` 安装
- 如 `scripts/` 目录下的安装脚本（`setup-new-pc.sh` 等）有平台特定语法，shellcheck 可能产生误报——使用 `.shellcheckrc` 或行内注释抑制

## 未决问题

- 无

## 用户确认记录

- 2026-06-20: 方案确认 — 渐进式引入（continue-on-error），不修改已有脚本
