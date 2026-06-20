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
| IMP-0010 | agent-flow-p1-improvements | New api-compatibility-check gate for API/permission drift detection | scripts | implemented | Added `api-compatibility-check.ps1/.sh`, registered in check-change, manifest, gates.txt | 2026-06-16 |
| IMP-0011 | agent-flow-p1-improvements | New db-migration-check gate for rollback SQL verification | scripts | implemented | Added `db-migration-check.ps1/.sh`, registered in check-change, manifest, gates.txt | 2026-06-16 |
| IMP-0012 | agent-flow-p1-improvements | Chrome DevTools debugging checklist in frontend-fit.md | docs | implemented | Added Network/Console/Elements/Application checklists | 2026-06-16 |
| IMP-0013 | agent-flow-p1-improvements | DB Change decision table and frontend verification contract in DESIGN.md template | templates | implemented | Added both tables to DESIGN.md template | 2026-06-16 |
| IMP-0014 | agent-flow-p1-improvements | manifest.yaml frontend_verify_required toggle | config | implemented | Added frontend.verify_required field to manifest.yaml + frontend-fit.md reference | 2026-06-16 |
| IMP-0015 | agent-flow-improvements-round2 | Non-functional requirements in REQUIREMENT.md template | templates | implemented | Added performance/security/observability/availability/latency table | 2026-06-16 |
| IMP-0016 | agent-flow-improvements-round2 | design-quality-check gate for design review quality | scripts | implemented | Added design-quality-check.ps1/.sh, registered in check-change, manifest, gates.txt | 2026-06-16 |
| IMP-0017 | agent-flow-improvements-round3 | conflict_warning column in TASKS.md template | templates | implemented | Added 8th column for parallel-safety marking + documentation | 2026-06-16 |
| IMP-0018 | agent-flow-improvements-round3 | integration_test + api_test commands in manifest.yaml | config | implemented | Added integration_test and api_test slots to manifest.yaml | 2026-06-16 |
| IMP-0019 | capability-score-report-2026-06-16 | Fix GO.md vs Light flow EVOLUTION.md conflict | docs | implemented | Added Light exception note to GO.md | 2026-06-16 |
| IMP-0020 | capability-score-report-2026-06-16 | Add Machine Gate Summary recommendation for Standard | docs | implemented | Added note to standard.md completion line | 2026-06-16 |

| IMP-0021 | fix-design-alignment-table | Fix DESIGN.md Alignment table column headers to match alignment-check expectation | templates | implemented | This change: fix-design-alignment-table | 2026-06-20 |

| IMP-0022 | context-aware-design-decisions | Design-decision context awareness: fix project-root detection, add non-backend guidance, skip State Machine Impact for non-backend | scripts/templates | implemented | This change: context-aware-design-decisions | 2026-06-20 |

| IMP-0023 | add-actionlint-gate | Add actionlint gate for CI YAML workflow validation | scripts | implemented | This change: add-actionlint-gate | 2026-06-20 |

| IMP-0024 | fix-gate-fatigue-check | Fix gate-fatigue-check.sh crash from unbound associative array variable | scripts | implemented | This change: fix-gate-fatigue-check | 2026-06-20 |

| IMP-0025 | cleanup-reasonix-and-evolution | Clean up .reasonix auto-generated files, fill missing EVOLUTION.md, integrate frontend-verify-check into check-change | cleanup/scripts | implemented | This change: cleanup-reasonix-and-evolution | 2026-06-20 |

| IMP-0026 | gate-tiering-matrix | Create gate tiering matrix document defining Required/Warning/Advisory for all 62 gates across Light/Standard/Heavy/Emergency | rules | implemented | This change: gate-tiering-matrix | 2026-06-20 |

| IMP-0027 | enhance-content-check | Extend content-check to scan agent-flow/core/ and rules/ directories for placeholders | scripts | implemented | This change: enhance-content-check | 2026-06-20 |

| IMP-0028 | remaining-enhancements | Generate CHECK_RESULT.json baselines, example freshness doc, ECC validation, performance baseline CI check | multiple | implemented | This change: remaining-enhancements | 2026-06-20 |

| IMP-0029 | remaining-enhancements | Create pi templates, verify examples, final review | multiple | implemented | This session | 2026-06-20 |

## Rules

- Add an item when `EVOLUTION.md` recommends changing `agent-flow/` templates, scripts, gates, knowledge, decisions, or flow rules.
- Use `rejected` when the recommendation was considered and intentionally not adopted.
- Use `deferred` only with a concrete next step or owner.
- When implemented, reference the change that made it real.
