# Tasks

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel |
|------|--------|----|------------|-------------|--------|----------|
| T-01 | completed | AC-01 | agent-flow/scripts/code-drift-check.ps1 | agent-flow/scripts/api-compatibility-check.ps1 | syntax check | yes |
| T-02 | completed | AC-01 | agent-flow/scripts/api-compatibility-check.ps1 | agent-flow/scripts/api-compatibility-check.sh | bash -n | yes |
| T-03 | completed | AC-02 | agent-flow/scripts/blocked-check.ps1 | agent-flow/scripts/db-migration-check.ps1 | syntax check | yes |
| T-04 | completed | AC-02 | agent-flow/scripts/db-migration-check.ps1 | agent-flow/scripts/db-migration-check.sh | bash -n | yes |
| T-05 | completed | AC-03 | agent-flow/scripts/check-change.ps1 | agent-flow/scripts/check-change.ps1 | grep confirm | no |
| T-06 | completed | AC-03 | agent-flow/manifest.yaml | agent-flow/manifest.yaml | scaffold-health | no |
| T-07 | completed | AC-04 | agent-flow/core/frontend-fit.md | agent-flow/core/frontend-fit.md | read confirm | yes |
| T-08 | completed | AC-05 | agent-flow/templates/DESIGN.md | agent-flow/templates/DESIGN.md | template-check | yes |

## AC Mapping

| AC | Definition | Verification |
|----|-----------|-------------|
| AC-01 | api-compatibility-check gate parses DESIGN.md API decisions and scans source | Script syntax OK; SKIP when no DESIGN.md |
| AC-02 | db-migration-check gate detects Heavy change write_files for rollback SQL | Script syntax OK; SKIP for Light changes |
| AC-03 | New gates registered in manifest.yaml, gates.txt, check-change.ps1/.sh | scaffold-health pass |
| AC-04 | frontend-fit.md contains Chrome DevTools debugging checklist | File content verified |
| AC-05 | DESIGN.md template contains DB change decision table and frontend verification contract | template-check pass |

write_files:
  - agent-flow/scripts/api-compatibility-check.ps1
  - agent-flow/scripts/api-compatibility-check.sh
  - agent-flow/scripts/db-migration-check.ps1
  - agent-flow/scripts/db-migration-check.sh
  - agent-flow/scripts/check-change.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/manifest.yaml
  - agent-flow/rules/gates.txt
  - agent-flow/core/frontend-fit.md
  - agent-flow/templates/DESIGN.md
  - agent-flow/knowledge/improvement-tracker.md
