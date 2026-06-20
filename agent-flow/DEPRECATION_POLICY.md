# Deprecation Policy

> 定义 agent-flow 模板、脚本、配置的弃用生命周期。

---

## 弃用生命周期

每个废弃项经过三个阶段：

```text
Deprecated (6个月) → Sunset (3个月) → Removed
```

### Phase 1: Deprecated（已弃用）

- 在文档中标记 **DEPRECATED**
- 脚本或工具运行时显示警告信息
- 提供迁移指南
- 仍可正常使用，无功能降级

### Phase 2: Sunset（日落期）

- 从默认安装中移除（需要 opt-in 才安装）
- 保留在仓库的 `deprecated/` 目录中
- 运行时会提示"此功能已进入日落期，请迁移到 X"
- 关键安全修复仍提供，新功能不开发

### Phase 3: Removed（已移除）

- 从仓库中删除
- 更新 `CHANGELOG.md` 记录移除
- 添加迁移指南到 `UPGRADE.md`

---

## 弃用触发条件

满足以下任意一项，启动弃用流程：

| 条件 | 示例 |
|------|------|
| 🔴 **安全漏洞无法修复** | 脚本使用了不安全的正则/路径处理 |
| 🟡 **被更优实现替代** | `verify-backend.ps1` 被 `run-verify.ps1` 替代 |
| 🟠 **平台支持结束** | PowerShell 5.1 特定脚本（要求 PS 7+） |
| 🔵 **重大变更不可避免** | 模板字段格式调整导致旧版本不兼容 |
| ⚪ **长期无维护** | 脚本在 12 个月内无提交且无活跃用户 |

---

## 迁移指南要求

每个进入 Deprecated 状态的项，必须提供：

```
MIGRATION-<source>-to-<target>.md
```

包含：
1. **当前行为**：做什么、怎么用、参数格式
2. **新行为**：替代方案做什么、怎么用、参数格式
3. **迁移步骤**：具体的替换操作（代码 diff 示例）
4. **回滚方案**：如果迁移失败如何恢复
5. **兼容性窗口**：两个版本并行支持的期限

---

## 当前已弃用项

| 项 | 弃用时间 | 日落时间 | 移除时间 | 替代方案 |
|---|---------|---------|---------|---------|
| `verify-backend.ps1/.sh` | v0.1.0 | TBD | TBD | `run-verify.ps1/.sh` |
| `verify-module.ps1/.sh` | v0.1.0 | TBD | TBD | `run-verify.ps1/.sh` |

---

## 弃用通讯

每次状态变更必须在以下渠道同步：

1. `CHANGELOG.md` — 版本日志中记录
2. `UPGRADE.md` — 升级指南中记录
3. 相关脚本添加运行时警告

### 脚本警告格式

```powershell
Write-Warning "[DEPRECATED] $ScriptName 已弃用，将在 YYYY-MM 移除。请使用 $AlternativeScript 替代。"
```

```bash
echo "[DEPRECATED] $ScriptName has been deprecated and will be removed by YYYY-MM. Use $AlternativeScript instead." >&2
```

---

## 例外

紧急安全修复可以跳过 Sunset 阶段，直接从 Deprecated 到 Removed，但必须：

1. 在 `CHANGELOG.md` 中注明紧急移除原因
2. 在 `UPGRADE.md` 中添加迁移指南
3. 在相关仓库 issue 中通知用户
