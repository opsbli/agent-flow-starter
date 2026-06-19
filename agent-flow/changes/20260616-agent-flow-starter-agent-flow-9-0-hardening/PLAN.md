# Plan

> Plan Status: planned
> Last Reviewed: 2026-06-16
> Source: agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening/CHANGE.md

## Current Baseline

The scaffold self-tests pass on both Windows and bash, but the review identified contract gaps in install hygiene, alignment semantics, init parity, closure aggregation, and CI duplication.

## Goals

- Implement AC-01 through AC-06 without adding dependencies.
- Keep the existing flow shape and script pairs.
- Preserve target project-owned data during upgrades.

## Non-Goals

- No router redesign.
- No application runtime code.
- No new parser dependency.

## Execution Phases

### Phase 1 - Install and Init Contracts

Status: planned

Scope: fix distribution hygiene and bash init missing-dir semantics.

read_files: `agent-flow/scripts/install-agent-flow.*`, `agent-flow/scripts/init-project.*`, `scripts/test-starter.*`

write_files: `agent-flow/scripts/install-agent-flow.*`, `agent-flow/scripts/init-project.*`, `scripts/test-starter.*`

Exit Criteria: clean install directories and empty-project placeholder behavior are covered by tests.

Verification: root starter self-tests.

### Phase 2 - Gate Contract Hardening

Status: planned

Scope: enforce user-confirmed alignment and closure required artifacts.

read_files: `alignment-check.*`, `check-change.*`, `_common.*`, templates and self-tests.

write_files: `alignment-check.*`, `check-change.*`, `templates/DESIGN.md`, `generate-design.*`, `scripts/test-starter.*`

Exit Criteria: positive and negative gate tests pass.

Verification: root starter self-tests.

### Phase 3 - CI Ownership

Status: planned

Scope: remove duplicate workflow.

read_files: `.github/workflows/scaffold-ci.yml`

write_files: `.github/workflows/agent-flow-starter-check.yml`

Exit Criteria: only the comprehensive scaffold workflow remains.

Verification: `rg --files .github/workflows`

## Closure Gates

- [ ] CODE_SCAN complete
- [ ] DESIGN reviewed
- [ ] design-check passed
- [ ] alignment-check passed
- [ ] TASKS bounded by read/write files
- [ ] Plan Audit completed and plan-check passed
- [ ] Verification passed
- [ ] AC evidence recorded
- [ ] Drift checks passed or adjudicated
- [ ] Closure audit acceptable
- [ ] Knowledge/log/baseline updated or explicitly not needed

## Risks

- Existing fixtures with `confirmed` must be migrated to `user-confirmed`.
- Install hygiene must still seed knowledge and decisions.
- Closure strictness must apply only when closure mode is requested.

## Protected Area Review

| Area | Touched | Approval / Reason |
|---|---|---|
| deployment / CI | yes | Workflow deduplication is part of AC-05 and limited to duplicate workflow removal. |
| root build files | no | No build files are modified. |
| schema/auth/API | no | No runtime protected areas touched. |

## Deferred But Adjudicated

| Item | Classification | Reason |
|---|---|---|
| Full bash `project-profiles.json` parser | deferred | AC-03 only requires missing-dir parity; adding a JSON parser would introduce dependency risk. |
