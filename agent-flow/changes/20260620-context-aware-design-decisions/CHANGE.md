# Change: context-aware-design-decisions

## 一句话需求

为 DESIGN.md 模板的 API/Permission/Auth 设计决策表增加上下文感知能力：非后端项目（dev-toolkit、frontend-only）可简化为一行的汇总声明；同时修复 design-check 脚本的 project-root 检测。

## 背景

`agent-flow/templates/DESIGN.md` 模板始终包含 8 行后端设计决策项（REST Path、HTTP Method、Permission Code 等）。对于非后端项目（如 agent-flow-starter 自身——一个 dev-toolkit），每次都要全部填 `not-applicable`，显得形式化。

同时：
- `design-check.sh` 和 `design-check.ps1` 已具备上下文感知跳过逻辑，但 project-root 检测方法（`$change_dir/../..`）在 agent-flow-starter 自身的 change（`agent-flow/changes/xxx`）中解析路径错误——`../..` 解析到 `agent-flow/` 而非项目根目录，导致 manifest.yaml 找不到，跳过逻辑不生效
- `generate-design.sh` 和 `generate-design.ps1` 始终输出完整的 8 行表格，不会根据项目类型简化

## 流程级别

- [ ] Light
- [x] Standard
- [ ] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由

修改模板和脚本逻辑，但不涉及 schema/权限/API。属于 Standard。

## 目标

- `templates/DESIGN.md`：增加非后端项目简化指引注释
- `design-check.sh`：修复 project-root 检测，增加 fallback 路径
- `design-check.ps1`：修复 project-root 检测，增加 fallback 路径
- `generate-design.sh`：读取 manifest.yaml，非后端项目输出简化表格
- `generate-design.ps1`：同上
- 所有 test fixtures 和 smoke/integration tests 同步更新
- EVOLUTION.md 中来自 shell-lint-ci change 的改进建议得到解决

## 非目标

- 不改动 flow 分级逻辑
- 不改动 alignment-check 或其他 gates
- 不经修改 design-decision.keys 本身

## 影响范围

- `agent-flow/templates/DESIGN.md`
- `agent-flow/scripts/design-check.sh`
- `agent-flow/scripts/design-check.ps1`
- `agent-flow/scripts/generate-design.sh`
- `agent-flow/scripts/generate-design.ps1`
- `agent-flow/test/fixtures/minimal-project/agent-flow/templates/DESIGN.md`
- `agent-flow/test/test-scripts/test-gate-smoke.sh`
- `agent-flow/test/test-scripts/test-gate-smoke.ps1`
- `agent-flow/test/test-scripts/test-check-change.sh`
- `agent-flow/test/test-scripts/test-check-change.ps1`

## 关联前端

- [x] 否

## 风险

- **低**：模板指引注释不影响逻辑；design-check 路径修复增加 fallback，不改变正常流程行为；generate-design 行为变化仅影响非后端项目

## Emergency（仅 Emergency 流程填写）

- Level: P0 / P1
- Approved by:
- Bypass reason:
- Backfill deadline:
- Backfill status: pending / done / waived

## 工件索引

- State:
- Requirement:
- Code Scan:
- Design:
- Tasks:
- Verify:
- Report:
- Evolution:
