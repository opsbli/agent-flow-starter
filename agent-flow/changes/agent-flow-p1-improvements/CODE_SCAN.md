# Code Scan

scan_time: 2026-06-16T15:00+08:00

related_modules:
  - agent-flow/scripts/ (new gate scripts)
  - agent-flow/core/frontend-fit.md (enhance)
  - agent-flow/templates/DESIGN.md (enhance)
  - agent-flow/manifest.yaml (register gates)
  - agent-flow/rules/gates.txt (register gates)

similar_implementations:
  - code-drift-check.ps1/.sh (DESIGN.md parsing, drift detection)
  - blocked-check.ps1/.sh (manifest.yaml parsing, static text scanning)
  - alignment-check.ps1/.sh (Get-FlowLevel usage pattern)

reusable_abstractions:
  - _common.ps1/sh (Get-FlowLevel, Test-Meaningful, Get-RuleList)
  - code-drift-check exit code convention (0=pass, 2=fail)

standards_snapshot:
  - All gate scripts in paired .ps1/.sh files
  - PowerShell -ChangeDir, Bash --change-dir dual support
  - Exit codes: 0=pass/skip, 2=fail
  - Use Get-FlowLevel to skip Light/Emergency changes
  - New gates register in manifest.yaml, gates.txt, check-change.ps1, check-change.sh
  - No external dependencies

test_baseline:
  - scripts/test-starter.ps1 and test-starter.sh
  - agent-flow/test/fixtures/minimal-project/
  - scaffold-health validates file presence

read_files: agent-flow/scripts/code-drift-check.ps1, agent-flow/scripts/code-drift-check.sh, agent-flow/scripts/blocked-check.ps1, agent-flow/scripts/blocked-check.sh, agent-flow/scripts/check-change.ps1, agent-flow/scripts/check-change.sh, agent-flow/scripts/_common.ps1, agent-flow/scripts/_common.sh, agent-flow/core/frontend-fit.md, agent-flow/templates/DESIGN.md, agent-flow/manifest.yaml, agent-flow/rules/gates.txt

write_files: agent-flow/scripts/api-compatibility-check.ps1, agent-flow/scripts/api-compatibility-check.sh, agent-flow/scripts/db-migration-check.ps1, agent-flow/scripts/db-migration-check.sh, agent-flow/scripts/check-change.ps1, agent-flow/scripts/check-change.sh, agent-flow/core/frontend-fit.md, agent-flow/templates/DESIGN.md, agent-flow/manifest.yaml, agent-flow/rules/gates.txt, agent-flow/knowledge/improvement-tracker.md

open_questions: none
