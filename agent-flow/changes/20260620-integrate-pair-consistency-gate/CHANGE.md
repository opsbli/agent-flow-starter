# Change: integrate-pair-consistency-gate

## 一句话需求

将 `pair-consistency-check` 从 tool 升级为正式 CI gate，在每次 push/PR 时自动检测 ps1/sh 脚本双轨差异。

## 流程级别

- [ ] Light
- [ ] Standard
- [x] Heavy
- [ ] Emergency

## 分级理由

触发 `heavy_if` 多项条件：(a) `workflow_change` — 修改 CI pipeline；(b) `public_api_change` — 变更 gate 注册表（manifest.yaml script_registry）；(c) 跨模块协作 — 涉及 CI、manifest、gates.txt、scripts 四个模块。

## 目标

- `pair-consistency-check` 从 tool 升级为 gate（非阻塞 advisory gate）
- CI 新增 `pair-consistency` job
- manifest.yaml 更新 script_registry 分类
- gates.txt 注册

## 工件索引

- State: STATE.md
- Requirement: REQUIREMENT.md
- Code Scan: CODE_SCAN.md
- Design: DESIGN.md
- Plan: PLAN.md
- Tasks: TASKS.md
- Verify: VERIFY.md
- Review: REVIEW.md
- Report: REPORT.md
- Audit: AUDIT.md
- Evolution: EVOLUTION.md
