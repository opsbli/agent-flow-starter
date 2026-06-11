---
description: ECC Build Fix — analyze and resolve build/compilation errors
argument-hint: "[error text or blank for last error]"
---
# ECC Build Fix

> Based on ECC's build-fix command and build-error-resolver agent

${1:-Analyze recent build output for errors}

## Process

1. **Identify** — Capture exact error message and location
2. **Read** — Read the failing code, not just the error
3. **Root Cause** — Trace symptom → cause
4. **Fix** — Apply minimal surgical change
5. **Verify** — Rebuild and confirm

Run:
```bash
# Capture latest build error
npm run build 2>&1 | tail -30
# Or language-specific
tsc --noEmit 2>&1 | head -20
cargo build 2>&1 | head -20
go build ./... 2>&1
```

## Common Fixes by Language

| Error Pattern | Likely Fix |
|--------------|------------|
| Missing import | Add or install the dependency |
| Type mismatch | Fix type annotation or cast |
| Module not found | Check path, install package |
| Cannot find name | Add `@types/` package |
| Lifetime error (Rust) | Add lifetime parameter or clone |
