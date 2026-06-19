# agent-flow 渐进式学习路径

> 从零开始，逐步掌握 agent-flow。每阶段只暴露你当前需要的复杂度。

---

## Phase 0：了解核心概念（5 分钟）

**目标**：理解 agent-flow 是什么、解决什么问题。

### 阅读
1. `agent-flow/README.md` — 了解项目内工作流
2. `README.md` — 了解整体定位
3. `agent-flow/FAQ.md` — 常见问题

### 关键概念
- **Change**: 一次需求的工作目录，包含所有工件
- **Flow Level**: Light / Standard / Heavy —— 按风险分级
- **Gate**: 门禁脚本，自动检查工件质量
- **TDD**: 所有代码必须先写测试（RED）→ 实现（GREEN）→ 重构（REFACTOR）

```
需求 → [Change] → [Code Scan] → [分级] → [工件] → [TDD实现] → [验证] → [报告]
```

### ✅ 完成标志
- [ ] 能说出 Light/Standard/Heavy 的区别
- [ ] 能说出 Change 是什么
- [ ] 知道 TDD 三步是什么

---

## Phase 1：完成你的第一个 Light Change（15 分钟）

**目标**：创建并完成一个最小级别的需求。

### 你需要知道的脚本（只需要 5 个）

| 脚本 | 作用 |
|------|------|
| `new-change.ps1/.sh` | 创建新的 change 目录 |
| `scaffold-health.ps1/.sh` | 检查脚手架完整性 |
| `manifest-check.ps1/.sh` | 检查项目配置完整性 |
| `next-step.ps1/.sh` | 告诉你 change 下一步做什么 |
| `check-change.ps1/.sh` | 汇总验证所有门禁 |

### 操作步骤

```powershell
# Windows
agent-flow/scripts/new-change.ps1 -Name my-first-change -Flow Light

# 查看下一步
agent-flow/scripts/next-step.ps1 -ChangeDir agent-flow/changes/my-first-change

# 按 next-step 的提示继续...
```

### 你需要写的工件（最少 5 个）

```
CHANGE.md      ← 描述你要改什么
CODE_SCAN.md   ← 代码扫描结果
VERIFY.md      ← 验证证据
REPORT.md      ← 交付报告
```

**关键约束**：必须走 TDD——先写测试，再写代码。

### ✅ 完成标志
- [ ] 创建了一个 Light change 并完成
- [ ] 能运行 `next-step` 了解当前状态
- [ ] 能运行 `scaffold-health` 检查脚手架

---

## Phase 2：完成 Standard Change（30 分钟）

**目标**：带完整设计和验证的标准需求。

### 新增需要了解的脚本（+3 个）

| 脚本 | 作用 |
|------|------|
| `design-check.ps1/.sh` | 检查设计文档完整性 |
| `alignment-check.ps1/.sh` | 检查用户确认的设计对齐 |
| `task-check.ps1/.sh` | 检查任务定义的完整性 |
| `run-verify.ps1/.sh` | 运行项目级验证命令 |

### 新增需要写的工件（+4 个）

```
REQUIREMENT.md  ← 带 AC-01 编号的可验证需求
DESIGN.md       ← 技术设计，需完成 Design Alignment/Grill
TASKS.md        ← 任务分解，每个任务绑定 AC
EVOLUTION.md    ← 复盘：流程改进和学习
```

### 关键检查点：Design Alignment

DESIGN.md 写完后，必须先通过：
1. 运行 `design-check`
2. 执行 **Design Alignment / Grill**（一次只问一个关键问题，给出推荐答案）
3. 运行 `alignment-check`
4. 拿到 `Verdict: aligned`
5. **才能进入 TASKS.md 和实现**

```
DESIGN.md → design-check → Design Alignment → alignment-check → TASKS.md → TDD实现 → VERIFY.md
```

### ✅ 完成标志
- [ ] 全部 9 个工件齐全
- [ ] Design Alignment Verdict 为 aligned
- [ ] 所有 AC 有验证证据

---

## Phase 3：完成 Heavy Change（45 分钟）

**目标**：高风险跨模块需求，涉及 schema/权限/状态机。

### 新增需要了解的脚本（+5 个）

| 脚本 | 作用 |
|------|------|
| `plan-check.ps1/.sh` | 检查计划的完整性和质量 |
| `code-drift-check.ps1/.sh` | 检查设计声明 vs 实际代码的偏移 |
| `blocked-check.ps1/.sh` | 检查是否触碰了禁止修改的规则 |
| `closure-check.ps1/.sh` | 收口审核 |
| `gate-fatigue-check.ps1/.sh` | 检查门禁是否已疲劳失效 |

### 新增需要写的工件（+2 个）

```
PLAN.md     ← 分阶段执行计划
AUDIT.md    ← Plan Audit + Closure Audit
```

### 完整流程

```
INTAKE → Requirements Grill → CODE_SCAN → DESIGN → Design Alignment
  → PLAN → Plan Audit → TASKS → TDD实现 (分阶段)
  → VERIFY → REVIEW → Closure Audit → EVOLUTION → 知识沉淀
```

**必须通过 Plan Audit（Verdict: accept）才能开始实现。**

### ✅ 完成标志
- [ ] 全部 12 个工件齐全
- [ ] Plan Audit accept
- [ ] Closure Audit 通过
- [ ] 知识已沉淀到 `agent-flow/knowledge/`

---

## Phase 4：使用仪表盘和分析工具（15 分钟）

**目标**：利用辅助工具了解项目全局状态。

```powershell
# 查看所有 change 状态
agent-flow/scripts/dashboard.ps1

# 检测门禁疲劳（哪些门禁一直通过没发现问题）
agent-flow/scripts/gate-fatigue-check.ps1

# 发现重复模式（哪些问题反复出现）
agent-flow/scripts/pattern-discovery.ps1

# 检查知识过期
agent-flow/scripts/knowledge-expiry-check.ps1
```

### ✅ 完成标志
- [ ] 能运行 dashboard 了解所有 change 状态
- [ ] 能运行 evolution-suggest 获取改进建议

---

## Phase 5：自定义和演进（长期）

**目标**：根据项目实际需要定制 agent-flow。

### 你可以定制的内容
1. **添加新门禁**：在 `agent-flow/scripts/` 下创建新脚本，注册到 `agent-flow/rules/gates.txt`
2. **更新模板**：修改 `agent-flow/templates/` 下的工件模板
3. **沉淀知识**：每次 change 后更新 `agent-flow/knowledge/`
4. **调整分级**：修改 `agent-flow/core/router.md` 的 Light/Standard/Heavy 判定规则
5. **升级 agent-flow**：重新运行 `install-agent-flow.ps1` 升级到最新版本

### 每次 change 后的必做动作

```text
1. 写 EVOLUTION.md
2. 运行 evolution-check
3. 更新 agent-flow/knowledge/ 中的相关文件
4. 如果有不可逆架构决策，写入 agent-flow/decisions/
```

---

## 命令速查卡

### 最常用（Phase 1-2 足够用）

```powershell
agent-flow/scripts/scaffold-health.ps1           # 每次修改后必做
agent-flow/scripts/new-change.ps1 -Name xxx -Flow Light/Standard/Heavy
agent-flow/scripts/next-step.ps1 -ChangeDir agent-flow/changes/xxx
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/xxx
agent-flow/scripts/manifest-check.ps1
```

### 设计阶段（Phase 2）

```powershell
agent-flow/scripts/design-check.ps1 -ChangeDir agent-flow/changes/xxx
agent-flow/scripts/alignment-check.ps1 -ChangeDir agent-flow/changes/xxx
agent-flow/scripts/task-check.ps1 -ChangeDir agent-flow/changes/xxx
```

### 收口阶段（Phase 3）

```powershell
agent-flow/scripts/plan-check.ps1 -ChangeDir agent-flow/changes/xxx
agent-flow/scripts/code-drift-check.ps1 -ChangeDir agent-flow/changes/xxx
agent-flow/scripts/blocked-check.ps1 -ChangeDir agent-flow/changes/xxx
agent-flow/scripts/task-boundary-check.ps1 -ChangeDir agent-flow/changes/xxx
agent-flow/scripts/closure-check.ps1 -ChangeDir agent-flow/changes/xxx
agent-flow/scripts/evolution-check.ps1 -ChangeDir agent-flow/changes/xxx
agent-flow/scripts/run-verify.ps1 -All
```

### 分析工具（Phase 4）

```powershell
agent-flow/scripts/dashboard.ps1
agent-flow/scripts/evolution-suggest.ps1 -ProjectRoot .
agent-flow/scripts/gate-fatigue-check.ps1
agent-flow/scripts/pattern-discovery.ps1
agent-flow/scripts/knowledge-expiry-check.ps1
```

---

## 需要帮助？

- `docs/TROUBLESHOOTING.md` — 常见错误排查
- `agent-flow/FAQ.md` — 常见问题解答
- `docs/PROMPTS.md` — 常用 AI prompt 菜谱
