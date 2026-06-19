# Code Scan

## 扫描时间

2026-06-15 00:00

## Machine Check

scan_time: 2026-06-15 00:00
related_modules: agent-flow/scripts, agent-flow/test/test-scripts, examples/sample-change
similar_implementations: agent-flow/scripts/check-change.ps1, agent-flow/scripts/check-change.sh, agent-flow/scripts/run-verify.ps1, agent-flow/scripts/run-verify.sh
reusable_abstractions: agent-flow/scripts/_common.ps1 and agent-flow/scripts/_common.sh helper functions
test_baseline: syntax checks, manifest-check, run-verify, test-new-change, sample check-change
read_files: agent-flow/GO.md, agent-flow/manifest.yaml, agent-flow/core/source-of-truth.md, agent-flow/core/evolution.md, agent-flow/scripts/blocked-check.ps1, agent-flow/scripts/blocked-check.sh, agent-flow/scripts/check-change.ps1, agent-flow/scripts/check-change.sh, agent-flow/scripts/run-verify.ps1, agent-flow/scripts/run-verify.sh, agent-flow/scripts/manifest-check.ps1, agent-flow/scripts/manifest-check.sh, agent-flow/scripts/scaffold-health.ps1, agent-flow/scripts/scaffold-health.sh, agent-flow/scripts/_common.ps1, agent-flow/scripts/_common.sh, agent-flow/scripts/ac-traceability-check.ps1, agent-flow/scripts/ac-traceability-check.sh, agent-flow/scripts/incremental-verify.ps1, agent-flow/scripts/incremental-verify.sh, agent-flow/scripts/new-change.ps1, agent-flow/scripts/new-change.sh, agent-flow/test/test-scripts/test-new-change.ps1, agent-flow/test/test-scripts/test-new-change.sh, scripts/test-starter.ps1, scripts/test-starter.sh, examples/sample-change/CODE_SCAN.md
write_files: agent-flow/scripts/_common.ps1, agent-flow/scripts/_common.sh, agent-flow/scripts/ac-traceability-check.ps1, agent-flow/scripts/ac-traceability-check.sh, agent-flow/scripts/blocked-check.ps1, agent-flow/scripts/blocked-check.sh, agent-flow/scripts/check-change.ps1, agent-flow/scripts/check-change.sh, agent-flow/scripts/incremental-verify.ps1, agent-flow/scripts/incremental-verify.sh, agent-flow/scripts/manifest-check.ps1, agent-flow/scripts/manifest-check.sh, agent-flow/scripts/new-change.ps1, agent-flow/scripts/new-change.sh, agent-flow/scripts/run-verify.ps1, agent-flow/scripts/run-verify.sh, agent-flow/scripts/scaffold-health.ps1, agent-flow/scripts/scaffold-health.sh, agent-flow/test/test-scripts/test-new-change.ps1, agent-flow/test/test-scripts/test-new-change.sh, scripts/test-starter.ps1, scripts/test-starter.sh, examples/sample-change/CODE_SCAN.md, examples/sample-change/STATE.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/CHANGE.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/REQUIREMENT.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/CODE_SCAN.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/DESIGN.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/PLAN.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/TASKS.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/VERIFY.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/REVIEW.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/REPORT.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/AUDIT.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/EVOLUTION.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/STATE.md, agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/CHECK_RESULT.json
open_questions: none

## 相关模块

- `agent-flow/scripts/check-change.*`: aggregate gate runner.
- `agent-flow/scripts/run-verify.*`: manifest verification command runner.
- `agent-flow/scripts/manifest-check.*`: starter manifest and gate list validation.
- `agent-flow/scripts/scaffold-health.*`: installed scaffold health validation.
- `agent-flow/scripts/blocked-check.*`: blocked_if scanner for Heavy closure.
- `agent-flow/scripts/ac-traceability-check.*`: AC traceability gate.
- `agent-flow/scripts/incremental-verify.*`: changed-file verification helper.
- `agent-flow/scripts/new-change.*`: change scaffold generator.
- `agent-flow/test/test-scripts/test-new-change.*`: smoke tests for change id generation and artifact creation.
- `examples/sample-change/`: runnable sample change.

## 相似实现

| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| Gate aggregation | `agent-flow/scripts/check-change.ps1` and `.sh` | Keep gate names and skip/pass/fail semantics aligned |
| Meaningfulness checks | `agent-flow/scripts/_common.ps1` and `.sh` | Reuse placeholder filtering instead of local ad hoc filters |
| Smoke test shape | `agent-flow/test/test-scripts/test-new-change.ps1` and `.sh` | Keep Windows and Bash assertions equivalent |

## 可复用抽象

- Use the existing `_common` helper layer for meaningful value filtering.
- Keep cross-platform behavior aligned by applying equivalent parser changes in `.ps1` and `.sh`.

## 禁止重复实现

- Do not introduce a new YAML parser dependency.
- Do not create a second aggregate gate runner.

## Maven / 模块影响

None.

## 数据库扫描

No database files involved.

## 权限扫描

No auth or permission behavior involved.

## API / 路由扫描

No application API or route files involved.

## 前端扫描

No frontend files involved.

## 测试基线

- Existing syntax checks failed before the fix for broken PowerShell strings and `check-change.sh`.
- `manifest-check` failed before the fix on valid inline comments.
- `run-verify` failed before the fix on quoted echo commands.
- `test-new-change` needed to tolerate date and project prefixes.

## read_files

read_files:
  - agent-flow/GO.md
  - agent-flow/manifest.yaml
  - agent-flow/core/source-of-truth.md
  - agent-flow/core/evolution.md
  - agent-flow/scripts/check-change.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/run-verify.ps1
  - agent-flow/scripts/run-verify.sh
  - agent-flow/scripts/manifest-check.ps1
  - agent-flow/scripts/manifest-check.sh
  - agent-flow/scripts/scaffold-health.ps1
  - agent-flow/scripts/scaffold-health.sh
  - agent-flow/scripts/blocked-check.ps1
  - agent-flow/scripts/blocked-check.sh
  - agent-flow/scripts/_common.ps1
  - agent-flow/scripts/_common.sh
  - agent-flow/scripts/ac-traceability-check.ps1
  - agent-flow/scripts/ac-traceability-check.sh
  - agent-flow/scripts/incremental-verify.ps1
  - agent-flow/scripts/incremental-verify.sh
  - agent-flow/scripts/new-change.ps1
  - agent-flow/scripts/new-change.sh
  - agent-flow/test/test-scripts/test-new-change.ps1
  - agent-flow/test/test-scripts/test-new-change.sh
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - examples/sample-change/CODE_SCAN.md

## write_files

write_files:
  - agent-flow/scripts/_common.ps1
  - agent-flow/scripts/_common.sh
  - agent-flow/scripts/ac-traceability-check.ps1
  - agent-flow/scripts/ac-traceability-check.sh
  - agent-flow/scripts/check-change.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/incremental-verify.ps1
  - agent-flow/scripts/incremental-verify.sh
  - agent-flow/scripts/manifest-check.ps1
  - agent-flow/scripts/manifest-check.sh
  - agent-flow/scripts/scaffold-health.ps1
  - agent-flow/scripts/scaffold-health.sh
  - agent-flow/scripts/blocked-check.ps1
  - agent-flow/scripts/blocked-check.sh
  - agent-flow/scripts/new-change.ps1
  - agent-flow/scripts/new-change.sh
  - agent-flow/scripts/run-verify.ps1
  - agent-flow/scripts/run-verify.sh
  - agent-flow/test/test-scripts/test-new-change.ps1
  - agent-flow/test/test-scripts/test-new-change.sh
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - examples/sample-change/CODE_SCAN.md
  - examples/sample-change/STATE.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/CHANGE.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/REQUIREMENT.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/CODE_SCAN.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/DESIGN.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/PLAN.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/TASKS.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/VERIFY.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/REVIEW.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/REPORT.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/AUDIT.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/EVOLUTION.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/STATE.md
  - agent-flow/changes/20260615-agent-flow-starter-fix-gate-script-reliability/CHECK_RESULT.json

## 破坏性变更

None. Parser changes are compatibility fixes for valid existing inputs.

## 未决问题

- none
