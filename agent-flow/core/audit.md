# Audit

## Purpose

Define independent review points for Heavy changes.

## Audit Types

### Plan Audit

When: after `PLAN.md` / `DESIGN.md` / `TASKS.md`, before implementation.

Goal: verify the plan is complete, bounded, and safe.

Checklist:

- [ ] Current baseline was checked against live code.
- [ ] Goals and Non-Goals are clear.
- [ ] Code scan lists similar implementations and reusable abstractions.
- [ ] Protected areas are identified.
- [ ] `read_files` and `write_files` are bounded.
- [ ] Execution phases have exit criteria.
- [ ] Closure gates are verifiable.
- [ ] Risks have mitigations.
- [ ] Skill/tool choices are recorded or explicitly none.

Verdict:

```text
accept | conditional | reject
```

### Closure Audit

When: after implementation and verification, before marking completed.

Goal: verify from live repo evidence that the change is complete.

Checklist:

- [ ] All closure gates pass.
- [ ] Verification commands ran or skip reasons are recorded.
- [ ] AC coverage has evidence.
- [ ] Drift checks passed or are adjudicated.
- [ ] No undeclared files were modified.
- [ ] Knowledge/decision/log/baseline updates are done.
- [ ] Residual risks are explicitly owned.

Verdict:

```text
acceptable | conditional | rejected
```

## Record Location

For each Heavy change, write audits to:

```text
agent-flow/changes/<change-id>/AUDIT.md
```

Light changes do not need audit. Standard changes may use closure audit when risk grows.
