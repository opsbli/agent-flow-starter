# Knowledge Index

> Global entry point for reusable project knowledge. Keep entries generic in the starter; target projects should replace TODO context during initialization.

## Files

| File | Purpose | Typical Update Trigger |
|---|---|---|
| `glossary.md` | Domain terms and canonical names | New term, renamed concept, ambiguous wording |
| `module-map.md` | Module boundaries and ownership | New module, moved responsibility, changed entry point |
| `reuse-map.md` | Reusable abstractions and shared capabilities | Reused helper, service, component, middleware, client |
| `pitfalls.md` | Known failure modes and guardrails | Repeated mistake, near miss, escaped bug |
| `verification.md` | Verification commands and evidence conventions | New test command, manual verification pattern |
| `known-good-baselines.md` | Last known healthy build/test/gate states | Verified release, major dependency update, green closeout |
| `improvement-tracker.md` | Process improvements raised by `EVOLUTION.md` | Template, script, gate, or flow improvement proposal |
| `frontend-fit.md` | Frontend UX and implementation fit notes | UI workflow or design-system rule discovered |

## Search

Use the lightweight search tool before creating new knowledge entries:

Windows:

```powershell
agent-flow/scripts/knowledge-search.ps1 -Query "permission"
```

Linux/macOS:

```bash
bash agent-flow/scripts/knowledge-search.sh --query "permission"
```

## Maintenance Rules

- Add reusable facts to the narrowest file first, then update this index only when a new knowledge file is added or its purpose changes.
- Do not store one-off change history here; put change-specific evidence in `agent-flow/changes/<change-id>/`.
- If knowledge conflicts with live code, live code wins and the knowledge file must be updated through a change.
