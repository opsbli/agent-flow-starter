# agent-flow 用户上手指南

> 一站掌握 agent-flow AI 开发流程。适合所有 AI 编码工具（pi agent、Claude Code、Cursor 等）。

---

## 一、什么是 agent-flow

agent-flow 是一个 **AI 开发流程框架**。它通过结构化的工件（artifacts）和自动门禁（gates），让 AI 在开发时更可控：

- **先查代码，再写方案** — CODE_SCAN.md 强制 code-first
- **先明确边界，再实现** — DESIGN.md + TASKS.md 约束修改范围
- **先验证，再宣布完成** — VERIFY.md + 门禁链保障质量
- **把经验沉淀回来** — EVOLUTION.md → improvement-tracker 形成闭环

---

## 二、快速开始（5 分钟）

### 检查脚手架

```bash
bash agent-flow/scripts/scaffold-health.sh      # Linux/macOS
agent-flow\scripts\scaffold-health.ps1           # Windows
```

### 创建第一个 Change

```bash
bash agent-flow/scripts/new-change.sh --name my-first-change --flow Light
```

### 查看下一步

```bash
bash agent-flow/scripts/next-step.sh --change-dir agent-flow/changes/my-first-change
```

### 运行门禁

```bash
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/my-first-change
```

---

## 三、流程分级

| 级别 | 适合场景 | 最少工件 | 关键门禁 |
|------|---------|---------|---------|
| **Light** | 文案、注释、单文件小修复 | CHANGE.md + CODE_SCAN.md + VERIFY.md + REPORT.md | scan-check (warn) |
| **Standard** | 单模块功能、CRUD、小型页面改动 | + REQUIREMENT.md + DESIGN.md + TASKS.md | design-check, alignment-check, task-check, evolution-check |
| **Heavy** | Schema/权限/API 变更、跨模块 | + PLAN.md + AUDIT.md + REVIEW.md | plan-check, code-drift-check, blocked-check, closure-check |
| **Emergency** | P0/P1 生产事故 | 24h 内回填所有工件 | emergency-check |

详细门禁分级：`agent-flow/rules/gate-tiers.md`

---

## 四、工作流全景

```text
需求进入
  │
  ▼
紧急判断 ──P0/P1──► Emergency 通道（24h 回填）
  │ NO
  ▼
[new-change] 创建 Change 目录
  │
  ▼
[CODE_SCAN.md] Code-First 扫描 ← scan-check
  │
  ▼
[CHANGE.md] 分级 Light / Standard / Heavy
  │
  ├── Light ──────► 实现 → [VERIFY.md] → [REPORT.md]
  │
  ├── Standard ──► Requirements Grill → [DESIGN.md]
  │                    │ → design-check
  │                    ▼
  │                Design Alignment → alignment-check
  │                    │
  │                    ▼
  │                [TASKS.md] → task-check
  │                    │
  │                    ▼
  │                实现 (TDD: RED → GREEN → REFACTOR)
  │                    │
  │                    ▼
  │                [VERIFY.md] → ac-check + coverage-check
  │                    │
  │                    ▼
  │                [EVOLUTION.md] → evolution-check
  │                    │
  │                    ▼
  │                [REPORT.md]
  │
  └── Heavy ────► Standard 全流程 +
                       │
                       ▼
                   Plan Audit → plan-check
                       │
                       ▼
                   实现（分阶段）
                       │
                       ▼
                   code-drift-check + blocked-check
                       │
                       ▼
                   Closure Audit → closure-check
```

---

## 五、工件说明

### CHANGE.md
一句话描述需求 + 流程分级 + 目标/非目标 + 影响范围。

### CODE_SCAN.md
读了哪些文件、找到哪些相似实现、可复用哪些抽象、只读/可写文件列表。

### REQUIREMENT.md
可验证的验收标准（AC-01、AC-02...），每条 AC 必须有 Given/When/Then。

### DESIGN.md
API 决策、权限变更、数据设计、状态机影响、Design Alignment 对齐记录。

### TASKS.md
分步骤执行计划。每任务含：读写文件、AC 映射、验证命令、并行标记。

### VERIFY.md
AC 证据表 + 命令记录 + Drift 检查 + Machine Gate Summary。

### EVOLUTION.md
本次流程哪里有效、哪里形式主义、哪些知识要沉淀、哪些模板要升级。

---

## 六、常用命令速查

### 创建与管理

| 命令 | 用途 |
|------|------|
| `new-change.sh --name <id> --flow <level>` | 创建新 change |
| `next-step.sh --change-dir <dir>` | 查看当前 stage 和下一步 |
| `sync-state.sh --change-dir <dir>` | 同步 STATE.md |
| `check-change.sh --change-dir <dir>` | 运行全套门禁 |

### 门禁检查

| 命令 | 用途 | 适用 |
|------|------|------|
| `scaffold-health.sh` | 脚手架完整性检查 | 始终 |
| `manifest-check.sh` | manifest.yaml 完整性 | 始终 |
| `template-check.sh` | 模板有效性 | 模板修改后 |
| `content-check.sh --project-root .` | 全项目占位符扫描 | 始终 |
| `scan-check.sh --change-dir <dir> --strict` | CODE_SCAN.md 审查 | L/S/H |
| `design-check.sh --change-dir <dir>` | 设计决策完整性 | S/H |
| `alignment-check.sh --change-dir <dir>` | Design Alignment 对齐 | S/H |
| `task-check.sh --change-dir <dir>` | TASKS.md 完整性 | S/H |
| `evolution-check.sh --change-dir <dir>` | EVOLUTION.md 审查 | S/H |
| `ac-check.sh --change-dir <dir>` | AC 证据追溯 | S/H |
| `coverage-check.sh --change-dir <dir>` | AC 覆盖率 | S/H |
| `plan-check.sh --change-dir <dir>` | Plan Audit | H |
| `code-drift-check.sh --change-dir <dir>` | 设计漂移检查 | H |
| `blocked-check.sh --change-dir <dir>` | 危险操作检查 | H |
| `closure-check.sh --change-dir <dir>` | 关闭检查 | H |

### 工具

| 命令 | 用途 |
|------|------|
| `generate-design.sh --change-dir <dir>` | 自动生成 DESIGN.md 骨架 |
| `generate-tasks.sh --change-dir <dir>` | 自动生成 TASKS.md |
| `generate-report.sh --change-dir <dir>` | 自动生成 REPORT.md |
| `evolution-stats.sh` | 项目演进统计 |
| `evolution-suggest.sh` | 演进改进建议 |
| `gate-fatigue-check.sh` | 门禁疲劳检测 |

---

## 七、AI 工具适配

| 工具 | 自动加载的配置 | 首次使用 |
|------|--------------|---------|
| pi agent | `.pi/APPEND_SYSTEM.md` + `AGENTS.md` | 无需配置 |
| Claude Code | `.claude/CLAUDE.md` + `AGENTS.md` | 无需配置 |
| Cursor | `AGENTS.md` | 可直接使用 |
| Windsurf | `AGENTS.md` | 可直接使用 |
| 其他工具 | `AGENTS.md` | Prompt 中引用 `AGENTS.md` |

工具适配详情：`MULTI-TOOL.md`

---

## 八、常用 Prompt

### 开始新需求
```text
按 agent-flow 流程处理这个需求：<需求描述>。
先做 code-first 扫描，判断 Light/Standard/Heavy，然后给我 CHANGE 和执行计划。
```

### 只做规划，不实现
```text
继续 agent-flow change：<change-id>。
先不要写业务代码。请补全 REQUIREMENT、CODE_SCAN、DESIGN。
完成后运行 design-check。
```

### 开始实现
```text
继续 agent-flow change：<change-id>。
严格按 TASKS.md 的 write_files 修改。
每完成一个任务更新 TASKS.md。
```

### 收口
```text
继续 agent-flow change：<change-id>。
补全 VERIFY、REVIEW、REPORT、EVOLUTION。
运行 check-change --closure。
```

---

## 九、常见问题

### 门禁失败怎么办？
每个门禁会输出明确的失败原因。按提示修复后重新运行。

### 不知道当前 stage？
```bash
bash agent-flow/scripts/next-step.sh --change-dir <dir>
```

### 想升级/降级 flow？
修改 CHANGE.md 中的流程级别标记，重新运行 `check-change`。

### 工件冲突了？
以 `STATE.md` 为导航，以实际工件为真相源。运行 `sync-state` 同步。

### 更多帮助
- `agent-flow/FAQ.md` — 常见问题解答
- `docs/TROUBLESHOOTING.md` — 故障排除
- `docs/learning-path.md` — 渐进式学习路径
