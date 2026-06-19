# Design

Decision Status: accepted

## Design Summary

Fix the existing gate implementations in place. Keep each Windows and Bash pair behaviorally aligned, prefer narrow parser changes over new dependencies, and use the current smoke tests plus direct command repros as regression coverage.

## Design Decisions

| Item | Decision | Evidence |
|---|---|---|
| REST Path | not-applicable | AC-01 through AC-05 affect local scripts only |
| HTTP Method | not-applicable | AC-01 through AC-05 do not touch application APIs |
| Permission Code | not-applicable | AC-01 through AC-05 do not add auth or permission codes |
| SaCheckPermission | not-applicable | No Java permission annotations involved |
| Anonymous Interface | not-applicable | No runtime API exposure involved |
| Login/Token | not-applicable | No login or token behavior involved |
| Tenant/Data Permission | not-applicable | No tenant or data permission behavior involved |
| State Machine Impact | no | Script gate execution has no product state machine |

State Machine Impact: no

## Approach

- AC-01: Correct aggregate gate invocation in `check-change.ps1` and `check-change.sh`, including `ac-traceability-check`.
- AC-02: Accept optional inline comments after `blocked_if` rule values in `manifest-check.ps1` and `.sh`.
- AC-03: Strip YAML wrapping quotes only when the whole command value is quoted, preserving internal command quotes in `run-verify.ps1` and `.sh`.
- AC-04: Replace corrupted status strings in `ac-traceability-check` and `incremental-verify` with ASCII status labels; remove the BOM from `check-change.sh`.
- AC-05: Update `examples/sample-change/CODE_SCAN.md` and add `examples/sample-change/STATE.md` so the sample passes current aggregate checks.

## API / Permission / Auth 决策

| Area | Decision | Evidence |
|---|---|---|
| API | unchanged | No application API files in write set |
| Permission | unchanged | No permission declarations in write set |
| Auth | unchanged | No auth or token files in write set |

## Data / Schema

No database schema, seed, migration, or production data changes.

## Compatibility

- Existing manifest `blocked_if` values without comments remain accepted.
- Existing commands that are fully YAML-quoted remain unwrapped.
- Existing commands with internal quotes are preserved.
- Existing generated change ids may include date and project prefixes; tests now assert by suffix instead of hard-coded full id.

## Design Alignment / Grill

Alignment Source: mixed
Open Questions: none

Alignment Verdict: skipped
Skip Reason: User explicitly requested ordered repair of confirmed script failures; code facts and command repros already identify the required fixes.

## AC Trace

| AC | Design Coverage |
|---|---|
| AC-01 | Aggregate runner invocation repair |
| AC-02 | Manifest inline-comment parser repair |
| AC-03 | Verification command quote-preservation repair |
| AC-04 | Syntax and encoding hardening |
| AC-05 | Runnable sample refresh |
