# Change: agent-flow-governance-9plus

## One-Sentence Requirement

Raise agent-flow-starter above 9.0 by fixing the highest-priority governance gaps found in the post-fix review.

## Flow Level

- [ ] Light
- [ ] Standard
- [x] Heavy

## Classification Reason

This modifies the scaffold's gate registry, health checks, install/self-test behavior, starter-owned documentation, and tracked starter history. It touches multiple scaffold modules and affects how future projects validate agent-flow.

## Goals

- AC-01: `agent-flow/rules/gates.txt` and `manifest.yaml` register all public `agent-flow/scripts/*.ps1/.sh` scripts, including `ac-traceability-check`.
- AC-02: `manifest-check` fails when a public script is missing from the formal gate registry or manifest.
- AC-03: `scaffold-health` derives required script files from `agent-flow/rules/gates.txt` instead of maintaining a stale duplicate list.
- AC-04: The starter no longer tracks real run-history files under `agent-flow/changes`, `agent-flow/logs`, or `agent-flow/reports`, except `.gitkeep`.
- AC-05: `scripts/test-starter.ps1/.sh` catches future run-history leakage and still passes on Windows and Bash.
- AC-06: Script documentation no longer hard-codes a stale script count and documents the formal registry source.

## Non-Goals

- No new workflow level.
- No change to Light / Standard / Heavy routing rules.
- No project-specific business knowledge.
- No rewrite of all gate scripts.

## Artifact Index

- Requirement: `REQUIREMENT.md`
- Code Scan: `CODE_SCAN.md`
- Design: `DESIGN.md`
- Plan: `PLAN.md`
- Tasks: `TASKS.md`
- Verify: `VERIFY.md`
- Review: `REVIEW.md`
- Report: `REPORT.md`
- Evolution: `EVOLUTION.md`
- Audit: `AUDIT.md`
