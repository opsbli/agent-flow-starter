# Evolution

problem: design-check.sh/ps1 的 project_root 检测路径 `change_dir/../..` 在 agent-flow-starter 自身 change（`agent-flow/changes/xxx`）中解析错误，导致 manifest.yaml 找不到，context-aware 跳过逻辑不生效。另，State Machine Impact 未被纳入 backend_keys，非后端项目仍被要求填写。

knowledge: (1) design-check.sh 和 design-check.ps1 的 context-aware 逻辑需要正确检测 project_root。`agent-flow/changes/xxx` 需要 `../../..` 才能回到项目根目录。(2) backend_keys 需包含 `State Machine Impact` 键，同时 State Machine Impact 节检查也需要跳过。(3) templates/DESIGN.md 模板注释可指引非后端用户简化设计决策表。

adr: 无新 ADR。

gate: 无新 gate。现有 design-check 逻辑扩展。

template: templates/DESIGN.md 和 test fixture 增加了非后端项目简化指引注释。

no_change_reason: generate-design 脚本使用独立的 "API & Permissions" 格式，不输出 8 行设计决策表，无需修改。

## Improvement Tracker 更新

- [x] 已新增或更新 `agent-flow/knowledge/improvement-tracker.md`

| Item | Tracker ID | Status | Owner / Next Step |
|---|---|---|---|
| Context-aware design-decision skipping for non-backend projects | IMP-0022 | implemented | This change: context-aware-design-decisions |
