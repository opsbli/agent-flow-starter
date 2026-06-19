# Adoption Guide

Use this guide when introducing `agent-flow` to a team project.

## Recommended Rollout

1. Install `agent-flow` into the project.
2. Run `init-project`.
3. Review and correct `AGENTS.md`, `manifest.yaml`, and `knowledge/*.md`.
4. Run `scaffold-health`.
5. Run one small Light change.
6. Run one realistic Standard or Heavy change.
7. Only then ask the wider team to use it for everyday work.

## Team Agreement

Before team-wide use, agree on:

- protected areas
- required verification commands
- who can accept conditional closure
- when ADRs are required
- how follow-up technical debt is tracked

## Starter Files Versus Project Files

Usually safe to update from the starter:

- `agent-flow/core`
- `agent-flow/flows`
- `agent-flow/templates`
- `agent-flow/scripts`
- `agent-flow/README.md`
- `agent-flow/UPGRADE.md`
- `agent-flow/VERSION`

Project-owned and preserved by installer:

- `agent-flow/changes`
- `agent-flow/logs`
- `agent-flow/reports`
- `agent-flow/knowledge`
- `agent-flow/decisions`

Review manually after upgrade:

- `AGENTS.md`
- `agent-flow/manifest.yaml`
- any locally customized templates or flows

