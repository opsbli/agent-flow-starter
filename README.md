# agent-flow-starter 中文使用手册

`agent-flow-starter` 是一套可复制到任意项目中的 AI 开发流程模板。它不是某个 IDE 的专属配置，也不是单纯的 prompt 集合，而是一套把需求、代码扫描、设计、任务、验证、复盘和知识沉淀都放进仓库里的受控协作框架。

它解决的问题是：AI 可以写代码，但老项目里的真实风险往往不在“代码能不能生成”，而在于它有没有先查现有实现、有没有越界改文件、有没有碰权限/API/schema、有没有验证证据、有没有把经验沉淀下来。

## 适合什么场景

适合：

- 老项目新增功能或新模块。
- 多人团队希望统一 AI 协作方式。
- 需要跨 IDE 使用同一套 AI 开发规则。
- 后端、前端、数据库、权限、工作流、状态机、部署等风险较多的项目。
- 希望每次 AI 对话后的知识和决策能沉淀到仓库，而不是留在聊天记录里。

不适合：

- 只想要一次性 prompt，不想维护项目文档。
- 非常小的脚本仓库，所有改动都能人工一眼看完。
- 不愿意给高风险变更加人工确认点的团队。

## 核心思想

`agent-flow` 的工作方式可以概括为：

```text
需求进入
-> 建立 change 档案
-> 代码优先扫描
-> 判断 Light / Standard / Heavy
-> 写需求、设计、任务
-> 高风险点先审计和确认
-> AI 按 write_files 边界实现
-> 运行验证并绑定 AC Evidence
-> 写报告、复盘、知识沉淀
-> 必要时演进模板和脚本
```

它默认认为：

- 代码事实优先于聊天描述。
- 聊天不是长期记忆，仓库文件才是。
- 非平凡需求不能直接写代码。
- Standard / Heavy 需求必须先完成 `Design Alignment / Grill`，再进入计划或实现。
- Heavy 需求必须先 Plan Audit，再实现。
- 没有验证证据，就不能说完成。
- 经验要反哺到 `knowledge/`、`templates/`、`scripts/`。

## 仓库结构

```text
agent-flow-starter/
├── .github/workflows/
│   ├── scaffold-ci.yml              # scaffold 健康检查 CI
│   └── agent-flow-starter-check.yml # starter 自测 CI
├── AGENTS.md                     # starter 仓库自己的规则
├── README.md                     # 当前文件
├── CHANGELOG.md                  # starter 版本变化
├── docs/
│   ├── ADOPTION.md               # 团队采用指南
│   └── PROMPTS.md                # 常用 prompt 菜谱
├── examples/
│   └── sample-change/            # 教学用 change 示例
├── agent-flow/                   # 会被复制到目标项目的工作流目录
└── scripts/
    ├── install-agent-flow.ps1    # Windows 安装/更新
    ├── install-agent-flow.sh     # Linux/macOS 安装/更新
    ├── test-starter.ps1          # Windows starter 自测
    └── test-starter.sh           # Linux/macOS starter 自测
```

安装到目标项目后，目标项目会得到：

```text
AGENTS.md
agent-flow/
├── GO.md
├── manifest.yaml
├── core/
├── flows/
├── templates/
├── changes/
├── knowledge/
├── decisions/
├── logs/
├── reports/
└── scripts/
```

## 安装到项目

Windows：

```powershell
C:\path\to\agent-flow-starter\scripts\install-agent-flow.ps1 -Target "C:\path\to\your-project"
```

Linux/macOS：

```bash
bash /path/to/agent-flow-starter/scripts/install-agent-flow.sh --target /path/to/your-project
```

安装脚本会做这些事：

- 复制或更新 `agent-flow/`。
- 创建或更新目标项目的 `AGENTS.md`。
- 如果目标项目已有 `AGENTS.md`，只替换 `<!-- agent-flow:start -->` 到 `<!-- agent-flow:end -->` 之间的块。
- 保留目标项目已有的 `agent-flow/changes`、`logs`、`reports`、`knowledge`、`decisions`。
- 运行 `agent-flow/scripts/scaffold-health` 检查脚手架完整性。

## 安装后初始化

进入目标项目根目录后，先运行初始化脚本。

Windows：

```powershell
agent-flow/scripts/init-project.ps1
```

Linux/macOS：

```bash
bash agent-flow/scripts/init-project.sh
```

初始化脚本会尝试扫描：

- 项目名称。
- 语言和构建工具。
- `package.json`、`pom.xml`、`build.gradle`、`pyproject.toml`、`go.mod`、`Cargo.toml` 等。
- 后端入口、前端入口、公共代码、业务模块、测试目录。
- 可能的 schema/migration/sql 路径。
- package scripts 中的 typecheck/test/lint 命令。

然后自动更新：

```text
AGENTS.md
agent-flow/manifest.yaml
agent-flow/knowledge/module-map.md
agent-flow/knowledge/reuse-map.md
agent-flow/knowledge/verification.md
```

初始化后还要让 AI 做一次人工校对：

```text
我已经在当前项目安装并初始化了 agent-flow。
先不要写业务代码。

请审查初始化结果：
1. 检查 AGENTS.md 的 Project Context 是否符合当前项目。
2. 检查 agent-flow/manifest.yaml 是否还有需要人工填写的 TODO。
3. 检查 module-map、reuse-map、verification、pitfalls 是否准确。
4. 如有缺失，先给出建议，再按我确认后的范围修改。
5. 运行 scaffold-health。
6. 输出这个项目后续如何使用 agent-flow。
```

也可以对照：

```text
agent-flow/templates/INIT_CHECKLIST.md
```

## 日常开发怎么用

### 1. 开始一个需求

```text
按 agent-flow 流程处理这个需求：<你的需求>。
先做 code-first 扫描，判断 Light/Standard/Heavy，然后给我 CHANGE 和执行计划。
```

AI 应该先读：

```text
agent-flow/GO.md
agent-flow/manifest.yaml
agent-flow/core/*
```

然后创建：

```text
agent-flow/changes/<change-id>/
```

其中 `STATE.md` 是当前 change 的导航和交接文件；如果它和实际工件冲突，以 `next-step` 推断和各工件内容为准，然后回写 `STATE.md`。

也可以用脚本创建：

Windows：

```powershell
agent-flow/scripts/new-change.ps1 -Name <change-id> -Flow Standard
```

Linux/macOS：

```bash
bash agent-flow/scripts/new-change.sh --name <change-id> --flow Standard
```

### 1.1 让流程推荐下一步

如果你不确定某个 change 现在该继续写需求、补设计、执行 Plan Audit、实现、验证，还是收口，可以先跑：

Windows：

```powershell
agent-flow/scripts/next-step.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/state-check.ps1 -ChangeDir agent-flow/changes/<change-id>
```

Linux/macOS：

```bash
bash agent-flow/scripts/next-step.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/state-check.sh --change-dir agent-flow/changes/<change-id>
```

它会输出当前 `stage`、缺失工件、阻塞项，以及一段可直接复制给 AI 的 `next_prompt`。
如果 change 中有 `STATE.md`，输出也会包含 `state_current_stage` 和 `state_next_action`，用于检查人工记录是否落后于实际工件。

也可以让 AI 代跑：

```text
按 agent-flow 流程检查 change：<change-id>。
先运行 next-step，读取输出里的 stage、missing、blocked 和 next_prompt。
然后按 next_prompt 继续处理；如果 blocked 不为空，先解释阻塞和可选方案。
```

### 2. Light 需求

适合：

- 文案修改。
- 单文件小 bug。
- 注释或低风险样式调整。
- 已有测试覆盖的小修复。

最小工件：

```text
CHANGE.md
CODE_SCAN.md
VERIFY.md
REPORT.md
```

示例 prompt：

```text
继续 agent-flow change：<change-id>。
这是 Light 需求。
请补齐 CODE_SCAN、实现最小修改、运行相关验证，并写 VERIFY 和 REPORT。
```

### 3. Standard 需求

适合：

- 单模块功能。
- 标准 CRUD。
- 明确边界的小型前后端改动。

常用工件：

```text
CHANGE.md
REQUIREMENT.md
CODE_SCAN.md
DESIGN.md
TASKS.md
VERIFY.md
REPORT.md
EVOLUTION.md
```

示例 prompt：

```text
继续 agent-flow change：<change-id>。
按 Standard 流程补全 REQUIREMENT、CODE_SCAN、DESIGN。
DESIGN 完成后执行 Design Alignment / Grill：一次只问一个关键问题；如果问题能通过读代码回答，先读代码；每个问题给出你的推荐答案。
Alignment Verdict 是 aligned 或我明确接受 skipped 后，再补 TASKS。
每个任务必须声明 read_files 和 write_files。
先不要实现，等我确认设计。
```

### 4. Heavy 需求

适合：

- 老项目新模块。
- 修改数据库 schema。
- 修改权限、登录态、Token、匿名接口。
- 修改公共 API 契约。
- 工作流、状态机、WebSocket、事件、缓存。
- 前后端联动。
- 部署、生产配置、生产风险。

必须额外有：

```text
PLAN.md
AUDIT.md
```

实现前必须有：

```text
Design Alignment / Grill -> Alignment Verdict: aligned
Plan Audit -> Verdict: accept
```

示例 prompt：

```text
继续 agent-flow change：<change-id>。
这个需求按 Heavy 处理。
不要实现代码。
请补全 REQUIREMENT、CODE_SCAN、DESIGN。
DESIGN 完成后执行 Design Alignment / Grill：一次只问一个关键问题；如果问题能通过读代码回答，先读代码；每个问题给出你的推荐答案。
Alignment Verdict 是 aligned 或我明确接受 skipped 后，再补 PLAN、TASKS，并执行 Plan Audit。
如果 Plan Audit 不是 accept，停止并列出必须修正项。
```

实现时：

```text
我接受 Plan Audit。
继续 agent-flow change：<change-id>。
严格按 TASKS.md 的 write_files 修改。
每完成一个任务更新 TASKS.md。
不要修改未授权文件。
```

收口时：

```text
继续 agent-flow change：<change-id>。
补全 VERIFY、REVIEW、REPORT、EVOLUTION 和 Closure Audit。
运行 ac-check、code-drift-check、blocked-check、scaffold-health，以及 manifest 中相关 run-verify 命令。
如果 Closure Audit 是 conditional，请明确残余风险和后续处理建议。
```

## 验证命令

`agent-flow` 支持 Windows 和 Linux/macOS。

Windows：

```powershell
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/next-step.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/state-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/alignment-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/run-verify.ps1 -All
agent-flow/scripts/run-verify.ps1 -Name backend_test
agent-flow/scripts/run-verify.ps1 -Name module_test -Module <module>
agent-flow/scripts/ac-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/code-drift-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/blocked-check.ps1 -ChangeDir agent-flow/changes/<change-id>
```

Linux/macOS：

```bash
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/next-step.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/state-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/alignment-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/run-verify.sh --all
bash agent-flow/scripts/run-verify.sh --name backend_test
bash agent-flow/scripts/run-verify.sh --name module_test --module <module>
bash agent-flow/scripts/ac-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/code-drift-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/blocked-check.sh --change-dir agent-flow/changes/<change-id>
```

`run-verify` 会读取：

```text
agent-flow/manifest.yaml
```

所以不同技术栈项目只需要维护 manifest 中的命令，例如：

```yaml
verification:
  backend_compile: mvn compile -DskipTests -q
  backend_test: mvn test -q
  frontend_typecheck: pnpm type-check
  frontend_test: pnpm test
  frontend_lint: pnpm lint
```

如果某个命令还没配置，`run-verify` 会跳过并提示，不会强行失败。

## 验收和证据

`REQUIREMENT.md` 中的 AC 必须使用：

```text
AC-01
AC-02
AC-03
```

不要使用：

```text
AC-1
```

因为 `ac-check` 会按机器可识别编号扫描证据。

`VERIFY.md` 必须写 AC Evidence：

```text
| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
```

证据可以是：

- 单元测试。
- 集成测试。
- 命令输出。
- 代码位置。
- 浏览器手工验证。
- 数据库验证 SQL。
- 明确记录的 skipped/conditional。

## 知识沉淀

每次需求结束后，AI 应该判断是否要更新：

```text
agent-flow/knowledge/glossary.md
agent-flow/knowledge/module-map.md
agent-flow/knowledge/reuse-map.md
agent-flow/knowledge/pitfalls.md
agent-flow/knowledge/verification.md
agent-flow/knowledge/known-good-baselines.md
```

适合沉淀的内容：

- 领域术语。
- 模块边界。
- 可复用抽象。
- 容易踩坑的规则。
- 新增验证命令。
- 已验证可工作的健康基线。

不可逆、有架构取舍的决策写入：

```text
agent-flow/decisions/
```

## 自我演进

每个完成的 change 都应该写：

```text
EVOLUTION.md
```

它回答：

- 这次流程哪里有价值？
- 哪些模板字段缺失？
- 是否要新增脚本 gate？
- 是否要更新 knowledge？
- 是否要调整 Light/Standard/Heavy 分流？

推荐先评估，不要直接改：

```text
基于本次 EVOLUTION.md，评估是否需要升级 agent-flow。
只评估，不直接修改。
优先级：templates > scripts > knowledge > flows > AGENTS.md。
```

## 升级 starter

目标项目升级时再次运行安装脚本即可。

Windows：

```powershell
C:\Users\sinvi\Documents\agent-flow-starter\scripts\install-agent-flow.ps1 -Target "C:\path\to\your-project"
```

Linux/macOS：

```bash
bash /path/to/agent-flow-starter/scripts/install-agent-flow.sh --target /path/to/your-project
```

安装器默认保留项目自有历史：

```text
agent-flow/changes
agent-flow/logs
agent-flow/reports
agent-flow/knowledge
agent-flow/decisions
```

升级后检查：

```text
agent-flow/UPGRADE.md
CHANGELOG.md
```

## Starter 自测

修改 starter 后，必须跑：

Windows：

```powershell
.\scripts\test-starter.ps1
```

Linux/macOS：

```bash
bash scripts/test-starter.sh
```

GitHub Actions 也会在 push / pull request 时运行同一套 bash 自测：

```text
.github/workflows/agent-flow-starter-check.yml
.github/workflows/scaffold-ci.yml
```

自测覆盖：

- scaffold health。
- shell/PowerShell 语法。
- 安装到空项目。
- 更新已有 AGENTS.md。
- 初始化项目。
- run-verify 跳过未配置命令。
- docs/examples 存在。
- 无项目特定残留。

## 示例

教学示例在：

```text
examples/sample-change/
```

它展示了：

- `AC-01` 编号。
- `CODE_SCAN.md` 如何写 read/write 边界。
- `DESIGN.md` 如何写 API/Permission/Auth 决策。
- `VERIFY.md` 如何绑定 AC Evidence。

## 常用 prompt

更多 prompt 在：

```text
docs/PROMPTS.md
```

团队采用建议在：

```text
docs/ADOPTION.md
```

## 版本

当前版本：

```text
agent-flow/VERSION
```

变更记录：

```text
CHANGELOG.md
```

升级说明：

```text
agent-flow/UPGRADE.md
```
