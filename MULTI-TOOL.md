# 多工具适配指南

> 本项目的 agent-flow 流程支持所有主流 AI 编码工具。
> 每个工具读取项目上下文的方式不同，下表说明如何在各工具中启用 agent-flow。

---

## 工具适配一览

| 工具 | 读取的配置文件 | 启用方式 | 状态 |
|------|---------------|---------|------|
| **pi agent** | `.pi/APPEND_SYSTEM.md` + `AGENTS.md` | 自动加载 | ✅ 原生支持 |
| **Claude Code** | `.claude/CLAUDE.md` + `AGENTS.md` | 自动加载 `.claude/` | ✅ 已配置 |
| **Cursor** | `.cursorrules` 或 `AGENTS.md` | 手动配置或读取 `AGENTS.md` | ✅ 通过 `AGENTS.md` |
| **Windsurf** | `.windsurfrules` 或 `AGENTS.md` | 手动配置或读取 `AGENTS.md` | ✅ 通过 `AGENTS.md` |
| **Codex (GitHub)** | 无标准配置文件 | 在 prompt 中引用 `AGENTS.md` | ⚠️ 手动引用 |
| **Open Code** | 无标准配置文件 | 在 prompt 中引用 `AGENTS.md` | ⚠️ 手动引用 |
| **GitHub Copilot Chat** | 无标准配置文件 | 在 prompt 中引用 `AGENTS.md` | ⚠️ 手动引用 |
| **其他工具** | 通常读取 `AGENTS.md` | 读取 `AGENTS.md` | ✅ |

---

## 各工具快速配置

### pi agent

无需配置。`AGENTS.md` 和 `.pi/APPEND_SYSTEM.md` 自动加载。

### Claude Code

自动加载 `.claude/CLAUDE.md` 和 `AGENTS.md`。无需额外配置。

首次使用建议运行：
```bash
bash agent-flow/scripts/scaffold-health.sh
```

### Cursor

Cursor 会读取项目根目录的 `AGENTS.md`。
如需更严格的绑定，创建 `.cursorrules`：

```bash
cp AGENTS.md .cursorrules
```

### Windsurf

Windsurf 会读取项目根目录的 `AGENTS.md`。
如需更严格的绑定，创建 `.windsurfrules`：

```bash
cp AGENTS.md .windsurfrules
```

### Codex / Open Code / GitHub Copilot

这些工具没有标准的项目配置文件。在使用时，在 prompt 开头加入：

```text
请先读取 AGENTS.md 和 agent-flow/GO.md，按 agent-flow 流程工作。
```

建议的 session 起始 prompt：
```text
按 agent-flow 流程处理这个需求：<需求内容>。
先做 code-first 扫描，判断 Light/Standard/Heavy，然后给我 CHANGE 和执行计划。
```

---

## 跨工具注意事项

1. **`AGENTS.md` 是核心入口** — 所有工具都至少能通过 AGENTS.md 获取流程说明
2. **pi agent 独占特性** — `.pi/APPEND_SYSTEM.md` 的绑定指令和 `.pi/skills/`、`.pi/prompts/` 是 pi agent 专属，其他工具有对应替代方案（快速参考 prompt、脚本命令）
3. **Windows 用户** — 所有门禁脚本均有 `.ps1` 版本，在 PowerShell 中运行
4. **首次运行** — 在任何工具中初次使用时，建议运行 `agent-flow/scripts/scaffold-health.sh` 确认脚手架完整

---

## 文件结构

```text
AGENTS.md                 ← 跨工具入口（所有工具都能读取）
.claude/CLAUDE.md         ← Claude Code 专属配置
.pi/APPEND_SYSTEM.md      ← pi agent 专属绑定指令
.pi/prompts/              ← pi agent 专属 prompt 模板
.pi/skills/               ← pi agent 专属技能
agent-flow/               ← 流程规则、门禁脚本、模板
```
