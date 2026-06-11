# Verify

## 验证环境

## 命令记录

| 命令 | 结果 | 证据 |
|---|---|---|

## AC 覆盖

| AC | 证据 | 状态 |
|---|---|---|

## AC Evidence

每个 `REQUIREMENT.md` 中的 AC 必须有证据行。AC 编号必须保持 `AC-01` 格式。

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | | test / command / code / manual / skipped | | pass / fail / conditional / skipped | |

## Drift 检查

| 类型 | 结果 | 说明 |
|---|---|---|
| schema | | |
| route | | |
| permission | | |
| pom | | |
| scan-check | | |
| task-check | | |
| task-boundary-check | | |
| manifest-check | | |
| blocked-check | | |
| evolution-check | | |
| closure-check | | |

## Machine Gate Summary

| Gate | Required For | Result | Evidence |
|---|---|---|---|
| scan-check | Light / Standard / Heavy | pass / fail / skipped | |
| task-check | Standard / Heavy / Emergency with TASKS.md | pass / fail / skipped | |
| ac-check | Standard / Heavy | pass / fail / skipped | |
| code-drift-check | Heavy | pass / fail / skipped | |
| blocked-check | Heavy | pass / fail / skipped | |
| task-boundary-check | Standard / Heavy | pass / fail / skipped | |
| manifest-check | all closure | pass / fail / skipped | |
| evolution-check | Standard / Heavy | pass / fail / skipped | |
| closure-check | Heavy closure | pass / fail / skipped | |

## 跳过项

| 项 | 原因 | 风险 |
|---|---|---|

## 结论

## Known-Good Baseline 更新

- [ ] 不适用
- [ ] 已更新 `agent-flow/knowledge/known-good-baselines.md`

记录行：

```text
| YYYY-MM-DD | {change-id} | pass/fail | pass/fail/N/A | pass/fail/N/A | {module} | {notes} |
```
