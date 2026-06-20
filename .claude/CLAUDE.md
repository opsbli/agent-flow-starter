# Claude Code — agent-flow 流程指令

本文件由 Claude Code 自动加载为项目上下文。
核心入口为 `AGENTS.md`，本文件仅补充 Claude Code 专属适配。

---

## 入口指令

收到任何开发需求后，**必须先读取 `agent-flow/GO.md` 并按路由执行**。
不允许直接进入编码、设计或分析。

流程纪律、违规召回、默认取向（12条）详见 `AGENTS.md`。

## 可用命令

### agent-flow 脚本
```bash
# 创建新 change
bash agent-flow/scripts/new-change.sh --name <change-id> --flow Standard

# 门禁检查
bash agent-flow/scripts/scan-check.sh --change-dir agent-flow/changes/<change-id> --strict
bash agent-flow/scripts/design-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/alignment-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/task-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/evolution-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id>

# 下一步
bash agent-flow/scripts/next-step.sh --change-dir agent-flow/changes/<change-id>
```

### 常用 prompt 模板
```
按 agent-flow 流程处理这个需求：<需求内容>。
先做 code-first 扫描，判断 Light/Standard/Heavy，然后给我 CHANGE 和执行计划。
```

## 注意事项

- Claude Code 自动加载本文件和 `AGENTS.md`
- 首次使用建议先运行 `bash agent-flow/scripts/scaffold-health.sh` 确认脚手架状态
- Windows 环境使用 `powershell` 运行 `.ps1` 版本脚本
