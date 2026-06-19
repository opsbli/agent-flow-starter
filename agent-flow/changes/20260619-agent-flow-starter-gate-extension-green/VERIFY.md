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

## Coverage Summary

`coverage-check` 会自动计算 AC Evidence 覆盖率。测试覆盖率可以来自 lcov、pytest-cov、JaCoCo、内置覆盖率报告，或明确写明不适用原因。

| Metric | Source | Value | Result | Notes |
|---|---|---|---|---|
| AC Coverage | `agent-flow/scripts/coverage-check.*` | auto | pass / fail / conditional / skipped | |
| Test Coverage | lcov / coverage report / N/A | | pass / conditional / skipped | |

## Drift 检查

| 类型 | 结果 | 说明 |
|---|---|---|
| schema | | |
| route | | |
| permission | | |
| pom | | |
| scan-check | | |
| design-check | | |
| alignment-check | | |
| task-check | | |
| plan-check | | |
| task-boundary-check | | |
| manifest-check | | |
| blocked-check | | |
| evolution-check | | |
| closure-check | | |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scan-check | Light / Standard / Heavy | pass / fail / skipped / conditional | | | | |
| design-check | Standard / Heavy | pass / fail / skipped / conditional | | | | |
| alignment-check | Standard / Heavy | pass / fail / skipped / conditional | | | | |
| task-check | Standard / Heavy / Emergency with TASKS.md | pass / fail / skipped / conditional | | | | |
| plan-check | Heavy | pass / fail / skipped / conditional | | | | |
| ac-check | Standard / Heavy | pass / fail / skipped / conditional | | | | |
| coverage-check | Standard / Heavy | pass / fail / skipped / conditional | | | | |
| code-drift-check | Heavy | pass / fail / skipped / conditional | | | | |
| blocked-check | Heavy | pass / fail / skipped / conditional | | | | |
| task-boundary-check | Standard / Heavy | pass / fail / skipped / conditional | | | | |
| manifest-check | all closure | pass / fail / skipped / conditional | | | | |
| emergency-check | Emergency / Heavy closure summary | pass / fail / skipped / conditional | | | | |
| evolution-check | Standard / Heavy | pass / fail / skipped / conditional | | | | |
| closure-check | Heavy closure | pass / fail / skipped / conditional | | | | |

## 跳过项

| 项 | 原因 | 风险 |
|---|---|---|

## 结论

## Known-Good Baseline 更新

- [ ] 不适用
- [ ] 已更新 `agent-flow/knowledge/known-good-baselines.md`

记录行：

```text
| YYYY-MM-DD | 20260619-agent-flow-starter-gate-extension-green | pass/fail | pass/fail/N/A | pass/fail/N/A | {module} | {notes} |
```

