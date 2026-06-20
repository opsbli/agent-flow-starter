# Evolution

problem: pair-consistency-check 之前仅作为 tool（需手动运行），未在 CI 中自动执行。升级为 gate 后确保每次 push/PR 自动检测 ps1/sh 脚本双轨差异。

knowledge: (1) pair-consistency-check 比较 .ps1 和 .sh 脚本的关键逻辑行（函数名、参数、分支条件），检测双轨 drift。(2) 从 tool 升级为 gate 需要更新 manifest.yaml 两处（script_registry 分类 + gates 注册）、gates.txt、check-change 注册、CI workflow。(3) 作为 advisory gate 使用 `continue-on-error: true`，不阻塞 CI。

adr: 无新 ADR。gate 升级不影响架构决策。

gate: ✅ pair-consistency-check 已从 tool 升级为 gate（advisory），在 CI 中自动运行。

template: 无变化。

no_change_reason: 本次 change 仅涉及 gate 注册和 CI 配置，不改动模板、知识库或流程分级。

## Improvement Tracker 更新

- [ ] 不需要跟踪，原因：本次 change 是工具升级，不涉及新改进建议。
- [ ] 已新增或更新 `agent-flow/knowledge/improvement-tracker.md`
