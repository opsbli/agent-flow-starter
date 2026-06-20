# Reuse Map

> Before writing new code, check here, then check the codebase. Add new reusable discoveries after each change.

| Capability | Existing Location | How To Reuse | Notes |
|---|---|---|---|
| Scaffold health check | `agent-flow/scripts/scaffold-health.sh` | Run after any structural change to verify framework integrity | Validates all core files, templates, scripts exist |
| Manifest validation | `agent-flow/scripts/manifest-check.sh` | Run after editing manifest.yaml or adding scripts | Ensures gates.txt ↔ manifest.yaml ↔ disk consistency |
| Flow detection | `agent-flow/scripts/flow-detect.sh --change-dir <path>` | Run when unsure about Light/Standard/Heavy classification | Heuristic-based with confidence score |
| Change creation | `agent-flow/scripts/new-change.sh --name <name> --flow Standard` | Creates a full change directory from templates | Use Light for fixes, Standard for features, Heavy for cross-module |
| Closure gate bundle | `agent-flow/scripts/check-change.sh --change-dir <path>` | Run before declaring a change complete | Runs all applicable gates |
| Next-step navigation | `agent-flow/scripts/next-step.sh --change-dir <path>` | Run when unsure about current workflow stage | Returns JSON with next_prompt |
| Shared shell functions | `agent-flow/scripts/_common.sh` | Source for `meaningful()`, `flow_level()`, `get_rule_list()` | Internal; not listed in gates.txt |
| Shared PS functions | `agent-flow/scripts/_common.ps1` | Dot-source for PowerShell gate scripts | Internal; not listed in gates.txt |
| Template CHECK | `agent-flow/templates/*.md` | Copy template when creating new artifacts manually | new-change.sh auto-copies relevant templates |
| Rule lists | `agent-flow/rules/*.keys`, `*.questions`, `*.json` | Reference by gate scripts via `get_rule_list` | design-decision.keys, design-alignment.questions, etc. |
| Pair consistency check | `agent-flow/scripts/pair-consistency-check.sh` | Run periodically to detect ps1/sh script divergence | Flags pairs with >30% line count difference |
| Knowledge search | `agent-flow/scripts/knowledge-search.sh --query <term>` | Run before adding new knowledge to avoid duplicates | Searches all knowledge/*.md files |
| Evolution statistics | `agent-flow/scripts/evolution-stats.sh --update-index` | Run after change completion to update knowledge/INDEX.md stats | Tracks change counts, AC pass rate, knowledge growth |
