# Evolution

problem: DESIGN.md Alignment 表列头与 alignment-check 期望不匹配。模板使用 `| Question | AI Recommended Answer | Confirmation | Final Decision |`，但 alignment-check 期望 `| # | Question | Confirmation | Evidence |`，导致 header 检测被静默跳过。

knowledge: (1) DESIGN.md 模板的 Alignment 表列头必须与 alignment-check.sh/ps1 的 header 检测一致（`#.*Question.*Confirmation`）。(2) 修改模板时必须同步更新 generate-design.ps1/.sh、test fixtures 和 test 数据中的副本。(3) `new-change.sh` 从模板复制生成 change DESIGN.md — 模板修正后新 change 自动使用正确列头。

adr: 无新 ADR。纯列名修正，不涉及架构决策。

gate: 无新 gate。alignment-check 已具备列数检测能力，修复模板后能正确触发。

template: DESIGN.md 模板的 Design Alignment 表列头已修正。见本 change。

no_change_reason: 本次修正覆盖了所有 source of truth 中的模板、生成脚本和测试数据。未来修改模板列头时需同步更新 8 个文件。

## 应写入 knowledge 的内容

- 无（本次修正已直接修改模板）

## 应新增或修改的 ADR

- 无

## 应新增的 gate

- 无

## 应调整的模板

- ✅ `templates/DESIGN.md` — 已修正

## Improvement Tracker 更新

- [x] 已新增或更新 `agent-flow/knowledge/improvement-tracker.md`

| Item | Tracker ID | Status | Owner / Next Step |
|---|---|---|---|
| Fix DESIGN.md Alignment table column headers to match alignment-check | IMP-0021 | implemented | This change: fix-design-alignment-table |
