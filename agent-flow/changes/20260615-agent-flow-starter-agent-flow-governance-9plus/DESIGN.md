# Design

## API / Permission / Auth Decisions

Decision Status: accepted

| Item | Decision | Evidence / Reason |
|---|---|---|
| REST Path | unchanged | Scaffold has no application API |
| HTTP Method | unchanged | Scaffold has no application API |
| Permission Code | not-applicable | No permission model |
| SaCheckPermission | not-applicable | No controller annotations |
| Anonymous Interface | not-applicable | No auth surface |
| Login/Token | unchanged | No auth/session behavior |
| Tenant/Data Permission | unchanged | No data permission behavior |
| State Machine Impact | no | No workflow state machine change |

State Machine Impact: no

## Design Alignment / Grill

Alignment Source: user-confirmed

Open Questions: none

| Question | AI Recommended Answer | Confirmation | Final Decision |
|---|---|---|---|
| Intent Risk | Gate registry drift undermines every later health claim. | confirmed | Fix registry first. |
| Existing Code Fit | `manifest-check` already reads `gates.txt`, so extending it fits the existing seam. | confirmed | Reuse `gates.txt` instead of adding a registry. |
| Unnecessary Abstraction | A generator is not needed; direct registry validation is enough. | confirmed | Do not add a new generator workflow. |
| Protected Areas | No API/auth/schema/deployment area is touched; scaffold scripts and `.gitignore` are in scope. | confirmed | Proceed inside declared `write_files`. |
| Boundary And Failure Modes | If registry drift returns, `manifest-check` and starter self-test should fail. | confirmed | Add negative self-test coverage. |

Alignment Verdict: aligned

Skip Reason:

## Architecture

- Treat `agent-flow/rules/gates.txt` as the formal public script registry.
- Keep `manifest.yaml` as the project-level declaration that mirrors the registry.
- Make `manifest-check` enforce:
  - each registry entry is present in `manifest.yaml`
  - each registry entry exists on disk
  - each public `agent-flow/scripts/*.ps1/.sh` file is registered
- Make `scaffold-health` derive required script files from `gates.txt`.
- Keep starter run-history out of git, while preserving `.gitkeep` placeholders.

## Protected Area Review

| Area | Touched | Approval / Reason |
|---|---|---|
| Root build files | no | not-applicable |
| Production config | no | not-applicable |
| Auth/permission | no | not-applicable |
| Public API | no | not-applicable |
| Scaffold validation scripts | yes | User requested the ordered quality upgrade |

## AC Trace

| AC | Coverage |
|---|---|
| AC-01 | `gates.txt` and `manifest.yaml` registry updates |
| AC-02 | `manifest-check.ps1/.sh` public script drift validation |
| AC-03 | `scaffold-health.ps1/.sh` deriving script requirements from `gates.txt` |
| AC-04 | Delete tracked run-history files and update `.gitignore` |
| AC-05 | `scripts/test-starter.ps1/.sh` tracked-history guard |
| AC-06 | `agent-flow/scripts/README.md` update |
| AC-07 | Verification command record in `VERIFY.md` |
