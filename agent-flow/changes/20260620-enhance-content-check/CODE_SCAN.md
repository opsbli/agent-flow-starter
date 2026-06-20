# Code Scan

## 扫描时间

2026-06-20 19:45

## Machine Check

scan_time: 2026-06-20 19:45
related_modules: scripts/content-check.sh, scripts/content-check.ps1, scripts/check-change.sh, scripts/check-change.ps1
similar_implementations: scaffold-health (已有路径注册模式), check-change (门禁注册模式)
reusable_abstractions: meaningful_file utility in _common.sh
standards_snapshot: content-check 的占位符检测模式已在 scaffold-health 级别的文件上验证
test_baseline: scaffold-health, content-check --project-root
read_files: agent-flow/scripts/content-check.sh, agent-flow/scripts/content-check.ps1, agent-flow/scripts/check-change.sh, agent-flow/scripts/check-change.ps1, agent-flow/scripts/_common.sh, agent-flow/scripts/_common.ps1
write_files: agent-flow/scripts/content-check.sh, agent-flow/scripts/content-check.ps1, agent-flow/scripts/check-change.sh, agent-flow/scripts/check-change.ps1
open_questions: none

## read_files

read_files:
  - agent-flow/scripts/content-check.sh
  - agent-flow/scripts/content-check.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/check-change.ps1
  - agent-flow/scripts/_common.sh
  - agent-flow/scripts/_common.ps1

## write_files

write_files:
  - agent-flow/scripts/content-check.sh
  - agent-flow/scripts/content-check.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/check-change.ps1

## 未决问题

无
