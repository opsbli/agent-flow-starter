---
description: agent-flow 增量验证 — 只检查变更文件相关的项目
argument-hint: "[change-id]"
---
# agent-flow Incremental Verify

> 只对你改动的文件运行相关检查，快速反馈

## 运行增量验证
```bash
# Windows
agent-flow/scripts/incremental-verify.ps1

# Linux/macOS
bash agent-flow/scripts/incremental-verify.sh
```

## 自动检测
脚本会自动识别改动文件的类型，只运行相关检查：
- `.ts/.tsx` → TypeScript check + ESLint
- `.go` → go vet + go build
- `.rs` → cargo check
- `.py` → python syntax compile
- 所有改动文件 → secrets scan + console.log check

## 如果失败
修复后重新运行 `incremental-verify` 直到全绿。
