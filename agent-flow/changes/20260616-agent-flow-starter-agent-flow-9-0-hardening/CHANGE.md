# Change: 20260616-agent-flow-starter-agent-flow-9-0-hardening

## One-line Request

Raise agent-flow-starter from the reviewed 8.4 state to roughly 9.0 by hardening distribution hygiene, cross-platform behavior, alignment semantics, closure aggregation, and CI ownership.

## Background

The latest review found that the scaffold is already strong, but several contract mismatches keep it below 9.0:

- New installs can copy starter-local `changes/`, `logs/`, and `reports/` history into business projects.
- `Design Alignment` documentation says at least three confirmations must be `user-confirmed`, while the gate accepts generic `confirmed`.
- `init-project.sh` reports fewer TODO placeholders than `init-project.ps1` for empty projects because missing directory probes fall back to the first candidate.
- `check-change --closure` can skip missing artifacts instead of failing according to flow-level completion requirements.
- CI has overlapping workflows that can drift.

## Flow Level

- [ ] Light
- [ ] Standard
- [x] Heavy
- [ ] Emergency

## Classification Reason

Heavy: this changes scaffold distribution scripts, gates, templates, tests, and CI workflow ownership. It affects how every downstream project receives and validates agent-flow.

## Goals

- AC-01: New installs must not copy starter-local `agent-flow/changes`, `agent-flow/logs`, or `agent-flow/reports` history; they should create only clean project-owned directories with `.gitkeep`.
- AC-02: `alignment-check` must enforce the documented rule that aligned Standard/Heavy designs contain at least three `user-confirmed` rows; generic `confirmed` must no longer satisfy the gate.
- AC-03: `init-project.sh` must match the PowerShell behavior for empty directory discovery by leaving explicit TODO placeholders instead of substituting first candidate paths.
- AC-04: `check-change --closure` must fail fast when flow-required artifacts are missing or still placeholder-like.
- AC-05: CI workflow ownership must be single-source to reduce duplicated checks and future drift.
- AC-06: Windows and bash self-tests must cover the new install hygiene and alignment semantics.

## Non-Goals

- No redesign of Light / Standard / Heavy routing.
- No business-project-specific residue or domain rules.
- No new external dependency such as jq.
- No change to runtime application code; this is scaffold-only.

## Impact

- Canonical installers.
- Alignment gate and design template/generator wording.
- Bash initialization heuristics.
- Aggregate check-change closure behavior.
- Starter self-tests.
- GitHub workflow files.

## Frontend

- [x] No
- [ ] Yes: `none`

## Risks

- Stricter gates may break existing sample fixtures until tests are updated.
- Install hygiene changes must still preserve target project-owned directories during upgrades.
- Closure strictness must not break non-closure exploratory use of `check-change`.

## User Confirmation Questions

none

## Artifact Index

- State: `agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening/STATE.md`
- Requirement: `agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening/REQUIREMENT.md`
- Code Scan: `agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening/CODE_SCAN.md`
- Design: `agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening/DESIGN.md`
- Tasks: `agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening/TASKS.md`
- Verify: `agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening/VERIFY.md`
- Report: `agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening/REPORT.md`
- Evolution: `agent-flow/changes/20260616-agent-flow-starter-agent-flow-9-0-hardening/EVOLUTION.md`
