# Practice Run Report: Install Agent-Flow to a Target Project

> **Purpose**: Demonstrate end-to-end agent-flow lifecycle on a target project.
> This is a reference template — target projects should replace with actual output.
>
> **Date**: 2026-06-15
> **Runner**: agent-flow-starter maintainer (manual practice run)

---

## What Was Done

- Ran `init-project.ps1` on a test target repo.
- Filled `manifest.yaml` with project context (framework: Spring Boot 3.x, MySQL, Redis).
- Ran `scaffold-health.ps1` — all checks passed.
- Created a practice Light change (`practice-first-change`).
- Ran `check-change.ps1` for final validation.
- Ran `evolution-stats.ps1 -UpdateIndex` to capture metrics.

## Results

| Step | Status | Evidence |
|---|---|---|
| init-project | ✅ Passed | manifest.yaml populated, AGENTS.md updated |
| scaffold-health | ✅ Passed | All 8 sections green (dirs, files, scripts, gates, templates, tests, cross-platform) |
| new-change (Light) | ✅ Passed | change dir created with STATE.md, CHANGE.md, CODE_SCAN.md, VERIFY.md, REPORT.md |
| scan-check | ✅ Passed | CODE_SCAN.md has all required fields |
| manifest-check | ✅ Passed | All gates present, verification commands populated |
| check-change (closure) | ✅ Passed | All gates green |

## AC Coverage

| AC | Criterion | Verified | Evidence |
|---|---|---|---|
| AC-01 | Init script runs without error | ✅ | `init-project.ps1` exit code 0 |
| AC-02 | Scaffold health passes all checks | ✅ | `scaffold-health.ps1` all green |
| AC-03 | Light change can be created | ✅ | `new-change.ps1` creates dir with templates |

## Commands Used

```bash
# Windows
powershell -File agent-flow/scripts/init-project.ps1 -ProjectRoot ../my-project
powershell -File agent-flow/scripts/scaffold-health.ps1 -ProjectRoot ../my-project
powershell -File agent-flow/scripts/new-change.ps1 -ChangeId practice-first-change -ProjectRoot ../my-project

# Linux/macOS
bash agent-flow/scripts/init-project.sh --project-root ../my-project
bash agent-flow/scripts/scaffold-health.sh --project-root ../my-project
bash agent-flow/scripts/new-change.sh --change-id practice-first-change --project-root ../my-project
```

## Observations

1. **init-project** handles existing `AGENTS.md` correctly (appends block instead of overwriting).
2. **scaffold-health** found missing `VERSION` in test fixture — documented in pitfalls.
3. **new-change** templates match the VERSION watermark — no drift detected.

## Decisions

| Decision | Rationale |
|---|---|
| Use `echo` for verification commands | Starter has no real build tools; echoing placeholders is intentional |
| Keep `TODO_*` in deployed installs | Each project must fill its own context; init replaces during first run |

## Next Steps for Target Project

- [ ] Fill `manifest.yaml` with real backend/frontend/database context
- [ ] Run first Heavy change with full gate chain
- [ ] Schedule `evolution-stats.ps1` after each change
- [ ] Set up CI pipeline to run `manifest-check` + `scaffold-health` on merge
