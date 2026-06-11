---
description: agent-flow 清理扫描 — 检测未使用脚本、模板和空知识文件
argument-hint: "[change-id]"
---
# agent-flow Cleanup Scan

> 自动检测项目中未使用的脚本、模板和空知识文件

## 运行清理扫描
```bash
# Windows
agent-flow/scripts/detect-unused.ps1

# Linux/macOS
bash agent-flow/scripts/detect-unused.sh
```

## 输出说明
| 状态 | 含义 | 建议 |
|------|------|------|
| UNUSED | 从未被引用 | 审查后归档或删除 |
| EMPTY | 空文件（≤3行） | 填充内容或删除 |
| STALE | 超过90天未更新 | 审查是否需要更新 |

## 建议
定期运行清理扫描，保持项目简洁。
