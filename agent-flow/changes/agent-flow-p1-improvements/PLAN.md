# Plan

Plan Status: completed

## Current Baseline

- Agent-flow v9.0+ scaffold with ~50 gate scripts, ~20 templates
- af-team-review identified gaps in frontend verification (5.0/10), API drift detection (7.5/10), DB migration check (6.5/10)

## Goals

1. AC-01: api-compatibility-check gate for API/permission drift
2. AC-02: db-migration-check gate for rollback SQL verification
3. AC-03: Register new gates in manifest.yaml, gates.txt, check-change
4. AC-04: Chrome DevTools checklist in frontend-fit.md
5. AC-05: DB change decision table + frontend verification contract in DESIGN.md

## Non-Goals

- No routing/principle/source-of-truth changes
- No external dependencies

## Execution Phases

### Phase 1: Gate scripts

- Status: completed
- Scope: Create api-compatibility-check.ps1/.sh, db-migration-check.ps1/.sh
- read_files: code-drift-check.ps1/.sh, blocked-check.ps1/.sh, _common.ps1/.sh
- write_files: 4 new script files
- Exit criteria: PowerShell + Bash syntax pass

### Phase 2: Gate registration

- Status: completed
- Scope: Register in manifest.yaml, gates.txt, check-change.ps1, check-change.sh
- read_files: manifest.yaml, gates.txt, check-change.ps1, check-change.sh
- write_files: manifest.yaml, gates.txt, check-change.ps1, check-change.sh
- Exit criteria: scaffold-health pass

### Phase 3: Documentation enhancement

- Status: completed
- Scope: Enhance frontend-fit.md + DESIGN.md template
- read_files: frontend-fit.md, DESIGN.md template
- write_files: frontend-fit.md, DESIGN.md template
- Exit criteria: template-check pass

## Closure Gates

- [x] scaffold-health pass
- [x] template-check pass
- [x] manifest-check pass
- [x] evolution-check pass

## Risks

- New gates are heuristic → non-blocking warning mode
- Frontend checklist is reference-only, not enforced

## Protected Area Review

- [x] Current baseline checked against live code
- [x] Goals and Non-Goals are clear
- [x] Code scan lists similar implementations
- [x] Design check passed
- [x] Design Alignment completed
- [x] Protected areas identified (frontend-fit.md, DESIGN.md, manifest.yaml)
- [x] read_files/write_files bounded
- [x] Execution phases have exit criteria
- [x] Closure gates are verifiable
- [x] Risks have mitigations

## Deferred But Adjudicated

- frontend_verify_required toggle in manifest.yaml → deferred to future change
- design-quality-check gate → needs separate design phase

## Plan Audit Verdict

accept

- Reviewer: AI Agent (self-review via af-team-review process)
- Date: 2026-06-16
