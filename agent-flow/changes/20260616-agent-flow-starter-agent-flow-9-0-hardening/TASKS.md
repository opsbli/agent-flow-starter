# Tasks

## Execution Principles

- Each task must stay inside the declared `write_files`.
- Each completed task must map to AC evidence in `VERIFY.md`.
- Script pairs must be kept in sync whenever behavior applies to both platforms.

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel |
|---|---|---|---|---|---|---|
| T001 | completed | AC-01 AC-06 | `agent-flow/scripts/install-agent-flow.*`, `scripts/test-starter.*` | `agent-flow/scripts/install-agent-flow.ps1`, `agent-flow/scripts/install-agent-flow.sh`, `scripts/test-starter.ps1`, `scripts/test-starter.sh` | `scripts/test-starter.ps1`; `bash scripts/test-starter.sh` | no |
| T002 | completed | AC-02 AC-06 | `agent-flow/scripts/alignment-check.*`, `agent-flow/templates/DESIGN.md`, `agent-flow/scripts/generate-design.*`, `scripts/test-starter.*` | `agent-flow/scripts/alignment-check.ps1`, `agent-flow/scripts/alignment-check.sh`, `agent-flow/templates/DESIGN.md`, `agent-flow/scripts/generate-design.ps1`, `agent-flow/scripts/generate-design.sh`, `agent-flow/flows/standard.md`, `scripts/test-starter.ps1`, `scripts/test-starter.sh` | `alignment-check.*`; root self-tests | no |
| T003 | completed | AC-03 AC-06 | `agent-flow/scripts/init-project.*`, `scripts/test-starter.*` | `agent-flow/scripts/init-project.ps1`, `agent-flow/scripts/init-project.sh`, `scripts/test-starter.ps1`, `scripts/test-starter.sh` | root starter self-tests | no |
| T004 | completed | AC-04 AC-06 | `agent-flow/scripts/check-change.*`, `agent-flow/scripts/sync-state.*`, `_common.*`, `scripts/test-starter.*` | `agent-flow/scripts/check-change.ps1`, `agent-flow/scripts/check-change.sh`, `agent-flow/scripts/sync-state.ps1`, `agent-flow/scripts/sync-state.sh`, `scripts/test-starter.ps1`, `scripts/test-starter.sh` | root starter self-tests and closure check-change | no |
| T005 | completed | AC-05 AC-06 | `.github/workflows/scaffold-ci.yml` | `.github/workflows/agent-flow-starter-check.yml`, `agent-flow/knowledge/known-good-baselines.md`, `agent-flow/logs/2026/06-16.md` | `rg --files .github/workflows` | yes |

## write_files Summary

write_files:
  - agent-flow/scripts/install-agent-flow.ps1
  - agent-flow/scripts/install-agent-flow.sh
  - agent-flow/scripts/alignment-check.ps1
  - agent-flow/scripts/alignment-check.sh
  - agent-flow/scripts/init-project.ps1
  - agent-flow/scripts/init-project.sh
  - agent-flow/scripts/check-change.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/sync-state.ps1
  - agent-flow/scripts/sync-state.sh
  - agent-flow/templates/DESIGN.md
  - agent-flow/scripts/generate-design.ps1
  - agent-flow/scripts/generate-design.sh
  - agent-flow/flows/standard.md
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - agent-flow/knowledge/known-good-baselines.md
  - agent-flow/logs/2026/06-16.md
  - .github/workflows/agent-flow-starter-check.yml

## Task Details

### T001 - Install hygiene

Status: completed

Goal: New installs must not copy starter-local history directories into target projects.

AC: AC-01 AC-06

read_files:
  - agent-flow/scripts/install-agent-flow.ps1
  - agent-flow/scripts/install-agent-flow.sh
  - scripts/test-starter.ps1
  - scripts/test-starter.sh

write_files:
  - agent-flow/scripts/install-agent-flow.ps1
  - agent-flow/scripts/install-agent-flow.sh
  - scripts/test-starter.ps1
  - scripts/test-starter.sh

Verify: `scripts/test-starter.ps1`; `bash scripts/test-starter.sh`

Parallel: no

### T002 - Alignment semantics

Status: completed

Goal: Make alignment gate enforce at least three `user-confirmed` rows.

AC: AC-02 AC-06

read_files:
  - agent-flow/scripts/alignment-check.ps1
  - agent-flow/scripts/alignment-check.sh
  - agent-flow/templates/DESIGN.md
  - agent-flow/scripts/generate-design.ps1
  - agent-flow/scripts/generate-design.sh
  - agent-flow/flows/standard.md
  - scripts/test-starter.ps1
  - scripts/test-starter.sh

write_files:
  - agent-flow/scripts/alignment-check.ps1
  - agent-flow/scripts/alignment-check.sh
  - agent-flow/templates/DESIGN.md
  - agent-flow/scripts/generate-design.ps1
  - agent-flow/scripts/generate-design.sh
  - agent-flow/flows/standard.md
  - scripts/test-starter.ps1
  - scripts/test-starter.sh

Verify: `alignment-check.*`; root self-tests

Parallel: no

### T003 - Init parity

Status: completed

Goal: Make bash init missing-dir behavior match PowerShell.

AC: AC-03 AC-06

read_files:
  - agent-flow/scripts/init-project.ps1
  - agent-flow/scripts/init-project.sh
  - scripts/test-starter.ps1
  - scripts/test-starter.sh

write_files:
  - agent-flow/scripts/init-project.ps1
  - agent-flow/scripts/init-project.sh
  - scripts/test-starter.ps1
  - scripts/test-starter.sh

Verify: root starter self-tests

Parallel: no

### T004 - Closure strictness

Status: completed

Goal: Make closure-mode `check-change` fail on required missing artifacts.

AC: AC-04 AC-06

read_files:
  - agent-flow/scripts/check-change.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/sync-state.ps1
  - agent-flow/scripts/sync-state.sh
  - agent-flow/scripts/_common.ps1
  - agent-flow/scripts/_common.sh
  - scripts/test-starter.ps1
  - scripts/test-starter.sh

write_files:
  - agent-flow/scripts/check-change.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/sync-state.ps1
  - agent-flow/scripts/sync-state.sh
  - scripts/test-starter.ps1
  - scripts/test-starter.sh

Verify: root starter self-tests and closure check-change

Parallel: no

### T005 - CI dedupe

Status: completed

Goal: Remove duplicate starter self-test workflow.

AC: AC-05 AC-06

read_files:
  - .github/workflows/scaffold-ci.yml

write_files:
  - .github/workflows/agent-flow-starter-check.yml
  - agent-flow/knowledge/known-good-baselines.md
  - agent-flow/logs/2026/06-16.md

Verify: `rg --files .github/workflows`

Parallel: yes
