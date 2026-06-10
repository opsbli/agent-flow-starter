# {project-name} Agent Rules

<!-- agent-flow:start -->
> This repository uses `agent-flow` as the default AI development workflow.
> The repo is the source of truth. Chat is only a temporary working surface.

## Default Entry

For any non-trivial request, agents must start from:

```text
agent-flow/GO.md
```

Read in order:

1. `agent-flow/GO.md`
2. `agent-flow/manifest.yaml`
3. `agent-flow/core/source-of-truth.md`
4. `agent-flow/core/autonomy-policy.md`
5. `agent-flow/core/router.md`
6. `agent-flow/core/code-first-context.md`
7. `agent-flow/core/memory.md`
8. `agent-flow/core/plan-guide.md`
9. `agent-flow/core/audit.md`
10. `agent-flow/core/logging.md`
11. `agent-flow/core/evolution.md`

If a task touches frontend work, also read:

```text
agent-flow/core/frontend-fit.md
```

## Project Context

This section must be initialized for the target project:

- Project name:
- Main stack:
- Backend directories:
- Frontend directories:
- Database or persistence:
- Test commands:
- Protected areas:

## Default Workflow

Classify each request as `Light`, `Standard`, or `Heavy` using `agent-flow/core/router.md`.

Heavy is required for schema, auth, public API contracts, workflow/state machines, cross-repo frontend/backend work, deployment, production-risk changes, or large module boundaries.

## Code-First Rule

Before design or implementation:

- scan relevant source code
- find similar implementation
- record `read_files`
- record `write_files`
- do not modify files outside the approved `write_files`

## Protected Areas

Follow `agent-flow/core/autonomy-policy.md`.

Stop and ask before touching protected areas such as database schema, auth/permission, public API contracts, token/session, deployment, production config, billing/license, destructive operations, or root build files.

## Verification

Windows:

```text
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/ac-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/drift-check.ps1 -ChangeDir agent-flow/changes/<change-id>
```

Linux/macOS:

```text
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/ac-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/drift-check.sh --change-dir agent-flow/changes/<change-id>
```

No change is complete without `VERIFY.md`.

## Knowledge And Decisions

- Reusable facts go to `agent-flow/knowledge/`.
- Irreversible architectural decisions go to `agent-flow/decisions/`.
- Each completed change writes `EVOLUTION.md`.

## Hard Prohibitions

- No direct-to-code for non-trivial changes.
- No design before `CODE_SCAN.md`.
- No Heavy implementation before Plan Audit.
- No Heavy completion before Closure Audit.
- No protected-area change without approval.
- No duplicate abstraction before search.
- No completion claim without verification evidence.
- No chat-only durable memory.
<!-- agent-flow:end -->

