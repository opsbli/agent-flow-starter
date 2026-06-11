---
description: agent-flow 验证 — 运行质量门禁 + 代码审查 + 安全扫描
argument-hint: "[change-id 或路径]"
---
# agent-flow Verify

> 执行 agent-flow 的验证步骤，产出 VERIFY.md

${1:-.}

## 验证链

### 1. 类型检查
```bash
test -f tsconfig.json && npx tsc --noEmit
```

### 2. 测试
```bash
npm test 2>&1 || cargo test 2>&1 || go test ./... 2>&1
```

### 3. 代码审查 — 使用 /ecc-review
审查所有变更，写入 REVIEW.md

### 4. 安全扫描 — 使用 /ecc-security ${1:-.}
扫描密钥和漏洞

### 5. 质量门禁 — 使用 /ecc-quality ${1:-.}
运行完整检查链

### 6. agent-flow 门禁
运行对应 check 脚本

完成后写 VERIFY.md，绑定每项 AC 的验证证据。
