# 路由

> **紧急通道**：P0/P1 生产事故、安全漏洞、数据丢失走 `agent-flow/flows/emergency.md`（见流程图顶部 bypass 出口）。
> Emergency 绕过标准流程，事后 24h 内必须回填。**它不是流程级别，而是 bypass 通道**，不与 Light/Standard/Heavy 并列。

## 流程总览

```
需求进入 → {Emergency?} → [Code Scan] → [分级] → [执行对应流程]
                ↑                              ↑
           bypass 出口                  建议运行 flow-detect 验证
```

## Light

适用：

- 单文件低风险修复。
- 文档、注释、局部样式。
- 已有测试覆盖下的小行为修正。

最低产物：

- `STATE.md`
- `CHANGE.md`
- `CODE_SCAN.md`
- `VERIFY.md`
- `REPORT.md`

## Standard

适用：

- 单模块功能。
- 标准 CRUD。
- 明确需求，无复杂状态机。
- 不改公共契约。

最低产物：

- `STATE.md`
- `CHANGE.md`
- `REQUIREMENT.md`
- `CODE_SCAN.md`
- `DESIGN.md`，其中 `Design Alignment / Grill` 的 `Alignment Verdict` 必须为 `aligned`，或为用户明确接受的 `skipped` 且带 `Skip Reason`
- `TASKS.md`
- `VERIFY.md`
- `REPORT.md`
- `EVOLUTION.md`

## Heavy

适用：

- 老项目新增业务模块。
- 跨模块协作。
- 改数据库 schema。
- 改权限、认证、Token、限流、防重。
- 涉及 Redis、WebSocket、工作流、状态机。
- 前后端联动。
- 生产事故成本高。

最低产物：

- `STATE.md`
- `CHANGE.md`
- `REQUIREMENT.md`
- `CODE_SCAN.md`
- `DESIGN.md`，其中 `Design Alignment / Grill` 的 `Alignment Verdict` 必须为 `aligned`，或为用户明确接受的 `skipped` 且带 `Skip Reason`
- `PLAN.md`
- `TASKS.md`
- `VERIFY.md`
- `REVIEW.md`
- `REPORT.md`
- `AUDIT.md`
- `EVOLUTION.md`
- 必要 ADR

## 降级三问

只有三问全部为“否”，才能从 Heavy 降级：

1. 是否跨模块、跨仓库或跨系统边界？
2. 是否修改 schema、状态机、权限、认证、公共 API 或外部副作用？
3. 出错后是否难以被普通测试或人工检查快速发现？

任一为"是"，保持 Heavy。

## 升级三问（Standard → Heavy）

当 Code Scan 发现下列迹象时，即使 CHANGE.md 标记为 Standard，也应升级为 Heavy：

1. 代码扫描是否发现了未声明的 schema/权限/API 变更？
2. 实际影响范围是否超出了 CHANGE.md 声明的边界？
3. 是否有未评估的生产风险（如数据迁移、外部依赖变更）？

任一为"是"，应升级为 Heavy。

## 验证分级

分级后建议运行 flow-detect 验证分级合理性：

```powershell
# Windows
agent-flow/scripts/flow-detect.ps1 -ChangeDir agent-flow/changes/<change-id>

# Linux/macOS
bash agent-flow/scripts/flow-detect.sh --change-dir agent-flow/changes/<change-id>
```

如果 flow-detect 的置信度为 low 且建议级别与实际勾选不匹配，需人工复核分级。

## 防过重机制

### 轻量优先原则

当分级不确定时（如 flow-detect 置信度 low），优先选择**较轻的级别**：

```
不确定是 Light 还是 Standard？ → 走 Light
不确定是 Standard 还是 Heavy？ → 走 Standard-Light
```

如果后续发现不够，**随时可以升级**：
- Light 发现跨模块影响 → 升级 Standard
- Standard 发现 schema 变更 → 升级 Heavy

不允许降级——只有主动升级。

### 后置降级检查

每个 change 完成后，运行后置检查判断是否被过重处理：

```powershell
agent-flow/scripts/gate-fatigue-check.ps1 -Threshold 8 -ProjectRoot .
```

如果某个级别的 change 连续 8 次所有门禁全通过且无发现问题，在 EVOLUTION.md 中记录降级建议。

## 防形式主义

### 内容质量门禁

所有模板字段必须通过 `Test-Meaningful` 检查：

```powershell
agent-flow/scripts/template-check.ps1
```

每个门禁需要同时满足：
- **存在性**：文件存在
- **内容性**：文件内容不是 TODO/TBD/占位符
- **证据性**：AI 写的决策必须引用具体代码位置

具体见 `agent-flow/scripts/content-check.ps1`。

## 防 AI 依赖

### 决策必须引用代码

DESIGN.md 中的每个决策（API、权限、数据模型）必须引用具体的代码位置。

反例：
> "使用 Redis 缓存" ❌

正例：
> "使用 Redis 缓存——参考 `common/cache/RedisCache.java:42` 的 `getWithLock` 模式" ✅

### AI 自治限制

| 动作 | 限制 |
|------|------|
| 修改 schema | 必须用户确认 |
| 修改公共 API 契约 | 必须用户确认 |
| 修改权限码 | 必须用户确认 |
| 选择技术方案（A/B 取舍） | 必须给出推荐+备选，用户确认 |
| 写测试 | AI 自治 |

见 `agent-flow/core/autonomy-policy.md` 的完整定义。
