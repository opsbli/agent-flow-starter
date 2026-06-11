---
description: ECC Quality Gate — run full quality checks: typecheck, lint, test, build, security
argument-hint: "[path]"
---
# ECC Quality Gate

> Based on ECC's quality-gate command

Target: ${1:-.}

## Gate Sequence

### 1. TypeScript Check
```bash
test -f tsconfig.json && npx tsc --noEmit 2>&1 || echo "No tsconfig"
```

### 2. Lint
```bash
test -f .eslintrc* && npx eslint ${1:-.} 2>&1 || echo "No eslint config"
test -f biome.json && npx biome check ${1:-.} 2>&1 || true
```

### 3. Tests
```bash
# Try common test runners
npm test 2>&1 || npx vitest run 2>&1 || npx jest 2>&1 || echo "No test command"
```

### 4. Build
```bash
npm run build 2>&1 || cargo build 2>&1 || go build ./... 2>&1 || echo "No build command"
```

### 5. Security
```bash
# Secrets scan
grep -rn 'sk-[A-Za-z0-9]\|ghp_[A-Za-z0-9]\|-----BEGIN.*PRIVATE KEY-----' \
  --include="*.{ts,js,py,go,rs}" . 2>/dev/null | grep -v node_modules | grep -v '.test.' || echo "No secrets found"

# Deps audit
npm audit --audit-level=high 2>&1 || echo "No npm audit"
```

## Report
Gate **PASS** only if ALL checks pass. List each failure with fix suggestion.
