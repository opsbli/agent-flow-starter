---
description: ECC Checkpoint — save verification state and create a restoration point
argument-hint: "[description]"
---
# ECC Checkpoint

> Based on ECC's checkpoint command

Description: ${1:-work-in-progress}

## Save Current State

1. Record current branch and commit:
```bash
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
```

2. Check for uncommitted changes:
```bash
git status --short
```

3. Stash if needed:
```bash
git stash push -m "checkpoint: ${1:-wip}"
```

## Verification
- [ ] TypeScript compiles: `npx tsc --noEmit`
- [ ] Tests pass: `npm test`
- [ ] Lint passes: `npx eslint .`
- [ ] Build succeeds: `npm run build`

## Restoration
To restore later: `git stash pop` or `git checkout $(git rev-parse HEAD)`
