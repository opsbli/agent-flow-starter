# Code Scan

## 扫描时间

2026-06-20 19:30

## Machine Check

scan_time: 2026-06-20 19:30
related_modules: rules/gate-tiers.md (new), scripts/scaffold-health.sh/ps1 (updated)
similar_implementations: rules/design-decision.keys, rules/design-alignment.questions (precedent for rule files)
reusable_abstractions: existing scaffold-health path registration pattern
standards_snapshot: 62 gate names extracted from manifest.yaml, flow doc gate requirements from GO.md + light.md + standard.md + heavy.md
test_baseline: scaffold-health
read_files: agent-flow/manifest.yaml, agent-flow/GO.md, agent-flow/flows/light.md, agent-flow/flows/standard.md, agent-flow/flows/heavy.md, agent-flow/flows/emergency.md, agent-flow/scripts/check-change.sh, agent-flow/scripts/scaffold-health.sh, agent-flow/scripts/scaffold-health.ps1
write_files: agent-flow/rules/gate-tiers.md, agent-flow/scripts/scaffold-health.sh, agent-flow/scripts/scaffold-health.ps1
open_questions: none

## read_files

read_files:
  - agent-flow/manifest.yaml
  - agent-flow/GO.md
  - agent-flow/flows/light.md
  - agent-flow/flows/standard.md
  - agent-flow/flows/heavy.md
  - agent-flow/flows/emergency.md
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/scaffold-health.sh
  - agent-flow/scripts/scaffold-health.ps1

## write_files

write_files:
  - agent-flow/rules/gate-tiers.md
  - agent-flow/scripts/scaffold-health.sh
  - agent-flow/scripts/scaffold-health.ps1

## 未决问题

无
