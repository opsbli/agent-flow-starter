# Verify

## Command Record

| Command | Result | Evidence |
|---|---|---|
| `agent-flow/scripts/manifest-check.ps1` | pass | Manifest gates match `gates.txt` and actual public scripts |
| `bash agent-flow/scripts/manifest-check.sh` | pass | Bash manifest check uses same registry rules |
| `agent-flow/scripts/scaffold-health.ps1` | pass | Required public scripts derived from `gates.txt` |
| `bash agent-flow/scripts/scaffold-health.sh` | pass | Bash scaffold-health derives script requirements from `gates.txt` |
| `agent-flow/scripts/template-check.ps1` | pass | Template checks passed |
| `bash agent-flow/scripts/template-check.sh` | pass | Template checks passed |
| PowerShell parser over `agent-flow/scripts`, `scripts`, and `agent-flow/test/test-scripts` | pass | All `.ps1` scripts syntax OK |
| `bash -n` over `agent-flow/scripts`, `scripts`, and `agent-flow/test/test-scripts` | pass | All `.sh` scripts syntax OK |
| Actual public script list vs `manifest.yaml` gates | pass | No diff |
| Actual public script list vs `agent-flow/rules/gates.txt` | pass | No diff |
| `scripts/test-starter.ps1` | pass | Installs, initializes, checks registry negative case, closes demo Heavy change |
| `bash scripts/test-starter.sh` | pass | Bash path covers the same starter self-test chain |
| `agent-flow/scripts/run-verify.ps1 -All` | pass | Scaffold verification commands all pass |
| `bash agent-flow/scripts/run-verify.sh --all` | pass | Scaffold verification commands all pass |
| `agent-flow/scripts/check-change.ps1 -ChangeDir examples/sample-change -ProjectRoot . -Closure` | pass | Sample change closure remains green |
| `bash agent-flow/scripts/check-change.sh --change-dir examples/sample-change --project-root . --closure` | pass | Sample change closure remains green |

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | All public scripts are registered in `gates.txt` and `manifest.yaml` | command | Actual script list comparison; `manifest-check.ps1/.sh` | pass | none |
| AC-02 | `manifest-check` detects public script registry drift | test | `scripts/test-starter.ps1/.sh` creates `unregistered-demo.ps1/.sh` and expects failure | pass | none |
| AC-03 | `scaffold-health` derives public scripts from `gates.txt` | command/code | `scaffold-health.ps1/.sh`; script implementation | pass | none |
| AC-04 | Starter does not track real run-history files beyond `.gitkeep` | command/code | `.gitignore`; deleted `agent-flow/logs/2026/06-15.md`; deleted `agent-flow/reports/practice-install-and-verify.md`; self-test guard | pass | pending commit removes deleted paths from index |
| AC-05 | Starter self-test catches future run-history leakage | test | `scripts/test-starter.ps1/.sh` tracked-history guard | pass | none |
| AC-06 | Script README no longer hard-codes stale count | review | `agent-flow/scripts/README.md` | pass | none |
| AC-07 | Windows and Bash starter self-tests pass | command | `scripts/test-starter.ps1`; `scripts/test-starter.sh` | pass | none |

## Coverage Summary

| Metric | Source | Value | Result | Notes |
|---|---|---|---|---|
| AC Coverage | VERIFY.md evidence rows | 7/7 (100%) | pass | Every AC has command, test, or code evidence |
| Test Coverage | starter self-test + gate checks | targeted | pass | Covers install/init/check-change/negative registry/run-history guard |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scan-check | Heavy | pass | `scan-check.ps1 -ChangeDir ... -Strict` | 0 | 2026-06-15 | strict scan passed |
| design-check | Heavy | pass | `design-check.ps1 -ChangeDir ...` | 0 | 2026-06-15 | design decisions accepted |
| alignment-check | Heavy | pass | `alignment-check.ps1 -ChangeDir ...` | 0 | 2026-06-15 | alignment rows confirmed |
| task-check | Heavy | pass | `task-check.ps1 -ChangeDir ...` | 0 | 2026-06-15 | tasks map to AC ids and write_files |
| plan-check | Heavy | pass | `plan-check.ps1 -ChangeDir ...` | 0 | 2026-06-15 | plan audit accepted |
| ac-check | Heavy | pass | `ac-check.ps1 -ChangeDir ...` | 0 | 2026-06-15 | 7 AC ids have evidence |
| coverage-check | Heavy | pass | `coverage-check.ps1 -ChangeDir ...` | 0 | 2026-06-15 | AC coverage 7/7 |
| code-drift-check | Heavy | pass | `code-drift-check.ps1 -ChangeDir ... -ProjectRoot .` | 0 | 2026-06-15 | no API/auth/schema drift |
| blocked-check | Heavy | pass | `blocked-check.ps1 -ChangeDir ... -ProjectRoot .` | 0 | 2026-06-15 | no blocked operation |
| task-boundary-check | Heavy | pass | `task-boundary-check.ps1 -ChangeDir ... -ProjectRoot .` | 0 | 2026-06-15 | changed files within write_files |
| manifest-check | all closure | pass | `manifest-check.ps1`; `manifest-check.sh` | 0 | 2026-06-15 | Both passed |
| emergency-check | Heavy closure summary | skipped | `emergency-check.ps1 -ChangeDir ...` | 0 | 2026-06-15 | Not an Emergency change |
| evolution-check | Heavy | pass | `evolution-check.ps1 -ChangeDir ...` | 0 | 2026-06-15 | evolution decision recorded |
| closure-check | Heavy | pass | `closure-check.ps1 -ChangeDir ... -ProjectRoot .` | 0 | 2026-06-15 | closure accepted |

## Skipped Items

| Item | Reason | Risk |
|---|---|---|
| Browser/UI verification | Scaffold-only workflow/tooling change | none |

## Conclusion

The ordered governance upgrades are implemented and covered by cross-platform machine checks.
