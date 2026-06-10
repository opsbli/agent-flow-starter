# Verify

## Command Record

| Command | Result | Evidence |
|---|---|---|
| `agent-flow/scripts/run-verify.ps1 -Name frontend_test` | pass | status label tests passed |
| `agent-flow/scripts/ac-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | pass | 2 AC ids have evidence |
| `agent-flow/scripts/drift-check.ps1 -ChangeDir agent-flow/changes/sample-status-label` | pass | no schema/API/permission drift |

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | Archived items display `Archived` | test | `tests/status-label.test.ts` | pass | none |
| AC-02 | Existing labels unchanged | test | `tests/status-label.test.ts` | pass | none |

## Skipped Items

| Item | Reason | Risk |
|---|---|---|
| Browser smoke | Small renderer-only sample | low |

## Conclusion

The change has evidence for all ACs and no protected-area drift.

