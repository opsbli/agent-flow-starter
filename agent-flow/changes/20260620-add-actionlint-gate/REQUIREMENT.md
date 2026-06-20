# Requirement

## 背景

`agent-flow/changes/20260620-add-shell-lint-ci/EVOLUTION.md` 建议新增一个 CI YAML workflow 语法验证 gate。当前 `.github/workflows/*.yml` 的语法正确性仅依赖 GitHub Actions 自身的运行时解析，修改后推送到 CI 才能发现错误。

## 用户角色

- agent-flow 维护者：修改 CI 配置时能通过 `actionlint-check` 本地/CI 发现语法错误
- agent-flow 使用者：项目中存在 `.github/workflows/*.yml` 时可运行门禁

## 目标

新增 actionlint gate，非阻塞模式，工具未安装时优雅跳过。

## 非目标

- 不安���本地 actionlint 作为硬依赖

## 验收标准

| AC | Given | When | Then | 验证方式 |
|---|---|---|---|---|
| AC-01 | actionlint 未安装 | 运行 `bash agent-flow/scripts/actionlint-check.sh` | 跳过并提示安装方式，exit 0 | `bash agent-flow/scripts/actionlint-check.sh` |
| AC-02 | actionlint 未安装 | 运行 `pwsh agent-flow/scripts/actionlint-check.ps1` | 跳过并提示安装方式，exit 0 | 手动确认（CI 环境） |
| AC-03 | 存在 `.github/workflows/*.yml` | 运行 actionlint-check | 检测到 workflow 文件 | 命令行输出确认 |
| AC-04 | manifest.yaml | 检查 script_registry.gates | 包含 actionlint-check 条目 | `manifest-check` pass |
| AC-05 | gates.txt | 检查文件内容 | 包含 actionlint-check 条目 | `grep` 确认 |
| AC-06 | check-change 脚本 | 检查调用 | 包含 actionlint-check 门禁 | `grep` 确认 |
| AC-07 | scaffold-ci.yml | 检查 CI 配置 | 包含 actionlint job | `grep` 确认 |
| AC-08 | 所有修改完成 | 运行 scaffold-health | 通过 | scaffold-health pass |

## 异常和边界

## 未决问题

## 用户确认记录
