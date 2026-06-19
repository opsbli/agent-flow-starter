# State

change_id: document-approval-workflow
flow: Heavy
current_stage: verify
blocked: false
blockers:
  - none
next_action: Run next-step and follow the returned next_prompt.
owner: unassigned
last_updated: YYYY-MM-DD

## Stage History

| Time | Stage | Actor | Notes |
|---|---|---|---|
| YYYY-MM-DD | intake | AI | Created change scaffold. |
| YYYY-MM-DD | requirement | AI | Finished Requirement and Grill. |
| YYYY-MM-DD | code-scan | AI | CODE_SCAN complete. |
| YYYY-MM-DD | design | AI | DESIGN with Design Alignment completed. |
| YYYY-MM-DD | plan | AI | PLAN and Plan Audit completed. |
| YYYY-MM-DD | tasks | AI | TASKS and task-check passed. |
| YYYY-MM-DD | implement | AI | All tasks completed. |
| YYYY-MM-DD | verify | AI | VERIFY done, Closure Audit acceptable. |

## Notes

- STATE.md is a lightweight navigation aid.
