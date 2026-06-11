---
description: agent-flow 紧急通道 — 自动生成 CANCEL.md + ROLLBACK.md
argument-hint: "<change-id>"
---
# agent-flow Emergency

> P0/P1 生产事故通道。Bypass 标准流程，事后 24h 回填。

Change: $1

## 1. 确认紧急条件
- [ ] 系统正在发生可量化的损失（用户/数据/收入）
- [ ] 标准流程会导致损失扩大
- [ ] 风险等级为 P0/P1
- [ ] 有权限的负责人已批准 bypass

## 2. 生成紧急模板
```bash
# Windows
agent-flow/scripts/generate-emergency.ps1 -ChangeDir agent-flow/changes/$1

# Linux/macOS
bash agent-flow/scripts/generate-emergency.sh --change-dir agent-flow/changes/$1
```

## 3. 实现修复
按 Emergency 流程实施修复。完成后：
- 编辑 CANCEL.md（如放弃）或 ROLLBACK.md（如回滚）
- 运行 `emergency-check`

## 4. 事后回填
24 小时内必须补全：
- `agent-flow/scripts/emergency-check.ps1 -ChangeDir agent-flow/changes/$1`
- 更新 knowledge/pitfalls.md
- 写 EVOLUTION.md 复盘
