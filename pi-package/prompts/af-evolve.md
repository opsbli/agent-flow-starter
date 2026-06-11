---
description: agent-flow 自动演进 — 数据驱动的 EVOLUTION.md 生成和改进建议
argument-hint: "[change-id]"
---
# agent-flow Auto Evolution

> 基于数据驱动的流程改进分析

## 1. 查看项目统计
```bash
# Windows
agent-flow/scripts/evolution-stats.ps1

# Linux/macOS
bash agent-flow/scripts/evolution-stats.sh
```

## 2. 获取改进建议
```bash
# Windows
agent-flow/scripts/evolution-suggest.ps1

# Linux/macOS
bash agent-flow/scripts/evolution-suggest.sh
```

## 3. 撰写 EVOLUTION.md

如果提供了 change-id，写 `agent-flow/changes/$1/EVOLUTION.md`，覆盖四个推演维度：

### 架构推演
- 是否出现新的公共能力候选？
- 是否出现循环依赖或隐性耦合？

### 流程推演
- 本次哪些步骤有价值？哪些只是形式主义？
- 是否应该降级或升级某类任务？

### 验证推演
- 哪个错误差点漏掉？
- 是否能写成 gate 脚本？

### 模板推演
- 哪个模板字段多余或缺失？

## 4. 更新改进跟踪
`agent-flow/knowledge/improvement-tracker.md`

## 输出
- EVOLUTION.md — 演进记录
- 改进跟踪已更新
