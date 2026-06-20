# Code Scan

## 扫描时间

2026-06-20 17:45

## Machine Check

scan_time: 2026-06-20 17:45
related_modules: .github/workflows/, agent-flow/scripts/, agent-flow/manifest.yaml, agent-flow/rules/
similar_implementations: manifest-check (existing CI gate that validates registry consistency)
reusable_abstractions: CI job template (needs: scaffold-health, continue-on-error pattern)
test_baseline: bash agent-flow/scripts/pair-consistency-check.sh
read_files: .github/workflows/scaffold-ci.yml, agent-flow/manifest.yaml, agent-flow/rules/gates.txt, agent-flow/scripts/pair-consistency-check.sh
write_files: .github/workflows/scaffold-ci.yml, agent-flow/manifest.yaml, agent-flow/rules/gates.txt, agent-flow/scripts/pair-consistency-check.sh
open_questions: none

## 相关模块

- `agent-flow/scripts/pair-consistency-check.*` — 被升级的脚本
- `.github/workflows/scaffold-ci.yml` — CI pipeline
- `agent-flow/manifest.yaml` — 脚本注册表
- `agent-flow/rules/gates.txt` — 公开脚本清单

## read_files

read_files:
  - .github/workflows/scaffold-ci.yml
  - agent-flow/manifest.yaml
  - agent-flow/rules/gates.txt
  - agent-flow/scripts/pair-consistency-check.sh

## write_files

write_files:
  - .github/workflows/scaffold-ci.yml
  - agent-flow/manifest.yaml
  - agent-flow/rules/gates.txt
  - agent-flow/scripts/pair-consistency-check.sh
