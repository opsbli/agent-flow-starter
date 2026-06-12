# Troubleshooting

This guide covers common `agent-flow-starter` installation, gate, and closeout failures. Keep project-specific fixes in the target project's `agent-flow/knowledge/pitfalls.md`; keep this file generic.

## Install Or Upgrade

### `scaffold-health` reports missing files

Run the installer again from the starter repository:

Windows:

```powershell
scripts/install-agent-flow.ps1 -Target "C:\path\to\project"
```

Linux/macOS:

```bash
bash scripts/install-agent-flow.sh --target /path/to/project
```

Then run both health checks when the starter itself changed:

```powershell
agent-flow/scripts/scaffold-health.ps1
```

```bash
bash agent-flow/scripts/scaffold-health.sh
```

### `manifest-check` warns about `TODO_` values

This is expected immediately after install. Run `init-project`, then replace remaining TODO values with concrete commands, paths, or explicit `none`/`N/A` decisions.

Use strict mode only when the target project context should already be complete.

## Change Gates

### `scan-check` fails

Open `CODE_SCAN.md` and fill the machine-check fields plus `read_files` and `write_files`. For Standard and Heavy changes, run the check before design.

### `alignment-check` fails

`DESIGN.md` must have `Alignment Verdict: aligned`, or `Alignment Verdict: skipped` with a real `Skip Reason` accepted by the user.

### `coverage-check` fails

`coverage-check` requires two kinds of evidence:

- Every `REQUIREMENT.md` AC id appears in `VERIFY.md` under `AC Evidence`.
- `VERIFY.md` has a `Coverage Summary` table with a `Test Coverage` row.

When automated coverage does not apply, set the Test Coverage row to `skipped` or `conditional` and explain why in `Notes`.

### `closure-check` says a gate row is missing

Heavy changes must list every gate in `VERIFY.md` under `Machine Gate Summary`. The expected gate list is in:

```text
agent-flow/rules/closure-heavy-gates.keys
```

Run `check-change` to produce a machine summary, then copy the final gate evidence into `VERIFY.md`.

## Knowledge And Decisions

### I cannot find prior knowledge

Use the local search helper before adding new knowledge:

```powershell
agent-flow/scripts/knowledge-search.ps1 -Query "your term"
```

```bash
bash agent-flow/scripts/knowledge-search.sh --query "your term"
```

If there is no match, add the fact to the narrowest file in `agent-flow/knowledge/` and update `agent-flow/knowledge/INDEX.md` only when the file map changes.

### ADR status is unclear

Update `agent-flow/decisions/INDEX.md` whenever an ADR is proposed, accepted, deprecated, or superseded. The ADR file owns the rationale; the index owns lifecycle status.

## Template Validation

Run template validation after changing `agent-flow/templates/` or `agent-flow/rules/artifact-schema.json`:

```powershell
agent-flow/scripts/template-check.ps1
```

```bash
bash agent-flow/scripts/template-check.sh
```

If it fails, fix the missing template, required heading, or schema metadata before shipping the starter.
