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
