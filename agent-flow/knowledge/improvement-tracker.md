# Improvement Tracker

> Track process improvements raised by `EVOLUTION.md` until they are adopted, rejected, or deferred with an owner.

## Status Values

```text
proposed | accepted | implemented | rejected | deferred
```

## Tracker

| ID | Source Change | Recommendation | Target | Status | Owner / Next Step | Date |
|---|---|---|---|---|---|---|
| IMP-0001 | p0-p1-starter-improvements | Group manifest TODO output and print next steps | manifest-check | implemented | Included in `manifest-check.ps1/.sh` | 2026-06-11 |
| IMP-0002 | p0-p1-starter-improvements | Validate AC Evidence rows instead of loose AC text search | ac-check | implemented | Included in `ac-check.ps1/.sh` | 2026-06-11 |
| IMP-0003 | p0-p1-starter-improvements | Add core gate negative tests | starter self-test | implemented | Included in `scripts/test-starter.ps1/.sh` | 2026-06-11 |
| IMP-0004 | p0-p1-starter-improvements | Track EVOLUTION recommendations | knowledge | implemented | Added this tracker | 2026-06-11 |
| IMP-0005 | p0-p1-starter-improvements | Add ADR index and lifecycle statuses | decisions | implemented | Added `decisions/INDEX.md` and README status guidance | 2026-06-11 |
| IMP-0006 | capability-score-report-2026-06-11 | Add global knowledge index and local knowledge search | knowledge/scripts | implemented | Added `knowledge/INDEX.md` and `knowledge-search.ps1/.sh` | 2026-06-12 |
| IMP-0007 | capability-score-report-2026-06-11 | Add template version and template validation | templates/scripts | implemented | Added `templates/VERSION`, `REQUIREMENT_ALIGNED.md`, and `template-check.ps1/.sh` | 2026-06-12 |
| IMP-0008 | capability-score-report-2026-06-11 | Add AC coverage and test coverage gate | scripts/templates | implemented | Added `coverage-check.ps1/.sh` and `VERIFY.md` Coverage Summary | 2026-06-12 |
| IMP-0009 | capability-score-report-2026-06-11 | Add troubleshooting guide | docs | implemented | Added `docs/TROUBLESHOOTING.md` and FAQ links | 2026-06-12 |

## Rules

- Add an item when `EVOLUTION.md` recommends changing `agent-flow/` templates, scripts, gates, knowledge, decisions, or flow rules.
- Use `rejected` when the recommendation was considered and intentionally not adopted.
- Use `deferred` only with a concrete next step or owner.
- When implemented, reference the change that made it real.
