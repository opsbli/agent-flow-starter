---
description: agent-flow CODE_SCAN — 快速代码优先扫描，生成 CODE_SCAN.md
argument-hint: "[需求描述]"
---
# agent-flow Code-First Scan

> 执行 agent-flow 的代码优先扫描，产出 CODE_SCAN.md

需求：$@

## 扫描步骤

1. **项目骨架** — 构建文件、入口、模块注册
2. **相似模块** — 查找现有类似能力
3. **数据库** — schema、迁移、种子数据
4. **测试** — 测试目录和风格
5. **安全** — 权限码、认证、敏感配置

使用 @ecc-explorer 加速扫描。完成后写 CODE_SCAN.md 到 `agent-flow/changes/<change-id>/`。
