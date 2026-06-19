# Verify

## Command Record

| Command | Result | Evidence |
|---|---|---|
| `agent-flow/scripts/manifest-check.ps1` | pass | AC-02 accepted inline-commented `blocked_if` rules |
| `bash agent-flow/scripts/manifest-check.sh` | pass | AC-02 accepted inline-commented `blocked_if` rules |
| `agent-flow/scripts/run-verify.ps1 -All` | pass | AC-03 preserved quoted echo commands |
| `bash agent-flow/scripts/run-verify.sh --all` | pass | AC-03 preserved quoted echo commands |
| PowerShell parser over `agent-flow/scripts` and `agent-flow/test/test-scripts` | pass | AC-04 all `.ps1` scripts parsed |
| `bash -n` over `agent-flow/scripts` and `agent-flow/test/test-scripts` | pass | AC-04 all `.sh` scripts parsed |
| `agent-flow/test/test-scripts/test-new-change.ps1` | pass | AC-05 prefixed change ids accepted by smoke test |
| `bash agent-flow/test/test-scripts/test-new-change.sh` | pass | AC-05 suffix-based smoke test passed |
| `agent-flow/scripts/check-change.ps1 -ChangeDir examples/sample-change -ProjectRoot . -Closure` | pass | AC-01 and AC-05 sample aggregate chain passed |
| `bash agent-flow/scripts/check-change.sh --change-dir examples/sample-change --project-root . --closure` | pass | AC-01 and AC-05 sample aggregate chain passed |

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | Aggregate check-change invokes AC and coverage gates correctly | command | sample `check-change` Windows and Bash runs | pass | none |
| AC-02 | manifest-check accepts inline-commented `blocked_if` rules | command | `manifest-check.ps1`; `manifest-check.sh` | pass | none |
| AC-03 | run-verify preserves internal command quotes | command | `run-verify.ps1 -All`; `run-verify.sh --all` | pass | none |
| AC-04 | scripts parse without corrupted strings or BOM failures | command | PowerShell parser; Bash syntax check | pass | none |
| AC-05 | runnable sample passes current gates | command | sample `check-change` Windows and Bash; `test-new-change` smoke tests | pass | none |

## Coverage Summary

| Metric | Source | Value | Result | Notes |
|---|---|---|---|---|
| AC Coverage | `agent-flow/scripts/coverage-check.*` | 5/5 | pass | Each AC has an evidence row |
| Test Coverage | targeted script commands | targeted | pass | Script scaffold has targeted smoke checks instead of numeric coverage |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scan-check | Heavy | pass | `agent-flow/scripts/scan-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability -ProjectRoot . -Strict` | 0 | 2026-06-15 | CODE_SCAN machine keys and paths valid |
| design-check | Heavy | pass | `agent-flow/scripts/design-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability` | 0 | 2026-06-15 | Decision Status accepted and decision rows complete |
| alignment-check | Heavy | skipped | `agent-flow/scripts/alignment-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability` | 0 | 2026-06-15 | User requested ordered repair; Skip Reason recorded |
| task-check | Heavy | pass | `agent-flow/scripts/task-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability` | 0 | 2026-06-15 | Completed tasks map to AC evidence |
| plan-check | Heavy | pass | `agent-flow/scripts/plan-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability` | 0 | 2026-06-15 | Plan Audit accepted |
| ac-check | Heavy | pass | `agent-flow/scripts/ac-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability` | 0 | 2026-06-15 | AC-01 through AC-05 have evidence |
| coverage-check | Heavy | pass | `agent-flow/scripts/coverage-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability` | 0 | 2026-06-15 | AC coverage recorded |
| code-drift-check | Heavy | pass | `agent-flow/scripts/code-drift-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability -ProjectRoot .` | 0 | 2026-06-15 | No API, schema, or permission drift |
| blocked-check | Heavy | pass | `agent-flow/scripts/blocked-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability -ProjectRoot .` | 0 | 2026-06-15 | No blocked operation triggered |
| task-boundary-check | Heavy | pass | `agent-flow/scripts/task-boundary-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability -ProjectRoot .` | 0 | 2026-06-15 | Changed files are within TASKS write_files or the change folder |
| manifest-check | all closure | pass | `agent-flow/scripts/manifest-check.ps1 -ProjectRoot .` | 0 | 2026-06-15 | Manifest and gate list valid |
| emergency-check | Heavy closure summary | skipped | `agent-flow/scripts/emergency-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability` | 0 | 2026-06-15 | Not an Emergency change |
| evolution-check | Heavy | pass | `agent-flow/scripts/evolution-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability` | 0 | 2026-06-15 | Evolution decision recorded |
| closure-check | Heavy closure | pass | `agent-flow/scripts/closure-check.ps1 -ChangeDir agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability -ProjectRoot .` | 0 | 2026-06-15 | Closure Audit accepted |

## Skipped Items

| Item | Reason | Risk |
|---|---|---|
| Design Alignment interview | User requested ordered repair of confirmed script failures; code facts were sufficient | low |

## Conclusion

AC-01 through AC-05 are covered by direct command evidence and aggregate gate evidence.
