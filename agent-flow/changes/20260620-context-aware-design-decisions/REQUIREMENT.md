# Requirement

## 背景

`agent-flow/templates/DESIGN.md` 模板始终包含 8 行后端设计决策项（REST Path、HTTP Method、Permission Code 等）。对于非后端项目（dev-toolkit、frontend-only），需要全部填 `not-applicable`，增加了不必要的形式主义开销。

此外，`design-check.sh` 和 `design-check.ps1` 已具备上下文感知跳过逻辑，但 project-root 检测路径在脚手架自检场景下失效。

## 用户角色

- agent-flow 使用者（非后端项目）：创建 change 时模板自动适配，无需逐行填 not-applicable
- agent-flow 使用者（后端项目）：模板保持完整 8 行，不受影响

## 目标

为设计决策表增加上下文感知，非后端项目可简化。

## 非目标

- 不改动 flow 分级
- 不改动 design-decision.keys 的内容

## 验收标准

| AC | Given | When | Then | 验证方式 |
|---|---|---|---|---|
| AC-01 | templates/DESIGN.md 存在 | 检查 API/Permission/Auth 节 | 包含非后端项目简化指引注释 | `grep` 确认 |
| AC-02 | dev-toolkit 项目内运行 design-check.sh | 检查后端决策行 | 跳过 8 行后端键（不报错） | mock 测试或路径修复验证 |
| AC-03 | dev-toolkit 项目内运行 design-check.ps1 | 检查后端决策行 | 跳过 8 行后端键（不报错） | mock 测试或路径修复验证 |
| AC-04 | 非后端项目运行 generate-design.sh | 检查输出 | 设计决策表为简化格式（单行汇总） | `grep` 确认 |
| AC-05 | 非后端项目运行 generate-design.ps1 | 检查输出 | 设计决策表为简化格式（单行汇总） | `grep` 确认 |
| AC-06 | 脚手架自身 change 运行 design-check | 项目根路径正确检测 | manifest.yaml 找到且 context-aware 跳过生效 | `bash agent-flow/scripts/design-check.sh` 通过 |
| AC-07 | 所有修改完成 | 运行 scaffold-health | 通过 | scaffold-health pass |
| AC-08 | 所有修改完成 | 运行 template-check | 通过 | template-check pass |

## 异常和边界

## 未决问题

## 用户确认记录
