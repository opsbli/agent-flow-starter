# Tasks

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel |
|---|---|---|---|---|---|---|
| T-01 | completed | AC-01 | `agent-flow/scripts/check-change.ps1`; `agent-flow/scripts/check-change.sh`; `agent-flow/scripts/ac-traceability-check.*` | `agent-flow/scripts/check-change.ps1`; `agent-flow/scripts/check-change.sh` | sample `check-change` Windows and Bash | no |
| T-02 | completed | AC-02 | `agent-flow/manifest.yaml`; `agent-flow/scripts/manifest-check.ps1`; `agent-flow/scripts/manifest-check.sh` | `agent-flow/scripts/manifest-check.ps1`; `agent-flow/scripts/manifest-check.sh` | `manifest-check.ps1`; `manifest-check.sh` | yes |
| T-03 | completed | AC-03 | `agent-flow/manifest.yaml`; `agent-flow/scripts/run-verify.ps1`; `agent-flow/scripts/run-verify.sh` | `agent-flow/scripts/run-verify.ps1`; `agent-flow/scripts/run-verify.sh` | `run-verify.ps1 -All`; `run-verify.sh --all` | yes |
| T-04 | completed | AC-04 | `agent-flow/scripts/ac-traceability-check.*`; `agent-flow/scripts/incremental-verify.*`; `agent-flow/scripts/check-change.sh`; `agent-flow/scripts/new-change.*` | `agent-flow/scripts/ac-traceability-check.ps1`; `agent-flow/scripts/ac-traceability-check.sh`; `agent-flow/scripts/incremental-verify.ps1`; `agent-flow/scripts/incremental-verify.sh`; `agent-flow/scripts/check-change.sh`; `agent-flow/scripts/new-change.ps1`; `agent-flow/scripts/new-change.sh` | PowerShell parser; Bash syntax check | no |
| T-05 | completed | AC-05 | `agent-flow/test/test-scripts/test-new-change.*`; `scripts/test-starter.*`; `examples/sample-change/CODE_SCAN.md`; `agent-flow/scripts/_common.*` | `agent-flow/test/test-scripts/test-new-change.ps1`; `agent-flow/test/test-scripts/test-new-change.sh`; `scripts/test-starter.ps1`; `scripts/test-starter.sh`; `examples/sample-change/CODE_SCAN.md`; `examples/sample-change/STATE.md`; `agent-flow/scripts/_common.ps1`; `agent-flow/scripts/_common.sh` | `test-new-change.ps1`; `test-new-change.sh`; sample `check-change`; `test-starter` | no |

## write_files 汇总

write_files:
  - agent-flow/scripts/_common.ps1
  - agent-flow/scripts/_common.sh
  - agent-flow/scripts/ac-traceability-check.ps1
  - agent-flow/scripts/ac-traceability-check.sh
  - agent-flow/scripts/check-change.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/blocked-check.ps1
  - agent-flow/scripts/blocked-check.sh
  - agent-flow/scripts/scaffold-health.ps1
  - agent-flow/scripts/scaffold-health.sh
  - agent-flow/scripts/incremental-verify.ps1
  - agent-flow/scripts/incremental-verify.sh
  - agent-flow/scripts/manifest-check.ps1
  - agent-flow/scripts/manifest-check.sh
  - agent-flow/scripts/new-change.ps1
  - agent-flow/scripts/new-change.sh
  - agent-flow/scripts/run-verify.ps1
  - agent-flow/scripts/run-verify.sh
  - agent-flow/test/test-scripts/test-new-change.ps1
  - agent-flow/test/test-scripts/test-new-change.sh
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - examples/sample-change/CODE_SCAN.md
  - examples/sample-change/STATE.md

## Task Details

### T-01

Status: completed
Goal: Restore aggregate gate execution for AC-01.
AC: AC-01
read_files: agent-flow/scripts/check-change.ps1, agent-flow/scripts/check-change.sh
write_files: agent-flow/scripts/check-change.ps1, agent-flow/scripts/check-change.sh
Verify: sample check-change Windows and Bash
Parallel: no

### T-02

Status: completed
Goal: Accept valid blocked_if inline comments for AC-02.
AC: AC-02
read_files: agent-flow/scripts/manifest-check.ps1, agent-flow/scripts/manifest-check.sh
write_files: agent-flow/scripts/manifest-check.ps1, agent-flow/scripts/manifest-check.sh, agent-flow/scripts/blocked-check.ps1, agent-flow/scripts/blocked-check.sh
Verify: manifest-check.ps1 and manifest-check.sh
Parallel: yes

### T-03

Status: completed
Goal: Preserve internal command quotes for AC-03.
AC: AC-03
read_files: agent-flow/scripts/run-verify.ps1, agent-flow/scripts/run-verify.sh
write_files: agent-flow/scripts/run-verify.ps1, agent-flow/scripts/run-verify.sh
Verify: run-verify.ps1 -All and run-verify.sh --all
Parallel: yes

### T-04

Status: completed
Goal: Restore syntax and encoding safety for AC-04.
AC: AC-04
read_files: agent-flow/scripts/ac-traceability-check.ps1, agent-flow/scripts/incremental-verify.ps1, agent-flow/scripts/check-change.sh
write_files: agent-flow/scripts/ac-traceability-check.ps1, agent-flow/scripts/ac-traceability-check.sh, agent-flow/scripts/incremental-verify.ps1, agent-flow/scripts/incremental-verify.sh, agent-flow/scripts/check-change.sh, agent-flow/scripts/new-change.ps1, agent-flow/scripts/new-change.sh
Verify: PowerShell parser and Bash syntax check
Parallel: no

### T-05

Status: completed
Goal: Refresh test and sample behavior for AC-05.
AC: AC-05
read_files: agent-flow/test/test-scripts/test-new-change.ps1, agent-flow/test/test-scripts/test-new-change.sh, examples/sample-change/CODE_SCAN.md
write_files: agent-flow/test/test-scripts/test-new-change.ps1, agent-flow/test/test-scripts/test-new-change.sh, scripts/test-starter.ps1, scripts/test-starter.sh, examples/sample-change/CODE_SCAN.md, examples/sample-change/STATE.md, agent-flow/scripts/_common.ps1, agent-flow/scripts/_common.sh
Verify: test-new-change.ps1, test-new-change.sh, sample check-change
Parallel: no
