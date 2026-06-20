# Module Map

## Current Modules

| Module | Path | Responsibility | Notes |
|---|---|---|---|
| agent-flow core | `agent-flow/` | AI 开发工作流框架核心 | 包含 flows/, core/, rules/, templates/, scripts/, knowledge/, decisions/ |
| agent-flow scripts | `agent-flow/scripts/` | 门禁(gates)、工具(tools)、生成器(generators) | 128 个脚本 (64 ps1 + 64 sh)，分类见 manifest.yaml script_registry |
| agent-flow flows | `agent-flow/flows/` | Light/Standard/Heavy/Emergency 流程定义 | 由 router.md 根据 risk_rules 自动路由 |
| agent-flow templates | `agent-flow/templates/` | 20 个 change 工件模板 | 含 STANDARD 流程全量工件及 CANCEL/ROLLBACK/INIT_CHECKLIST |
| agent-flow rules | `agent-flow/rules/` | gate 读取的规则文件和检查清单 | design-decision.keys, design-alignment.questions, gates.txt, artifact-schema.json 等 |
| CI pipeline | `.github/workflows/scaffold-ci.yml` | 脚手架健康检查 + 语法检查 + 静态分析 + 冒烟测试 + 单元测试 | 9 个 job 覆盖 Linux/Windows 双平台 |
| Installer scripts | `scripts/` | 安装器、新机配置、ECC 技能打包 | setup-new-pc, install-agent-flow, bundle-ecc-skills, test-starter |
| Documentation | `docs/` | 中文使用手册、渐进学习路径、反模式指南、故障排除 | 中英双语 |
| Examples | `examples/` | Light/Standard/Heavy 三个级别的示例 change | 含 WALKTHROUGH.md 逐步讲解 |
| pi integration | `.pi/` | pi AI 编码助手绑定指令和技能 | APPEND_SYSTEM.md (入口指令), prompts/, skills/ |

## Entry Points

| Entry | Path | Purpose |
|---|---|---|
| AI 默认入口 | `agent-flow/GO.md` | 收到需求后 AI 的第一读取文件 |
| 项目画像 | `agent-flow/manifest.yaml` | 项目类型、技术栈、风险规则、脚本注册表 |
| 知识索引 | `agent-flow/knowledge/INDEX.md` | 知识库全局入口 + 流程统计 |
| 终端兜底 | `agent-flow/READING.md` | 终端乱码时的 ASCII 读取兜底 |
| 用户快速开始 | `agent-flow/scripts/af-quickstart.sh` | 新手引导第一命令 |
| CI 入口 | `.github/workflows/scaffold-ci.yml` | 自动化质量门禁 |

## New Module Registry

| Module | Path | Responsibility | Registration Point | Change |
|---|---|---|---|---|
| pair-consistency-check | `agent-flow/scripts/pair-consistency-check.*` | 检测 ps1/sh 双轨脚本差异 | manifest.yaml tools, gates.txt | add-shell-lint-ci |
