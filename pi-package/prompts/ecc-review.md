---
description: ECC Code Review — inspect staged/local changes or PR (pass PR number for PR mode)
argument-hint: "[pr-number | pr-url | blank for local]"
---
# ECC Code Review

> Based on ECC's code-review command and code-reviewer agent

$ARGUMENTS

## Mode Selection

If `$1` contains a PR number or URL:
→ Use **PR Review Mode**

Otherwise:
→ Use **Local Review Mode**

## Local Review Mode

### Phase 1 — Gather
```bash
git diff --staged
git diff
git log --oneline -5
```

### Phase 2 — Review Checklist
- **CRITICAL**: Logic errors, security vulnerabilities, data loss
- **HIGH**: Error handling gaps, race conditions, resource leaks
- **MEDIUM**: Code duplication, missing edge cases, test gaps
- **LOW**: Style, naming, documentation

### Phase 3 — Report
Only report issues >80% confidence. Format:

```
## [CRITICAL|HIGH|MEDIUM|LOW] title
**File**: `path:line`
**Problem**: what
**Fix**: specific change
```

## PR Review Mode
For $1: fetch PR details, review diff, check for merge conflicts, verify CI status.
