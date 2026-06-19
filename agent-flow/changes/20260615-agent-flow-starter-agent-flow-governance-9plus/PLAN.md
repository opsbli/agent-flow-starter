# Plan

> Plan Status: planned
> Last Reviewed: 2026-06-15
> Source: agent-flow/changes/20260615-agent-flow-starter-agent-flow-governance-9plus/CHANGE.md

## Current Baseline

- Review score: 8.5 / 10.
- Passing baseline: `manifest-check`, `scaffold-health`, `template-check`, and starter self-tests pass on PowerShell and Bash.
- Known gaps: gate registry drift, tracked starter run-history, stale script README count, duplicate script lists in scaffold-health.

## Goals

- Fix all high-priority review gaps in order.
- Keep starter generic.
- Preserve cross-platform support.
- Add self-test coverage so the same drift is caught next time.

## Non-Goals

- No workflow-level redesign.
- No new application runtime.
- No replacement of PS/Bash dual implementations.

## Execution Phases

### Phase 1 - Registry source of truth

Status: planned

Scope:

- Register all public scripts in `gates.txt` and `manifest.yaml`.
- Extend `manifest-check` to fail when public scripts are not registered.

read_files:

- agent-flow/rules/gates.txt
- agent-flow/manifest.yaml
- agent-flow/scripts/manifest-check.ps1
- agent-flow/scripts/manifest-check.sh
- agent-flow/scripts/init-project.ps1
- agent-flow/scripts/init-project.sh

write_files:

- agent-flow/rules/gates.txt
- agent-flow/manifest.yaml
- agent-flow/scripts/manifest-check.ps1
- agent-flow/scripts/manifest-check.sh
- agent-flow/scripts/init-project.ps1
- agent-flow/scripts/init-project.sh

Exit Criteria:

- Actual public scripts and manifest gate entries match.

Verification:

- `manifest-check.ps1`
- `manifest-check.sh`

### Phase 2 - Scaffold health locality

Status: planned

Scope:

- Derive script requirements from `gates.txt`.
- Keep non-script required scaffold files as explicit base requirements.

read_files:

- agent-flow/scripts/scaffold-health.ps1
- agent-flow/scripts/scaffold-health.sh

write_files:

- agent-flow/scripts/scaffold-health.ps1
- agent-flow/scripts/scaffold-health.sh

Exit Criteria:

- Both scaffold-health scripts pass and fail if a `gates.txt` entry is missing.

Verification:

- `scaffold-health.ps1`
- `scaffold-health.sh`

### Phase 3 - Starter hygiene

Status: planned

Scope:

- Remove tracked run-history files from starter.
- Update `.gitignore` to keep future run-history local.
- Reset known-good baselines to a reusable template.

read_files:

- .gitignore
- agent-flow/logs/2026/06-15.md
- agent-flow/reports/practice-install-and-verify.md
- agent-flow/knowledge/known-good-baselines.md
- scripts/setup-new-pc.ps1

write_files:

- .gitignore
- agent-flow/logs/2026/06-15.md
- agent-flow/reports/practice-install-and-verify.md
- agent-flow/knowledge/known-good-baselines.md
- scripts/setup-new-pc.ps1

Exit Criteria:

- `git ls-files agent-flow/changes agent-flow/logs agent-flow/reports` returns only `.gitkeep` paths.

Verification:

- `git ls-files`
- starter self-tests

### Phase 4 - Docs and self-test

Status: planned

Scope:

- Update script README to avoid stale counts.
- Add self-test guard for tracked run-history.

read_files:

- agent-flow/scripts/README.md
- scripts/test-starter.ps1
- scripts/test-starter.sh

write_files:

- agent-flow/scripts/README.md
- scripts/test-starter.ps1
- scripts/test-starter.sh

Exit Criteria:

- Both starter self-tests pass.

Verification:

- `scripts/test-starter.ps1`
- `scripts/test-starter.sh`

## Closure Gates

- [ ] manifest-check PowerShell/Bash
- [ ] scaffold-health PowerShell/Bash
- [ ] template-check PowerShell/Bash
- [ ] starter self-test PowerShell/Bash
- [ ] script syntax checks
- [ ] sample change closure checks
- [ ] git diff --check
- [ ] tracked history guard

## Risks

| Risk | Mitigation |
|---|---|
| Manifest list and gates.txt still drift | Add manifest-check public script registry validation |
| Target project scaffold-health fails due logs/reports | Put starter-only history guard in root self-test, not target scaffold-health |
| Large script list edit misses one file | Compare actual scripts against manifest after edit |

## Protected Area Review

| Area | Touched | Decision |
|---|---|---|
| Scaffold scripts | yes | Required for requested quality upgrade |
| Root `.gitignore` | yes | Required to keep starter generic |
| Run-history files | yes | Delete tracked starter history; keep `.gitkeep` |

## Deferred But Adjudicated

| Item | Classification | Reason |
|---|---|---|
| Full generated README index | deferred | Avoid introducing new generation workflow; current README can reference gates.txt |
| JSON output for blocked-check | deferred | Useful but not required to cross 9.0 |
