# Tasks

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel |
|---|---|---|---|---|---|---|
| T001 | completed | AC-01, AC-02 | `agent-flow/rules/gates.txt`, `agent-flow/manifest.yaml`, `agent-flow/scripts/manifest-check.ps1`, `agent-flow/scripts/manifest-check.sh`, `agent-flow/scripts/init-project.ps1`, `agent-flow/scripts/init-project.sh` | `agent-flow/rules/gates.txt`, `agent-flow/manifest.yaml`, `agent-flow/scripts/manifest-check.ps1`, `agent-flow/scripts/manifest-check.sh`, `agent-flow/scripts/init-project.ps1`, `agent-flow/scripts/init-project.sh` | `manifest-check.ps1/.sh` | no |
| T002 | completed | AC-03 | `agent-flow/scripts/scaffold-health.ps1`, `agent-flow/scripts/scaffold-health.sh` | `agent-flow/scripts/scaffold-health.ps1`, `agent-flow/scripts/scaffold-health.sh` | `scaffold-health.ps1/.sh` | no |
| T003 | completed | AC-04, AC-05 | `.gitignore`, `scripts/test-starter.ps1`, `scripts/test-starter.sh`, `scripts/setup-new-pc.ps1`, `agent-flow/logs/2026/06-15.md`, `agent-flow/reports/practice-install-and-verify.md`, `agent-flow/knowledge/known-good-baselines.md` | `.gitignore`, `scripts/test-starter.ps1`, `scripts/test-starter.sh`, `scripts/setup-new-pc.ps1`, `agent-flow/logs/2026/06-15.md`, `agent-flow/reports/practice-install-and-verify.md`, `agent-flow/knowledge/known-good-baselines.md` | `git ls-files`; starter self-tests | no |
| T004 | completed | AC-06 | `agent-flow/scripts/README.md` | `agent-flow/scripts/README.md` | documentation review | yes |
| T005 | pending | AC-07 | all changed files | `VERIFY.md`, `REVIEW.md`, `REPORT.md`, `EVOLUTION.md`, `AUDIT.md` | closure checks | no |

## write_files 汇总

write_files:
  - agent-flow/rules/gates.txt
  - agent-flow/manifest.yaml
  - agent-flow/scripts/manifest-check.ps1
  - agent-flow/scripts/manifest-check.sh
  - agent-flow/scripts/init-project.ps1
  - agent-flow/scripts/init-project.sh
  - agent-flow/scripts/scaffold-health.ps1
  - agent-flow/scripts/scaffold-health.sh
  - agent-flow/scripts/README.md
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - scripts/setup-new-pc.ps1
  - .gitignore
  - agent-flow/knowledge/known-good-baselines.md
  - agent-flow/logs/2026/06-15.md
  - agent-flow/reports/practice-install-and-verify.md
  - agent-flow/changes/20260615-agent-flow-starter-agent-flow-governance-9plus/VERIFY.md
  - agent-flow/changes/20260615-agent-flow-starter-agent-flow-governance-9plus/REVIEW.md
  - agent-flow/changes/20260615-agent-flow-starter-agent-flow-governance-9plus/REPORT.md
  - agent-flow/changes/20260615-agent-flow-starter-agent-flow-governance-9plus/EVOLUTION.md
  - agent-flow/changes/20260615-agent-flow-starter-agent-flow-governance-9plus/AUDIT.md
