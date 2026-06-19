# Change

## Goals

1. 新增 `api-compatibility-check` 门禁，在实现后自动验证 API / Permission 声明与实际代码的一致性
2. 增强 `agent-flow/core/frontend-fit.md`，增加 Chrome DevTools 联调检查清单和前端验证强制要求
3. 新增 `db-migration-check` 门禁，验证涉及 Schema 变更的 change 是否包含回滚 SQL

## Non-Goals

- 不改动核心路由逻辑（router.md 分级标准不变）
- 不改动现有 Gate 脚本的退出码或接口约定
- 不引入外部测试框架依赖
- 不修改 principles.md / source-of-truth.md / evolution.md 等核心设计文档

## Risk Level

Medium — 新增门禁和修改模板不影响现有 Change 流程，但要保证跨平台脚本一致性

## Flow Level

- [ ] Light
- [ ] Standard
- [x] Heavy
- [ ] Emergency

## Classification Reason

Heavy: adds new gate script pairs (.ps1 + .sh), modifies templates (DESIGN.md), enhances flow files (frontend-fit.md), and registers gates in manifest.yaml / gates.txt / check-change.ps1/.sh.

rollback: not-needed (gate scripts are not database migrations)

## User Roles

- AI Agent 作为执行者
- Developer 作为批准者和验证者

## Business Boundary

仅限于 agent-flow 脚手架自身的改进，不涉及被 agent-flow 管理的业务项目

## Frontend Involved

No — agent-flow 本身没有前端

## AI Autonomy Level

implement-with-gates — 实现后需要通过 scaffold-health 和现有的门禁验证

## Protected Areas

- agent-flow/core/ → 修改 frontend-fit.md，需确认
- agent-flow/templates/ → 修改 DESIGN.md，需确认
- agent-flow/manifest.yaml → 登记新 Gate，需确认
