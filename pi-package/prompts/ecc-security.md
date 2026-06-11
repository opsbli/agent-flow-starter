---
description: ECC Security Scan — scan for vulnerabilities, secrets, and OWASP Top 10 issues
argument-hint: "[path]"
---
# ECC Security Scan

> Based on ECC's security-scan command and security-reviewer agent

Target: ${1:-.}

## Scan Commands

### Secrets Detection
```bash
grep -rn 'sk-[A-Za-z0-9]\{20,\}\|ghp_[A-Za-z0-9]\{36,\}\|AKIA[0-9A-Z]\{16\}\|-----BEGIN.*PRIVATE KEY-----\|xox[baprs]-[a-zA-Z0-9]\{10,\}' \
  --include="*.{ts,js,py,go,rs,java,kt,rb,php,yml,yaml,json,toml,sh}" ${1:-.} \
  2>/dev/null | grep -v node_modules | grep -v '.test.' | grep -v '.spec.'
```

### Dangerous Patterns
```bash
grep -rn 'eval(\|exec(\|child_process\|innerHTML\|dangerouslySetInnerHTML\|raw(\|unsafe\|\${{' \
  --include="*.{ts,tsx,js,jsx,py,go}" ${1:-.} \
  2>/dev/null | grep -v node_modules | grep -v '.test.'
```

### Dependency Audit
```bash
npm audit 2>&1 | head -30
```

## Categories to Check

| Category | Examples |
|----------|----------|
| CRITICAL | Hardcoded secrets, SQL injection, RCE |
| HIGH | XSS, CSRF, SSRF, path traversal, broken auth |
| MEDIUM | Missing validation, weak crypto, info disclosure |

Report findings with file:line references and specific fix recommendations.
