# Requirement

## Background

agent-flow-starter already has a strong flow and gate chain. The remaining gap to a 9.0-level scaffold is mostly contract consistency: what the docs promise, what scripts enforce, and what installers distribute must line up.

## Users

- Agent using agent-flow in a downstream repository.
- Maintainer upgrading agent-flow-starter.
- Reviewer trusting machine gate output.

## Terms

| Term | Definition | Glossary |
|---|---|---|
| history directories | `agent-flow/changes`, `agent-flow/logs`, and `agent-flow/reports` | existing |
| user-confirmed | Alignment row confirmation explicitly approved by the user | existing |

## Goals

- Keep downstream projects clean when installing the starter.
- Make Design Alignment machine enforcement match the documented user-confirmation rule.
- Remove a cross-platform init discrepancy between PowerShell and bash.
- Make closure-mode aggregate checks fail when required artifacts are missing.
- Remove duplicate CI workflow ownership.

## Non-Goals

- Do not change the Light / Standard / Heavy router.
- Do not introduce a new dependency.
- Do not add business-project-specific history or domain rules.

## Business Rules

| ID | Rule |
|---|---|
| R-01 | Starter-owned files can be overwritten during install. |
| R-02 | Project-owned directories must be preserved during upgrade. |
| R-03 | Empty target projects must receive clean history directories, not starter-local histories. |
| R-04 | A Standard/Heavy design is aligned only when at least three alignment rows are explicitly `user-confirmed`, unless the user explicitly accepts `skipped` with a reason. |

## Acceptance Criteria

| AC | Given | When | Then | Verification |
|---|---|---|---|---|
| AC-01 | The starter workspace has local ignored history directories | A new target project is installed | Target `changes/`, `logs/`, and `reports/` contain no starter history and have `.gitkeep` only | Windows and bash starter self-tests inspect installed target directories |
| AC-02 | A Standard/Heavy design has `Alignment Verdict: aligned` | `alignment-check` runs | The gate requires at least three `user-confirmed` rows and rejects generic `confirmed` | Positive and negative self-tests for both platforms |
| AC-03 | An empty project has no backend/common/business/test/sql directories | `init-project.sh` runs | Manifest keeps explicit TODO placeholders for missing dirs, matching PowerShell | Bash starter self-test and code review |
| AC-04 | A Heavy change is missing a required artifact | `check-change --closure` runs | The aggregate check fails with a closure-required-artifacts result | Negative closure self-test |
| AC-05 | CI workflows are listed | The repository is scanned | Only the comprehensive scaffold workflow remains | `rg --files .github/workflows` |
| AC-06 | The hardening is complete | Verification runs | Windows and bash scaffold checks and starter self-tests pass | Command evidence in VERIFY.md |

## Exceptions And Edges

- Existing target `changes/`, `logs`, and `reports` must not be deleted or overwritten.
- `check-change` without closure mode may still report skipped gates for not-yet-created artifacts.
- `Alignment Verdict: skipped` remains allowed only with `Skip Reason`.

## Open Questions

none

## User Confirmation Record

The user requested direct optimization to the prior 9.0 target. The implementation scope follows the five top findings from the review.
