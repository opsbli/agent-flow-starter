# Upgrade Guide

Use the starter installer to update a target project:

Windows:

```powershell
C:\path\to\agent-flow-starter\scripts\install-agent-flow.ps1 -Target "C:\path\to\project"
```

Linux/macOS:

```bash
bash /path/to/agent-flow-starter/scripts/install-agent-flow.sh --target /path/to/project
```

## Preserved By Default

The installer preserves target-project history and knowledge:

- `agent-flow/changes`
- `agent-flow/logs`
- `agent-flow/reports`
- `agent-flow/knowledge`
- `agent-flow/decisions`

## After Upgrade

Run:

Windows:

```powershell
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/init-project.ps1
```

Linux/macOS:

```bash
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/init-project.sh
```

Then inspect any project-local template or flow customizations before accepting the upgrade.

## Conflict Strategy

The installer updates starter-owned files and preserves project-owned history.

Starter-owned by default:

- `agent-flow/core`
- `agent-flow/flows`
- `agent-flow/templates`
- `agent-flow/scripts`
- `agent-flow/README.md`
- `agent-flow/UPGRADE.md`
- `agent-flow/VERSION`

Project-owned by default:

- `agent-flow/changes`
- `agent-flow/logs`
- `agent-flow/reports`
- `agent-flow/knowledge`
- `agent-flow/decisions`

Manually review:

- `AGENTS.md`
- `agent-flow/manifest.yaml`
- customized templates or flows

If a project intentionally customizes starter-owned files, record that decision in `agent-flow/decisions/` before upgrading.
