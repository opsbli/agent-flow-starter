---
description: agent-flow 自动报告 — 聚合所有工件和检查结果生成 REPORT.md
argument-hint: "<change-id>"
---
# agent-flow Auto Report

> 从所有 change 工件自动生成 REPORT.md + 运行 evolution-check

Change: $1

## 自动执行链

### 1. 生成 REPORT.md
```bash
# Windows
agent-flow/scripts/generate-report.ps1 -ChangeDir agent-flow/changes/$1

# Linux/macOS
bash agent-flow/scripts/generate-report.sh --change-dir agent-flow/changes/$1
```

### 2. 运行收口检查
```bash
# Windows
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/$1 -Closure -OutputPath agent-flow/changes/$1/CHECK_RESULT.json
agent-flow/scripts/evolution-check.ps1 -ChangeDir agent-flow/changes/$1

# Linux/macOS
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/$1 --closure --output agent-flow/changes/$1/CHECK_RESULT.json
bash agent-flow/scripts/evolution-check.sh --change-dir agent-flow/changes/$1
```

### 3. AI 辅助填充
`@ecc-reviewer 审查所有变更，写 REVIEW.md`

`/skill:continuous-learning-v2 提取本次经验`

### 4. 更新知识
- 新增坑点 → `agent-flow/knowledge/pitfalls.md`
- 更新模块地图 → `agent-flow/knowledge/module-map.md`
- 如涉及不可逆决策 → 写 ADR 到 `agent-flow/decisions/`

## 输出
- REPORT.md — 交付报告
- REVIEW.md — 代码审查记录
- CHECK_RESULT.json — 门禁汇总
- 知识沉淀已完成
