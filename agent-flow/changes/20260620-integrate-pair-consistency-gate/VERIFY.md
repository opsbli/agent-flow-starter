# Verify
## AC Evidence
| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|----|-------------------|---------------|-------------------|--------|---------------|
| AC-01 | manifest.yaml: pair-consistency moved tools→gates | manifest diff | agent-flow/manifest.yaml L146-148, L193-196 | pass | none |
| AC-02 | CI 新增 pair-consistency advisory job | CI config | .github/workflows/scaffold-ci.yml L205-214 | pass | none |
| AC-03 | scaffold-health + manifest-check pass | verification | bash agent-flow/scripts/scaffold-health.sh | pass | none |
## Coverage Summary
| Metric | Source | Value | Result | Notes |
|--------|--------|-------|--------|-------|
| AC Coverage | TASKS.md | 3/3 (100%) | pass | All ACs verified |
| Test Coverage | CI simulation | 0/0 | skipped | CI-only change |
