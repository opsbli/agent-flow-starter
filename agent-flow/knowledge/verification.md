# Verification Knowledge

## Backend

`	ext
TODO_BACKEND_COMPILE_COMMAND
TODO_BACKEND_TEST_COMMAND
`

## Frontend

`	ext
TODO_FRONTEND_TYPECHECK_COMMAND
TODO_FRONTEND_TEST_COMMAND
TODO_FRONTEND_LINT_COMMAND
`

## Gates

Windows:

`powershell
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/run-verify.ps1 -All
`

Linux/macOS:

`ash
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/run-verify.sh --all
`

## Evidence Requirement

VERIFY.md must record commands, results, failure summaries, skipped checks, and AC evidence.
