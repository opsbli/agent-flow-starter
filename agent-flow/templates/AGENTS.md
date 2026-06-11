# {project-name} Agent 规则

<!-- agent-flow:start -->
> 本仓库默认使用 `agent-flow` 作为 AI 开发流程。
> 代码仓库是事实来源，聊天内容只是临时工作界面。

## 默认入口

任何非平凡需求，必须先读：

```text
agent-flow/GO.md
```

按顺序读取：

1. `agent-flow/GO.md`
2. `agent-flow/manifest.yaml`
3. `agent-flow/core/source-of-truth.md`
4. `agent-flow/core/autonomy-policy.md`
5. `agent-flow/core/router.md`
6. `agent-flow/core/code-first-context.md`
7. `agent-flow/core/memory.md`
8. `agent-flow/core/plan-guide.md`
9. `agent-flow/core/audit.md`
10. `agent-flow/core/logging.md`
11. `agent-flow/core/evolution.md`

如果任务涉及前端，还必须读：

```text
agent-flow/core/frontend-fit.md
```

## 项目上下文

安装后必须为目标项目初始化本节：

- 项目名称：
- 主要技术栈：
- 后端目录：
- 前端目录：
- 数据库或持久化：
- 测试命令：
- 受保护区域：

## 默认流程

每个需求都必须按 `agent-flow/core/router.md` 判断为 `Light`、`Standard` 或 `Heavy`。

涉及数据库 schema、认证鉴权、公开 API 契约、workflow/state machine、跨仓前后端、部署、生产风险、大模块边界时，必须走 `Heavy`。

## Code-First 规则

设计或实现前必须：

- 扫描相关源码。
- 查找相似实现。
- 记录 `read_files`。
- 记录 `write_files`。
- 不修改未获批准的 `write_files` 之外的文件。
- `CODE_SCAN.md` 完成后运行 `scan-check`。
- Standard / Heavy 进入实现前运行 `task-check`。
- Emergency change 必须运行 `emergency-check`。
- 不确定 change 是否健康时运行 `check-change`。

## 受保护区域

遵守 `agent-flow/core/autonomy-policy.md`。

触碰数据库 schema、认证/权限、公开 API 契约、token/session、部署、生产配置、计费/授权、破坏性操作、根构建文件前，必须先停下来请求确认。

## 验证

Windows：

```text
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/scan-check.ps1 -ChangeDir agent-flow/changes/<change-id> -ProjectRoot . -Strict
agent-flow/scripts/task-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/emergency-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/ac-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/code-drift-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/blocked-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/task-boundary-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/manifest-check.ps1
agent-flow/scripts/evolution-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/<change-id> -OutputPath agent-flow/changes/<change-id>/CHECK_RESULT.json
```

Linux/macOS：

```text
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/scan-check.sh --change-dir agent-flow/changes/<change-id> --project-root . --strict
bash agent-flow/scripts/task-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/emergency-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/ac-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/code-drift-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/blocked-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/task-boundary-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/manifest-check.sh
bash agent-flow/scripts/evolution-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id> --output agent-flow/changes/<change-id>/CHECK_RESULT.json
```

没有 `VERIFY.md`，不得声明完成。

## 知识和决策

- 可复用事实写入 `agent-flow/knowledge/`。
- 不可逆架构决策写入 `agent-flow/decisions/`。
- 每个完成的 change 必须写 `EVOLUTION.md`。

## 禁止事项

- 非平凡需求禁止直接写代码。
- 没有 `CODE_SCAN.md` 禁止先做设计。
- Heavy change 没有通过 `Plan Audit` 禁止实现。
- Heavy change 没有通过 `Closure Audit` 禁止收口。
- 未获批准禁止修改受保护区域。
- 查找前禁止新增重复抽象。
- 没有验证证据禁止声明完成。
- 禁止只在聊天里保存长期知识。
<!-- agent-flow:end -->
