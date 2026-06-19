# Change: 20260615-agent-flow-starter-fix-gate-script-reliability

## 一句话需求

Fix the starter gate scripts in priority order so core checks, verification commands, and example closeout are runnable on Windows and Bash.

## 背景

Live verification found several starter reliability failures: `check-change.sh` had a broken gate call and BOM, `check-change.ps1` had a malformed `ac-traceability-check` invocation, `run-verify` truncated quoted echo commands, `manifest-check` rejected valid `blocked_if` rows with inline comments, PowerShell scripts contained broken encoded status strings, and `examples/sample-change` drifted from current `scan-check` rules.

## 流程级别

- [ ] Light
- [ ] Standard
- [x] Heavy
- [ ] Emergency（仅限 P0/P1 生产事故）

## 分级理由

This changes the starter's cross-platform gate chain, verification runner, common helper semantics, smoke tests, and runnable example. A broken gate chain can falsely block or falsely pass future agent-flow changes.

## 目标

- Restore Windows and Bash syntax validity for changed scripts.
- Make `manifest-check` accept valid inline comments on `blocked_if` rules.
- Make `run-verify` preserve quotes inside command values.
- Make `check-change` run `ac-check`, `ac-traceability-check`, and `coverage-check` on both platforms.
- Make `new-change` and its smoke tests agree on prefixed change ids.
- Make `examples/sample-change` pass the current aggregate gate chain.

## 非目标

- No redesign of the Light, Standard, Heavy, or Emergency process.
- No broad replacement of all non-ASCII output in unrelated scripts.
- No business-project-specific rules.

## 影响范围

- `agent-flow/scripts/`
- `agent-flow/test/test-scripts/`
- `examples/sample-change/`
- This change's own closeout artifacts.

## 关联前端

- [x] 否
- [ ] 是：`none`

## 风险

- Gate parser changes can affect future false-positive and false-negative behavior.
- Test updates must avoid hard-coding generated date or project prefixes.

## 需要用户确认的问题

- None. User requested the ordered repairs.

## Emergency（仅 Emergency 流程填写）

- Level: none
- Approved by: none
- Bypass reason: none
- Backfill deadline: none
- Backfill status: none

## 工件索引

- State: `STATE.md`
- Requirement: `REQUIREMENT.md`
- Code Scan: `CODE_SCAN.md`
- Design: `DESIGN.md`
- Tasks: `TASKS.md`
- Verify: `VERIFY.md`
- Report: `REPORT.md`
- Evolution: `EVOLUTION.md`
