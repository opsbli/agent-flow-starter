# Verify

## 验证环境

- Date: 2026-06-11
- OS: Windows PowerShell + Bash/WSL
- Project root: `C:\Users\sinvi\Documents\agent-flow-starter`

## 命令记录

| 命令 | 结果 | 证据 |
|---|---|---|
| `agent-flow/scripts/scaffold-health.ps1` | pass | `agent-flow scaffold health check passed.` |
| `bash agent-flow/scripts/scaffold-health.sh` | pass | `agent-flow scaffold health check passed.` |
| `agent-flow/scripts/manifest-check.ps1` | pass | Printed TODO guidance grouped by project map paths, verification commands, explicit none decisions. |
| `bash agent-flow/scripts/manifest-check.sh` | pass | Printed TODO guidance grouped by project map paths, verification commands, explicit none decisions. |
| PowerShell parser over `agent-flow/scripts/*.ps1` and `scripts/*.ps1` | pass | No parser errors after fixing `ac-check.ps1`. |
| `bash -n agent-flow/scripts/ac-check.sh` | pass | Bash syntax OK. |
| `bash -n agent-flow/scripts/manifest-check.sh` | pass | Bash syntax OK. |
| `scripts/test-starter.ps1` | pass | Installed empty/update targets, ran gate positive/negative cases, closure check, residue scan. |
| `bash scripts/test-starter.sh` | pass | Installed empty/update targets, ran gate positive/negative cases, closure check, residue scan. |
| `task-boundary-check.ps1 -ChangeDir agent-flow/changes/p0-p1-starter-improvements -ProjectRoot .` | pass | Changed files are within `TASKS.md write_files` or the change folder. |
| `bash agent-flow/scripts/task-boundary-check.sh --change-dir agent-flow/changes/p0-p1-starter-improvements --project-root .` | pass | Changed files are within `TASKS.md write_files` or the change folder. |

## AC 覆盖

| AC | 证据 | 状态 |
|---|---|---|
| AC-01 | `manifest-check.ps1/.sh` output now includes TODO guidance categories and next steps. | pass |
| AC-02 | `scripts/test-starter.ps1/.sh` asserts missing/incomplete AC Evidence fails `ac-check`. | pass |
| AC-03 | `scripts/test-starter.ps1/.sh` asserts complete AC Evidence passes `ac-check`. | pass |
| AC-04 | `scripts/test-starter.ps1/.sh` includes negative cases for scan/design/alignment/ac/code-drift/blocked/task-boundary. | pass |
| AC-05 | README, DESIGN, EVOLUTION, improvement tracker, ADR index files updated. | pass |
| AC-06 | `scaffold-health.ps1/.sh` and starter self-tests pass with new files included. | pass |

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | Manifest TODO output gives actionable categories and next steps | command / code | `agent-flow/scripts/manifest-check.ps1`; `agent-flow/scripts/manifest-check.sh`; command output in this VERIFY | pass | none |
| AC-02 | Missing or incomplete AC Evidence fails `ac-check` | command / test | `scripts/test-starter.ps1`; `scripts/test-starter.sh` negative cases | pass | none |
| AC-03 | Complete AC Evidence passes `ac-check` | command / test | `scripts/test-starter.ps1`; `scripts/test-starter.sh` positive cases | pass | none |
| AC-04 | Core gate negative paths are covered by starter self-test | command / test | `scripts/test-starter.ps1`; `scripts/test-starter.sh` | pass | none |
| AC-05 | P1 docs/templates/tracker/index are present | code / manual | `README.md`; `agent-flow/README.md`; `agent-flow/templates/DESIGN.md`; `agent-flow/templates/EVOLUTION.md`; `agent-flow/knowledge/improvement-tracker.md`; `agent-flow/decisions/INDEX.md` | pass | none |
| AC-06 | New files are included in scaffold health and installed fixture | command / code | `agent-flow/scripts/scaffold-health.ps1`; `agent-flow/scripts/scaffold-health.sh`; `agent-flow/test/fixtures/minimal-project/agent-flow/...` | pass | none |

## Drift 检查

| 类型 | 结果 | 说明 |
|---|---|---|
| schema | pass | No schema changes. |
| route | pass | No API route changes. |
| permission | pass | No auth/permission changes. |
| pom | pass | No build/module registration changes. |
| scan gate | pass | `scan-check.ps1 -Strict` passed for this change. |
| design gate | pass | `design-check.ps1` passed. |
| alignment gate | pass | `alignment-check.ps1` passed. |
| task gate | pass | `task-check.ps1` passed. |
| plan gate | pending | Filled before final closure. |
| task boundary gate | pass | Windows and Bash passed. |
| manifest gate | pass | Windows and Bash passed with expected placeholder warnings. |
| blocked gate | pending | Filled before final closure. |
| evolution gate | pending | Filled before final closure. |
| closure gate | pending | Filled before final closure. |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scan-check | Light / Standard / Heavy | pass | `agent-flow/scripts/scan-check.ps1 -ChangeDir agent-flow/changes/p0-p1-starter-improvements -ProjectRoot . -Strict` | 0 | 2026-06-11 | strict scan passed |
| design-check | Standard / Heavy | pass | `agent-flow/scripts/design-check.ps1 -ChangeDir agent-flow/changes/p0-p1-starter-improvements` | 0 | 2026-06-11 | design decisions accepted |
| alignment-check | Standard / Heavy | pass | `agent-flow/scripts/alignment-check.ps1 -ChangeDir agent-flow/changes/p0-p1-starter-improvements` | 0 | 2026-06-11 | alignment source mixed, questions confirmed |
| task-check | Standard / Heavy / Emergency with TASKS.md | pass | `agent-flow/scripts/task-check.ps1 -ChangeDir agent-flow/changes/p0-p1-starter-improvements` | 0 | 2026-06-11 | task matrix complete |
| plan-check | Heavy | conditional | pending final command | 0 | 2026-06-11 | will run after PLAN/AUDIT update |
| ac-check | Standard / Heavy | pass | `scripts/test-starter.ps1`; `bash scripts/test-starter.sh` | 0 | 2026-06-11 | self-tests include `ac-check` positive/negative cases |
| code-drift-check | Heavy | pass | `scripts/test-starter.ps1`; `bash scripts/test-starter.sh` | 0 | 2026-06-11 | self-tests include positive and schema-drift negative case |
| blocked-check | Heavy | pass | `scripts/test-starter.ps1`; `bash scripts/test-starter.sh` | 0 | 2026-06-11 | self-tests include positive and blocked SQL negative case |
| task-boundary-check | Standard / Heavy | pass | `task-boundary-check.ps1` and `task-boundary-check.sh` for this change | 0 | 2026-06-11 | write_files boundary passed |
| manifest-check | all closure | pass | `manifest-check.ps1` and `manifest-check.sh` | 0 | 2026-06-11 | placeholder guidance printed |
| emergency-check | Emergency / Heavy closure summary | skipped | not an Emergency change | 0 | 2026-06-11 | not applicable |
| evolution-check | Standard / Heavy | conditional | pending final command | 0 | 2026-06-11 | will run after EVOLUTION update |
| closure-check | Heavy closure | conditional | pending final command | 0 | 2026-06-11 | will run after closure docs update |

## 跳过项

| 项 | 原因 | 风险 |
|---|---|---|
| Runtime backend/frontend tests | Starter has no business backend/frontend runtime. | Covered by scaffold self-tests and script syntax checks. |

## 结论

P0/P1 implementation evidence is present. Final closure gates remain to be run after PLAN/AUDIT/REPORT/EVOLUTION are updated.

## Known-Good Baseline 更新

- [x] 不适用
- [ ] 已更新 `agent-flow/knowledge/known-good-baselines.md`

记录行：

```text
| 2026-06-11 | p0-p1-starter-improvements | N/A | pass | N/A | agent-flow-starter | P0/P1 scaffold checks pass on Windows and Bash. |
```
