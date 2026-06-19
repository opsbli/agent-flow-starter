# Code Scan

## 扫描时间

2026-06-15

## Machine Check

scan_time: 2026-06-15
related_modules: agent-flow/rules/gates.txt, agent-flow/manifest.yaml, agent-flow/scripts/manifest-check.ps1, agent-flow/scripts/manifest-check.sh, agent-flow/scripts/scaffold-health.ps1, agent-flow/scripts/scaffold-health.sh, scripts/test-starter.ps1, scripts/test-starter.sh, agent-flow/scripts/README.md, .gitignore
similar_implementations: manifest-check already reads gates.txt before falling back to built-in list; scaffold-health currently has a duplicate static script list; test-starter already has project residue scans
reusable_abstractions: gates.txt as source-of-truth; Test-Path checks; git ls-files checks in self-test
test_baseline: manifest-check.ps1/.sh, scaffold-health.ps1/.sh, template-check.ps1/.sh, scripts/test-starter.ps1/.sh
read_files: .pi/APPEND_SYSTEM.md, agent-flow/README.md, agent-flow/GO.md, agent-flow/manifest.yaml, agent-flow/core/source-of-truth.md, agent-flow/core/evolution.md, agent-flow/core/principles.md, agent-flow/core/autonomy-policy.md, agent-flow/core/router.md, agent-flow/core/code-first-context.md, agent-flow/core/memory.md, agent-flow/core/plan-guide.md, agent-flow/core/audit.md, agent-flow/core/logging.md, agent-flow/core/frontend-fit.md, agent-flow/ecc-integration.md, agent-flow/rules/gates.txt, agent-flow/scripts/manifest-check.ps1, agent-flow/scripts/manifest-check.sh, agent-flow/scripts/scaffold-health.ps1, agent-flow/scripts/scaffold-health.sh, agent-flow/scripts/README.md, scripts/test-starter.ps1, scripts/test-starter.sh, .gitignore
write_files: agent-flow/rules/gates.txt, agent-flow/manifest.yaml, agent-flow/scripts/manifest-check.ps1, agent-flow/scripts/manifest-check.sh, agent-flow/scripts/scaffold-health.ps1, agent-flow/scripts/scaffold-health.sh, agent-flow/scripts/init-project.ps1, agent-flow/scripts/init-project.sh, agent-flow/scripts/README.md, scripts/test-starter.ps1, scripts/test-starter.sh, scripts/setup-new-pc.ps1, .gitignore, agent-flow/knowledge/known-good-baselines.md, agent-flow/logs/2026/06-15.md, agent-flow/reports/practice-install-and-verify.md
open_questions: none

## 相关模块

- Gate registry: `agent-flow/rules/gates.txt`, `agent-flow/manifest.yaml`
- Gate validation: `agent-flow/scripts/manifest-check.ps1`, `agent-flow/scripts/manifest-check.sh`
- Scaffold validation: `agent-flow/scripts/scaffold-health.ps1`, `agent-flow/scripts/scaffold-health.sh`
- Starter self-test: `scripts/test-starter.ps1`, `scripts/test-starter.sh`
- Documentation: `agent-flow/scripts/README.md`
- Starter hygiene: `.gitignore`, `agent-flow/logs`, `agent-flow/reports`, `agent-flow/knowledge/known-good-baselines.md`

## 相似实现

| Capability | Reference | Reuse |
|---|---|---|
| Formal gate list | `manifest-check.ps1/.sh` | Already reads `agent-flow/rules/gates.txt`; extend it to validate registry completeness |
| Scaffold required files | `scaffold-health.ps1/.sh` | Keep static base requirements, derive script requirements from `gates.txt` |
| Starter residue scanning | `scripts/test-starter.ps1/.sh` | Extend existing residue scan to catch tracked run-history files |

## 可复用抽象

- `agent-flow/rules/gates.txt` is the best existing source of truth for public script files.
- `git ls-files` can identify tracked starter history without being confused by ignored local change docs.

## 禁止重复实现

- Do not introduce another script registry file.
- Do not hard-code script counts in README.
- Do not make target-project `scaffold-health` fail because target projects have legitimate logs/reports.

## 构建 / 模块 / 路由影响

- No application build files exist in this scaffold-only repo.
- Changes affect scaffold validation and starter CI behavior.

## 数据库 / 权限 / API 扫描

- No database, auth, permission, public API, cache, WebSocket, or production config impact.

## 测试基线

- `manifest-check.ps1/.sh`
- `scaffold-health.ps1/.sh`
- `template-check.ps1/.sh`
- `scripts/test-starter.ps1`
- `scripts/test-starter.sh`
- PowerShell/Bash syntax checks

## read_files

read_files:
  - .pi/APPEND_SYSTEM.md
  - agent-flow/README.md
  - agent-flow/GO.md
  - agent-flow/manifest.yaml
  - agent-flow/core/source-of-truth.md
  - agent-flow/core/evolution.md
  - agent-flow/core/principles.md
  - agent-flow/core/autonomy-policy.md
  - agent-flow/core/router.md
  - agent-flow/core/code-first-context.md
  - agent-flow/core/memory.md
  - agent-flow/core/plan-guide.md
  - agent-flow/core/audit.md
  - agent-flow/core/logging.md
  - agent-flow/core/frontend-fit.md
  - agent-flow/ecc-integration.md
  - agent-flow/rules/gates.txt
  - agent-flow/scripts/manifest-check.ps1
  - agent-flow/scripts/manifest-check.sh
- agent-flow/scripts/scaffold-health.ps1
- agent-flow/scripts/scaffold-health.sh
- agent-flow/scripts/init-project.ps1
- agent-flow/scripts/init-project.sh
- agent-flow/scripts/README.md
- scripts/test-starter.ps1
- scripts/test-starter.sh
- scripts/setup-new-pc.ps1
- .gitignore

## write_files

write_files:
  - agent-flow/rules/gates.txt
  - agent-flow/manifest.yaml
  - agent-flow/scripts/manifest-check.ps1
  - agent-flow/scripts/manifest-check.sh
  - agent-flow/scripts/scaffold-health.ps1
  - agent-flow/scripts/scaffold-health.sh
  - agent-flow/scripts/init-project.ps1
  - agent-flow/scripts/init-project.sh
  - agent-flow/scripts/README.md
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - scripts/setup-new-pc.ps1
  - .gitignore
  - agent-flow/knowledge/known-good-baselines.md
  - agent-flow/logs/2026/06-15.md
  - agent-flow/reports/practice-install-and-verify.md

## 未决问题

- none
