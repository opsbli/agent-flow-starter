# Requirement

## Summary

Re-score the current `agent-flow` starter from development workflow dimensions and determine whether tracked scaffold fixes are needed to reach 9.0.

## Goals

- AC-01: Produce a current multi-dimensional score based on live repository evidence.
- AC-02: Verify the scaffold baseline with Windows and bash health/self-test commands.
- AC-03: Identify strong areas and ordered optimization opportunities.
- AC-04: Avoid tracked scaffold edits when the current score is already at or above 9.0.

## Non-Goals

- No new workflow stage.
- No new dependency.
- No changes to starter-owned scripts, templates, gates, or root workflow unless a regression blocks the 9.0 target.
- No target-project business history or domain facts in the starter.

## Acceptance Criteria

| AC | Description | Evidence |
|---|---|---|
| AC-01 | Current scorecard covers flow, gates, templates, cross-platform parity, install/upgrade, knowledge, CI, security, and maintainability. | `REPORT.md` scorecard |
| AC-02 | Baseline commands pass on both PowerShell and bash paths. | `VERIFY.md` command log |
| AC-03 | Remaining optimization items are ordered and scoped. | `REPORT.md` optimization list |
| AC-04 | No tracked scaffold edits are made when live score is already >= 9.0. | `git status`, `git ls-files` evidence |

## Assumptions

- The previous 9.0 hardening record is historical context, but the current score must be verified from live files and commands.
- A score above 9.0 means no mandatory fix is required for the user's stated target.

## Constraints

- Starter remains generic.
- `agent-flow/changes`, `agent-flow/logs`, and `agent-flow/reports` remain project-owned history areas and are ignored except `.gitkeep`.
