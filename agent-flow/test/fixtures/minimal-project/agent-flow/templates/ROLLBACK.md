# Rollback Plan

> Use this template when a completed change needs to be rolled back.
> Heavy changes should include rollback steps before merging.

## Change

- Change ID: `{change-id}`
- Rollback requested by:
- Date:

## Scope of Rollback

- [ ] Full rollback (revert all files)
- [ ] Partial rollback (revert specific files/modules)

## Files to Revert

| File | Revert Strategy | Risk |
|---|---|---|

## Data / Schema Rollback

- [ ] No schema change
- [ ] Migration rollback: `{command}`
- [ ] Data fix: `{description}`

## Permission / Config Rollback

- [ ] No permission/config change
- [ ] Permission revert: `{details}`
- [ ] Config revert: `{details}`

## Verification After Rollback

| Check | Command | Expected |
|---|---|---|

## Rollback Verification

- [ ] Rollback compile passed
- [ ] Tests passed
- [ ] Schema reverted
- [ ] Permissions restored
- [ ] Manual smoke test passed

## Rollback History

| Date | Action | By |
|---|---|---|
