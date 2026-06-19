# Requirement

## Background

The starter promises machine-checkable closeout, but live checks exposed gate-chain failures across Windows and Bash. These failures must be fixed before higher-level process scoring or adoption guidance can be trusted.

## Acceptance Criteria

| AC | Given | When | Then | Verification |
|---|---|---|---|---|
| AC-01 | A change has `REQUIREMENT.md` and `VERIFY.md` | `check-change.ps1` or `check-change.sh` runs | The aggregate chain invokes `ac-check`, `ac-traceability-check`, and `coverage-check` with valid paths and arguments | Syntax checks and sample `check-change` runs |
| AC-02 | `manifest.yaml` has `blocked_if` entries with inline comments | `manifest-check.ps1` or `.sh` runs | The valid rules are accepted without missing-rule false positives | `manifest-check.ps1`; `manifest-check.sh` |
| AC-03 | Verification commands contain internal quotes, such as `echo "message"` | `run-verify.ps1 -All` or `run-verify.sh --all` runs | Commands execute without losing their closing quote | `run-verify.ps1 -All`; `run-verify.sh --all` |
| AC-04 | Scripts contain status output | PowerShell and Bash syntax checks run | Changed scripts parse without broken encoded string literals or BOM-triggered Bash errors | PowerShell parser; `bash -n`; changed smoke tests |
| AC-05 | The starter example is used as a runnable reference | `check-change` runs on `examples/sample-change` | The example passes current gate rules and does not leave an untracked state artifact | Windows and Bash sample `check-change` runs |

## Boundaries

- Modify starter scripts, starter smoke tests, and the sample change only.
- Keep fixes general and project-agnostic.
- Do not change flow routing policy or Heavy gate requirements.
