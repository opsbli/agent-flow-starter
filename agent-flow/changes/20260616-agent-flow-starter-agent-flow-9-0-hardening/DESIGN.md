# Design

## Design Goal

Close the contract gaps that kept the scaffold below 9.0 while preserving its current flow shape.

## Design Constraints

No new external dependencies. Windows and bash behavior must stay paired. The install contract must preserve target-owned data on upgrades.

## Module Boundaries

This change stays within the scaffold modules:

- Installer distribution behavior.
- Alignment gate semantics.
- Init project discovery.
- Aggregate closure gate behavior.
- Starter self-tests and CI workflow ownership.

## Reuse Existing Abstractions

Reuse `_common` helpers, existing `DESIGN.md` alignment table, existing self-test helpers, and the current canonical installer scripts.

## Non-Reuse Reason

No new abstraction is needed; existing modules are deep enough once their interfaces enforce the documented contracts.

## Non-Functional Requirements

| Dimension | Requirement | Verification |
|---|---|---|
| Performance | no special requirement | self-tests complete successfully |
| Latency | no special requirement | self-tests complete successfully |
| Concurrency | no special requirement | not applicable |
| Availability | install and gate behavior remain usable | Windows/bash self-tests |
| Security | no auth/security behavior changes | blocked-check and code review |
| Observability | gate output should name failures clearly | negative tests |

## API Design

| Method | Path | Permission | Input | Output |
|---|---|---|---|---|
| none | none | none | none | none |

## API / Permission / Auth Decisions

Decision Status: accepted

Allowed Decision Values: unchanged / new / modified / deleted / not-applicable

| Item | Decision | Evidence / Reason |
|---|---|---|
| REST Path | not-applicable | Scaffold scripts do not expose REST routes. |
| HTTP Method | not-applicable | No HTTP interface is changed. |
| Permission Code | not-applicable | No permission model is changed. |
| SaCheckPermission | not-applicable | No Java controller permission annotations exist. |
| Anonymous Interface | not-applicable | No anonymous interface behavior exists. |
| Login/Token | not-applicable | No login or token semantics are changed. |
| Tenant/Data Permission | not-applicable | No tenant or data permission behavior exists. |
| State Machine Impact | not-applicable | No workflow or status machine is changed. |

State Machine Impact: no

## Data Design

none

## State Machine

State Machine Impact: no

### Status Vocabulary

| Status | Source | Meaning | New Write? | Frontend Display |
|---|---|---|---|---|
| none | none | none | no | none |

### Status Mapping

| Input / Legacy Status | Target Status | Usage Location | Compatibility Strategy |
|---|---|---|---|
| none | none | none | none |

### Legacy Compatibility

| Legacy Value | New Value | Query Compatibility | Write Compatibility | Migration Required |
|---|---|---|---|---|
| none | none | none | none | no |

## Service Orchestration

Script modules remain independent. The install scripts own distribution hygiene; alignment-check owns alignment semantics; init-project owns manifest discovery; check-change owns aggregate gate orchestration; sync-state owns removal of scaffold placeholder history rows before closure artifact checks.

## Error Handling

Each tightened gate must emit a specific message so self-tests can assert the expected failure mode.

## Idempotency / Rate Limit / Audit

Install remains idempotent: existing project-owned directories are preserved. Clean directories receive `.gitkeep` only for history directories.

## Security And Permission

No auth or security filter behavior changes.

## Test Strategy

| AC | Test File | Method | Type |
|---|---|---|---|
| AC-01 | `scripts/test-starter.ps1`, `scripts/test-starter.sh` | Assert installed `changes/logs/reports` contain no starter history. | smoke |
| AC-02 | `scripts/test-starter.ps1`, `scripts/test-starter.sh` | Positive user-confirmed case and negative legacy confirmed/code-only case. | gate |
| AC-03 | `scripts/test-starter.sh` | Init empty project leaves TODO placeholders for missing dirs. | smoke |
| AC-04 | `scripts/test-starter.ps1`, `scripts/test-starter.sh`, `check-change --closure` | Negative closure check-change case fails on missing Heavy artifact; positive closure path rejects placeholder state history. | gate |
| AC-05 | repository workflow files | Delete duplicate workflow. | static |
| AC-06 | root scripts and agent-flow gates | Run all listed verification commands. | regression |

## UI Flow / Component Tree

| Screen / Component | State | User Action | Expected Result | Notes |
|---|---|---|---|---|
| none | none | none | none | none |

## Demo Evidence

| Evidence | Location / Command | Covered AC | Result |
|---|---|---|---|
| none | none | none | not-applicable |

## Design Alignment / Grill

Alignment Source: user-confirmed

Open Questions: none

| Question | AI Recommended Answer | Confirmation | Final Decision |
|---|---|---|---|
| Intent Risk | Focus on the five reviewed gaps instead of adding new stages. | user-confirmed | Scope is the 9.0 hardening list. |
| Existing Code Fit | Patch the current script modules and self-tests. | user-confirmed | Reuse existing modules. |
| Unnecessary Abstraction | Do not add new registries or dependencies. | user-confirmed | Keep current interfaces deeper. |
| Protected Areas | CI workflow deletion is acceptable; no runtime protected area is touched. | user-confirmed | Proceed inside declared write_files. |
| Boundary And Failure Modes | Stricter gates may break fixtures, so tests must be updated first-class. | user-confirmed | Add positive and negative coverage. |

Alignment Verdict: aligned

Skip Reason:

## Release And Rollback

Rollback by reverting the touched scripts/templates/tests/workflow deletion. No data migration or runtime deployment is involved.

## ADR Candidates

none
