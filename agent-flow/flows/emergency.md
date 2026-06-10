# Emergency 流程

> 仅限**生产事故、安全漏洞、数据丢失**等紧急情况。
> 滥用此通道会破坏 agent-flow 的审计和风控体系。

## 使用条件

**全部满足**才能走 Emergency 通道：

1. 🔴 系统正在发生或即将发生**可量化的损失**（用户影响、数据丢失、收入损失）。
2. ⏱️ Standard/Heavy 流程的完整执行会导致损失扩大。
3. ✅ 你（或 incident commander）明确判断风险等级为 **P0 / P1**。
4. 🧑‍💼 有权限的负责人已批准 bypass。

**不满足时**，必须退回 Standard 或 Heavy 流程。

## 风险声明

Emergency 通道绕过了以下安全门：

- ❌ CODE_SCAN.md（完整版）
- ❌ Design Alignment / Grill
- ❌ Plan Audit
- ❌ Closure Audit
- ❌ REVIEW.md

**必须在 24 小时内回填**被跳过的工件。

## 步骤

### 阶段 0：确认 + 创建

1. 在 Change 命名中加前缀 `hotfix-`，例如 `hotfix-login-npe`。
2. 创建 `STATE.md` 和 `CHANGE.md`，在 CHANGE.md 中：
   - 标记 `Emergency`（在流程级别后新增一行）
   - 明确事故等级（P0/P1）
   - 记录批准人
   - 设定回填截止时间（默认 24h）
3. 在 `CHANGE.md` 的「风险」中记录 bypass 的理由。

### 阶段 1：最小扫描 + 实现

1. 写最小 `CODE_SCAN.md`，只需：
   - `read_files`（只读修复必需的文件）
   - `write_files`（只写修复必需的文件）
   - `未决问题`
2. 写 `TASKS.md`（只包含修复任务，任务粒度为 5-15 分钟）。
3. 实现修复。

### 阶段 2：最小验证

1. 运行修复相关的编译命令。
2. 运行修复相关的测试。
3. 写 `VERIFY.md`，至少包含：
   - 修复验证证据
   - 回滚步骤
   - 监控确认（日志/告警）
4. 如果涉及数据库，必须有回滚 SQL。

### 阶段 3：部署

1. 按项目部署流程发布。
2. 确认修复生效（监控/日志/用户反馈）。

### 阶段 4：回填（24 小时内）

必须在 24 小时内补充：

- [ ] 完整 `REQUIREMENT.md`（即使事后复盘）
- [ ] 完整 `CODE_SCAN.md`
- [ ] `DESIGN.md`（含 Design Alignment）
- [ ] `REVIEW.md`
- [ ] `AUDIT.md`（Closure Audit）
- [ ] `EVOLUTION.md`
- [ ] 更新 `agent-flow/knowledge/pitfalls.md`（如果有坑）
- [ ] 更新 `agent-flow/logs/YYYY/MM-DD.md`

### 阶段 5：复盘

事故解决后写 `REPORT.md`，回答：

- 紧急通道是否合理？
- 哪些步骤跳过导致了额外风险？
- 如何防止同类事故？

## 产物清单

| 阶段 | 必须 | 可选 |
|---|---|---|
| 0-确认 | `STATE.md` `CHANGE.md` | — |
| 1-实现 | `CODE_SCAN.md`(最小) `TASKS.md` | — |
| 2-验证 | `VERIFY.md` | 回滚 SQL |
| 3-部署 | 部署记录 | 监控确认 |
| 4-回填 | 完整工件 (见上) | — |
| 5-复盘 | `REPORT.md` `EVOLUTION.md` | ADR |

## Emergency 标识

`CHANGE.md` 中必须增加：

```text
## Emergency

- Level: P0 / P1
- Approved by: {name}
- Bypass reason: {root cause + why full process was skipped}
- Backfill deadline: {YYYY-MM-DD HH:mm} (默认 +24h)
- Backfill status: pending / done / waived
```

## 禁止

- **不允许**把 Emergency 通道用于常规紧急需求。
- **不允许**回填超时不补充说明。
- **不允许**连续两次使用 Emergency 而不做根本原因分析。
