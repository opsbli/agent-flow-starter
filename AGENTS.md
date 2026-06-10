# agent-flow-starter Agent Rules

> This repository is the reusable starter for the `agent-flow` AI development workflow.
> Keep this repo generic. Do not add project-specific business history to the starter.

## Default Entry

For work inside this starter repo, start from:

```text
agent-flow/README.md
```

When updating the workflow itself, also read:

```text
agent-flow/GO.md
agent-flow/manifest.yaml
agent-flow/core/source-of-truth.md
agent-flow/core/evolution.md
```

## Editing Rules

- Keep `AGENTS.md` short and operational.
- Put detailed usage in `README.md` or `agent-flow/README.md`.
- Keep templates generic.
- Do not add real project `changes/`, `logs/`, `reports/`, or `known-good-baselines` to this starter.
- When changing scripts, update both Windows `.ps1` and Linux/macOS `.sh` versions when applicable.
- Run both scaffold health scripts after changing scaffold structure.

## Install Contract

The starter must support:

- Creating or updating `agent-flow/` in a target project.
- Creating or updating an `AGENTS.md` agent-flow block in a target project.
- Preserving target project history under `agent-flow/changes`, `agent-flow/logs`, and `agent-flow/reports` unless explicitly forced.

