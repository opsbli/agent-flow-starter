# Knowledge Index

> Global entry point for reusable project knowledge.
> **Always search before adding new knowledge.** The knowledge-search script checks existing entries to avoid duplicates.
>
> 👉 If you don't find what you need, add it to the narrowest file, then update this index only when a new file is added.

## Quick Search

Windows:
```powershell
agent-flow/scripts/knowledge-search.ps1 -Query "<your-query>"
```

Linux/macOS:
```bash
bash agent-flow/scripts/knowledge-search.sh --query "<your-query>"
```

## Files

| File | Purpose | Typical Update Trigger |
|---|---|---|
| `glossary.md` | Domain terms and canonical names | New term, renamed concept, ambiguous wording |
| `module-map.md` | Module boundaries and ownership | New module, moved responsibility, changed entry point |
| `reuse-map.md` | Reusable abstractions and shared capabilities | Reused helper, service, component, middleware, client |
| `pitfalls.md` | Known failure modes and guardrails | Repeated mistake, near miss, escaped bug |
| `verification.md` | Verification commands and evidence conventions | New test command, manual verification pattern |
| `known-good-baselines.md` | Last known healthy build/test/gate states | Verified release, major dependency update, green closeout |
| `improvement-tracker.md` | Process improvements raised by EVOLUTION.md | Template, script, gate, or flow improvement proposal |
| `frontend-fit.md` | Frontend UX and implementation fit notes | UI workflow or design-system rule discovered |

## Latest Discoveries

> Automatically updated after each completed change. Lists the most recent additions to the knowledge base.

| Date | Type | File | Summary |
|---|---|---|---|
| 2026-06-15 | Glossary expansion | `glossary.md` | Added full agent-flow core term definitions, verification terms, and change lifecycle terms |
| 2026-06-15 | Baseline establishment | `known-good-baselines.md` | Added scaffold health baseline table, conventions, and update triggers |
| 2026-06-15 | Index restructure | `INDEX.md` | Added Latest Discoveries table, process-stats section placeholder |
| _(Add new entries here)_ | | | |


## Process Statistics (cumulative)

> Tracks aggregate health across changes. Auto-updated by evolution-stats.ps1 -UpdateIndex.

| Metric | Value | As Of |
|--------|-------|-------|
| Total changes completed | 1 | 2026-06-15 |
| Heavy changes | 0 | 2026-06-15 |
| Standard changes | 0 | 2026-06-15 |
| Light changes | 0 | 2026-06-15 |
| Emergency changes | 1 | 2026-06-15 |
| Active / blocked changes | 0 / 0 | 2026-06-15 |
| AC pass rate | 100% | 2026-06-15 |
| Knowledge files | 9 | 2026-06-15 |
| ADRs | 1 | 2026-06-15 |
| Current scaffold version | 0.2.0 | 2026-06-15 |

## Over Time (by quarter)

> Populated as changes accumulate.

| Quarter | Changes | Heavy | Standard | Light | AC Pass Rate |
|---------|---------|-------|----------|-------|--------------|
| 2026-Qq | 1 | 0 | 0 | 0 | 100% |## Maintenance Rules

- Add reusable facts to the narrowest file first, then update this index only when a new knowledge file is added or its purpose changes.
- Do not store one-off change history here; put change-specific evidence in `agent-flow/changes/<change-id>/`.
- If knowledge conflicts with live code, live code wins and the knowledge file must be updated through a change.
- After each change completion, update the "Latest Discoveries" section and verify INDEX.md links still resolve.
