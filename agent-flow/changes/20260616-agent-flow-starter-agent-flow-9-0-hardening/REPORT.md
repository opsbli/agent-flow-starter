# Report

## Delivered

- AC-01: Installers now create clean `changes/`, `logs`, and `reports` directories and do not seed starter-local histories.
- AC-02: `alignment-check.ps1` and `alignment-check.sh` now require at least three `user-confirmed` rows for aligned Standard/Heavy changes.
- AC-03: `init-project.sh` now preserves explicit missing-dir placeholders for empty projects.
- AC-04: `check-change.ps1 -Closure` and `check-change.sh --closure` now fail on missing flow-required artifacts.
- AC-05: Removed duplicate `.github/workflows/agent-flow-starter-check.yml`; `scaffold-ci.yml` remains the single comprehensive workflow.
- AC-06: Updated Windows and bash self-tests to cover the new behavior.

## Verification

- `agent-flow/scripts/scaffold-health.ps1` pass
- `bash agent-flow/scripts/scaffold-health.sh` pass
- `agent-flow/scripts/template-check.ps1` pass
- `bash agent-flow/scripts/template-check.sh` pass
- `agent-flow/scripts/manifest-check.ps1` pass
- `bash agent-flow/scripts/manifest-check.sh` pass
- `scripts/test-starter.ps1` pass
- `bash scripts/test-starter.sh` pass

## Residual Risks

none

## Rollback

Revert the touched scripts, tests, template updates, baseline/log entry, and workflow deletion.
