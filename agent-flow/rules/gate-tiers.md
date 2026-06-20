# Gate Tiering Matrix

> Defines which gates are required (blocking), recommended, or advisory for each change level.
> This is the single source of truth — `check-change`, flow docs, and CI reference this matrix.

## Tier Definitions

| Tier | Label | Behavior | Applicable To |
|------|-------|----------|---------------|
| **R** | Required | Must pass; blocks completion | Specified flow levels |
| **R*** | Required (conditional) | Must pass if the relevant artifact exists | Depends on change content |
| **W** | Warning | Should pass; logs warning on failure | Advisory, non-blocking |
| **A** | Advisory | Run if available; never blocks | Optional, informational |
| **S** | Skip / N/A | Not relevant for this flow level | — |

## Gate Matrix

### L — Light flow

| Gate | Tier | Condition | Notes |
|------|------|-----------|-------|
| `scan-check` | **W** | CODE_SCAN.md present | Warn on failure; consider upgrade to Standard if risk detected |
| `task-boundary-check` | **A** | TASKS.md present | Recommended to confirm write_files accuracy |
| `manifest-check` | **R** | Always | Verify scaffold integrity |
| `ac-check` | **R** | REQUIREMENT.md + VERIFY.md present | Verify AC traceability |
| `actionlint-check` | **A** | .github/workflows/*.yml exists | Non-blocking; tool optional |
| `frontend-verify-check` | **A** | manifest declares frontend | Advisory when no frontend |

### S — Standard flow

| Gate | Tier | Condition | Notes |
|------|------|-----------|-------|
| All Light **R** + **W** + **A** gates apply | | | |
| `scan-check` | **R** | Must pass before DESIGN.md | Strict mode |
| `design-check` | **R** | DESIGN.md present | Must pass before Alignment |
| `alignment-check` | **R** | DESIGN.md present | Verdict must be aligned or skipped with reason |
| `task-check` | **R** | TASKS.md present | Must pass before implementation |
| `task-boundary-check` | **R** | TASKS.md present | Run before closure |
| `ac-check` | **R** | REQUIREMENT.md + VERIFY.md | AC Evidence check |
| `coverage-check` | **R** | REQUIREMENT.md + VERIFY.md | AC coverage + test coverage |
| `evolution-check` | **R** | EVOLUTION.md present | Must pass before closure |
| `manifest-check` | **R** | Always | Run at closure |
| `design-quality-check` | **W** | DESIGN.md present | Quality advisory |
| `code-drift-check` | **W** | DESIGN.md + code change | Drift detection advisory |
| `api-compatibility-check` | **A** | DESIGN.md present | API drift detection |
| `content-check` | **A** | Any artifact present | Placeholder detection |
| `ac-traceability-check` | **A** | REQUIREMENT.md + VERIFY.md | Detailed traceability |
| `doc-quality-check` | **A** | DESIGN.md present | Documentation quality |
| `knowledge-expiry-check` | **A** | knowledge/ present | Knowledge freshness |

### H — Heavy flow

| Gate | Tier | Condition | Notes |
|------|------|-----------|-------|
| All Standard **R** + **W** + **A** gates apply | | | |
| `plan-check` | **R** | PLAN.md + AUDIT.md present | Must pass before implementation |
| `plan-check` (audit) | **R** | AUDIT.md present | Plan Audit Verdict must be accept/conditional |
| `code-drift-check` | **R** | DESIGN.md + code change | Must pass before closure |
| `blocked-check` | **R** | TASKS.md + manifest blocked_if | Must not match blocked patterns |
| `db-migration-check` | **R** | Migration/schema files | Rollback verification |
| `closure-check` | **R** | Heavy closure | Must pass before marking complete |
| `api-compatibility-check` | **R* | API changes declared | Required when API changes detected |
| `design-quality-check` | **R** | DESIGN.md present | Quality gate |
| `emergency-check` | **R** | Emergency flow | P0/P1 verification |

### E — Emergency flow

| Gate | Tier | Condition | Notes |
|------|------|-----------|-------|
| `emergency-check` | **R** | Always | P0/P1, approval, bypass reason, backfill deadline |
| `emergency-abuse-check` | **R** | Always | Detect pattern abuse |
| `emergency-backfill-check` | **R** | 24h after emergency | Verify backfill completion |
| `emergency-time-lock` | **R** | Always | Enforce 24h time lock |
| All other gates | **S** | Bypassed during emergency | Must be backfilled within 24h |

### Universal (all levels)

| Gate | Tier | Notes |
|------|------|-------|
| `manifest-check` | **R** | Run at every closure |
| `scaffold-health` | **R** | Run after any scaffold modification |
| `template-check` | **R* | Run after any template modification |
| `sync-state` | **R** | Run when STATE.md may be stale |
| `state-check` | **R* | Run when STATE.md exists |
| `gate-fatigue-check` | **A** | Periodic; detects ineffective gates |
| `pair-consistency-check` | **A** | Cross-platform script parity |
| `incremental-verify` | **A** | Selective re-verification |

## check-change Automation

The `check-change.sh` / `.ps1` script automatically selects the appropriate tier based on the flow level read from `CHANGE.md`:

1. Read `CHANGE.md` → determine flow (Light / Standard / Heavy / Emergency)
2. Select gate set per this matrix
3. For conditional gates (R*), skip when the required artifact is absent
4. Output pass/fail/skip per gate
5. Generate `CHECK_RESULT.json` with per-gate results

## References

- GO.md: lines 271-290 (gate requirements per flow level)
- light.md: scan-check (warn), task-boundary-check (recommended)
- standard.md: scan-check, design-check, alignment-check, task-check, evolution-check
- heavy.md: all Standard + plan-check, code-drift-check, blocked-check, closure-check
- check-change.sh/ps1: gate execution logic with artifact-aware skipping
