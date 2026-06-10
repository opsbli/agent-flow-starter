# Verification Knowledge

> Initialize project-specific commands after installing agent-flow.

## Backend

```text
TODO_BACKEND_COMPILE_COMMAND
TODO_BACKEND_TEST_COMMAND
```

## Frontend

```text
TODO_FRONTEND_TYPECHECK_COMMAND
TODO_FRONTEND_TEST_COMMAND
TODO_FRONTEND_LINT_COMMAND
```

## Gates

Windows:

```powershell
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/run-verify.ps1 -All
agent-flow/scripts/run-verify.ps1 -Name backend_test
agent-flow/scripts/run-verify.ps1 -Name module_test -Module <module>
agent-flow/scripts/ac-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/drift-check.ps1 -ChangeDir agent-flow/changes/<change-id>
```

Linux/macOS:

```bash
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/run-verify.sh --all
bash agent-flow/scripts/run-verify.sh --name backend_test
bash agent-flow/scripts/run-verify.sh --name module_test --module <module>
bash agent-flow/scripts/ac-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/drift-check.sh --change-dir agent-flow/changes/<change-id>
```

## Evidence Requirement

`VERIFY.md` must record commands, results, failure summaries, skipped checks, and AC evidence.
