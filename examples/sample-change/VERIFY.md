# Verify

## Command Record

| Command | Result | Evidence |
|---|---|---|
| `agent-flow/scripts/run-verify.ps1 -Name frontend_test` | pass | status label tests passed |
| `agent-flow/scripts/ac-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | pass | 2 AC ids have evidence |
| `agent-flow/scripts/code-drift-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | pass | no schema/API/permission drift |

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | Archived items display `Archived` | test | `tests/status-label.test.ts` | pass | none |
| AC-02 | Existing labels unchanged | test | `tests/status-label.test.ts` | pass | none |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scan-check | Standard | pass | `agent-flow/scripts/scan-check.ps1 -ChangeDir agent-flow/changes/sample-status-label -ProjectRoot . -Strict` | 0 | 2026-06-10 10:00 | CODE_SCAN paths checked |
| design-check | Standard | pass | `agent-flow/scripts/design-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | 0 | 2026-06-10 10:00 | API/Auth/Permission decisions accepted |
| alignment-check | Standard | pass | `agent-flow/scripts/alignment-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | 0 | 2026-06-10 10:00 | design alignment confirmed |
| task-check | Standard | pass | `agent-flow/scripts/task-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | 0 | 2026-06-10 10:00 | tasks mapped to AC ids |
| ac-check | Standard | pass | `agent-flow/scripts/ac-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | 0 | 2026-06-10 10:00 | 2 AC ids have evidence |
| code-drift-check | Standard | pass | `agent-flow/scripts/code-drift-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | 0 | 2026-06-10 10:00 | no schema/API/permission drift |
| blocked-check | Standard | pass | `agent-flow/scripts/blocked-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | 0 | 2026-06-10 10:00 | no blocked operations |
| task-boundary-check | Standard | pass | `agent-flow/scripts/task-boundary-check.ps1 -ChangeDir agent-flow/changes/sample-status-label -ProjectRoot .` | 0 | 2026-06-10 10:00 | changed files within write_files |
| manifest-check | all closure | pass | `agent-flow/scripts/manifest-check.ps1 -ProjectRoot .` | 0 | 2026-06-10 10:00 | manifest valid |
| emergency-check | Standard | skipped | `agent-flow/scripts/emergency-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | 0 | 2026-06-10 10:00 | not an Emergency change |
| evolution-check | Standard | pass | `agent-flow/scripts/evolution-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | 0 | 2026-06-10 10:00 | evolution decision recorded |

## Skipped Items

| Item | Reason | Risk |
|---|---|---|
| Browser smoke | Small renderer-only sample | low |

## Conclusion

The change has evidence for all ACs and no protected-area drift.
