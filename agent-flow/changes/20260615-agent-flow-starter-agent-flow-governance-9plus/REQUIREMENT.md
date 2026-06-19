# Requirement

## Confirmed Intent

Improve agent-flow-starter from the current 8.5-level review state to above 9.0 by completing the highest-priority gaps in order:

1. Formal gate registry consistency.
2. Starter generic-history hygiene.
3. Script index / documentation drift prevention.
4. Cross-platform verification.

## Acceptance Criteria

| AC | Criterion | Verification |
|---|---|---|
| AC-01 | All public `agent-flow/scripts/*.ps1/.sh` scripts are listed in `agent-flow/rules/gates.txt` and `manifest.yaml`. | `manifest-check.ps1/.sh`; comparison command over actual scripts vs manifest |
| AC-02 | `manifest-check` detects public script registry drift. | Code review plus negative or structural self-test coverage |
| AC-03 | `scaffold-health` uses `gates.txt` as the script source of truth. | `scaffold-health.ps1/.sh` |
| AC-04 | Starter does not track real `agent-flow/changes`, `agent-flow/logs`, or `agent-flow/reports` content beyond `.gitkeep`. | `git ls-files` check in self-test |
| AC-05 | Root `.gitignore` prevents future run-history leakage while keeping `.gitkeep`. | `git status --short --untracked-files=all`; self-test |
| AC-06 | Script README describes the registry source and avoids stale hard-coded counts. | Documentation review |
| AC-07 | Windows and Bash starter self-tests pass. | `scripts/test-starter.ps1`; `scripts/test-starter.sh` |

## Human Confirmation

User request: "按顺序补全，到9.0分以上"

Interpretation: The user accepted the ordered improvement plan from the review and asked to implement it.
