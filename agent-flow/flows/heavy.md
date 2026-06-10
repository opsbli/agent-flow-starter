# Heavy 流程

适合老项目新模块、跨模块、高风险需求。

## 阶段 0：Intake

产物：`CHANGE.md`

必须明确：

- 目标
- 非目标
- 风险级别
- 用户角色
- 业务边界
- 是否涉及前端仓库
- 本次 AI 自治等级
- 是否触碰 protected areas

## 阶段 1：Grill

产物：更新 `REQUIREMENT.md` 和必要知识文件。

用 `grill-with-docs` 的方式追问：

- 每个业务名词的精确定义是什么？
- 哪些状态、权限、数据归属必须明确？
- 哪些场景不能做？
- 失败后系统应该如何恢复？
- 旧代码是否支持用户的说法？

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

## 阶段 3.5：Design Alignment / Grill

产物：更新 `DESIGN.md` 的 `Design Alignment / Grill` 小节。

目的：把用户自然语言、AI 理解、现有代码事实对齐，避免带着误解进入计划和实现。

必须执行：

- 一次只问一个关键问题。
- 如果问题能通过读代码回答，先读代码，不要问用户。
- 每个问题给出 AI 推荐答案。
- 用户确认后，把结论写回 `DESIGN.md`。
- `Alignment Verdict` 必须是 `aligned`，或用户明确接受 `skipped` 且填写 `Skip Reason`。

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
- AC 映射。
- `read_files`。
- `write_files`。
- 验证命令。
- 是否允许并行。

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
- ac-check
- drift-check
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
- drift-check 已执行或有明确裁决。
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
