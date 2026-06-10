# Change: sample-status-label

## One-Sentence Requirement

Update an example list page so archived items display a stable `Archived` status label.

## Flow Level

- [x] Light
- [ ] Standard
- [ ] Heavy

## Classification Reason

This is a low-risk UI copy/rendering change. It does not touch schema, auth, public API contracts, workflow/state machines, deployment, or cross-module boundaries.

## Goals

- Display `Archived` when an item status is `archived`.
- Keep existing status behavior unchanged.
- Record AC evidence in `VERIFY.md`.

## Non-Goals

- No API changes.
- No database changes.
- No permission changes.

## Artifact Index

- Requirement: `REQUIREMENT.md`
- Code Scan: `CODE_SCAN.md`
- Verify: `VERIFY.md`
- Report: `REPORT.md`

