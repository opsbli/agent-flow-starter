# agent-flow + ECC 能力集成

本文件将 ECC 的 197 个技能映射到 agent-flow 的每个工作流步骤。
安装 ECC 后（`pi install npm:ecc-universal`），AI 可在对应步骤自动调用相关技能。

---

## 技能速查表

### 第零步：紧急判断

| 需要 | 对应 ECC 能力 | 用法 |
|------|-------------|------|
| 快速评估风险等级 | /ecc-plan | `/ecc-plan 评估此生产事故的影响范围和修复方案` |

---

### 第一步：建立 change

无需 ECC 技能。纯文件操作。

---

### 第二步：代码优先扫描 → CODE_SCAN.md ← **核心收益点**

| 扫描内容 | ECC 加速方案 | 用法 |
|---------|-------------|------|
| 项目骨架、构建文件、入口 | **ecc-explorer agent** | 在 CODE_SCAN.md 开头：`@ecc-explorer 扫描本项目结构和构建配置` |
| 现有相似模块/服务 | **ecc-explorer** | `@ecc-explorer 查找与 [功能] 相似的现有实现` |
| 数据库 schema / 迁移 | `/skill:postgres-patterns` | 查现有 schema 时参考数据库模式规范 |
| API 路由 / 接口风格 | `/skill:api-design` | 检查现有 API 是否符合 REST 设计规范 |
| 测试风格和覆盖率 | `/skill:verification-loop` | 了解项目现有测试模式 |
| 前端相关扫描 | `/skill:frontend-patterns` | 前端代码扫描时参考最佳实践 |

**推荐用法**：在 CODE_SCAN.md 中直接写：

```markdown
## ECC 辅助扫描记录
- 代码结构探索：@ecc-explorer
- API 设计检查：参考 api-design skill
- 安全风险初筛：参考 security-review skill
```

---

### 第三步：任务分级

无需 ECC 技能。遵循 `agent-flow/core/router.md` 判断。

---

### 第四步：写需求、设计、任务

| 工件 | ECC 能力 | 用法 |
|------|---------|------|
| REQUIREMENT.md | /ecc-plan | `/ecc-plan [功能描述]` 生成需求分析和范围界定 |
| DESIGN.md | **ecc-architect agent** | `@ecc-architect 设计 [模块] 架构，输出 ADR` |
| DESIGN.md | /skill:api-design | 设计 API 时参考 REST 模式 |
| DESIGN.md | /skill:backend-patterns | 后端架构决策参考 |
| DESIGN.md | /skill:frontend-patterns | 前端组件设计参考 |
| DESIGN.md | /skill:database-migrations | 数据库 schema 设计参考 |
| DESIGN.md | /skill:error-handling | 错误处理设计模式 |
| DESIGN.md | /skill:dart-flutter-patterns | Flutter 组件树设计 |
| TASKS.md | /ecc-plan | 结合 CODE_SCAN 结果分解任务 |

**推荐用法**：在 DESIGN.md 中嵌入：

```markdown
## 方案设计（ECC 辅助）
### 架构决策
（参考 ecc-architect agent、api-design skill 完成）

### 数据库设计
（参考 database-migrations skill、postgres-patterns skill）

### 安全设计
（参考 security-review skill）
```

---

### 第五步：高风险审计

| 审计项 | ECC 能力 | 用法 |
|-------|---------|------|
| 安全风险审查 | /ecc-security | `/ecc-security agent-flow/changes/<id>/` 扫描方案中涉及的安全风险 |
| 依赖风险评估 | /skill:security-review | 审查设计中的第三方依赖风险 |
| 架构合理性 | **ecc-architect agent** | `@ecc-architect 审查此设计方案的风险和备选方案` |

---

### 第六步：实现

| 语言/框架 | ECC 技能 | 用法 |
|----------|---------|------|
| TypeScript / JavaScript | /skill:coding-standards | 遵循项目编码规范 |
| React | /skill:react-patterns | 组件模式、hooks、性能优化 |
| NestJS | /skill:nestjs-patterns | 模块/服务/控制器模式 |
| Angular | /skill:angular-developer | Angular 组件和服务模式 |
| Python | /skill:python-patterns | Pythonic 编码规范 |
| FastAPI | /skill:fastapi-patterns | API 路由、依赖注入、Pydantic |
| Django | /skill:django-patterns | ORM、视图、中间件模式 |
| Go | /skill:golang-patterns | 并发、接口、错误处理模式 |
| Rust | /skill:rust-patterns | 所有权、trait、错误处理 |
| Java / Spring Boot | /skill:springboot-patterns | 分层架构、依赖注入 |
| Kotlin | /skill:kotlin-patterns | 协程、Flow、空安全 |
| Swift / SwiftUI | /skill:swiftui-patterns | 状态管理、视图组合 |
| Flutter / Dart | /skill:dart-flutter-patterns | Widget 组件化、状态管理 |
| Docker | /skill:docker-patterns | Dockerfile、Compose 最佳实践 |
| 通用 | /skill:error-handling | 错误处理模式 |

**推荐用法**：实现阶段 AI 会自行根据项目语言加载对应 skill。无需显式调用。

---

### 第七步：验证

| 验证项 | ECC 能力 | 用法 |
|-------|---------|------|
| 代码审查 | /ecc-review | `/ecc-review` 审查所有变更 |
| 安全扫描 | /ecc-security | `/ecc-security .` 扫描密钥和漏洞 |
| 质量门禁 | /ecc-quality | `/ecc-quality .` 运行完整检查链 |
| TDD 工作流 | /ecc-tdd | `/ecc-tdd [功能]` 红绿重构循环 |
| E2E 测试 | /skill:e2e-testing | Playwright 端到端测试模式 |
| 验证循环 | /skill:verification-loop | 编译、lint、测试、构建、安全全链验证 |

**推荐用法**：在 VERIFY.md 中记录：

```markdown
## 验证证据
### ECC 辅助验证
- [ ] 代码审查：运行 /ecc-review
- [ ] 安全扫描：运行 /ecc-security
- [ ] 质量门禁：运行 /ecc-quality
- [ ] 测试运行：npm test（或对应命令）
```

---

### 第八步：报告复盘

| 事项 | ECC 能力 | 用法 |
|------|---------|------|
| EVOLUTION.md | /skill:continuous-learning-v2 | 本能式提取本次经验 |
| 坑点记录 | — | 结合 agent-flow knowledge/pitfalls.md 手动记录 |

---

### 第九步：持续演进

| 事项 | ECC 能力 | 用法 |
|------|---------|------|
| 本能学习 | /skill:continuous-learning-v2 | 自动从 session 提取模式 |
| 技能演进 | /skill:continuous-learning | 从本能聚类为正式技能 |

---

## 速查：agent-flow 命令 → ECC 等价物

| agent-flow 门禁/检查 | ECC 替代/补充 |
|--------------------|-------------|
| `scan-check` | @ecc-explorer |
| `design-check` | @ecc-architect |
| `alignment-check` | @ecc-architect / Grill |
| `plan-check` | /ecc-plan |
| `task-check` | /ecc-plan |
| `code-drift-check` | /ecc-review |
| `blocked-check` | /ecc-security |
| `evolution-check` | /skill:continuous-learning-v2 |

---

## 安装

ECCs 已通过 `pi install npm:ecc-universal` 安装到本机。如需在目标项目启用集成：

```bash
# 确保 ECC 已安装
pi list | grep ecc-universal

# 安装 agent-flow（如尚未安装）
agent-flow/scripts/install-agent-flow.ps1 -Target .

# 本文件 agent-flow/ecc-integration.md 已随安装同步
```

---

*本文件随 agent-flow-starter 分发，需配合 ECC（affaan-m/ECC）使用。*

---
*This file is distributed with agent-flow-starter. Requires ECC (affaan-m/ECC).*

## New Automation Capabilities (2026-06)

| Step | Capability | Usage |
|------|-----------|-------|
| Design | generate-design.ps1/.sh - auto-generate DESIGN.md from CODE_SCAN.md | agent-flow/scripts/generate-design.ps1 -ChangeDir changes/<id> |
| Tasks | generate-tasks.ps1/.sh - auto-generate TASKS.md from DESIGN.md | agent-flow/scripts/generate-tasks.ps1 -ChangeDir changes/<id> |
| Report | generate-report.ps1/.sh - aggregate check results into REPORT.md | agent-flow/scripts/generate-report.ps1 -ChangeDir changes/<id> |
| Evolution | evolution-stats.ps1/.sh - data-driven project statistics | agent-flow/scripts/evolution-stats.ps1 |
| Evolution | evolution-suggest.ps1/.sh - auto improvement suggestions | agent-flow/scripts/evolution-suggest.ps1 |

Quick templates (in pi):
- /af-design-auto <change-id> - auto design + task breakdown
- /af-report <change-id> - auto report generation
- /af-evolve [change-id] - data-driven evolution
