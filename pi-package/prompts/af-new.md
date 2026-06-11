---
description: agent-flow 新建 Change — 自动带日期前缀和项目标识
argument-hint: "<change-name> [flow] [prefix]"
---
# agent-flow New Change

> 自动创建 change 目录，带日期前缀和项目标识

Name: $1
Flow: ${2:-Standard}
Prefix: ${3:-auto-from-manifest}

## 执行
```bash
# Windows
agent-flow/scripts/new-change.ps1 -Name "$1" -Flow ${2:-Standard}

# Linux/macOS
bash agent-flow/scripts/new-change.sh --name "$1" --flow ${2:-Standard}
```

## 自动特性
- Change ID 格式：`YYYYMMDD-projectprefix-change-name`
- 日期前缀自动添加
- 项目前缀从 manifest.yaml 自动读取
- 按 Flow 级别创建对应工件模板
