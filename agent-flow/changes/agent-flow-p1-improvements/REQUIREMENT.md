# Requirement

## Background

af-team-review (2026-06-16) identified three improvement areas for agent-flow scaffold:
1. P1 — Frontend verification and Chrome DevTools debugging (scored 5.0-6.5/10)
2. P1 — Runtime API/permission drift detection (scored 7.5/10)
3. P2 — Database migration rollback verification (scored 6.5/10)

## Goals

- Add api-compatibility-check gate for DESIGN.md vs code API/permission drift detection
- Add db-migration-check gate for migration rollback SQL verification
- Enhance frontend-fit.md with Chrome DevTools debugging checklist
- Enhance DESIGN.md template with DB change decision table and frontend verification contract

## Non-Goals

- Not changing core routing logic (router.md)
- Not modifying existing gate exit codes or interfaces
- Not introducing external test framework dependencies
- Not modifying principles.md / source-of-truth.md / evolution.md

## Acceptance Criteria

| AC | Given | When | Then | Verification |
|----|-------|------|------|-------------|
| AC-01 | A change has DESIGN.md with API decisions | api-compatibility-check runs | It parses routes/permissions and reports warnings | Script syntax passes; SKIP on no DESIGN.md |
| AC-02 | A Heavy change has migration files in write_files | db-migration-check runs | It checks for rollback counterparts | Script syntax passes; SKIP on Light |
| AC-03 | New gates are created | check-change runs | Gates are invoked during check | scaffold-health pass |
| AC-04 | frontend-fit.md is updated | Read the file | Chrome DevTools checklist exists | File content verified |
| AC-05 | DESIGN.md template is updated | template-check runs | New tables exist | template-check pass |
