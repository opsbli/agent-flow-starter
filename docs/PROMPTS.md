# Prompt Cookbook

## Initialize After Install

```text
I have installed agent-flow in this project.
Do not write business code yet.

Review the generated initialization:
1. Check AGENTS.md Project Context.
2. Check agent-flow/manifest.yaml.
3. Check agent-flow/knowledge/module-map.md, reuse-map.md, verification.md, and pitfalls.md.
4. Fill any remaining TODO values.
5. Run scaffold-health and safe verification commands.
6. Output how to use agent-flow in this project.
```

## Start A Requirement

```text
Use the agent-flow process for this request: <requirement>.
Start with code-first scan, classify Light/Standard/Heavy, then give me CHANGE and the execution plan.
```

## Create Change Folder

```text
Create an agent-flow change for: <requirement>.
Use new-change with the selected Light / Standard / Heavy flow.
Then run next-step and continue from the returned next_prompt.
```

Commands:

```powershell
agent-flow/scripts/new-change.ps1 -Name <change-id> -Flow Standard
```

```bash
bash agent-flow/scripts/new-change.sh --name <change-id> --flow Standard
```

## Heavy Planning

```text
Continue agent-flow change: <change-id>.
Do not implement yet.
Complete REQUIREMENT, CODE_SCAN, DESIGN, Design Alignment / Grill, PLAN, TASKS, then run Plan Audit.
Run scan-check after CODE_SCAN, use strict scan when paths are known, and run task-check after TASKS.
If Plan Audit is not accept, stop and list required fixes.
```

## Design Alignment / Grill

```text
Continue agent-flow change: <change-id>.
Run Design Alignment / Grill before planning or implementation.

Read REQUIREMENT.md, CODE_SCAN.md, and DESIGN.md.
Interview me one question at a time until user intent, code facts, and the design are aligned.
If a question can be answered by reading the codebase, read the codebase instead of asking me.
For every question, provide your recommended answer.
After each confirmed answer, update DESIGN.md.
Run alignment-check after updating DESIGN.md.
Do not create PLAN.md, TASKS.md, or implement code until Alignment Verdict is aligned or I explicitly accept skipped with Skip Reason.
```

## Ask What To Do Next

```text
Check agent-flow change: <change-id>.
First run next-step and read stage, state_current_stage, state_next_action, missing, blocked, and next_prompt.
If STATE.md conflicts with inferred stage, run sync-state, then run state-check.
Then continue according to next_prompt.
If blocked is not empty, explain the blocker and give me the available options before editing files.
```

Commands:

```powershell
agent-flow/scripts/next-step.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/sync-state.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/state-check.ps1 -ChangeDir agent-flow/changes/<change-id>
```

```bash
bash agent-flow/scripts/next-step.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/sync-state.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/state-check.sh --change-dir agent-flow/changes/<change-id>
```

## Implementation

```text
I accept the Plan Audit.
Continue agent-flow change: <change-id>.
Implement strictly within TASKS.md write_files.
Update TASKS.md status after each task.
Run task-check after updating TASKS.md.
```

## Closure

```text
Continue agent-flow change: <change-id>.
Complete VERIFY, REVIEW, REPORT, EVOLUTION, and Closure Audit.
Run scan-check, task-check, ac-check, code-drift-check, blocked-check, task-boundary-check, manifest-check, emergency-check, evolution-check, scaffold-health, and relevant run-verify commands.
Fill VERIFY.md Machine Gate Summary with Result, Command, Exit Code, When, and Evidence for every required gate.
For Heavy changes, also run closure-check before saying the change is complete.
If closure is conditional, list residual risks clearly.
```

## Full Change Check

```text
Run agent-flow full check for change: <change-id>.
Use check-change and write CHECK_RESULT.json. If any gate fails, stop and explain the failing gate before editing files.
```

Commands:

```powershell
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/<change-id> -OutputPath agent-flow/changes/<change-id>/CHECK_RESULT.json
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/<change-id> -Closure -OutputPath agent-flow/changes/<change-id>/CHECK_RESULT.json
```

```bash
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id> --output agent-flow/changes/<change-id>/CHECK_RESULT.json
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id> --closure --output agent-flow/changes/<change-id>/CHECK_RESULT.json
```

## Evolution

```text
Based on EVOLUTION.md, evaluate whether the starter should change.
Prefer template, knowledge, and script improvements before root AGENTS.md changes.
Do not modify files until I approve the proposed upgrade list.
```
