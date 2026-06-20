# Requirement

## 背景

`agent-flow/templates/DESIGN.md` 模板中 Design Alignment / Grill 表格使用了 `| Question | AI Recommended Answer | Confirmation | Final Decision |` 列头，但 `alignment-check.ps1` 和 `alignment-check.sh` 期望的是 `| # | Question | Confirmation | Evidence |`。

这导致：
1. alignment-check 的 header 检测（查找 `#` 和 `Question` 模式）无法识别模板列头，column-count 安全检测被静默跳过
2. 新用户按模板创建 DESIGN.md 后，若意外增加列数，alignment-check 不会报错

相同的错误列头也出现在 `generate-design` 脚本、test fixtures 和 smoke/integration tests 中，需要一并修正。

## 用户角色

- agent-flow 使用者：创建 change 时从模板得到正确的列头
- agent-flow 维护者：运行 test suite 时测试不会因列头检测失败

## 目标

将所有 source of truth 中 Alignment 表的列头统一为 `| # | Question | Confirmation | Evidence |`。

## 非目标

- 不改动 alignment-check 的检测逻辑
- 不改动 alignment 表格的 question 列表内容
- 不改动其他模板章节

## 验收标准

| AC | Given | When | Then | 验证方式 |
|---|---|---|---|---|
| AC-01 | 存在 templates/DESIGN.md | 检查 Alignment 表列头 | 列头为 `| # | Question | Confirmation | Evidence |` | `grep` 确认 |
| AC-02 | 存在 generate-design.sh | 检查输出模板 | 生成的 Alignment 表使用正确列头 | `grep` 确认 |
| AC-03 | 存在 generate-design.ps1 | 检查输出模板 | 生成的 Alignment 表使用正确列头 | `grep` 确认 |
| AC-04 | 存在 test fixtures | 检查 template | fixture 中 Alignment 表使用正确列头 | `grep` 确认 |
| AC-05 | 存在 test-gate-smoke.sh | 检查 smoke test DESIGN.md | 使用正确列头和数据行编号 | `grep` 确认 |
| AC-06 | 存在 test-gate-smoke.ps1 | 检查 smoke test DESIGN.md | 使用正确列头和数据行编号 | `grep` 确认 |
| AC-07 | 存在 test-check-change.sh | 检查 test DESIGN.md | 使用正确列头和数据行编号 | `grep` 确认 |
| AC-08 | 存在 test-check-change.ps1 | 检查 test DESIGN.md | 使用正确列头和数据行编号 | `grep` 确认 |
| AC-09 | 所有修改完成 | 运行 scaffold-health | 所有检查通过 | `bash agent-flow/scripts/scaffold-health.sh` |

## 异常和边界

## 未决问题

## 用户确认记录
