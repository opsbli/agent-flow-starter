# agent-flow 入口

你是当前项目的 AI 开发协作者。收到需求后，必须按本文件路由，不允许直接进入编码。

```text
┌─────────────┐
│   需求进入   │
└──────┬──────┘
       ▼
┌──────────────┐     YES     ┌──────────────────┐
│ P0/P1 事故？ ├───────────►│ Emergency 通道   │
└──────┬───────┘             │ (bypass, 24h回填)│
       │ NO                  └──────────────────┘
       ▼
┌──────────────────┐
│ 建立 Change 工件  │
└──────┬───────────┘
       ▼
┌──────────────────┐
│Code-First 代码扫描│
└──────┬───────────┘
       ▼
┌────────────────────────────┐
│ 路由分级 (Light/Std/Heavy) │
└──────┬─────────────────────┘
       │
       ├── Light ──────► Light 流程 (5 工件)
       │
       ├── Standard ──► Requirements Grill
       │                   │ Code Scan → DESIGN
       │                   │ Design Alignment
       │                   │ TASKS → 实现 → VERIFY
       │
       └── Heavy ──────► Requirements Grill
                           │ Code Scan → DESIGN
                           │ Design Alignment
                           │ Plan Audit
                           │ TASKS → 实现 (分阶段)
                           │ VERIFY → Closure Audit

所有路径的完成线：VERIFY.md + REPORT.md + EVOLUTION.md

> ⚠️ Light 路径例外：Light 流程要求的最低产物是 `STATE.md` + `CHANGE.md` + `CODE_SCAN.md` + `VERIFY.md` + `REPORT.md`，**不要求 `EVOLUTION.md`**（见 `agent-flow/flows/light.md`）。`EVOLUTION.md` 仅在 Standard / Heavy 路径中强制。
```

## 读取策略

根据路由分级选择读取路径。**读完 router.md 确定分级后，再决定是否继续读其余文件。**

### 轻量路径（Standard 及以下）

```text
1. agent-flow/manifest.yaml           ← 项目配置
2. agent-flow/core/router.md          ← 分级判定
3. agent-flow/core/code-first-context.md  ← 扫描指引
4. agent-flow/core/frontend-fit.md    ← 仅前端任务
5. agent-flow/ecc-integration.md      ← 可选，有 ECC 时
```

### 完整路径（Heavy）

```text
1. agent-flow/manifest.yaml
2. agent-flow/core/principles.md
3. agent-flow/core/source-of-truth.md
4. agent-flow/core/autonomy-policy.md
5. agent-flow/core/router.md
6. agent-flow/core/code-first-context.md
7. agent-flow/core/memory.md
8. agent-flow/core/plan-guide.md
9. agent-flow/core/audit.md
10. agent-flow/core/logging.md
11. agent-flow/core/evolution.md
12. agent-flow/core/frontend-fit.md   ← 仅前端任务
13. agent-flow/ecc-integration.md     ← 可选，有 ECC 时
```

> ⚠️ 如果分级后确定为 Heavy，但已经按轻量路径开始，**必须回退到完整路径重读**。

## 第零步：紧急判断

是否**生产事故 / 安全漏洞 / 数据丢失**且满足 `agent-flow/flows/emergency.md` 的全部条件？

- **是** → 走 `agent-flow/flows/emergency.md`，事后 24 小时内回填完整工件
- **否** → 继续第一步

> Emergency 通道绕开了 Plan Audit、Closure Audit、REVIEW.md 等安全门。
> 只有 P0/P1 事故且有人批准才能使用。

## 第一步：建立 change

为需求生成短横线命名的 `change-id`，例如：

```text
im-anonymous-conversation
asset-stocktake-module
monitor-alert-rule-refactor
```

在 `agent-flow/changes/<change-id>/` 下创建本次工件：

```text
STATE.md
CHANGE.md
REQUIREMENT.md
CODE_SCAN.md
DESIGN.md
TASKS.md
VERIFY.md
REVIEW.md
REPORT.md
EVOLUTION.md
```

轻量任务可以只创建 `STATE.md`、`CHANGE.md`、`CODE_SCAN.md`、`VERIFY.md`、`REPORT.md`。

`STATE.md` 只用于导航和交接，真正事实以各工件内容为准。

Heavy 任务必须额外创建：

```text
PLAN.md
AUDIT.md
```

## 第二步：任务分级

使用 `agent-flow/core/router.md` 分级。

同时使用 `agent-flow/core/autonomy-policy.md` 判断本次 AI 自治等级。默认是 `plan-first`，触碰 protected areas 时必须停下来确认。

以下情况强制 Heavy：

- 新增业务模块、包、子系统或跨边界能力。
- 修改根构建文件、模块注册点或应用入口依赖。
- 新增或修改数据库 schema。
- 新增权限码、匿名接口、登录态、Token、限流、防重逻辑。
- 涉及 WebSocket、实时通信、缓存、工作流、状态机。
- 涉及前后端联调。

## 第三步：代码优先上下文

在写需求和设计前，先完成 `CODE_SCAN.md`。

必须先查：

- 构建文件：`package.json`、`pom.xml`、`build.gradle`、`pyproject.toml`、`Cargo.toml` 等。
- 应用入口、模块注册点和路由入口。
- 现有相似模块、服务、组件和测试。
- 公共能力、工具、注解、中间件、客户端封装。
- 数据库迁移、schema、seed、字典、权限配置。
- 测试目录和现有测试风格。

如果前端相关，必须同时扫描前端仓库：

```text
在 `agent-flow/manifest.yaml` 中记录的 frontend repo/path。
```

## 第四步：执行流程

按对应 flow 文件继续：

- Light：`agent-flow/flows/light.md`
- Standard：`agent-flow/flows/standard.md`
- Heavy：`agent-flow/flows/heavy.md`

## 硬规则

- 不确认事实源优先级，不处理冲突。
- `STATE.md` 与工件冲突时，以工件和 `next-step` 推断结果为准，并更新 `STATE.md`。
- `STATE.md` 滞后时，运行 `sync-state` 后再继续。
- 没有 `CODE_SCAN.md`，不写 `DESIGN.md`。
- `CODE_SCAN.md` 完成后运行 `scan-check`，Standard / Heavy 必须通过后再进入设计。
- Standard / Heavy change 没有通过 `design-check`，不进入 `Design Alignment / Grill`、`PLAN.md`、`TASKS.md` 或实现代码。
- Standard / Heavy change 没有完成 `Design Alignment / Grill`，不写 `PLAN.md`、`TASKS.md` 或实现代码。
- Standard / Heavy change 的 `alignment-check` 未通过，不写 `PLAN.md`、`TASKS.md` 或实现代码。
- 没有 `DESIGN.md`，不写实现代码。
- Heavy change 没有 Plan Audit 或 `plan-check` 未通过，不写实现代码。
- Standard / Heavy change 实现前必须运行 `task-check`，确认 `TASKS.md` 的任务状态、AC 映射、读写文件和验证命令完整。
- 没有 `VERIFY.md`，不说完成。
- Heavy change 没有 Closure Audit，不标记完成。
- Heavy change 必须运行 `code-drift-check`（设计声明 vs 实际代码的漂移检查），通过后才能收口。
- `drift-check` 已废弃，请使用 `code-drift-check` 代替。
- Standard / Heavy change 收口前必须运行 `coverage-check`，确认 AC Evidence 覆盖率和测试覆盖率记录。
- Heavy change 必须运行 `blocked-check`（检查是否触碰 manifest.yaml 中 `blocked_if` 规则）。
- Standard / Heavy change 收口前必须运行 `task-boundary-check`，确认实际改动没有超出 `TASKS.md write_files`。
- Emergency change 必须运行 `emergency-check`，确认 P0/P1、批准人、bypass 理由和回填状态完整。
- 收口前必须运行 `manifest-check`，确认脚手架清单、gate 文件和 blocked_if 规则完整。
- Standard / Heavy change 收口前必须运行 `evolution-check`，确认经验升级或不升级理由已写清。
- Heavy change 标记完成前必须运行 `closure-check`。
- 不确定当前 change 是否健康时，运行 `check-change`，它会串起状态、扫描、设计、对齐、计划、任务、AC、漂移、阻塞、边界、manifest、Emergency、演进和关闭检查，并可输出 `CHECK_RESULT.json`。
- 发现术语、规则、坑点，立即写入 `agent-flow/knowledge/`。
- 发现不可逆取舍，写入 `agent-flow/decisions/`。
- 验证通过后，如形成新的健康状态，更新 `agent-flow/knowledge/known-good-baselines.md`。
- Heavy change 必须写入 `agent-flow/logs/YYYY/MM-DD.md`。
- 每次完成后必须写 `EVOLUTION.md`，判断脚手架是否应升级。
- **每次 change 完成后必须调用 `manage_plan clear` 清空计划面板**，避免残留到下一轮对话。

> `manage_plan clear` 是收口的标准最后一步，各 flow 文件已明确写入完成步骤中。

## 运行所有门禁

单个 change 需要机器汇总时，运行：

```text
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/<change-id> -OutputPath agent-flow/changes/<change-id>/CHECK_RESULT.json
agent-flow/scripts/coverage-check.ps1 -ChangeDir agent-flow/changes/<change-id>
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id> --output agent-flow/changes/<change-id>/CHECK_RESULT.json
bash agent-flow/scripts/coverage-check.sh --change-dir agent-flow/changes/<change-id>
```

收口阶段加 closure 模式：

```text
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/<change-id> -Closure -OutputPath agent-flow/changes/<change-id>/CHECK_RESULT.json
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id> --closure --output agent-flow/changes/<change-id>/CHECK_RESULT.json
```

脚手架自身改动还必须同时运行 Windows 和 Linux/macOS 两套 `scaffold-health`。
