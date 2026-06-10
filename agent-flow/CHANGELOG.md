# Changelog

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
