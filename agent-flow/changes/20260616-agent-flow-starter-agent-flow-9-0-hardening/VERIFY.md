# Verify

## Summary

The 9.0 hardening changes were verified on both Windows/PowerShell and bash paths.

## Command Log

| Command | Result | Notes |
|---|---|---|
| `agent-flow/scripts/scaffold-health.ps1` | pass | Required scaffold files present. |
| `bash agent-flow/scripts/scaffold-health.sh` | pass | Required scaffold files present. |
| `agent-flow/scripts/template-check.ps1` | pass | Templates remain compatible. |
| `bash agent-flow/scripts/template-check.sh` | pass | Templates remain compatible. |
| `agent-flow/scripts/manifest-check.ps1` | pass | Manifest and gate registry valid. |
| `bash agent-flow/scripts/manifest-check.sh` | pass | Manifest and gate registry valid. |
| `scripts/test-starter.ps1` | pass | Windows install/gate/closure self-test passed. |
| `bash scripts/test-starter.sh` | pass | Bash install/gate/closure self-test passed. |

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | Clean install history directories | automated smoke | `scripts/test-starter.ps1`, `scripts/test-starter.sh`, installer output `CREATED: changes/ (clean history directory)` | pass | none |
| AC-02 | Alignment requires at least three `user-confirmed` rows | automated gate | `alignment-check.ps1`, `alignment-check.sh`, legacy/code-only negative self-test cases | pass | none |
| AC-03 | Bash init preserves explicit missing-dir placeholders | automated smoke | `init-project.sh`, bash self-test asserts `TODO_BACKEND_ENTRY`, `TODO_COMMON_CODE_PATH`, `TODO_BUSINESS_MODULE_PATH`, `TODO_TEST_PATH`, `TODO_SQL_PATH` | pass | none |
| AC-04 | Closure aggregate fails on missing required artifacts | automated gate | `check-change.ps1`, `check-change.sh`, negative `demo-missing-closure` self-test | pass | none |
| AC-05 | Single CI workflow owner remains | static check | `.github/workflows/scaffold-ci.yml` exists; `.github/workflows/agent-flow-starter-check.yml` deleted; self-tests assert absence | pass | none |
| AC-06 | Full regression checks pass on both platforms | automated regression | `scripts/test-starter.ps1`; `bash scripts/test-starter.sh`; scaffold/template/manifest checks | pass | none |

## Coverage Summary

| Metric | Source | Value | Result | Notes |
|---|---|---|---|---|
| AC Coverage | `coverage-check` | 6/6 | pass | Every AC has evidence. |
| Test Coverage | root starter self-tests | install, init, alignment, closure, CI dedupe | pass | This scaffold has smoke/gate coverage rather than product unit coverage. |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scan-check | Heavy | pass | `agent-flow/scripts/scan-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening -ProjectRoot . -Strict` | 0 | 2026-06-16 | CODE_SCAN strict check passed |
| design-check | Heavy | pass | `agent-flow/scripts/design-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening` | 0 | 2026-06-16 | DESIGN decisions accepted |
| alignment-check | Heavy | pass | `agent-flow/scripts/alignment-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening` | 0 | 2026-06-16 | user-confirmed alignment passed |
| task-check | Heavy | pass | `agent-flow/scripts/task-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening` | 0 | 2026-06-16 | all tasks map to AC evidence |
| plan-check | Heavy | pass | `agent-flow/scripts/plan-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening` | 0 | 2026-06-16 | Plan Audit accepted |
| ac-check | Heavy | pass | `agent-flow/scripts/ac-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening` | 0 | 2026-06-16 | AC Evidence rows complete |
| coverage-check | Heavy | pass | `agent-flow/scripts/coverage-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening` | 0 | 2026-06-16 | AC coverage 6/6 |
| code-drift-check | Heavy | pass | `agent-flow/scripts/code-drift-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening -ProjectRoot .` | 0 | 2026-06-16 | no schema/auth/API drift |
| blocked-check | Heavy | pass | `agent-flow/scripts/blocked-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening -ProjectRoot .` | 0 | 2026-06-16 | no blocked operation detected |
| task-boundary-check | Heavy | pass | `agent-flow/scripts/task-boundary-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening -ProjectRoot .` | 0 | 2026-06-16 | changed files stayed within write_files |
| manifest-check | all closure | pass | `agent-flow/scripts/manifest-check.ps1` | 0 | 2026-06-16 | manifest valid |
| emergency-check | Heavy closure summary | skipped | `agent-flow/scripts/emergency-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening` | 0 | 2026-06-16 | not an Emergency change |
| evolution-check | Heavy | pass | `agent-flow/scripts/evolution-check.ps1 -ChangeDir agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening` | 0 | 2026-06-16 | evolution recorded |

## Conclusion

All ACs passed. The scaffold is now at the intended 9.0 hardening target.
