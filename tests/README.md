# Starter Tests

This directory is reserved for starter-level integration tests that run against the
`agent-flow-starter` repository itself.

## Test locations

| What | Where |
|------|-------|
| **Scaffold health check** | `agent-flow/scripts/scaffold-health.sh` |
| **Manifest validation** | `agent-flow/scripts/manifest-check.sh` |
| **Template validation** | `agent-flow/scripts/template-check.sh` |
| **Unit tests (PowerShell)** | `agent-flow/test/unit/test-common.ps1` (Pester) |
| **Unit tests (Bash)** | `agent-flow/test/unit/test-common.bats` (bats) |
| **Smoke tests** (new-change, next-step) | `agent-flow/test/test-scripts/` |
| **Gate fixture tests** | `scripts/test-gate-fixtures.sh` |
| **End-to-end starter self-test** | `scripts/test-starter.sh` |

## Running unit tests

### PowerShell (Pester)
```powershell
Invoke-Pester agent-flow/test/unit/test-common.ps1
```

### Bash (bats)
```bash
bats agent-flow/test/unit/test-common.bats
```

## Adding tests

Add new test scripts to `scripts/` for starter-level tests, or to
`agent-flow/test/test-scripts/` for scaffold tests that ship with the scaffold.
