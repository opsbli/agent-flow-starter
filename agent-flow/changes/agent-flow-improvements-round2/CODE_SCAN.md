# Code Scan

scan_time: 2026-06-16T17:00+08:00

related_modules:
  - agent-flow/manifest.yaml (add frontend_verify_required toggle)
  - agent-flow/templates/REQUIREMENT.md (add non-functional requirements)
  - agent-flow/core/frontend-fit.md (reference the toggle)
  - agent-flow/scripts/ (new design-quality-check)

similar_implementations:
  - code-drift-check.ps1/.sh (DESIGN.md parsing pattern for design-quality-check)
  - alignment-check.ps1/.sh (design quality validation pattern)

reusable_abstractions:
  - _common.ps1/.sh (Get-FlowLevel, Test-Meaningful)
  - code-drift-check exit code convention

standards_snapshot:
  - All gate scripts paired .ps1/.sh
  - Exit codes: 0=pass/skip, 2=fail
  - New gates register in manifest.yaml, gates.txt, check-change.ps1/.sh

test_baseline:
  - scaffold-health.ps1/.sh
  - template-check.ps1/.sh

read_files:
  - agent-flow/manifest.yaml
  - agent-flow/templates/REQUIREMENT.md
  - agent-flow/core/frontend-fit.md
  - agent-flow/scripts/alignment-check.ps1
  - agent-flow/scripts/check-change.ps1
  - agent-flow/rules/gates.txt

write_files:
  - agent-flow/manifest.yaml
  - agent-flow/templates/REQUIREMENT.md
  - agent-flow/core/frontend-fit.md
  - agent-flow/scripts/design-quality-check.ps1
  - agent-flow/scripts/design-quality-check.sh
  - agent-flow/scripts/check-change.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/rules/gates.txt
  - agent-flow/knowledge/improvement-tracker.md

open_questions: none
