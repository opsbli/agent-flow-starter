# Design

## 设计概述

将 `pair-consistency-check` 从 tool 分类升级为 advisory gate，在 CI 中新增非阻塞 job 自动运行。Gate 仅产生 warning 不阻塞 CI。

## 关键决策

| # | 决策点 | 选项 A | 选项 B | 选择 | 理由 |
|---|--------|--------|--------|------|------|
| D-01 | Gate 类型 | blocking gate | advisory gate | **advisory** | 双轨差异是维护债信号，不是安全/bug 风险，不应阻塞 CI |
| D-02 | CI 运行位置 | 每次 push/PR | 仅 cron 周检 | **每次 push** | 增量检测开销 < 1s，值得每次运行以尽早发现新差异 |
| D-03 | 阈值 | 30%（现有） | 20%（更严格） | **30%** | 保持与 CLI 工具一致的阈值，避免 CI 噪音 |
| D-04 | REST Path | — | — | **not-applicable** | CI 配置变更 |
| D-05 | HTTP Method | — | — | **not-applicable** | CI 配置变更 |
| D-06 | Permission Code | — | — | **not-applicable** | 无权限变更 |
| D-07 | SaCheckPermission | — | — | **not-applicable** | 无权限变更 |
| D-08 | Anonymous Interface | — | — | **not-applicable** | 无接口变更 |
| D-09 | Login/Token | — | — | **not-applicable** | 无认证变更 |
| D-10 | Tenant/Data Permission | — | — | **not-applicable** | 无租户变更 |
| D-11 | State Machine Impact | — | — | **not-applicable** | 无状态机影响 |

Decision Status: accepted

State Machine Impact: not-applicable

This change has no state machine or workflow impact (CI configuration only).

## Design Alignment / Grill

Alignment Source: mixed

Open Questions: none

| # | Question | Confirmation | Evidence |
|---|---------|-------------|----------|
| Intent Risk | 将 tool 升级为 gate 是否可能改变用户对"gate"概念的认知？建议：**否**，advisory gate 概念已在 coverage-check、design-quality-check 中建立。 | user-confirmed | design-quality-check 已有 "non-blocking quality advisory" 先例 |
| Existing Code Fit | 新增 CI job 是否遵循现有模式？建议：**是**，完全复用 `needs: scaffold-health` + `continue-on-error: true` 模式。 | code-confirmed | static-analysis job (L204-234) 使用相同模式 |
| Unnecessary Abstraction | 是否引入了不必要的抽象？建议：**否**，直接在 CI 中调用已有脚本，零新增抽象。 | code-confirmed | pair-consistency-check.sh 已存在且可独立运行 |
| Protected Areas | 是否触碰受保护区域？建议：**否**，脚本自身不变，仅改变元数据分类和 CI 调用方式。 | user-confirmed | manifest.yaml 和 CI 的变更均是可逆的元数据修改 |
| Boundary And Failure Modes | 失败模式是否已评估？建议：**已评估**。脚本自身可能因新脚本加入而发现新差异，`continue-on-error: true` 兜底。 | user-confirmed | static-analysis job 验证了 non-blocking gate 模式的安全性 |

Alignment Verdict: aligned

## 实现路径

1. 更新 `manifest.yaml` — script_registry: pair-consistency-check 从 tools 移至 gates
2. 更新 `gates.txt` — 确认已注册
3. 更新 `.github/workflows/scaffold-ci.yml` — 新增 `pair-consistency` job
4. 运行 scaffold-health 验证
