# Glossary

> Domain terms and canonical names for agent-flow. Target projects should extend with their own business terminology.

## Core Concepts

| Term | Definition | First Used In |
|---|---|---|
| **Change** | A unit of work representing one development request. Contains lifecycle artifacts (REQUIREMENT, DESIGN, TASKS, VERIFY, etc.). | GO.md |
| **Gate** | A verifiable check that must pass before proceeding to the next development phase. Implemented as scripts in `agent-flow/scripts/`. | manifest.yaml |
| **Grill** | Structured questioning process where AI challenges design assumptions against code facts. Two types: Requirements Grill (pre-REQUIREMENT) and Design Alignment (post-DESIGN). | heavy.md |
| **Design Alignment** | Lightweight alignment step after writing DESIGN.md to ensure user intent matches AI understanding before implementation begins. | standard.md |
| **Light** | Low-risk change level: single-file fix, docs, small behavior correction with existing test coverage. | router.md |
| **Standard** | Moderate-risk change level: single-module feature, CRUD, no schema/auth/public-contract changes. | router.md |
| **Heavy** | High-risk change level: new module, cross-module, schema/auth/permission changes, realtime/state-machine work. | router.md |
| **Emergency** | Bypass channel for P0/P1 production incidents, security vulnerabilities, or data loss. Requires backfill within 24h. | emergency.md |
| **Code-First** | Principle: scan live code before writing specs. Design requires CODE_SCAN.md evidence. | principles.md |
| **AC (Acceptance Criterion)** | Verifiable condition that a change must satisfy. Numbered AC-01, AC-02, etc., traced through REQUIREMENT → DESIGN → TASKS → VERIFY → REPORT. | heavy.md |
| **Protected Area** | Code or configuration that requires human approval before modification. Includes: DB schema, auth/permissions, public API contracts, payment/billing, destructive operations. | autonomy-policy.md |
| **Autonomy Level** | Defines what AI may do without human approval. Levels: research-only, plan-first, implement-safe, implement-with-gates, ask-first, blocked. | autonomy-policy.md |
| **Source of Truth Chain** | Authoritative hierarchy: Code > Decisions > Knowledge > Requirement > Design > Tasks > State > Chat. Higher wins when conflicts arise. | source-of-truth.md |
| **Drift** | Difference between DESIGN.md declarations and actual live code. Detected by code-drift-check. | source-of-truth.md |
| **ADR (Architecture Decision Record)** | Document recording a significant, irreversible architecture decision with alternatives considered. | memory.md |
| **EVOLUTION.md** | Post-change reflection document answering what the scaffold itself should learn from the change. | evolution.md |

## Verification Terms

| Term | Definition |
|---|---|
| **scan-check** | Gate: validates CODE_SCAN.md completeness before design. |
| **design-check** | Gate: validates DESIGN.md decision status and structure. |
| **alignment-check** | Gate: validates Design Alignment has ≥3 user-confirmed questions. |
| **task-check** | Gate: validates TASKS.md completeness and machine-readable boundary. |
| **task-boundary-check** | Gate: validates actual file modifications do not exceed declared write_files. |
| **code-drift-check** | Gate: compares DESIGN.md path/name declarations against live code structure. |
| **blocked-check** | Gate: checks if change violates manifest.yaml blocked_if rules. |
| **coverage-check** | Gate: validates AC Evidence coverage and test coverage records. |
| **closure-check** | Gate: final Heavy-change completeness verification before marking done. |
| **manifest-check** | Gate: verifies scaffold inventory, gate files, and project configuration completeness. |
| **evolution-check** | Gate: validates EVOLUTION.md is present and answers required questions. |
| **check-change** | Aggregated runner: executes all relevant gates for the current change. |

## Change Lifecycle Terms

| Term | Definition |
|---|---|
| **STATE.md** | Navigation-only file; records current phase, next-step, and key links. Never authoritative for behavior. |
| **CHANGE.md** | Change metadata: goals, non-goals, risk level, scope. |
| **REQUIREMENT.md** | Authoritative source for what the current change must achieve. |
| **CODE_SCAN.md** | Code-first scan results; must be complete before DESIGN.md. |
| **DESIGN.md** | Authoritative for the approved implementation approach. |
| **TASKS.md** | Execution plan with task breakdown, write_files boundary, and verification per task. |
| **VERIFY.md** | Verification evidence: AC coverage, test results, drift checks. |
| **REPORT.md** | Delivery report: what was done, what was tested, what is deferred. |
| **AUDIT.md** | Plan Audit (pre-implementation) and Closure Audit (post-implementation) for Heavy changes. |
| **EVOLUTION.md** | Scaffold improvement reflection. |
