# /af-design-auto — Auto Design + Task Breakdown

Automates design generation and task decomposition for an existing change.

## Usage

```
/af-design-auto <change-id>
```

## Steps

1. Read `agent-flow/changes/<change-id>/CHANGE.md` and `CODE_SCAN.md`
2. Run `agent-flow/scripts/generate-design.sh --change-dir agent-flow/changes/<change-id> --project-root .`
3. Run `agent-flow/scripts/design-check.sh --change-dir agent-flow/changes/<change-id>`
4. Run `agent-flow/scripts/alignment-check.sh --change-dir agent-flow/changes/<change-id>`
5. Run `agent-flow/scripts/generate-tasks.sh --change-dir agent-flow/changes/<change-id> --project-root .`
6. Run `agent-flow/scripts/task-check.sh --change-dir agent-flow/changes/<change-id>`

## Exit Codes

- 0: Design + tasks generated and gates passed
- 1: Missing required artifacts (CHANGE.md, CODE_SCAN.md)
- 2: Gate failure — review output for details
