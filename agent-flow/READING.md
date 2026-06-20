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
emergency-check
ac-check
code-drift-check
blocked-check
evolution-check
closure-check
check-change
scaffold-health
```

## Script Registry Contract

`agent-flow/rules/gates.txt` is the public-script registry. Every public
`.ps1` / `.sh` script in `agent-flow/scripts` must appear there unless it is an
internal helper whose filename starts with `_`.

`agent-flow/manifest.yaml` must also classify every public script under
`script_registry`:

```text
script_registry:
  gates:       blocking or advisory validation checks
  tools:       user-facing helpers, dashboards, installers, navigators
  generators:  scripts that create or update workflow artifacts
  deprecated:  compatibility entries that still exist on disk
```

Keep `gates:` in `manifest.yaml` for backward compatibility with older tooling,
but treat it as generated from `script_registry.gates`. Run `manifest-check`
after adding, renaming, or deleting scripts.

## Capability Map

Core path:

```text
af-quickstart -> new-change -> next-step -> check-change -> report/evolution
```

Script groups:

```text
gates:
  scaffold-health, manifest-check, scan-check, design-check, alignment-check
  task-check, plan-check, ac-check, coverage-check, code-drift-check
  blocked-check, task-boundary-check, emergency-check, evolution-check
  closure-check, content-check, api-compatibility-check, db-migration-check

tools:
  af-quickstart, dashboard, next-step, new-change, recover, flow-detect
  sync-state, knowledge-search, knowledge-suggest, pattern-discovery
  evolution-stats, evolution-suggest, fatigue-action, install-git-hooks

generators:
  generate-scan, generate-design, generate-tasks, generate-verify
  generate-audit, generate-report, generate-emergency

recovery and governance:
  recover, emergency-time-lock, emergency-abuse-check, emergency-backfill-check
  gate-fatigue-check, manifest-drift-check, knowledge-expiry-check
```

Use `af-quickstart` for onboarding. Use `next-step` when the current state is
unclear. Use `check-change` before claiming a change is complete.

## Minimum Safe Loop

```text
1. Run next-step.
2. Run sync-state if STATE.md is stale.
3. Read the returned next_prompt.
4. Do not edit outside TASKS.md write_files.
5. Run task-check before implementation and after task status changes.
6. Run task-boundary-check before closure.
7. Run emergency-check for Emergency changes, or record its skipped result in Heavy closure.
8. Run check-change when unsure whether a change is healthy.
9. Run closure-check before calling the change complete.
```
