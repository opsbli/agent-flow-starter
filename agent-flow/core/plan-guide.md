# Plan Guide

## Purpose

Define when a change needs a formal plan and how that plan closes.

`TASKS.md` is not enough for Heavy work. Heavy work also needs a plan section or `PLAN.md` with status, phases, and closure gates.

## When To Create PLAN.md

Create `PLAN.md` when the change has any of these traits:

- changes API, database/model, auth, integration, deployment, or public contract behavior
- touches multiple modules or repositories
- adds a new Maven module
- changes user-visible behavior across more than one feature surface
- is expected to take more than one AI session
- modifies more than 5 files or likely exceeds 200 changed lines
- has unresolved product or technical risk
- needs staged rollout or explicit closure gates

## Status

Use one of:

```text
proposed | planned | in-progress | partially-completed | completed | superseded | replaced | deferred | cancelled
```

## Required Sections

1. Current Baseline
2. Goals
3. Non-Goals
4. Execution Phases
5. Closure Gates
6. Risks
7. Protected Area Review
8. Deferred But Adjudicated

## Phase Rules

Each phase must include:

- status
- scope
- `read_files`
- `write_files`
- exit criteria
- verification command or evidence

## Non-Degradable Items

These cannot be downgraded to advisory:

- static checks and fail-fast gates
- confirmed live defects
- confirmed contract drift
- required tests for accepted behavior
- protected area approval

## Completion Rule

A plan can only be marked `completed` after:

- all closure gates pass
- `VERIFY.md` records evidence
- closure audit verdict is `acceptable` or human-approved `conditional`
- logs and known-good baseline are updated when applicable
