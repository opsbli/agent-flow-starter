# Change

## Goals

- IMP-0014: Add `frontend_verify_required` toggle in manifest.yaml — project-level opt-in for mandatory frontend verification
- IMP-NF: Add non-functional requirements fields to REQUIREMENT.md template (performance, security, observability)
- IMP-DQ: Add `design-quality-check` gate (optional) — checks DESIGN.md reuse analysis and over-engineering risk

## Non-Goals

- No changes to existing gate exit codes or interfaces
- No changes to core routing (router.md, principles.md)
- No external dependencies

## Flow Level

- [ ] Light
- [x] Standard
- [ ] Heavy
- [ ] Emergency

## Classification Reason

Standard: template changes to REQUIREMENT.md and manifest.yaml; new optional gate script (design-quality-check).

rollback: not-needed (template and config changes only)
