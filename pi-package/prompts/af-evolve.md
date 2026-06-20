# /af-evolve — Data-Driven Evolution

Analyzes historical change data and suggests improvements to templates, gates, and knowledge base.

## Usage

```
/af-evolve [change-id]
```

## Steps (without change-id — project-level)

1. Run `agent-flow/scripts/evolution-stats.sh --project-root .`
2. Run `agent-flow/scripts/evolution-suggest.sh --project-root .`
3. Run `agent-flow/scripts/gate-fatigue-check.sh --project-root .`
4. Review output and update `agent-flow/knowledge/improvement-tracker.md`

## Steps (with change-id — change-level)

1. Read `agent-flow/changes/<change-id>/EVOLUTION.md`
2. Run `agent-flow/scripts/evolution-check.sh --change-dir agent-flow/changes/<change-id>`
3. If recommendations exist, update `agent-flow/knowledge/improvement-tracker.md`

## Exit Codes

- 0: Evolution analysis complete
- 1: Project root or change directory not found
