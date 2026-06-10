# Initialization Checklist

Use this after installing `agent-flow` into a target project.

## Required

- [ ] `AGENTS.md` contains the `agent-flow` block.
- [ ] `AGENTS.md` Project Context is filled with real project facts.
- [ ] `agent-flow/manifest.yaml` has no unresolved `TODO_` values that matter to the project.
- [ ] `agent-flow/knowledge/module-map.md` lists real modules and entry points.
- [ ] `agent-flow/knowledge/reuse-map.md` lists common/shared capabilities.
- [ ] `agent-flow/knowledge/verification.md` lists runnable verification commands.
- [ ] Windows or Linux/macOS scaffold health passes.

## Recommended

- [ ] Run one small Light change to validate the workflow.
- [ ] Run one realistic Standard or Heavy change before team-wide adoption.
- [ ] Record project-specific protected areas in `agent-flow/core/autonomy-policy.md` or `AGENTS.md`.
- [ ] Confirm `run-verify` commands are safe and do not hit production resources.

## Commands

Windows:

```powershell
agent-flow/scripts/init-project.ps1
agent-flow/scripts/scaffold-health.ps1
```

Linux/macOS:

```bash
bash agent-flow/scripts/init-project.sh
bash agent-flow/scripts/scaffold-health.sh
```

