# Changelog

## Unreleased

### ✨ New

- `coverage-check.ps1/.sh` computes AC Evidence coverage and requires test coverage evidence or an explicit skip reason.
- `template-check.ps1/.sh` validates required templates, template version metadata, and `artifact-schema.json`.
- `knowledge-search.ps1/.sh` searches `agent-flow/knowledge/` and `agent-flow/decisions/` before adding new long-term facts.
- `knowledge/INDEX.md`, `templates/VERSION`, and `templates/REQUIREMENT_ALIGNED.md` strengthen knowledge indexing and template lifecycle management.

### 🔧 Updated

- `check-change` now runs `coverage-check` after `ac-check` when `REQUIREMENT.md` and `VERIFY.md` are present.
- Heavy closure gate rules and `VERIFY.md` now include `coverage-check` and `Coverage Summary`.
- Installers seed missing starter-owned files inside preserved `knowledge/` and `decisions/` directories without overwriting project-owned content.

## 0.2.0 (2026-06-10)

> Semantic versioning: MAJOR.MINOR.PATCH
> - MAJOR: incompatible changes to core/flows/templates/scripts or install/upgrade contract
> - MINOR: new files, templates, tools, or non-breaking enhancements
> - PATCH: bug fixes, documentation improvements, or backward-compatible adjustments

### ✨ New

- `scripts/install-agent-flow.ps1` and `install-agent-flow.sh` for installing or upgrading the scaffold in target projects (#upgrade-guide)
- `test/` directory with smoke tests for new-change script and minimal-project fixture (#test-coverage)
- `CHANGELOG.md` for version tracking (#changelog)
- `CODE_SCAN.md` template now includes a Light-mode summary section (#light-simplification)
- `code-drift-check` scripts for comparing DESIGN.md declarations against live code structure (#drift-detection)
- `CANCEL.md` and `ROLLBACK.md` templates for change lifecycle management (#lifecycle)

### 🧹 Fixed

- `frontend-fit.md` path inconsistency: moved from `knowledge/` reference to unified `core/frontend-fit.md` (#path-consistency)
- `manifest.yaml` now includes `blocked_if` risk rules (#blocked-rules)
- `verify-backend` scripts collapsed into `run-verify` (#script-collapse)
- `pitfalls.md` expanded with additional common pitfalls (#pitfalls)

### 🔧 Updated

- `scaffold-health` now validates install-agent-flow scripts, test directory, and test scripts
- `VERSION` updated to 0.2.0
- `UPGRADE.md` includes error handling and conflict resolution guidance

### 🗑 Removed

- `scripts/verify-backend.ps1` (replaced by `run-verify.ps1 -Name backend_compile|backend_test`)
- `scripts/verify-backend.sh` (replaced by `run-verify.sh --name backend_compile|backend_test`)
- `scripts/verify-module.ps1` (replaced by `run-verify.ps1 -Name module_compile|module_test -Module <name>`)
- `scripts/verify-module.sh` (replaced by `run-verify.sh --name module_compile|module_test --module <name>`)
