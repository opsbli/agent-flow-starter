# agent-flow Scripts

> 脚本数量会随 starter 演进变化。正式公开脚本清单以 `agent-flow/rules/gates.txt` 为准，`manifest-check` 和 `scaffold-health` 会验证这份清单。

## 快速参考

| 你要做什么 | 运行这个 |
|---|---|
| 🚀 **首次安装到项目** | `init-project.ps1` / `.sh` |
| ✅ **检查脚手架是否完整** | `scaffold-health.ps1` / `.sh` |
| 🆕 **开始一个新需求** | `new-change.ps1` / `.sh` |
| 🔍 **一键检查当前 change 健康状况** | `check-change.ps1` / `.sh` |
| 📊 **查看项目统计** | `evolution-stats.ps1` / `.sh` |
| 📝 **搜索已有知识** | `knowledge-search.ps1` / `.sh` |

## 脚本分类

### 初始化（Install / Init）

| 脚本 | 作用 | 何时运行 |
|---|---|---|
| `init-project.ps1` / `.sh` | 检测项目类型，填充 manifest.yaml | 安装后首次 |
| `install-agent-flow.ps1` / `.sh` | 从 starter 安装/升级到目标项目 | 安装/升级时 |
| `scaffold-health.ps1` / `.sh` | 验证脚手架结构完整性 | 安装后、升级后、脚手架自改后 |
| `install-git-hooks.ps1` / `.sh` | 安装 git hooks（可选） | 团队协同时 |

### Change 生命周期

| 脚本 | 作用 | 级别要求 |
|---|---|---|
| `new-change.ps1` / `.sh` | 创建 change 目录和工件 | 所有 |
| `sync-state.ps1` / `.sh` | 根据工件推断并更新 STATE.md | 所有 |
| `next-step.ps1` / `.sh` | 显示当前 change 的下一步 | 所有 |

### 门禁检查（Gates）

AI 在流程自动调用这些。你可以不记得它们，但了解它们的存在有助于理解流程质量。

| 检查门 | 作用 | 级别要求 |
|---|---|---|
| `state-check` | 验证 STATE.md 存在且可解析 | 所有 |
| `scan-check` | 验证 CODE_SCAN.md 完整性 | Standard+ |
| `design-check` | 验证 DESIGN.md Decision Status | Standard+ |
| `alignment-check` | 验证 Design Alignment 完成 | Standard+ |
| `plan-check` | 验证 PLAN.md 完整 | Heavy |
| `task-check` | 验证 TASKS.md 完整 | Standard+ |
| `task-boundary-check` | 验证实际修改不超 write_files | Standard+ |
| `code-drift-check` | 验证实现与设计一致 | Standard+ |
| `blocked-check` | 检查是否触碰 blocked_if 规则 | Standard+ |
| `ac-traceability-check` | 检查 AC 是否贯穿需求、设计、任务、验证和报告 | Standard+ |
| `coverage-check` | 验证 AC 覆盖率和测试覆盖率 | Standard+ |
| `manifest-check` | 验证大门禁和配置完整性 | Standard+ |
| `evolution-check` | 验证 EVOLUTION.md 存在 | Standard+ |
| `closure-check` | 收口前最终检查 | Heavy |
| `emergency-check` | Emergency 通道合规检查 | Emergency |
| `template-check` | 验证模板版本和结构 | 脚手架修改后 |

### 验证运行

| 脚本 | 作用 |
|---|---|
| `run-verify.ps1` / `.sh` | 运行编译/测试/前端检查 |
| `verify-backend.ps1` / `.sh` | （已弃用，改用 run-verify） |
| `verify-module.ps1` / `.sh` | （已弃用，改用 run-verify） |
| `ac-check.ps1` / `.sh` | 检查 AC 在 VERIFY.md 中的覆盖率 |
| `incremental-verify.ps1` / `.sh` | 根据改动文件运行局部验证提示 |

### 聚合检查

| 脚本 | 作用 |
|---|---|
| `check-change.ps1` / `.sh` | 运行所有相关门禁，输出 CHECK_RESULT.json |
| `drift-check.ps1` / `.sh` | （已弃用，改用 code-drift-check） |

### 辅助工具

| 脚本 | 作用 |
|---|---|
| `evolution-stats.ps1` / `.sh` | 统计 change、AC、知识库等指标。支持 `-UpdateIndex` 更新 INDEX.md |
| `evolution-suggest.ps1` / `.sh` | 基于 EVOLUTION.md 历史给出改进建议 |
| `knowledge-search.ps1` / `.sh` | 搜索知识库和决策记录 |
| `generate-*.ps1` / `.sh` | 生成各类工件草稿（可选，AI 通常直接写文件） |
| `detect-unused.ps1` / `.sh` | 检测长时间未更新的 knowledge 文件 |

### 公共库（不作为独立 gate 运行）

| 脚本 | 作用 |
|---|---|
| `_common.ps1` | Windows 共享函数库 |
| `_common.sh` | Linux/macOS 共享函数库 |

## 命名约定

- 每个 gate 有 `.ps1` 和 `.sh` 两份，保证跨平台一致性
- 公开脚本必须登记在 `agent-flow/rules/gates.txt` 和 `manifest.yaml` 的 `gates` 中
- 以 `_` 开头的脚本是共享库，不作为独立门禁
- 已弃用的脚本有替代品（如 `drift-check` → `code-drift-check`）

## 常见流程

```powershell
# 开始一个新需求
agent-flow/scripts/new-change.ps1 -ChangeId my-feature

# 运行后检查
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/my-feature

# 查看项目统计
agent-flow/scripts/evolution-stats.ps1 -UpdateIndex
```
