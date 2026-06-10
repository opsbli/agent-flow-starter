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

## Heavy Planning

```text
Continue agent-flow change: <change-id>.
Do not implement yet.
Complete REQUIREMENT, CODE_SCAN, DESIGN, PLAN, TASKS, then run Plan Audit.
If Plan Audit is not accept, stop and list required fixes.
```

## Ask What To Do Next

```text
Check agent-flow change: <change-id>.
First run next-step and read stage, missing, blocked, and next_prompt.
Then continue according to next_prompt.
If blocked is not empty, explain the blocker and give me the available options before editing files.
```

Commands:

```powershell
agent-flow/scripts/next-step.ps1 -ChangeDir agent-flow/changes/<change-id>
```

```bash
bash agent-flow/scripts/next-step.sh --change-dir agent-flow/changes/<change-id>
```

## Implementation

```text
I accept the Plan Audit.
Continue agent-flow change: <change-id>.
Implement strictly within TASKS.md write_files.
Update TASKS.md after each task.
```

## Closure

```text
Continue agent-flow change: <change-id>.
Complete VERIFY, REVIEW, REPORT, EVOLUTION, and Closure Audit.
Run ac-check, drift-check, scaffold-health, and relevant run-verify commands.
If closure is conditional, list residual risks clearly.
```

## Evolution

```text
Based on EVOLUTION.md, evaluate whether the starter should change.
Prefer template, knowledge, and script improvements before root AGENTS.md changes.
Do not modify files until I approve the proposed upgrade list.
```
