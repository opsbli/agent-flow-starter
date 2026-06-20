# Verification Knowledge

> This project is a dev-toolkit (shell/powershell scripts), not a traditional backend/frontend app.
> "Testing" here means scaffold self-checks and gate validation.

## Scaffold Integrity

```bash
# Linux/macOS
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/manifest-check.sh
bash agent-flow/scripts/template-check.sh
```

```powershell
# Windows
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/manifest-check.ps1
agent-flow/scripts/template-check.ps1
```

## Change Workflow Gates

```bash
# Per-change gate bundle (run before declaring done)
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id>

# Individual gates (run as needed)
bash agent-flow/scripts/design-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/alignment-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/task-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/ac-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/ac-traceability-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/coverage-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/code-drift-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/closure-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/evolution-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/task-boundary-check.sh --change-dir agent-flow/changes/<change-id>
```

## Cross-Platform Consistency

```bash
# Check ps1/sh pair line-count divergence
bash agent-flow/scripts/pair-consistency-check.sh
# With custom threshold (default 30%)
bash agent-flow/scripts/pair-consistency-check.sh --threshold 20

# Check script registry sync
bash agent-flow/scripts/registry-sync.sh
```

## CI Simulation

```bash
# Run the full CI pipeline locally
bash scripts/test-starter.sh
bash scripts/test-gate-fixtures.sh

# Run gate smoke tests
bash agent-flow/test/test-scripts/test-gate-smoke.sh
bash agent-flow/test/test-scripts/test-next-step.sh
```

## Common Verification Patterns

| When | Run |
|------|-----|
| After editing any script | `scaffold-health.sh + manifest-check.sh` |
| After adding a new script | `manifest-check.sh + registry-sync.sh` |
| After a change milestone | `check-change.sh --change-dir <path>` |
| Before claiming change complete | `closure-check.sh + task-boundary-check.sh` |
| After install/upgrade | `scaffold-health.sh + init-project.sh` |
| Monthly health check | `pair-consistency-check.sh + evolution-stats.sh --update-index` |
