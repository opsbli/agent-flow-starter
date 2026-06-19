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
agent-flow/scripts/scan-check.ps1 -ChangeDir agent-flow/changes/<change-id> -ProjectRoot . -Strict
agent-flow/scripts/design-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/alignment-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/task-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/plan-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/emergency-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/evolution-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/<change-id> -OutputPath agent-flow/changes/<change-id>/CHECK_RESULT.json
agent-flow/scripts/run-verify.ps1 -All
~~~

Linux/macOS:

~~~bash
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/manifest-check.sh
bash agent-flow/scripts/scan-check.sh --change-dir agent-flow/changes/<change-id> --project-root . --strict
bash agent-flow/scripts/design-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/alignment-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/task-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/plan-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/emergency-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/evolution-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id> --output agent-flow/changes/<change-id>/CHECK_RESULT.json
bash agent-flow/scripts/run-verify.sh --all
~~~

## Evidence Requirement

VERIFY.md must record commands, results, failure summaries, skipped checks, AC evidence, and Machine Gate Summary rows with Result, Command, Exit Code, When, and Evidence.
