---
description: agent-flow 完整流程 — 从需求到交付一站式执行
argument-hint: "<需求描述>"
---
# agent-flow Full Workflow

> 按 agent-flow 完整流程处理需求。先做 code-first 扫描，判断 Light/Standard/Heavy。

需求：$@

## 自动执行链

1. **读取规则** → `agent-flow/GO.md`
2. **建立 change** → 生成 change-id，建目录
3. **CODE_SCAN** → 使用 /af-scan $@ 或 @ecc-explorer
4. **分级** → 按 router.md 判断 Light/Standard/Heavy
5. **设计** → /af-design $@（Standard/Heavy 需要）
6. **审计** → /ecc-security + Plan Audit（Heavy 需要）
7. **实现** → 按 write_files 边界编码
8. **验证** → /af-verify <change-id>
9. **报告** → REPORT.md + EVOLUTION.md
10. **沉淀** → 更新 knowledge/、必要时更新 decisions/

## 门禁检查
每步完成后运行对应 check 脚本。
最后运行 `check-change -Closure` 收口。
