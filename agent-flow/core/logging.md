# Logging

## Purpose

Logs provide a short time-based memory across changes. Reports are change-level; logs are day-level.

## Location

```text
agent-flow/logs/YYYY/MM-DD.md
```

## Rules

- Append only.
- Keep entries short.
- Link to real change docs and code paths.
- Do not make logs authoritative for behavior.
- If a log contains a reusable fact, also write it to `knowledge/`.

## Entry Format

```md
# Log - YYYY-MM-DD

### HH:mm - <change-id>

- What happened:
- Key decision:
- Verification:
- Next:
```

## When Required

Write a log entry when:

- Heavy change starts.
- Plan audit passes or fails.
- Closure audit passes or fails.
- Known-good baseline changes.
- A protected area decision is made.
- Scaffold itself is modified (upgrade, improvement batch, structure change).
- A session starts that spans multiple changes or requires context carry-over.

## Personal Observability (Optional but Recommended)

After each significant work session (not per change, but per work episode), write a brief 3-5 line log entry:

```markdown
### HH:mm - {change-id}

- What happened:
- Key decision:
- Verification:
- Next:
```

This gives future sessions **time-based memory** even when they don't read every change directory.

## Automated Stats

Periodically (or after Heavy changes), run:

Windows:
```powershell
agent-flow/scripts/evolution-stats.ps1 -UpdateIndex
```

Linux/macOS:
```bash
bash agent-flow/scripts/evolution-stats.sh --update-index
```

This updates the `INDEX.md` Process Statistics table, giving a dashboard view of scaffold health over time.
