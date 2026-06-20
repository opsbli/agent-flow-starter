# agent-flow-starter — AI 开发流程

> 本仓库是 `agent-flow` AI 开发流程的通用 starter。
> 支持所有 AI 编码工具：pi agent、Claude Code、Cursor、Windsurf、Codex、Open Code 等。
> 工具适配指南见 `MULTI-TOOL.md`。

---

## 入口指令（所有工具通用）

收到任何开发需求后，**必须先读取 `agent-flow/GO.md` 并按路由执行**。
不允许直接进入编码、设计或分析。

**不需要用户提醒"走流程"——这是默认行为，不是可选操作。**

### 流程纪律

| 规则 | Light | Standard | Heavy | Emergency |
|------|-------|----------|-------|-----------|
| Code-first 扫描 (CODE_SCAN.md) | ✅ (warn) | ✅ | ✅ | ⏳ 24h 回填 |
| scan-check | ✅ (warn) | ✅ | ✅ | ⏳ |
| design-check | — | ✅ | ✅ | ⏳ |
| Design Alignment / alignment-check | — | ✅ | ✅ | ⏳ |
| TASKS.md / task-check | — | ✅ | ✅ | ⏳ |
| Plan Audit / plan-check | — | — | ✅ | ⏳ |
| code-drift-check | — | — | ✅ | ⏳ |
| blocked-check | — | — | ✅ | ⏳ |
| EVOLUTION.md / evolution-check | — | ✅ | ✅ | ⏳ |
| Closure Audit / closure-check | — | — | ✅ | ⏳ |

完整门禁分级见 `agent-flow/rules/gate-tiers.md`。

### 违规召回关键词

如果 AI 跳过了流程，用户回复以下关键词可强制回退：

| 关键词 | 含义 | AI 行动 |
|---|---|---|
| `[流程违规]` | 跳过了入口路由或流程步骤 | 停下来，确认违规步骤，回退重做 |
| `[缺少Grill]` | Design Alignment 未完成就进入实现 | 停在原地，重新打开 DESIGN.md 逐条对齐 |
| `[越界修改]` | 修改了 write_files 以外的文件 | 回退越界修改，只保留 write_files 内的变更 |

---

## 默认取向（12 条）

除非用户明确覆盖，否则以下规则适用于所有任务：

1. **编码前先思考** — 明确说明假设，不确定先问，有更简单方案要提出异议
2. **简洁优先** — 使用能解决问题的最少代码，不要投机性功能
3. **外科手术式修改** — 只改必须改的地方，不要"顺手改进"
4. **目标驱动执行** — 定义成功标准，循环验证直到达成
5. **把模型用于需要判断力的地方** — 确定性逻辑用代码，不要浪费模型
6. **Token 预算** — 单任务 4K，单 session 30K，接近时先总结再重新开始
7. **暴露冲突，不要折中平均** — 两个既有模式矛盾时选一个，解释原因
8. **写之前先读** — 添加代码前先读当前文件的 exports、调用方、共享工具
9. **测试要验证意图** — 业务逻辑变化时测试必须失败，浅层测试不证明正确性
10. **每个重要步骤后设置检查点** — 总结已完成、已验证、剩余内容
11. **匹配代码库约定** — 使用现有命名/结构/风格，即使你不同意
12. **大声失败** — 有任何内容被静默跳过就不能说"已完成"

---

## Reference Rules

### 默认入口

在本 starter 仓库内工作时，先读：

```text
agent-flow/README.md
```

修改流程本身时，还必须读：

```text
agent-flow/GO.md
agent-flow/manifest.yaml
agent-flow/core/source-of-truth.md
agent-flow/core/evolution.md
```

### 编辑规则

- `AGENTS.md` 是跨工具入口。所有工具的绑定指令以本文件为准。
- 详细用法写入 `README.md` 或 `agent-flow/README.md`。
- 模板必须保持通用，不写具体项目名称、模块名、业务状态或历史结论。
- 修改脚本时，凡是适用的能力必须同时更新 Windows `.ps1` 和 Linux/macOS `.sh`。
- 修改脚手架结构后，必须运行两套 `scaffold-health`。

### ECC 能力集成（可选）

如果使用 pi agent + ECC（`pi install npm:ecc-universal`），映射表见 `agent-flow/ecc-integration.md`。
其他工具请参考 `agent-flow/ecc-integration.md` 中的手动调用方式。

### 安装契约

starter 必须支持：

- 在目标项目创建或更新 `agent-flow/`。
- 在目标项目创建或更新 `AGENTS.md` 中的 `agent-flow` 区块。
- 除非显式强制覆盖，否则保留目标项目的 `agent-flow/changes`、`agent-flow/logs`、`agent-flow/reports`。

---

## pi agent 专属配置

`.pi/APPEND_SYSTEM.md` 是 pi agent 的绑定指令文件，内容与本文档的"入口指令"和"默认取向"章节一致。
pi agent 用户已自动加载，无需额外操作。
