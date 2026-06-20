# /af-report — Auto Report Generation

Aggregates check results and generates a comprehensive change report.

## Usage

```
/af-report <change-id>
```

## Steps

1. Read `agent-flow/changes/<change-id>/STATE.md`
2. Run `agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id> --closure --output agent-flow/changes/<change-id>/CHECK_RESULT.json`
3. Run `agent-flow/scripts/generate-report.sh --change-dir agent-flow/changes/<change-id> --project-root .`
4. Run `agent-flow/scripts/evolution-check.sh --change-dir agent-flow/changes/<change-id>`

## Exit Codes

- 0: Report generated and evolution-check passed
- 1: Change directory does not exist
- 2: Gate failures or missing artifacts
