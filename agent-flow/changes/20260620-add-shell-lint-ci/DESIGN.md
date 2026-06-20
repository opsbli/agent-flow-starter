# Design

## 设计概述

在现有 CI 配置中新增两个 job：
1. `static-analysis`（ubuntu-latest）— 使用 shellcheck 扫描所有 `.sh` 脚本
2. `static-analysis-ps1`（windows-latest）— 使用 PSScriptAnalyzer 扫描所有 `.ps1` 脚本

验收标准：AC-01 (shellcheck执行), AC-02 (PSScriptAnalyzer执行), AC-03 (非阻塞), AC-04 (优雅跳过)。

## 关键决策

| # | 决策点 | 选项 A | 选项 B | 选择 | 理由 | 代码引用 |
|---|--------|--------|--------|------|------|---------|
| D-01 | shellcheck 失败策略 | `continue-on-error: true`（宽松） | 阻塞 CI（严格） | **A — 宽松** | 18K 行脚本积累了大量 warning，阻塞 CI 会阻塞所有 PR。先用宽松模式收集基线，后续 change 逐步修复 | `.github/workflows/scaffold-ci.yml` 现有 `syntax-check` 也是先检查再决定是否 fail |
| D-02 | PSScriptAnalyzer 安装方式 | `Install-Module` 在线安装 | 预装到 runner 镜像 | **A — 在线安装** | windows-latest 镜像未预装 PSScriptAnalyzer，在线安装是官方推荐方式 | GitHub Actions windows-latest 软件清单 |
| D-03 | shellcheck severity 级别 | `--severity=warning` | `--severity=error` | **A — warning** | 与渐进式策略一致。warning 级别的发现（如 SC2086 未加引号变量）在生产中更常见，error 级别太少 | shellcheck 官方文档 |
| D-04 | 扫描范围 | `agent-flow/scripts/*.sh` + `agent-flow/test/test-scripts/*.sh` | 全仓库 `**/*.sh` | **A — 限定范围** | `scripts/` 下的安装脚本（如 setup-new-pc.sh）包含平台特定路径语法，容易触发误报。限定范围与现有 syntax-check 一致 | `.github/workflows/scaffold-ci.yml:140` 已有的文件范围 |
| D-05 | Job 依赖 | `needs: scaffold-health` | 独立运行 | **A — 依赖 scaffold-health** | 与现有所有质量 job 保持一致（syntax-check, smoke-test-ps1 等都依赖 scaffold-health） | `.github/workflows/scaffold-ci.yml:80,108,130` |
| D-06 | REST Path | — | — | **not-applicable** | 纯 CI 配置变更，无 REST API 变更 | — |
| D-07 | HTTP Method | — | — | **not-applicable** | 纯 CI 配置变更，无 HTTP 方法变更 | — |
| D-08 | Permission Code | — | — | **not-applicable** | 纯 CI 配置变更，无权限码变更 | — |
| D-09 | SaCheckPermission | — | — | **not-applicable** | 纯 CI 配置变更，无权限注解变更 | — |
| D-10 | Anonymous Interface | — | — | **not-applicable** | 纯 CI 配置变更，无接口变更 | — |
| D-11 | Login/Token | — | — | **not-applicable** | 纯 CI 配置变更，无登录/Token变更 | — |
| D-12 | Tenant/Data Permission | — | — | **not-applicable** | 纯 CI 配置变更，无租户/数据权限变更 | — |
| D-13 | State Machine Impact | — | — | **not-applicable** | 纯 CI 配置变更，无状态机影响 | — |

Decision Status: accepted

State Machine Impact: not-applicable

This change has no state machine or workflow impact (CI configuration only).

## Design Alignment / Grill

Alignment Source: mixed

Open Questions: none

| # | Question | Confirmation | Evidence |
|---|---------|-------------|----------|
| Intent Risk | 本次变更是否可能误解需求意图？建议：**否**。需求明确——在 CI 中新增 shellcheck + PSScriptAnalyzer，不修改业务逻辑。范围精确到单一 YAML 文件。 | user-confirmed | REQUIREMENT.md AC-01~AC-04 明确定义了4条可验证的验收标准 |
| Existing Code Fit | 新增代码是否符合项目现有模式？建议：**是**。完全遵循现有 CI 配置结构：`needs: scaffold-health`、分离 Linux/Win job、Step Summary 输出。 | code-confirmed | `.github/workflows/scaffold-ci.yml:130-172` syntax-check 结构；L50-76 Step Summary 模式 |
| Unnecessary Abstraction | 是否引入了不必要的抽象？建议：**否**。零新增抽象。仅新增两个 CI job，直接使用 shellcheck 和 PSScriptAnalyzer 命令行调用，无封装层。 | code-confirmed | shellcheck 和 Invoke-ScriptAnalyzer 均为标准 CLI 调用 |
| Protected Areas | 是否触碰了受保护区域？建议：**否**。不修改任何 agent-flow 规则文件、模板、核心脚本。仅编辑 CI 配置文件。 | user-confirmed | write_files 限定为 `.github/workflows/scaffold-ci.yml` |
| Boundary And Failure Modes | 边界条件和失败模式是否已评估？建议：**是**。已评估：(a) shellcheck 误报；(b) PSScriptAnalyzer 安装失败；(c) 企业 runner 无网络。所有失败模式均为非阻塞，continue-on-error 兜底。 | user-confirmed | DESIGN.md 风险评估表：3 个风险均有缓解措施 |
| shellcheck-warning-threshold | shellcheck 初始运行时预计产生 50+ warning，使用 `continue-on-error: true` 是否接受？建议：**是**，渐进式引入，后续 change 逐步修复。 | user-confirmed | 业界标准做法（ESLint 迁移、mypy 渐进类型化） |
| ci-summary-output | 是否需要在 CI step summary 中输出 lint 结果摘要？建议：**是**，参考现有 Performance Baseline Summary。 | user-confirmed | `.github/workflows/scaffold-ci.yml:50-76` 已有模式 |
| pssa-install-overhead | PSScriptAnalyzer 在线安装每次 CI 都要下载模块（~2MB），是否接受？建议：**是**，2MB 下载对 CI 时间影响 < 5s。 | user-confirmed | PowerShell Gallery CDN 延迟通常 < 1s |

Alignment Verdict: aligned

## State Machine Impact

- 无（不涉及状态机变更）

## API / Permission / Auth Impact

- 无（纯 CI 配置变更，不涉及应用级 API/权限/认证）

## 风险评估

| 风险 | 概率 | 影响 | 缓解 |
|------|------|------|------|
| shellcheck 误报导致开发者困惑 | 中 | 低 | 使用 `continue-on-error: true`，不影响 CI 通过；在 CI log 中标注"非阻塞" |
| PSScriptAnalyzer 安装失败 | 低 | 低 | 使用 `continue-on-error: true`，job 显示 warning 但不失败 |
| windows-latest 无网络权限（企业 runner） | 低 | 中 | PSScriptAnalyzer job 标记 `continue-on-error: true`，网络不可用时跳过 |

## 实现路径

1. 编辑 `.github/workflows/scaffold-ci.yml`
2. 在 `file-consistency` job 之后插入 `static-analysis` 和 `static-analysis-ps1` 两个新 job
3. 运行 `agent-flow/scripts/scaffold-health.sh` 验证 CI 配置不破坏现有检查
