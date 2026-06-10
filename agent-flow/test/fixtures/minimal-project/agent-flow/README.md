# agent-flow 项目内使用手册

这个目录是目标项目里的 AI 开发工作流运行区。安装 `agent-flow-starter` 后，AI 和开发者主要围绕这里工作。

`agent-flow` 的目标不是增加文档负担，而是让 AI 在老项目和复杂项目里更可控：先查代码，再写方案；先明确边界，再实现；先验证，再宣布完成；最后把经验沉淀回来。

## 每次需求的默认流程

```text
需求进入
-> 读取 agent-flow/GO.md
-> 创建 agent-flow/changes/<change-id>
-> 完成 CODE_SCAN.md
-> 判断 Light / Standard / Heavy
-> 写对应工件
-> 实现
-> 验证
-> 报告
-> 复盘和沉淀
```

所有非平凡需求都应该从：

```text
agent-flow/GO.md
```

开始。

## 目录说明

```text
agent-flow/
├── GO.md                         # AI 默认入口
├── manifest.yaml                 # 项目画像、验证命令、风险规则
├── VERSION                       # agent-flow starter 版本
├── UPGRADE.md                    # 升级说明
├── CHANGELOG.md                  # 版本日志
├── core/                         # 核心规则
├── flows/                        # Light / Standard / Heavy 流程
├── templates/                    # change 工件模板（含 CANCEL.md / ROLLBACK.md）
├── changes/                      # 每个需求的工作目录
├── knowledge/                    # 长期知识沉淀
├── decisions/                    # ADR 决策记录
├── logs/                         # 日级过程日志
├── reports/                      # 交付报告
└── scripts/                      # 验证、初始化、自检、升级脚本
```

## 安装后第一步

第一次安装到项目后，先初始化。

Windows：

```powershell
agent-flow/scripts/init-project.ps1
agent-flow/scripts/scaffold-health.ps1
```

Linux/macOS：

```bash
bash agent-flow/scripts/init-project.sh
bash agent-flow/scripts/scaffold-health.sh
```

初始化会更新：

```text
AGENTS.md
agent-flow/manifest.yaml
agent-flow/knowledge/module-map.md
agent-flow/knowledge/reuse-map.md
agent-flow/knowledge/verification.md
```

然后用这段 prompt 让 AI 复核：

```text
我已经安装并初始化 agent-flow。
先不要写业务代码。

请审查初始化结果：
1. 检查 AGENTS.md Project Context。
2. 检查 agent-flow/manifest.yaml。
3. 检查 module-map、reuse-map、verification、pitfalls。
4. 填补或指出仍然存在的 TODO。
5. 运行 scaffold-health。
6. 输出本项目如何使用 agent-flow。
```

检查清单：

```text
agent-flow/templates/INIT_CHECKLIST.md
```

## 三种流程

### Light

用于低风险小改动。

典型场景：

- 文案。
- 注释。
- 单文件小修复。
- 局部样式。
- 已有测试覆盖的小 bug。

最小工件：

```text
CHANGE.md
CODE_SCAN.md
VERIFY.md
REPORT.md
```

### Standard

用于边界明确的单模块需求。

典型场景：

- 单模块功能。
- 标准 CRUD。
- 小型页面或接口改动。
- 不涉及 schema/auth/public API 破坏性变化的需求。

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

### Heavy

用于高风险或跨边界需求。

典型场景：

- 老项目新模块。
- 数据库 schema。
- 权限、登录、Token、匿名接口。
- 公共 API 契约。
- 工作流、状态机、WebSocket、实时事件。
- 前后端联动。
- 部署、生产配置、生产风险。

必须额外有：

```text
PLAN.md
AUDIT.md
```

实现前必须完成：

```text
Plan Audit
Verdict: accept
```

完成前必须完成：

```text
Closure Audit
VERIFY.md
REVIEW.md
REPORT.md
EVOLUTION.md
```

## 常用 prompt

### 开始需求

```text
按 agent-flow 流程处理这个需求：<需求内容>。
先做 code-first 扫描，判断 Light/Standard/Heavy，然后给我 CHANGE 和执行计划。
```

也可以先创建 change 目录：

Windows：

```powershell
agent-flow/scripts/new-change.ps1 -Name <change-id> -Flow Standard
```

Linux/macOS：

```bash
bash agent-flow/scripts/new-change.sh --name <change-id> --flow Standard
```

脚本会同时创建 `STATE.md`。它只用于导航和交接；如果它和 `CHANGE.md`、`DESIGN.md`、`TASKS.md` 等工件冲突，以工件和 `next-step` 推断为准。

### 只做规划，不实现

```text
继续 agent-flow change：<change-id>。
先不要写业务代码。
请补全 REQUIREMENT、CODE_SCAN、DESIGN。
DESIGN 完成后执行 Design Alignment / Grill：一次只问一个关键问题。
如果问题能通过读代码回答，先读代码；每个问题给出你的推荐答案。
运行 alignment-check。
Alignment Verdict 是 aligned，或我明确接受 skipped 且写明 Skip Reason 后，再补 TASKS。
如果是 Heavy，再补 PLAN 并执行 Plan Audit。
```

### 开始实现

```text
我接受 Plan Audit。
继续 agent-flow change：<change-id>。
严格按 TASKS.md 的 write_files 修改。
每完成一个任务更新 TASKS.md。
```

### 收口

```text
继续 agent-flow change：<change-id>。
补全 VERIFY、REVIEW、REPORT、EVOLUTION、AUDIT。
运行 ac-check、drift-check、scaffold-health 和相关 run-verify 命令。
如果 Closure Audit 是 conditional，请列出残余风险。
```

### 推荐下一步

当你不知道一个 change 下一步该做什么时，先让脚手架读工件状态：

Windows：

```powershell
agent-flow/scripts/next-step.ps1 -ChangeDir agent-flow/changes/<change-id>
```

Linux/macOS：

```bash
bash agent-flow/scripts/next-step.sh --change-dir agent-flow/changes/<change-id>
```

输出会包含：

- `stage`：当前所处阶段。
- `state_current_stage`：`STATE.md` 记录的阶段。
- `state_next_action`：`STATE.md` 记录的下一步。
- `missing`：缺失或仍是占位内容的工件。
- `blocked`：需要人工决策的阻塞。
- `next`：下一步摘要。
- `next_prompt`：可直接复制给 AI 的下一轮 prompt。

常用 prompt：

```text
按 agent-flow 流程检查 change：<change-id>。
先运行 next-step，读取输出里的 stage、missing、blocked 和 next_prompt。
然后按 next_prompt 继续处理；如果 blocked 不为空，先解释阻塞和可选方案。
```

### 自我演进

```text
基于本次 EVOLUTION.md，评估是否需要升级 agent-flow。
只评估，不直接修改。
优先级：templates > scripts > knowledge > flows > AGENTS.md。
```

更多 prompt：

```text
docs/PROMPTS.md
```

## 验证命令

### 脚手架健康检查

Windows：

```powershell
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/next-step.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/alignment-check.ps1 -ChangeDir agent-flow/changes/<change-id>
```

Linux/macOS：

```bash
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/next-step.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/alignment-check.sh --change-dir agent-flow/changes/<change-id>
```

### 运行项目验证

验证命令来自：

```text
agent-flow/manifest.yaml
```

Windows：

```powershell
agent-flow/scripts/run-verify.ps1 -All
agent-flow/scripts/run-verify.ps1 -Name backend_compile
agent-flow/scripts/run-verify.ps1 -Name backend_test
agent-flow/scripts/run-verify.ps1 -Name frontend_typecheck
agent-flow/scripts/run-verify.ps1 -Name module_test -Module <module>
```

Linux/macOS：

```bash
bash agent-flow/scripts/run-verify.sh --all
bash agent-flow/scripts/run-verify.sh --name backend_compile
bash agent-flow/scripts/run-verify.sh --name backend_test
bash agent-flow/scripts/run-verify.sh --name frontend_typecheck
bash agent-flow/scripts/run-verify.sh --name module_test --module <module>
```

如果 manifest 里是 `TODO_...`，脚本会跳过并提示。

### AC 证据检查

Windows：

```powershell
agent-flow/scripts/ac-check.ps1 -ChangeDir agent-flow/changes/<change-id>
```

Linux/macOS：

```bash
bash agent-flow/scripts/ac-check.sh --change-dir agent-flow/changes/<change-id>
```

要求 `REQUIREMENT.md` 中使用：

```text
AC-01
AC-02
```

### Drift 检查

Windows：

```powershell
agent-flow/scripts/drift-check.ps1 -ChangeDir agent-flow/changes/<change-id>
```

Linux/macOS：

```bash
bash agent-flow/scripts/drift-check.sh --change-dir agent-flow/changes/<change-id>
```

它会检查设计中常见的 schema、API、权限决策漂移。

## 工件怎么写

### REQUIREMENT.md

必须包含可验证 AC：

```text
AC-01
AC-02
AC-03
```

每条 AC 要能在 `VERIFY.md` 找到证据。

### CODE_SCAN.md

必须说明：

- 读了哪些文件。
- 找到哪些相似实现。
- 复用了哪些抽象。
- 哪些文件只读。
- 哪些文件允许写。
- 哪些问题未决。

### DESIGN.md

涉及接口、权限或认证时，必须写：

```text
API / Permission / Auth 决策
```

涉及 workflow/status/state machine 时，必须写：

```text
Status Vocabulary
Status Mapping
Legacy Compatibility
```

普通 CRUD 可以明确写“不涉及状态机”。

所有 Standard / Heavy change 进入 `PLAN.md` 或 `TASKS.md` 前，必须完成：

```text
Design Alignment / Grill
Alignment Verdict: aligned
```

如果用户明确接受跳过，可以写：

```text
Alignment Verdict: skipped
```

但必须在 `DESIGN.md` 里写明跳过原因。

### TASKS.md

每个任务都要有：

- 目标。
- AC 映射。
- `read_files`。
- `write_files`。
- 验证命令。
- 是否允许并行。

### VERIFY.md

必须包含：

```text
AC Evidence
```

证据可以是测试、命令、代码位置、手工验证或明确跳过原因。

### EVOLUTION.md

回答：

- 这次流程哪里有效？
- 哪里像形式主义？
- 哪些知识要沉淀？
- 哪些模板要升级？
- 是否要新增验证脚本？

## 知识库

长期事实写入：

```text
agent-flow/knowledge/glossary.md
agent-flow/knowledge/module-map.md
agent-flow/knowledge/reuse-map.md
agent-flow/knowledge/pitfalls.md
agent-flow/knowledge/verification.md
agent-flow/knowledge/known-good-baselines.md
```

建议：

- 新术语写 glossary。
- 模块边界写 module-map。
- 可复用能力写 reuse-map。
- 踩坑写 pitfalls。
- 验证方式写 verification。
- 已确认可工作的健康状态写 known-good-baselines。

## 决策记录

写入：

```text
agent-flow/decisions/
```

适合写 ADR 的情况：

- 架构边界变化。
- 不可逆或难回滚的选择。
- 影响多个模块。
- 有明显取舍，未来需要解释。

不适合写 ADR 的情况：

- 普通实现细节。
- 临时 bugfix。
- 没有长期解释成本的小改动。

## 升级 agent-flow

目标项目升级时，从 `agent-flow-starter` 重新运行安装脚本。

安装器默认保留：

```text
agent-flow/changes
agent-flow/logs
agent-flow/reports
agent-flow/knowledge
agent-flow/decisions
```

升级后看：

```text
agent-flow/UPGRADE.md
```

## 完成定义

一个 change 只有满足以下条件，才能说完成：

- `REPORT.md` 已写交付摘要。
- `VERIFY.md` 已写验证证据。
- 所有 AC 有 Evidence 或明确 residual risk。
- `ac-check`、`drift-check`、`scaffold-health` 已执行或说明跳过原因。
- Heavy change 有 Closure Audit。
- 新知识、坑点、决策已沉淀。
- `EVOLUTION.md` 已写。

## 示例

教学示例：

```text
examples/sample-change/
```

它展示：

- Light change 怎么组织。
- `AC-01` 怎么写。
- `CODE_SCAN.md` 怎么写边界。
- `DESIGN.md` 怎么写 API/Auth 决策。
- `VERIFY.md` 怎么绑定 AC Evidence。
