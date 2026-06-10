# agent-flow 脚手架

> 面向任意软件项目的 AI 开发脚手架。它定义一套可复制、可审计、可演进的工作流。

## 定位

`agent-flow` 不是另一套厚重文档体系，而是一套可执行的协作协议：

- 代码优先：每次需求先查项目代码、模块边界、既有抽象，再写方案。
- 轻重分流：小改动走轻流程，高风险变更走完整流程。
- 知识沉淀：每次对话中确认的术语、规则、坑点都写入可复用文件。
- 决策沉淀：难以逆转、有取舍、有未来解释成本的选择写成 ADR。
- 验证收口：没有外部验证证据，不允许声明完成。
- 自我演进：每次交付后反推脚手架、规则、模板和验证闸门是否需要升级。

## 从几篇文章里保留的经验

### 来自 Spec 驱动系列

- Spec 不是代码真相，而是意图契约。
- 真正长期有价值的是测试、知识库、验证闸门和项目约束。
- 模型越强，Spec 越应该薄；验证越应该硬。
- 小需求不该被重流程拖慢，大需求不该靠直觉硬冲。

### 来自 flow-kit

- 每个 change 应该有独立档案，方便审计、交接和复盘。
- 老项目必须先入场扫描，先找既有抽象，再写新代码。
- 每个任务需要声明 `read_files` 和 `write_files`，防止越界修改。
- 破坏性变更需要人工卡点。
- 前端新模块必须对齐既有视觉语汇。

### 来自 grill-with-docs

- 需求中的术语要和代码、领域文档互相校验。
- 模糊词要被追问成精确概念。
- 只有真正难以逆转且有取舍的选择才写 ADR。
- 术语和决策不要停留在聊天里，要及时写回文件。

### 来自 Semble 式代码优先上下文

这里不绑定具体工具，只吸收其思想：先检索项目事实，再生成回答。

每次 AI 开发前必须先回答：

1. 这次需求和哪些现有模块、表、接口、权限、抽象有关？
2. 项目里是否已有类似实现？
3. 哪些文件只允许读，哪些文件允许写？
4. 哪些代码事实会约束本次设计？

## 目录

```text
agent-flow/
├── GO.md                         # AI 入口
├── manifest.yaml                 # 项目画像和闸门声明
├── core/                         # 宪法、路由、记忆、自演进规则
├── flows/                        # 分阶段工作流
├── templates/                    # change/requirement/design/task/report 模板
├── changes/                      # 每次需求的 change 档案
├── knowledge/                    # 项目知识沉淀
├── decisions/                    # ADR 决策沉淀
└── reports/                      # 交付和自演进报告

agent-flow/scripts/
├── run-verify.ps1                # Windows manifest-driven verification runner
├── run-verify.sh                 # Linux/macOS manifest-driven verification runner
├── init-project.ps1              # Windows project initialization
├── init-project.sh               # Linux/macOS project initialization
├── verify-backend.ps1            # Windows 后端基线验证
├── verify-backend.sh             # Linux/macOS 后端基线验证
├── verify-module.ps1             # Windows Maven 模块验证
├── verify-module.sh              # Linux/macOS Maven 模块验证
├── ac-check.ps1                  # Windows AC 编号覆盖检查
├── ac-check.sh                   # Linux/macOS AC 编号覆盖检查
├── drift-check.ps1               # Windows schema/路由/权限漂移检查
├── drift-check.sh                # Linux/macOS schema/路由/权限漂移检查
├── scaffold-health.ps1           # Windows 脚手架健康检查
└── scaffold-health.sh            # Linux/macOS 脚手架健康检查
```

Windows:

```powershell
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/init-project.ps1
agent-flow/scripts/run-verify.ps1 -All
agent-flow/scripts/ac-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/drift-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/verify-backend.ps1 -SkipTests
agent-flow/scripts/verify-module.ps1 -Module <module-path-or-name> -SkipTests
```

Linux/macOS:

```bash
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/init-project.sh
bash agent-flow/scripts/run-verify.sh --all
bash agent-flow/scripts/ac-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/drift-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/verify-backend.sh --skip-tests
bash agent-flow/scripts/verify-module.sh --module <module-path-or-name> --skip-tests
```

## 从 AGE-workflow 加入的治理层

- `source-of-truth.md`：定义代码、需求、设计、任务、报告、聊天冲突时谁优先。
- `autonomy-policy.md`：定义 AI 自治等级和 protected areas。
- `plan-guide.md`：定义 Heavy change 的计划状态、阶段和关闭门槛。
- `audit.md`：定义 Plan Audit 和 Closure Audit。
- `logging.md`：定义日级短日志。
- `known-good-baselines.md`：记录项目健康状态。

## 初始化

Windows:

```powershell
agent-flow/scripts/init-project.ps1
agent-flow/scripts/scaffold-health.ps1
```

Linux/macOS:

```bash
bash agent-flow/scripts/init-project.sh
bash agent-flow/scripts/scaffold-health.sh
```

初始化后检查：

```text
agent-flow/templates/INIT_CHECKLIST.md
```

## 推荐用法

在任意 AI IDE 中输入：

```text
@agent-flow/GO.md
我要在老项目里新增一个 xxx 模块，用于 ...
```

AI 必须先执行路由和代码扫描，不允许直接写实现。

## 三档流程

| 档位 | 场景 | 流程 |
|---|---|---|
| Light | 小 bug、文案、单文件低风险修改 | intake -> code-scan -> dev -> verify -> memory |
| Standard | 单模块功能、标准 CRUD、明确需求 | intake -> requirement -> code-scan -> design -> task -> dev -> verify -> report |
| Heavy | 老项目新模块、跨模块、schema、权限、状态机、WebSocket、生产风险 | intake -> grill -> requirement -> code-scan -> design -> task -> dev -> verify -> review -> evolve |

老项目新模块、跨模块、schema、权限、状态机、前后端联动、生产风险默认走 Heavy。

## 完成定义

一次 change 只有同时满足以下条件，才能标记完成：

- `agent-flow/changes/<change-id>/REPORT.md` 已写入验证证据。
- 相关 AC 有测试或手工验证记录。
- 项目相关编译、测试或替代验证已执行。
- schema、路由、权限等漂移检查已执行或明确记录跳过原因。
- 新术语、坑点、决策已沉淀到 `knowledge/` 或 `decisions/`。
- `EVOLUTION.md` 已判断脚手架是否需要更新。
