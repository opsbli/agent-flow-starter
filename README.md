# agent-flow-starter

Reusable starter for a controlled AI development workflow.

`agent-flow` gives a project a file-based workflow for:

- code-first context scanning
- Light / Standard / Heavy change routing
- requirement, design, task, verification, review, and evolution artifacts
- AC evidence and drift checks
- project knowledge and ADR capture
- Windows and Linux/macOS verification scripts

## Install Into A Project

Windows:

```powershell
.\scripts\install-agent-flow.ps1 -Target "C:\path\to\your-project"
```

Linux/macOS:

```bash
bash scripts/install-agent-flow.sh --target /path/to/your-project
```

The installer will:

- copy or update `agent-flow/`
- create or update an `AGENTS.md` block
- preserve existing `agent-flow/changes`, `agent-flow/logs`, `agent-flow/reports`, `agent-flow/knowledge`, and `agent-flow/decisions`
- run `agent-flow/scripts/scaffold-health`

## After Install

Run the initializer once in the target project.

Windows:

```powershell
agent-flow/scripts/init-project.ps1
```

Linux/macOS:

```bash
bash agent-flow/scripts/init-project.sh
```

Then ask your AI IDE:

```text
I have installed agent-flow in this project.
Do not write business code yet.

Review the generated agent-flow initialization:
1. Check AGENTS.md Project Context.
2. Check agent-flow/manifest.yaml.
3. Check agent-flow/knowledge/module-map.md, reuse-map.md, verification.md, and pitfalls.md.
4. Fill any remaining TODO values.
5. Run scaffold-health and the safe verification commands.
6. Output how to use agent-flow in this project.
```

## Daily Usage

```text
Use the agent-flow process for this request: <your requirement>.
Start with code-first scan, classify Light/Standard/Heavy, then give me CHANGE and the execution plan.
```

For Heavy work:

```text
Continue agent-flow change: <change-id>.
Do not implement yet.
Complete REQUIREMENT, CODE_SCAN, DESIGN, PLAN, TASKS, then run Plan Audit.
```

## Repository Layout

```text
agent-flow-starter/
├── AGENTS.md
├── README.md
├── docs/
├── examples/
├── agent-flow/
└── scripts/
    ├── install-agent-flow.ps1
    ├── install-agent-flow.sh
    ├── test-starter.ps1
    └── test-starter.sh
```

## Starter Self-Test

Windows:

```powershell
.\scripts\test-starter.ps1
```

Linux/macOS:

```bash
bash scripts/test-starter.sh
```

## Manifest-Driven Verification

Target projects should store verification commands in `agent-flow/manifest.yaml`.

Windows:

```powershell
agent-flow/scripts/run-verify.ps1 -All
agent-flow/scripts/run-verify.ps1 -Name backend_test
agent-flow/scripts/run-verify.ps1 -Name module_test -Module <module>
```

Linux/macOS:

```bash
bash agent-flow/scripts/run-verify.sh --all
bash agent-flow/scripts/run-verify.sh --name backend_test
bash agent-flow/scripts/run-verify.sh --name module_test --module <module>
```

## Versioning

The starter version is stored in:

```text
agent-flow/VERSION
```

Upgrade notes are in:

```text
CHANGELOG.md
agent-flow/UPGRADE.md
```

## More Docs

- `docs/ADOPTION.md`
- `docs/PROMPTS.md`
- `examples/sample-change/`
