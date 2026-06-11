# Pitfalls

| Pitfall | Consequence | Guardrail | Source Change |
|---|---|---|---|
| Creating abstractions before scanning existing code | Duplicated behavior and project-style drift | `CODE_SCAN.md` must list similar implementations first | starter |
| Changing public contracts without an explicit decision | Frontend/backend or external clients break silently | `DESIGN.md` must include API / Permission / Auth decisions | starter |
| Completing work without AC evidence | The change looks done but cannot be audited | `VERIFY.md` must include an AC Evidence table | starter |
| Treating chat as durable memory | Future agents lose decisions or repeat mistakes | Move reusable knowledge into `agent-flow/knowledge` or ADRs | starter |
| Skipping CODE_SCAN.md on Light changes | Missed existing abstractions, accidental duplication | Light flow also requires minimal CODE_SCAN.md | starter |
| Heavy change bypassing Plan Audit | Implementation starts without bounded scope, leading to scope creep | `AUDIT.md` Plan Audit with verdict `accept` required before implementation | starter |
| Using STATE.md as source of truth instead of navigation aid | Outdated state blocks correct next-step decisions | `STATE.md` is navigation only; actual truth is in artifacts | starter |
| Editing files outside declared `write_files` | Undeclared side effects, hard-to-review changes | `TASKS.md` write_files is the exclusive write boundary | starter |
| Not running code-drift-check after implementation | Schema/route/permission drift goes undetected until runtime | `VERIFY.md` must include code-drift-check results | starter |
| Not running task-boundary-check before closure | Undeclared file changes sneak into the final diff | `TASKS.md write_files` must match actual git changes | starter |
| Bumping flow level (Light→Standard→Heavy) without updating CHANGE.md | Scripts misclassify the change, gates are skipped | Update `[x]` marker in CHANGE.md when flow changes | starter |
| Writing REQURIEMENT.md AC numbers as AC-1 instead of AC-01 | `ac-check.ps1` regex fails to match two-digit requirement | Always use `AC-01`, `AC-02` format (zero-padded) | starter |
| Forgetting to run scaffold-health after install/upgrade | Missing files go unnoticed until first change attempt | Always run `scaffold-health.ps1/.sh` after install | starter |
| Heavy change skipping CODE_SCAN for frontend when UI changes | Backend-only scan misses UI conventions and API client patterns | Frontend changes require scanning frontend routes, API layer, component library | starter |
| Writing EVOLUTION.md without actionable changes | Process stops improving, same friction repeats | Each EVOLUTION entry should have at least one actionable recommendation | starter |
