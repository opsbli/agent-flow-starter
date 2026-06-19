# Verify

## 验证环境

本地开发环境，MySQL 8.0，JDK 17

## 命令记录

| 命令 | 结果 | 证据 |
|---|---|---|
| `mvn test` | pass | 45 tests passed |
| `agent-flow/scripts/ac-check.ps1` | pass | 5 AC ids have evidence |
| `agent-flow/scripts/code-drift-check.ps1` | pass | schema 变更匹配设计 |
| `agent-flow/scripts/closure-check.ps1` | pass | Heavy closure 通过 |

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | 提交审批后文档状态变更为待审批 | test | `ApprovalSubmitTest.java:32` | pass | none |
| AC-02 | 一级审批人批准后流转到二级审批 | test | `ApprovalApproveTest.java:45` | pass | none |
| AC-03 | 二级审批人批准后文档状态变更为已批准 | test | `ApprovalApproveTest.java:78` | pass | none |
| AC-04 | 审批人驳回后文档状态变更为已驳回 | test | `ApprovalRejectTest.java:33` | pass | none |
| AC-05 | 被驳回文档重新提交后进入待审批 | test | `ApprovalResubmitTest.java:28` | pass | none |

## Coverage Summary

| Metric | Source | Value | Result | Notes |
|---|---|---|---|---|
| AC Coverage | `coverage-check` | 5/5 (100%) | pass | All ACs have evidence |
| Test Coverage | JaCoCo | 92% | pass | New code covered |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scan-check | Heavy | pass | `scan-check --strict` | 0 | YYYY-MM-DD | paths validated |
| design-check | Heavy | pass | `design-check` | 0 | YYYY-MM-DD | decisions accepted |
| alignment-check | Heavy | pass | `alignment-check` | 0 | YYYY-MM-DD | 3 user-confirmed |
| task-check | Heavy | pass | `task-check` | 0 | YYYY-MM-DD | tasks bounded |
| plan-check | Heavy | pass | `plan-check` | 0 | YYYY-MM-DD | plan valid |
| ac-check | Heavy | pass | `ac-check` | 0 | YYYY-MM-DD | 5 AC ids |
| coverage-check | Heavy | pass | `coverage-check` | 0 | YYYY-MM-DD | 5/5 + JaCoCo |
| code-drift-check | Heavy | pass | `code-drift-check` | 0 | YYYY-MM-DD | no drift |
| blocked-check | Heavy | pass | `blocked-check` | 0 | YYYY-MM-DD | no blocked ops |
| closure-check | Heavy | pass | `closure-check` | 0 | YYYY-MM-DD | all gates pass |

## 结论

Heavy change 完成。所有 AC 有测试证据，设计对齐、Plan Audit、Closure Audit 全部通过。
