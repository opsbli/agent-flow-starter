# Heavy 流程

适合老项目新模块、跨模块、高风险需求。

## 阶段 0：Intake

> **紧急出口**：如果这是 P0/P1 生产事故，考虑走 `agent-flow/flows/emergency.md`。
> Emergency 通道可绕过 Heavy 流程的大多数安全门，但需 24 小时内回填。

产物：`STATE.md`、`CHANGE.md`

必须明确：

- 目标
- 非目标
- 风险级别
- 用户角色
- 业务边界
- 是否涉及前端仓库
- 本次 AI 自治等级
- 是否触碰 protected areas
- 当前阶段和下一步，写入 `STATE.md`

## 阶段 1：Requirements Grill

> **意图**：在写需求文档前，确保 AI 和用户对业务术语、边界、假设达成一致理解。

产物：更新 `REQUIREMENT.md` 和必要知识文件。

直接引用 `grill-with-docs` 技能执行结构化追问：

- 每个业务名词的精确定义是什么？与 `agent-flow/knowledge/` 中已有术语是否冲突？
- 哪些状态、权限、数据归属必须明确？
- 哪些场景不能做？
- 失败后系统应该如何恢复？
- 旧代码是否支持用户的说法？
- 每次只问一个关键问题，给出 AI 推荐答案。
- 术语一旦明确，立即更新 `agent-flow/knowledge/`。
- 遇到不可逆取舍，创建 ADR 到 `agent-flow/decisions/`。

验收标准必须使用 `AC-01`、`AC-02` 这种两位数字编号，并在后续 `TASKS.md`、`VERIFY.md`、`REPORT.md` 中保持一致。

## 阶段 2：Code Scan

产物：`CODE_SCAN.md`

必须扫描：

- Maven 模块注册点。
- 相似模块。
- 公共注解和工具。
- SQL、菜单、字典、权限。
- 测试样例。
- 前端语汇。

完成后必须运行 `scan-check`。未通过时，不进入 `DESIGN.md`。

## 阶段 3：Design

产物：`DESIGN.md`

必须包含：

- 模块边界。
- API 和权限。
- API / Permission / Auth 决策块，明确 REST 路径、HTTP Method、权限码、`@SaCheckPermission`、匿名接口、登录态是否变化。
- 数据模型和索引。
- 状态机。
- Service 编排。
- 错误处理。
- 幂等、限流、审计。
- 测试策略。
- 发布和回滚。

如果涉及 workflow/status/state machine，必须额外包含：

- Status Vocabulary。
- Status Mapping。
- Legacy Compatibility。

普通 CRUD 不强制填写 workflow/status 条件小节，可明确写“不涉及状态机”。

## 阶段 3.5：Design Alignment

> **注意**：不要和阶段 1 的 Requirements Grill 混淆。Grill 是需求对齐，Design Alignment 是设计正确性确认。

产物：更新 `DESIGN.md` 的 `Design Alignment / Grill` 小节。

目的：把用户自然语言、AI 理解、现有代码事实对齐，避免带着误解进入计划和实现。

必须执行：

- 一次只问一个关键问题。
- 如果问题能通过读代码回答，先读代码，不要问用户。
- 每个问题给出 AI 推荐答案。
- 用户确认后，把结论写回 `DESIGN.md`。
- `Alignment Verdict` 必须是 `aligned`，或用户明确接受 `skipped` 且填写 `Skip Reason`。
- alignment-check 要求至少 **3 个问题** 的 Confirmation 标记为 `user-confirmed`（纯 `code-confirmed` 不能通过）。

先运行 `design-check`。如果 `Decision Status` 不是 `accepted`，不得进入 Design Alignment。

如果 `Alignment Verdict: pending` 或 `blocked`，不得进入 `PLAN.md`、`TASKS.md` 或实现。

## 阶段 3.6：Plan

产物：`PLAN.md`

必须包含：

- Current Baseline。
- Goals / Non-Goals。
- Execution Phases。
- Closure Gates。
- Protected Area Review。
- Deferred But Adjudicated。
- `alignment-check` 已通过或用户明确接受 `skipped` 风险。
- `design-check` 已通过。

如果涉及 protected areas，必须记录用户批准或停止。

## 阶段 3.7：Plan Audit

产物：`AUDIT.md` 的 Plan Audit 部分。

实现前必须得到：

```text
Verdict: accept
```

或者用户明确接受 `conditional` 风险。

## 阶段 4：Tasks

产物：`TASKS.md`

每个任务必须有：

- 目标。
- 状态：`pending`、`in_progress`、`completed`、`blocked` 或 `skipped`。
- AC 映射。
- `read_files`。
- `write_files`。
- 验证命令。
- 是否允许并行。

完成 `TASKS.md` 后必须运行 `task-check`。未通过时，不进入实现。

完成 Plan Audit 后必须运行 `plan-check`。未通过时，不进入实现。

## 阶段 5：Dev

每个任务独立上下文执行：

1. 读任务。
2. 读限定文件。
3. 先写或定位测试。
4. 实现。
5. 运行任务级验证。
6. 追加任务摘要。

## 阶段 6：Verify

产物：`VERIFY.md`

必须运行或记录跳过原因：

- backend compile
- module compile
- module test
- scan-check
- design-check
- alignment-check
- task-check
- plan-check
- ac-check
- code-drift-check（首选：设计声明 vs 实际代码的漂移检查）
- drift-check（可选补充：DESIGN.md 内部一致性）
- blocked-check（检查 blocked_if 规则违规）
- task-boundary-check（检查实际 git 改动是否超出 TASKS.md write_files）
- emergency-check（非 Emergency 时记录 skipped；Emergency 时必须通过）
- manifest-check（检查 manifest/gates/blocked_if 完整性）
- evolution-check（确认经验沉淀或不升级理由完整）
- frontend typecheck/test/lint（如涉及前端）

必须填写 `AC Evidence` 表，把每个 `AC-01` 等验收项绑定到测试、命令、代码位置、人工验证或明确跳过原因。

## 阶段 7：Review

产物：`REVIEW.md`

三层审查：

- 意图合规：是否满足目标和非目标。
- 架构合规：是否复用既有抽象，是否越界。
- 代码质量：是否可测试、可维护、可回滚。

## 阶段 7.5：Closure Audit

产物：`AUDIT.md` 的 Closure Audit 部分。

完成前必须验证：

- Closure Gates 全部通过。
- `VERIFY.md` 有证据。
- AC 覆盖有证据。
- scan-check 已通过或有明确裁决。
- task-check 已通过或有明确裁决。
- code-drift-check 已通过或有明确裁决。
- drift-check（如执行）已通过或有明确裁决。
- blocked-check 已通过或有明确裁决。
- task-boundary-check 已通过或有明确裁决。
- emergency-check 已通过或明确 skipped。
- manifest-check 已通过或有明确裁决。
- evolution-check 已通过或有明确裁决。
- closure-check 已通过。
- knowledge / decisions / logs / baseline 已更新。

## 阶段 8：Evolve

产物：`EVOLUTION.md`

把本次经验反推到：

- `agent-flow/knowledge/`
- `agent-flow/decisions/`
- `agent-flow/templates/`
- `agent-flow/scripts/`

## 阶段 9：Log and Baseline

产物：

- `agent-flow/logs/YYYY/MM-DD.md`
- `agent-flow/knowledge/known-good-baselines.md`

记录：

- 本次完成了什么。
- 关键决策。
- 验证命令和结果。
- 下一个可执行工作。
- `STATE.md` 的最终状态。
