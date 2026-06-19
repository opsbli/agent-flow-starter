# Evolution

## Machine Check

problem: documented scaffold contracts can drift from executable gates
knowledge: updated known-good baseline for starter scaffold hardening
adr: none
gate: strengthened alignment-check and check-change closure mode
template: DESIGN alignment confirmation wording updated
no_change_reason: no new flow stage or ADR needed because existing modules were deepened

## Findings

- Install hygiene belongs in the installer module, not in user instructions.
- Alignment confirmation semantics must be machine-enforced because users rely on the gate result.
- Closure aggregation should fail before running the rest of the gate chain when required artifacts are absent.

## Rule Upgrades

- `alignment-check` now requires at least three `user-confirmed` rows.
- `check-change --closure` now records `closure-required-artifacts`.

## Knowledge Added

- `agent-flow/knowledge/known-good-baselines.md` records the starter scaffold hardening baseline.

## New Gates

- No new standalone gate script. `check-change` gained a stricter closure sub-gate.

## Template Adjustments

- `agent-flow/templates/DESIGN.md` now documents `user-confirmed` and `code-confirmed` values.
- `generate-design.ps1` and `generate-design.sh` generate alignment rows compatible with the gate.

## Standards

- Keep project-owned runtime history directories clean during starter install.
