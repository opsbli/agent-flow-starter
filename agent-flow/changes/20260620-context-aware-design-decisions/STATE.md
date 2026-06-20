# State

change_id: 20260620-context-aware-design-decisions
flow: Standard
current_stage: complete-or-conditional
blocked: true
blockers:
  - blocked
next_action: Artifacts are ready. Review manually, then close the change.
owner: unassigned
last_updated: 2026-06-20

## Stage History

| Time | Stage | Actor | Notes |
|---|---|---|---|
| '2026-06-20' | 'complete-or-conditional' | sync-state | Synced from next-step. |
| 2026-06-20 | intake | AI | Created change scaffold |
| 2026-06-20 | scanning | AI | Completed CODE_SCAN.md — identified design-check path bug + template gaps |
| 2026-06-20 | design | AI | DESIGN.md completed — context-aware simplified format for dev-toolkit |
| 2026-06-20 | implementation | AI | Fixed design-check.sh/.ps1 project-root detection; added non-backend guidance to templates; added State Machine Impact skip |
| 2026-06-20 | verification | AI | scaffold-health, template-check, manifest-check, design-check, scan-check, alignment-check, evolution-check all passed |
| 2026-06-20 | closure | AI | VERIFY.md, REPORT.md, EVOLUTION.md completed |

## Notes

- `STATE.md` is a lightweight navigation aid.
- Source-of-truth remains the actual artifacts: `CHANGE.md`, `CODE_SCAN.md`, `REQUIREMENT.md`, `DESIGN.md`, `TASKS.md`, `VERIFY.md`, `REPORT.md`, and audits.
- If `STATE.md` conflicts with the artifacts, update `STATE.md` after checking `next-step`.
