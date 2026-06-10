# Requirement

## Background

Users can see list items with different statuses. The project already handles active and disabled states. Archived items need a clear label.

## Acceptance Criteria

Numbering must use `AC-01` format so `ac-check` can find it.

| AC | Given | When | Then | Verification |
|---|---|---|---|---|
| AC-01 | An item has `status=archived` | The list renders | The row displays `Archived` | Unit or component test |
| AC-02 | An item has an existing status | The list renders | Existing status labels stay unchanged | Regression test or manual check |

## Boundaries

- No schema change.
- No API route change.
- No permission or auth change.

