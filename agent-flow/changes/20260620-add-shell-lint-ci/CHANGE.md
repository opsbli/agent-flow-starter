# Change: add-shell-lint-ci

## 一句话需求

在 CI 中新增 shellcheck + PSScriptAnalyzer 静态分析 job，渐进式引入（不阻塞 CI）。

## 背景

CI 已有 `syntax-check`（bash -n / ParseFile 语法）和 `file-consistency`（ps1/sh 配对），但 18K 行脚本缺乏结构化静态分析能力。shellcheck 和 PSScriptAnalyzer 是各自生态的标准工具，集成成本极低。

## 流程级别

- [ ] Light
- [x] Standard
- [ ] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由

单文件修改（`.github/workflows/scaffold-ci.yml`），不改 schema/权限/API。属于 Standard 流程（有明确的验收标准和设计选择）。

## 目标

- `.github/workflows/scaffold-ci.yml` 新增 `static-analysis` (shellcheck) + `static-analysis-ps1` (PSScriptAnalyzer) job
- 所有 `.sh` 文件通过 shellcheck 扫描
- 所有 `.ps1` 文件通过 PSScriptAnalyzer 扫描
- 初始运行使用 `continue-on-error: true`，渐进式引入

## 非目标

- 不修改任何已有脚本代码使其通过 lint
- 不添加本地 pre-commit hook
- 不替换现有 syntax-check job

## 影响范围

- `.github/workflows/scaffold-ci.yml`（唯一修改文件）
- 可选：`.shellcheckrc`（shellcheck 配置，抑制特定规则）

## 关联前端

- [x] 否

## 风险

- **低**：仅新增 CI job，不修改已有逻辑
- shellcheck 可能对平台特定脚本（如 setup-new-pc.sh 的 apt-get 路径）产生误报
- PSScriptAnalyzer 需要网络安装模块（windows-latest 镜像）

## 需要用户确认的问题

- 无（方案已在 REQUIREMENT.md 中明确）

## 工件索引

- State: STATE.md
- Requirement: REQUIREMENT.md
- Code Scan: CODE_SCAN.md
- Design: DESIGN.md
- Tasks: TASKS.md
- Verify: VERIFY.md
- Report: REPORT.md
- Evolution: EVOLUTION.md
