# Verification Knowledge

## Backend

~~~text
TODO_BACKEND_COMPILE_COMMAND
TODO_BACKEND_TEST_COMMAND
~~~

## Frontend

~~~text
TODO_FRONTEND_TYPECHECK_COMMAND
TODO_FRONTEND_TEST_COMMAND
TODO_FRONTEND_LINT_COMMAND
~~~

## Gates

Windows:

~~~powershell
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/manifest-check.ps1
agent-flow/scripts/run-verify.ps1 -All
~~~

Linux/macOS:

~~~bash
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/manifest-check.sh
bash agent-flow/scripts/run-verify.sh --all
~~~

## Evidence Requirement

VERIFY.md must record commands, results, failure summaries, skipped checks, and AC evidence.
