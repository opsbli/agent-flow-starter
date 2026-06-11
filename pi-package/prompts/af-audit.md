---
description: agent-flow 自动审计 — 从现有工件生成 AUDIT.md
argument-hint: "<change-id>"
---
# agent-flow Auto Audit

> 从现有工件自动填充 Plan Audit + Closure Audit 检查清单

Change: $1

## 1. 生成 AUDIT.md 骨架
```bash
# Windows
agent-flow/scripts/generate-audit.ps1 -ChangeDir agent-flow/changes/$1

# Linux/macOS
bash agent-flow/scripts/generate-audit.sh --change-dir agent-flow/changes/$1
```

## 2. AI 辅助完善
`@ecc-reviewer 审查设计方案的完整性和风险`

`/skill:security-review 评估安全风险`

## 3. 手动完成
- 指派 Reviewer
- 填写 Findings
- 设置 Verdict (accept/conditional/reject)

## 输出
- AUDIT.md — 审计记录（Plan Audit + Closure Audit）
- Verdict 决定是否可以进入下一阶段
