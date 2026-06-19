# Design

## 设计目标

- AC-01: 新增 `api-compatibility-check` 门禁，解析 DESIGN.md 的 API / Permission / Auth 决策表，与代码交叉验证
- AC-02: 新增 `db-migration-check` 门禁，检查涉及 Schema 变更的 change 是否包含回滚 SQL
- AC-03: 注册新 Gate 到 manifest.yaml、gates.txt、check-change.ps1/.sh
- AC-04: 增强 `frontend-fit.md`，增加 Chrome DevTools 联调检查清单
- AC-05: 增强 `DESIGN.md` 模板，增加 DB 变更决策表和前端验证契约

## 设计约束

- 不引入外部依赖（纯 PowerShell / Bash）
- 新 Gate 必须成对（.ps1 + .sh）
- 兼容 Windows 和 Linux/macOS
- 不修改已有 Gate 脚本的接口或退出码约定

## 模块边界

| 模块 | 归属 | 设计决策 |
|------|------|----------|
| `api-compatibility-check` | 新 Gate | 解析 DESIGN.md API 决策表 + 扫描代码文件，默认非阻塞 warning |
| `db-migration-check` | 新 Gate | 检查 Heavy change 的 write_files 是否包含回滚文件 |
| `frontend-fit.md` | 增强 | 增加 Chrome DevTools 清单 + 全栈项目强制前端验证提示 |
| `templates/DESIGN.md` | 增强 | 增加 DB 变更决策表 + 前端验证契约 |

## 复用现有抽象

- `_common.ps1` / `_common.sh` — Get-FlowLevel, Test-Meaningful
- `code-drift-check` — DESIGN.md 解析模式、退出码约定
- `check-change.ps1` — Invoke-Gate 模式

## 不复用的原因

N/A

## 非功能需求

| 维度 | 要求 | 验证方式 |
|------|------|----------|
| 性能 | 单 Gate 执行 < 5s | 手动计时 |
| 兼容性 | PowerShell 5.1+ / Bash 3.2+ | scaffold-health |

## API 设计

N/A — agent-flow 自身不提供 API。

## API / Permission / Auth Decisions

必须明确记录，即使结论是 `unchanged` 或 `not-applicable`。

Decision Status: accepted

Allowed Decision Values: unchanged / new / modified / deleted / not-applicable

| Item | Decision | Evidence / Reason |
|---|---|---|
| REST Path | not-applicable | agent-flow has no REST API |
| HTTP Method | not-applicable | agent-flow has no REST API |
| Permission Code | not-applicable | agent-flow has no permission system |
| SaCheckPermission | not-applicable | agent-flow has no permission annotations |
| Anonymous Interface | not-applicable | agent-flow has no anonymous interfaces |
| Login/Token | not-applicable | agent-flow has no login/token system |
| Tenant/Data Permission | not-applicable | agent-flow has no multi-tenant data |
| State Machine Impact | not-applicable | agent-flow has no state machines |

State Machine Impact: not-applicable

## 数据设计

N/A — 不涉及数据模型。

## State Machine

State Machine Impact: not-applicable

## 详细设计：P1 — api-compatibility-check

### 目的

在实现后，自动验证 DESIGN.md 中声明的 API 路径、权限码、HTTP 方法是否与实际代码一致。

### 工作原理

DESIGN.md 解析 → 提取路径/方法/权限码 → 扫描 src/app/modules → 正则匹配 → 输出 warning（非阻塞）

### 关键设计决策

- 轻量启发式：不是精确 AST 解析，而是基于正则的模式匹配
- 默认非阻塞（warning 级别），可通过 manifest.yaml `strict_compatibility: true` 升级为 fail

## 详细设计：P2 — db-migration-check

### 目的

验证涉及 Schema 变更的 change 是否包含回滚 SQL 或回滚步骤。

### 工作原理

读取 CHANGE.md → Heavy/Standard? → 扫描 write_files → 检查回滚文件 → 输出 warning（非阻塞）

### 关键设计决策

- 非阻塞 warning：有些 schema 变更（如新增列）不需要回滚
- Heavy 级别限定：Light/Emergency 自动 SKIP
- 支持 CHANGE.md 中声明 `rollback: not-needed` 显式豁免

## 详细设计：P1 — frontend-fit.md 增强

### 新增内容

- Chrome DevTools 联调检查清单（Network/Console/Elements/Application）
- 交付前检查强制声明（含前端项目必须执行）
- 联调结果记录指引

## Design Alignment / Grill

Alignment Source: user-confirmed

Open Questions: none

| Question | AI Recommended Answer | Confirmation | Final Decision |
|---|---|---|---|
| Intent Risk | Change affects agent-flow scaffold only, no production risk | code-confirmed | Low risk |
| Existing Code Fit | New gates follow established pattern (code-drift-check + blocked-check) | user-confirmed | Pattern matched from existing gates |
| Unnecessary Abstraction | No new abstraction needed | code-confirmed | Standalone scripts only |
| Protected Areas | frontend-fit.md, DESIGN.md, manifest.yaml | user-confirmed | Documented in write_files |
| Boundary And Failure Modes | Gates are warning-only; manual confirm needed | user-confirmed | Non-blocking design |
| Non-blocking vs strict mode | Default warning, strict via manifest.yaml | user-confirmed | Non-blocking + optional strict |
| Rollback判定边界 | 统一查 rollback 文件，支持显式豁免 | user-confirmed | warning 而非 fail |
| 前端清单强制程度 | 本次做参考清单，后续加开关 | user-confirmed | 分步走 |

Alignment Verdict: aligned

Skip Reason:
