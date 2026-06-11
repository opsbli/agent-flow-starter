---
description: agent-flow 自动设计 — 从 CODE_SCAN.md 生成 DESIGN.md + TASKS.md
argument-hint: "<change-id>"
---
# agent-flow Auto Design

> 从 CODE_SCAN.md 自动生成 DESIGN.md 和 TASKS.md

Change: $1

## 自动执行链

### 1. 生成 DESIGN.md
```bash
# Windows
agent-flow/scripts/generate-design.ps1 -ChangeDir agent-flow/changes/$1

# Linux/macOS
bash agent-flow/scripts/generate-design.sh --change-dir agent-flow/changes/$1
```

### 2. 使用 @ecc-architect 完善设计
`@ecc-architect 根据 CODE_SCAN.md 和项目代码，完善 DESIGN.md 的以下部分：`

- 模块边界和数据模型
- API 路径和权限
- Service 编排和调用链
- 安全设计

### 3. 参考设计模式
- /skill:api-design (API 设计)
- /skill:backend-patterns (后端架构)
- /skill:database-migrations (数据模型)
- /skill:error-handling (错误处理)

### 4. 生成 TASKS.md
```bash
# Windows
agent-flow/scripts/generate-tasks.ps1 -ChangeDir agent-flow/changes/$1

# Linux/macOS
bash agent-flow/scripts/generate-tasks.sh --change-dir agent-flow/changes/$1
```

### 5. 运行门禁
```bash
# Windows
agent-flow/scripts/design-check.ps1 -ChangeDir agent-flow/changes/$1
agent-flow/scripts/task-check.ps1 -ChangeDir agent-flow/changes/$1

# Linux/macOS
bash agent-flow/scripts/design-check.sh --change-dir agent-flow/changes/$1
bash agent-flow/scripts/task-check.sh --change-dir agent-flow/changes/$1
```

## 输出
- DESIGN.md — 架构设计
- TASKS.md — 任务分解
- 设计门禁通过
