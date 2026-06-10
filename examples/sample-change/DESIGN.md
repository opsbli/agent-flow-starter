# Design

## Design Goal

Add one status mapping while preserving the existing renderer.

## API / Permission / Auth Decision

| Item | Decision | Notes |
|---|---|---|
| REST Path | unchanged | No route change |
| HTTP Method | unchanged | No route change |
| Permission Code | not added | UI-only label change |
| Auth / Token | unchanged | No auth behavior change |
| Anonymous Interface | not added | No public endpoint change |

## Status Machine

Not a workflow/state-machine change. This is a display mapping only.

## Test Strategy

| AC | Test File | Test Method | Type |
|---|---|---|---|
| AC-01 | `tests/status-label.test.ts` | renders archived label | unit |
| AC-02 | `tests/status-label.test.ts` | preserves active/disabled labels | regression |

