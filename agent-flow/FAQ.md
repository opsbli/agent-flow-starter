# FAQ

## 基本概念

### agent-flow 是什么？

一个项目级的 AI 开发工作流框架。它定义了一套文件和规则，让 AI 在开发时先查代码再写方案、先验证再宣布完成，避免"直接写代码"带来的风险。

### 和 cursor rules / copilot instructions 有什么区别？

| | cursor rules | agent-flow |
|---|---|---|
| 范围 | IDE 级别 | 项目级别（跨 IDE、跨设备） |
| 存储 | IDE 配置 | 代码仓库 |agent-flow/ |
| 流程 | 规则片段 | 完整流程（Light/Standard/Heavy/Emergency） |
| 验证 | 无内置 | AC Evidence、code-drift-check、task-boundary-check、blocked-check |
| 记忆 | 有限 | 知识库 + ADR 决策记录 |

### 一定要用全部流程吗？

不需要。Light 流程只有 5 个工件，适合小改动。只有 Heavy 流程有 12 个工件。流程强度由风险决定。

## 安装和初始化

### 如何安装到我的项目？

```powershell
# Windows
C:\path\to\agent-flow-starter\scripts\install-agent-flow.ps1 -Target "C:\path\to\project"

# Linux/macOS
bash /path/to/agent-flow-starter/scripts/install-agent-flow.sh --target /path/to/project
```

### 安装后还要做什么？

```powershell
cd your-project
agent-flow/scripts/init-project.ps1      # 检测项目类型，填写 manifest.yaml
agent-flow/scripts/scaffold-health.ps1   # 验证脚手架完整性
```

### 如何升级已安装的 agent-flow？

重复运行 `install-agent-flow`。它会：

- 覆盖 starter-owned 文件（`core/`、`flows/`、`templates/`、`scripts/`）
- 保留 project-owned 历史（`changes/`、`logs/`、`reports/`、`knowledge/`、`decisions/`）
- 智能合并 `manifest.yaml`（保留已填写的配置）

升级后运行 `scaffold-health` 和 `init-project` 确认一切正常。

### 我的项目不是 Maven/Node，能用吗？

能。`init-project` 支持 Maven、Gradle、Python、Go、Rust 和 Node（自动检测）。其他项目类型会使用通用模板，手动填写 `manifest.yaml` 即可。

## 使用流程

### 我该选 Light、Standard 还是 Heavy？

参考 `agent-flow/core/router.md`：

- **Light**：单文件修复、文案、注释
- **Standard**：单模块功能、标准 CRUD
- **Heavy**：新模块、改 schema、权限、跨模块协作

不确定时选 Heavy，然后走"降级三问"（见 router.md）。

### 生产事故怎么办？

走 **Emergency 通道**：

1. 确认是 P0/P1 事故（有可量化损失）
2. 走 `agent-flow/flows/emergency.md`
3. 24 小时内回填被跳过的工件

### 我的 change 做到一半发现方向不对，怎么办？

创建 `CANCEL.md`（从 `agent-flow/templates/CANCEL.md` 复制），记录：

- 已经做了什么
- 为什么放弃
- 哪些知识/代码可以保留

然后把 `STATE.md` 的 `current_stage` 改为 `cancelled`。

### 如何回滚一个已完成的 change？

创建 `ROLLBACK.md`（从 `agent-flow/templates/ROLLBACK.md` 复制），按模板列出：

- 需要 revert 的文件
- 数据库回滚步骤
- 权限/配置恢复步骤
- 回滚后验证命令

## 常见问题

### 脚本报错 "Cannot find path"

确保你在项目根目录运行脚本。如果从子目录运行，使用绝对路径：

```powershell
& "C:\full\path\to\agent-flow\scripts\scaffold-health.ps1"
```

### alignment-check 失败

可能原因：

1. `DESIGN.md` 的 `Alignment Verdict` 字段缺失或为 `pending`
2. 使用了 `skipped` 但没有填写 `Skip Reason`

修复：在 `DESIGN.md` 中设置 `Alignment Verdict: aligned` 或填写 `Skip Reason`。

### ac-check 找不到我的 AC 编号

确保使用 `AC-01` 格式（两位数字零填充）。`AC-1`、`AC-001` 都不会被识别。

### code-drift-check 说表不存在但我还没创建

正常。`code-drift-check` 检查设计文档中声明的表是否在 schema 文件中存在。如果在设计阶段运行，表当然还不存在。这是预期的。

设计阶段运行 `code-drift-check` → 预期有漂移（还没实现）
实现后运行 `code-drift-check` → 应该无漂移

### 我改了一个文件但不在 write_files 里

在 `TASKS.md` 的 `write_files` 中声明你要修改的文件。未声明的文件被修改后会触发 `task-boundary-check` 失败。

## 脚本参考

### 我该怎么记住所有命令？

常用的就几个：

| 场景 | 命令 |
|---|---|
| 安装 | `install-agent-flow.ps1` |
| 创建 change | `new-change.ps1 -Name "my-change" -Flow Standard` |
| 推进 change | `next-step.ps1 -ChangeDir agent-flow/changes/my-change` |
| 验证 | `run-verify.ps1 -All` |
| 健康检查 | `scaffold-health.ps1` |

完整的命令列表见 `agent-flow/manifest.yaml` 的 `gates` 部分。

### 如何一次运行所有检查？

优先使用 `check-change` 汇总单个 change 的门禁结果。

Windows：

```powershell
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/<change-id> -OutputPath agent-flow/changes/<change-id>/CHECK_RESULT.json
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/<change-id> -Closure -OutputPath agent-flow/changes/<change-id>/CHECK_RESULT.json
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/manifest-check.ps1
```

Linux/macOS：

```bash
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id> --output agent-flow/changes/<change-id>/CHECK_RESULT.json
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id> --closure --output agent-flow/changes/<change-id>/CHECK_RESULT.json
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/manifest-check.sh
```

`check-change` 会串起状态、扫描、设计、对齐、计划、任务、AC、漂移、阻塞、边界、manifest、Emergency、演进和关闭检查；项目业务验证仍由 `run-verify` 根据 `manifest.yaml` 执行。

### run-verify 和 verify-backend 什么关系？

`verify-backend.ps1` 已废弃，只是 `run-verify.ps1` 的包装。直接使用：

```powershell
agent-flow/scripts/run-verify.ps1 -Name backend_compile
agent-flow/scripts/run-verify.ps1 -Name backend_test
agent-flow/scripts/run-verify.ps1 -Name module_compile -Module my-module
```

## 故障排除

### scaffold-health 报"Missing scaffold files"

运行 `install-agent-flow` 重新安装缺失的文件。如果文件在旧版本中存在但新版中已移除（如 `verify-backend.ps1`），更新 `scaffold-health` 或重新安装即可。

### init-project 检测不到我的项目类型

手动填写 `agent-flow/manifest.yaml`：

```yaml
project:
  name: my-project
  kind: custom
  backend:
    framework: your-framework
    language: your-language
    build: your-build-command
```

### drift-check / code-drift-check 总是失败

如果设计阶段运行，漂移是正常的（代码还没写）。如果实现后运行，检查：

- 你创建了 schema 迁移文件了吗？
- 你的 API 路径和设计文档一致吗？
- 你的权限码在代码中有 @SaCheckPermission 引用吗？

如果确定是误报，可以在 `VERIFY.md` 中记录明确裁决。
