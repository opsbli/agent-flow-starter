# Evolution

problem: 设计检查对非后端变更的适配性不足。`design-decision.keys` 中 8 个必填决策行（REST Path、HTTP Method、Permission Code 等）对 CI 配置类变更完全不适用，全部填 not-applicable 显得形式化。

knowledge: (1) shellcheck — Haskell 编写的 shell 静态分析工具，检查 bash/sh 脚本中的常见错误和陷阱；(2) PSScriptAnalyzer — Microsoft 官方的 PowerShell 静态代码检查器；(3) DESIGN.md 表格列偏移陷阱 — Design Alignment 表格必须严格使用 4 列格式（# / Question / Confirmation / Evidence），额外列会导致 alignment-check 字段偏移失败。

adr: 无新 ADR。本次变更范围（CI workflow 新增 job）不涉及架构决策变更。

gate: 建议新增 CI YAML workflow 语法验证 gate（如 actionlint），在修改 .github/workflows/*.yml 时自动触发。当前依赖 GitHub Actions 自身的运行时解析。

template: DESIGN.md 模板的 Design Alignment / Grill 章节应增加注释：表格必须严格 4 列（| # | Question | Confirmation | Evidence |），额外列会导致 alignment-check 失败。

no_change_reason: design-decision.keys 上下文感知改动涉及流程核心逻辑，需独立 Heavy change 评审。alignment-check 表格列偏移是脚本实现细节，需专门 bugfix change。
