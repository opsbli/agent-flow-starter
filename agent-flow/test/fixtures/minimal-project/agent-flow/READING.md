# Reading Fallback

Use this file when terminal output renders Chinese markdown incorrectly.

## Stable Entry Points

Read in this order:

```text
agent-flow/GO.md
agent-flow/manifest.yaml
agent-flow/core/source-of-truth.md
agent-flow/core/router.md
agent-flow/flows/light.md
agent-flow/flows/standard.md
agent-flow/flows/heavy.md
docs/PROMPTS.md
```

## Encoding

All markdown files should be UTF-8.

Windows:

```powershell
Get-Content -Encoding utf8 -Raw agent-flow/GO.md
```

Linux/macOS:

```bash
cat agent-flow/GO.md
```

If a terminal still shows garbled text, rely on ASCII identifiers and script names:

```text
Light / Standard / Heavy
CODE_SCAN.md
REQUIREMENT.md
DESIGN.md
TASKS.md
VERIFY.md
AUDIT.md
EVOLUTION.md
next-step
sync-state
state-check
alignment-check
scan-check
task-check
task-boundary-check
manifest-check
ac-check
code-drift-check
blocked-check
evolution-check
closure-check
check-change
scaffold-health
```

## Minimum Safe Loop

```text
1. Run next-step.
2. Run sync-state if STATE.md is stale.
3. Read the returned next_prompt.
4. Do not edit outside TASKS.md write_files.
5. Run task-check before implementation and after task status changes.
6. Run task-boundary-check before closure.
7. Run check-change when unsure whether a change is healthy.
8. Run closure-check before calling the change complete.
```
