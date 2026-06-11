---
description: ECC Refactor — find dead code, reduce duplication, improve structure
argument-hint: "[path or description]"
---
# ECC Refactor

> Based on ECC's refactor-clean command

Focus: ${1:-Scan current directory for improvement opportunities}

## Refactoring Targets

1. **Dead code** — unused functions, variables, imports, exports
2. **Duplication** — DRY violations, repeated patterns
3. **Complexity** — deep nesting, long functions, high cyclomatic complexity
4. **Naming** — unclear, inconsistent, misleading names
5. **Types** — `any` usage, missing types, incorrect types
6. **Error handling** — missing try/catch, swallowed errors, empty catch blocks

## Rules
- One focused change at a time
- Keep existing code style
- Don't change behavior
- Run tests after each change

## Scan commands
```bash
# Find potential dead exports
grep -rn '^export' --include="*.ts" . | head -20

# Find long functions
grep -rn '^\s*\(async\s\+\)\?function\s\+\w\+' --include="*.ts" . | head -20
```
