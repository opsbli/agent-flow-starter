# Code Scan

## Scan Time

2026-06-16 10:00

## Machine Check

scan_time: 2026-06-16 10:00
related_modules: agent-flow/scripts, scripts/test-starter, agent-flow/templates, .github/workflows
similar_implementations: agent-flow/scripts/install-agent-flow.ps1
reusable_abstractions: agent-flow/scripts/_common.ps1 and agent-flow/scripts/_common.sh
test_baseline: scripts/test-starter.ps1 and scripts/test-starter.sh
read_files: agent-flow/GO.md
write_files: agent-flow/scripts/install-agent-flow.ps1
open_questions: none

## Related Modules

- Installer: `agent-flow/scripts/install-agent-flow.ps1`, `agent-flow/scripts/install-agent-flow.sh`
- Aggregate gate runner: `agent-flow/scripts/check-change.ps1`, `agent-flow/scripts/check-change.sh`
- State synchronizer: `agent-flow/scripts/sync-state.ps1`, `agent-flow/scripts/sync-state.sh`
- Alignment gate: `agent-flow/scripts/alignment-check.ps1`, `agent-flow/scripts/alignment-check.sh`
- Initializer: `agent-flow/scripts/init-project.ps1`, `agent-flow/scripts/init-project.sh`
- Design template/generators: `agent-flow/templates/DESIGN.md`, `agent-flow/scripts/generate-design.ps1`, `agent-flow/scripts/generate-design.sh`
- Starter self-tests: `scripts/test-starter.ps1`, `scripts/test-starter.sh`
- CI workflows: `.github/workflows/scaffold-ci.yml`, `.github/workflows/agent-flow-starter-check.yml`

## Similar Implementations

| Capability | Reference File | Reuse |
|---|---|---|
| Flow detection | `agent-flow/scripts/_common.ps1`, `agent-flow/scripts/_common.sh` | Reuse flow-level helpers for closure artifact requirements. |
| Gate aggregation | `agent-flow/scripts/check-change.ps1`, `agent-flow/scripts/check-change.sh` | Add `closure-required-artifacts` as another gate result. |
| State sync cleanup | `agent-flow/scripts/sync-state.ps1`, `agent-flow/scripts/sync-state.sh` | Remove scaffold placeholder history rows before closure checks inspect `STATE.md`. |
| Alignment parsing | `agent-flow/scripts/alignment-check.ps1`, `agent-flow/scripts/alignment-check.sh` | Extend existing table row parsing. |
| Install preservation | `agent-flow/scripts/install-agent-flow.ps1`, `agent-flow/scripts/install-agent-flow.sh` | Keep project-owned preservation and specialize history dirs. |
| Self-test assertions | `scripts/test-starter.ps1`, `scripts/test-starter.sh` | Add positive/negative checks near existing install and gate assertions. |

## Reusable Abstractions

- `_common` provides flow detection and meaningful-file checks.
- Existing self-test helpers such as `Assert-Fails` / `expect_failure` can cover new negative cases.
- `gates.txt` remains the public script registry; no new registry is needed.

## Do Not Reimplement

- Do not create a second installer path.
- Do not create a second alignment artifact.
- Do not add jq or another parser dependency.

## Build / Module / Route Impact

No build file, module registration, or route impact.

## Database / Permission / API Scan

No database, permission, auth, or API behavior is changed.

## Frontend Scan

No frontend.

## Test Baseline

- `agent-flow/scripts/scaffold-health.ps1`
- `bash agent-flow/scripts/scaffold-health.sh`
- `agent-flow/scripts/manifest-check.ps1`
- `bash agent-flow/scripts/manifest-check.sh`
- `agent-flow/scripts/template-check.ps1`
- `bash agent-flow/scripts/template-check.sh`
- `scripts/test-starter.ps1`
- `bash scripts/test-starter.sh`

## read_files

read_files:
  - agent-flow/GO.md
  - agent-flow/manifest.yaml
  - agent-flow/core/source-of-truth.md
  - agent-flow/core/router.md
  - agent-flow/core/code-first-context.md
  - agent-flow/core/autonomy-policy.md
  - agent-flow/core/plan-guide.md
  - agent-flow/core/audit.md
  - agent-flow/core/evolution.md
  - agent-flow/core/logging.md
  - agent-flow/scripts/_common.ps1
  - agent-flow/scripts/_common.sh
  - agent-flow/scripts/install-agent-flow.ps1
  - agent-flow/scripts/install-agent-flow.sh
  - agent-flow/scripts/alignment-check.ps1
  - agent-flow/scripts/alignment-check.sh
  - agent-flow/scripts/init-project.ps1
  - agent-flow/scripts/init-project.sh
  - agent-flow/scripts/check-change.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/sync-state.ps1
  - agent-flow/scripts/sync-state.sh
  - agent-flow/scripts/closure-check.ps1
  - agent-flow/templates/DESIGN.md
  - agent-flow/scripts/generate-design.ps1
  - agent-flow/scripts/generate-design.sh
  - agent-flow/flows/standard.md
  - agent-flow/flows/heavy.md
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - .github/workflows/scaffold-ci.yml

## write_files

write_files:
  - agent-flow/scripts/install-agent-flow.ps1
  - agent-flow/scripts/install-agent-flow.sh
  - agent-flow/scripts/alignment-check.ps1
  - agent-flow/scripts/alignment-check.sh
  - agent-flow/scripts/init-project.ps1
  - agent-flow/scripts/init-project.sh
  - agent-flow/scripts/check-change.ps1
  - agent-flow/scripts/check-change.sh
  - agent-flow/scripts/sync-state.ps1
  - agent-flow/scripts/sync-state.sh
  - agent-flow/templates/DESIGN.md
  - agent-flow/scripts/generate-design.ps1
  - agent-flow/scripts/generate-design.sh
  - agent-flow/flows/standard.md
  - scripts/test-starter.ps1
  - scripts/test-starter.sh
  - agent-flow/knowledge/known-good-baselines.md
  - agent-flow/logs/2026/06-16.md
  - .github/workflows/agent-flow-starter-check.yml

## Breaking Changes

Deletes one duplicate CI workflow file. No runtime code, schema, auth, API, or deployment behavior is changed.

## Open Questions

none
