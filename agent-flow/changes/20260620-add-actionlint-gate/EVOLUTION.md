# Evolution

problem: 之前 CI 中缺乏对 `.github/workflows/*.yml` 的静态验证，修改后只能通过 GitHub Actions 运行时发现错误。

knowledge: (1) actionlint 是 GitHub Actions workflow YAML 的静态分析工具，支持本地和 CI 运行。(2) 新增 gate 需要同步注册到 manifest.yaml（script_registry.gates 和 gates 两处）、gates.txt、check-change.sh/ps1。(3) CI 中使用 `continue-on-error: true` 保持非阻塞。

adr: 无新 ADR。

gate: ✅ 新增 `actionlint-check.ps1` 和 `actionlint-check.sh` — GitHub Actions workflow YAML 语法验证 gate。

template: 无。actionlint-check 是独立 gate，不修改模板。

no_change_reason: 仅新增 gate，不改动现有结构和流程。

## Improvement Tracker 更新

- [x] 已新增或更新 `agent-flow/knowledge/improvement-tracker.md`

| Item | Tracker ID | Status | Owner / Next Step |
|---|---|---|---|
| Add actionlint gate for CI YAML workflow validation | IMP-0023 | implemented | This change: add-actionlint-gate |
