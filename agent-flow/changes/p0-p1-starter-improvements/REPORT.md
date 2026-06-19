# Report

## Change

`p0-p1-starter-improvements`

## 完成内容

- P0：`manifest-check.ps1/.sh` 输出 TODO 分类和 next steps。
- P0：`ac-check.ps1/.sh` 改为验证 `VERIFY.md` 的 AC Evidence 表。
- P0：`scripts/test-starter.ps1/.sh` 增加 scan/design/alignment/ac/code-drift/blocked/task-boundary 负例。
- P1：新增 `agent-flow/knowledge/improvement-tracker.md`。
- P1：新增 `agent-flow/decisions/INDEX.md`，并补充 ADR 状态生命周期说明。
- P1：根 README 和 `agent-flow/README.md` 增加 3 分钟快速开始。
- P1：`DESIGN.md` 增加 UI Flow / Component Tree 和 Demo Evidence。
- 同步 minimal-project fixture 并把新文件纳入 `scaffold-health`。

## 修改文件

- `README.md`
- `agent-flow/README.md`
- `agent-flow/scripts/manifest-check.ps1`
- `agent-flow/scripts/manifest-check.sh`
- `agent-flow/scripts/ac-check.ps1`
- `agent-flow/scripts/ac-check.sh`
- `agent-flow/scripts/scaffold-health.ps1`
- `agent-flow/scripts/scaffold-health.sh`
- `scripts/test-starter.ps1`
- `scripts/test-starter.sh`
- `agent-flow/templates/DESIGN.md`
- `agent-flow/templates/EVOLUTION.md`
- `agent-flow/knowledge/improvement-tracker.md`
- `agent-flow/decisions/README.md`
- `agent-flow/decisions/INDEX.md`
- `agent-flow/test/fixtures/minimal-project/agent-flow/...`
- `agent-flow/changes/p0-p1-starter-improvements/...`

## 验证证据

- `agent-flow/scripts/scaffold-health.ps1`: pass.
- `bash agent-flow/scripts/scaffold-health.sh`: pass.
- `agent-flow/scripts/manifest-check.ps1`: pass with TODO guidance.
- `bash agent-flow/scripts/manifest-check.sh`: pass with TODO guidance.
- PowerShell parser over script files: pass.
- `bash -n agent-flow/scripts/ac-check.sh`: pass.
- `bash -n agent-flow/scripts/manifest-check.sh`: pass.
- `scripts/test-starter.ps1`: pass.
- `bash scripts/test-starter.sh`: pass.
- `task-boundary-check.ps1/.sh`: pass.

## 未完成事项

- 无。

## 风险和回滚

- 风险：旧 change 如果没有 `AC Evidence` 表，新的 `ac-check` 会失败。
- 处理：补齐 `VERIFY.md` 表格，或在历史 change 中记录明确跳过/迁移原因。
- 回滚：还原上述脚本、模板、README、fixture 和新增 knowledge/decision 文件。

## 知识沉淀

- `agent-flow/knowledge/improvement-tracker.md`

## 决策沉淀

- `agent-flow/decisions/INDEX.md`
- `agent-flow/decisions/README.md`

## 日志和基线

- Log: not required; starter process change is documented in this change folder.
- Known-Good Baseline: not updated; no runtime baseline.

## 审计

- Plan Audit: accept.
- Closure Audit: acceptable.

## 后续建议

- Consider adding more gate-specific negative tests as future failures are discovered.
