# Plan

> Plan Status: planned
> Last Reviewed: 2026-06-11
> Source: agent-flow/changes/p0-p1-starter-improvements/CHANGE.md

## Current Baseline

The starter already has Light/Standard/Heavy flow files, canonical ps1/sh scripts, starter self-tests, scaffold health checks, templates, knowledge files, and ADR storage. Gaps are execution quality and discoverability: manifest placeholder output is not actionable enough, `ac-check` is too loose, gate negative cases are thin, EVOLUTION suggestions lack a tracker, ADRs lack an index, README lacks a short path, and UI/interaction design evidence is not explicit.

## Goals

- Add actionable manifest placeholder guidance.
- Make `ac-check` validate `VERIFY.md` AC Evidence rows.
- Add core gate negative tests to starter self-test.
- Add improvement tracker and ADR index.
- Add README quick start and UI/demo design template sections.
- Keep changes generic and cross-platform.

## Non-Goals

- Do not add Medium flow.
- Do not add enterprise approval workflows, video docs, or default pre-commit hooks.
- Do not add business-project terms or history.

## Execution Phases

### Phase 1 - P0 gate precision

Status: completed

Scope:

- `manifest-check.ps1/.sh`
- `ac-check.ps1/.sh`
- starter self-test negative cases

read_files:

- agent-flow/scripts/manifest-check.ps1
- agent-flow/scripts/manifest-check.sh
- agent-flow/scripts/ac-check.ps1
- agent-flow/scripts/ac-check.sh
- scripts/test-starter.ps1
- scripts/test-starter.sh

write_files:

- agent-flow/scripts/manifest-check.ps1
- agent-flow/scripts/manifest-check.sh
- agent-flow/scripts/ac-check.ps1
- agent-flow/scripts/ac-check.sh
- scripts/test-starter.ps1
- scripts/test-starter.sh

Exit Criteria:

- Manifest placeholder values print categories and next steps.
- Missing or incomplete AC Evidence fails `ac-check`.
- Complete AC Evidence passes `ac-check`.
- Starter self-tests exercise positive and negative gate paths.

Verification:

- `agent-flow/scripts/manifest-check.ps1`
- `bash agent-flow/scripts/manifest-check.sh`
- `scripts/test-starter.ps1`
- `bash scripts/test-starter.sh`

### Phase 2 - P1 docs and tracking

Status: completed

Scope:

- quick-start docs
- design/evolution templates
- improvement tracker
- ADR index
- scaffold health required files
- minimal-project fixture sync

read_files:

- README.md
- agent-flow/README.md
- agent-flow/templates/DESIGN.md
- agent-flow/templates/EVOLUTION.md
- agent-flow/decisions/README.md
- agent-flow/scripts/scaffold-health.ps1
- agent-flow/scripts/scaffold-health.sh

write_files:

- README.md
- agent-flow/README.md
- agent-flow/templates/DESIGN.md
- agent-flow/templates/EVOLUTION.md
- agent-flow/knowledge/improvement-tracker.md
- agent-flow/decisions/README.md
- agent-flow/decisions/INDEX.md
- agent-flow/scripts/scaffold-health.ps1
- agent-flow/scripts/scaffold-health.sh
- agent-flow/test/fixtures/minimal-project

Exit Criteria:

- New files are included in scaffold health.
- Docs describe quick start, tracker, ADR index, UI flow, and demo evidence.
- Fixture carries the starter-owned updates.

Verification:

- `agent-flow/scripts/scaffold-health.ps1`
- `bash agent-flow/scripts/scaffold-health.sh`
- `scripts/test-starter.ps1`
- `bash scripts/test-starter.sh`

## Closure Gates

- [x] CODE_SCAN complete
- [x] DESIGN reviewed
- [x] design-check passed
- [x] alignment-check passed or explicitly skipped
- [x] TASKS bounded by read/write files
- [x] Plan Audit completed and plan-check passed
- [x] Verification passed
- [x] AC evidence recorded
- [x] Drift checks passed or adjudicated
- [x] Closure audit acceptable
- [x] Knowledge/decision/log/baseline updated

## Risks

- Stricter `ac-check` may break old changes that only mention AC ids outside `AC Evidence`.
- New fixture files can drift if future updates forget the fixture.
- Placeholder guidance remains advisory unless strict placeholder mode is used.

Mitigations:

- Starter self-tests now use the strict AC Evidence format.
- `scaffold-health` requires the new tracker and ADR index.
- `manifest-check` keeps warning/pass semantics by default.

## Protected Area Review

| Area | Touched | Approval / Reason |
|---|---|---|
| Schema | no | no runtime data changes |
| Auth / Permission | no | no security model changes |
| Public API | no | no API changes |
| Build / module registration | no | no build files changed |
| Deployment / production config | no | starter docs/scripts only |
| Destructive data operations | no | none |

## Deferred But Adjudicated

| Item | Classification | Reason |
|---|---|---|
| Medium flow | rejected | Adds routing complexity; current Light/Standard/Heavy with downgrade questions is sufficient. |
| `coverage-check` script | rejected | AC coverage belongs in strengthened `ac-check` and `VERIFY.md`. |
| `REQUIREMENT_ALIGNED.md` | rejected | Alignment belongs in existing `DESIGN.md` section. |
| `DEMO_RECORD.md` | rejected | Demo evidence belongs in `DESIGN.md` and `VERIFY.md` first. |
