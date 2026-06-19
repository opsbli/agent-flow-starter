# Plan

Plan Status: completed

## Current Baseline

The live baseline showed these failures: `manifest-check` rejected valid `blocked_if` rows with inline comments, `run-verify` truncated quoted echo commands, `check-change.sh` had a malformed `ac-traceability-check` invocation and BOM, `check-change.ps1` had malformed aggregate gate arguments, and PowerShell syntax checks failed on corrupted output strings.

## Goals

- AC-01: Restore aggregate gate execution on Windows and Bash.
- AC-02: Remove manifest inline-comment false positives.
- AC-03: Preserve quoted verification commands.
- AC-04: Restore script syntax validity and avoid corrupted status literals.
- AC-05: Make the sample change runnable under current gates.

## Non-Goals

- No process-level routing redesign.
- No full cleanup of unrelated Unicode output.
- No application business code changes.

## Execution Phases

1. Fix aggregate gate calls and verification command parsing.
2. Fix manifest parser false positives and script encoding damage.
3. Align `new-change` smoke tests with generated prefixed ids.
4. Refresh the runnable sample change.
5. Run syntax, smoke, manifest, verify, sample aggregate, and starter self-tests.

## read_files

- `agent-flow/scripts/check-change.ps1`
- `agent-flow/scripts/check-change.sh`
- `agent-flow/scripts/run-verify.ps1`
- `agent-flow/scripts/run-verify.sh`
- `agent-flow/scripts/manifest-check.ps1`
- `agent-flow/scripts/manifest-check.sh`
- `agent-flow/scripts/scaffold-health.ps1`
- `agent-flow/scripts/scaffold-health.sh`
- `agent-flow/scripts/blocked-check.ps1`
- `agent-flow/scripts/blocked-check.sh`
- `agent-flow/scripts/_common.ps1`
- `agent-flow/scripts/_common.sh`
- `agent-flow/test/test-scripts/test-new-change.ps1`
- `agent-flow/test/test-scripts/test-new-change.sh`
- `scripts/test-starter.ps1`
- `scripts/test-starter.sh`
- `examples/sample-change/CODE_SCAN.md`

## write_files

- `agent-flow/scripts/_common.ps1`
- `agent-flow/scripts/_common.sh`
- `agent-flow/scripts/ac-traceability-check.ps1`
- `agent-flow/scripts/ac-traceability-check.sh`
- `agent-flow/scripts/check-change.ps1`
- `agent-flow/scripts/check-change.sh`
- `agent-flow/scripts/incremental-verify.ps1`
- `agent-flow/scripts/incremental-verify.sh`
- `agent-flow/scripts/manifest-check.ps1`
- `agent-flow/scripts/manifest-check.sh`
- `agent-flow/scripts/scaffold-health.ps1`
- `agent-flow/scripts/scaffold-health.sh`
- `agent-flow/scripts/blocked-check.ps1`
- `agent-flow/scripts/blocked-check.sh`
- `agent-flow/scripts/new-change.ps1`
- `agent-flow/scripts/new-change.sh`
- `agent-flow/scripts/run-verify.ps1`
- `agent-flow/scripts/run-verify.sh`
- `agent-flow/test/test-scripts/test-new-change.ps1`
- `agent-flow/test/test-scripts/test-new-change.sh`
- `scripts/test-starter.ps1`
- `scripts/test-starter.sh`
- `examples/sample-change/CODE_SCAN.md`
- `examples/sample-change/STATE.md`

## Exit Criteria

- PowerShell script parser passes for all starter scripts.
- Bash syntax check passes for all starter scripts and test scripts.
- `manifest-check.ps1` and `manifest-check.sh` pass.
- `run-verify.ps1 -All` and `run-verify.sh --all` pass.
- `test-new-change.ps1` and `test-new-change.sh` pass.
- `check-change` passes on `examples/sample-change` on both platforms.

## Verification

Use direct repro commands for AC-01 through AC-05, then run the starter self-tests.

## Closure Gates

Run `scan-check`, `design-check`, `alignment-check`, `task-check`, `plan-check`, `ac-check`, `coverage-check`, `code-drift-check`, `blocked-check`, `task-boundary-check`, `manifest-check`, `emergency-check`, `evolution-check`, and `closure-check` via `check-change`.

## Protected Area Review

Protected areas are limited to starter gate scripts and tests. No auth, schema, API, production config, or business module behavior is modified.
