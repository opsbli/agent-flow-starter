# Source of Truth

## Purpose

Define which artifact is authoritative when code, change docs, knowledge, decisions, reports, and chat disagree.

## Precedence

1. **Live code** is authoritative for current behavior.
2. **`agent-flow/decisions/`** is authoritative for accepted architectural decisions.
3. **`agent-flow/knowledge/`** is authoritative for reusable project facts, terminology, pitfalls, and verification baselines.
4. **`agent-flow/changes/<change-id>/REQUIREMENT.md`** is authoritative for what the current change must achieve.
5. **`agent-flow/changes/<change-id>/DESIGN.md`** is authoritative for the current approved implementation approach.
6. **`agent-flow/changes/<change-id>/TASKS.md`** is authoritative for execution boundaries and allowed file writes.
7. **`agent-flow/changes/<change-id>/STATE.md`** is a navigation aid only. If it conflicts with other artifacts, update it after checking `next-step`.
8. **`VERIFY.md`, `REPORT.md`, logs, and baselines** are historical evidence.
9. **Chat is never authoritative.** Chat only becomes durable when written into the proper file.

## Conflict Handling

| Conflict | Resolution |
|---|---|
| Code differs from knowledge | Treat code as current behavior; update knowledge if intentional, or create a change if drift |
| Requirement differs from design | Requirement wins for intent; design must be updated |
| Design differs from tasks | Design wins for approach; tasks must be updated |
| Tasks allow a file not justified by design | Stop and revise design or task boundary |
| Report claims completion but VERIFY lacks evidence | Not complete |
| Chat contradicts files | Ask whether to update files; do not silently follow chat |

## Drift Rule

If live code contradicts accepted decisions or knowledge, record it as one of:

- intentional evolution -> update knowledge/decision through a change
- implementation drift -> create a follow-up task
- unclear -> stop and ask
