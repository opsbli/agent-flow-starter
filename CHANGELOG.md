# Changelog

## Unreleased

- Added `coverage-check`, `template-check`, and `knowledge-search` scripts for stronger coverage, template validation, and knowledge retrieval.
- Added `agent-flow/knowledge/INDEX.md`, `agent-flow/templates/VERSION`, `agent-flow/templates/REQUIREMENT_ALIGNED.md`, and `docs/TROUBLESHOOTING.md`.
- Updated `check-change`, closure gate rules, scaffold health, manifest gates, examples, and docs to include coverage evidence and template validation.

## 0.2.0

- Added manifest-driven verification runner: `run-verify.ps1` and `run-verify.sh`.
- Changed backend/module verification wrappers to read commands from `agent-flow/manifest.yaml`.
- Added project initialization scripts: `init-project.ps1` and `init-project.sh`.
- Added starter self-test scripts: `test-starter.ps1` and `test-starter.sh`.
- Added version, upgrade, and initialization checklist documents.

## 0.1.0

- Initial reusable `agent-flow` scaffold.
- Added installer scripts for Windows and Linux/macOS.
- Added cross-platform scaffold, AC, and drift checks.
