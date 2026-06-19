# Verify

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|----|-------------------|-------------|------------------|--------|---------------|
| AC-01 | frontend_verify_required toggle in manifest.yaml | Code review | agent-flow/manifest.yaml | pass | Project must explicitly set true to activate |
| AC-02 | Non-functional requirements in REQUIREMENT.md | Template verification | agent-flow/templates/REQUIREMENT.md | pass | none |
| AC-03 | design-quality-check gate | Static analysis | agent-flow/scripts/design-quality-check.ps1/.sh | pass | Optional advisory only |

## Coverage Summary

| Metric | Source | Value | Result | Notes |
|--------|--------|-------|--------|-------|
| AC Coverage | VERIFY.md AC Evidence table | 3/3 (100%) | pass | All ACs have evidence rows |
| Script Syntax | PowerShell + Bash parse | 2/2 scripts pass | pass | Both design-quality-check scripts parse OK |
| Scaffold Health | scaffold-health.ps1 | pass | pass | All required files present |

## Machine Gate Summary

| Gate | RequiredFor | Result | Command | Exit Code | When | Evidence |
|------|-------------|--------|---------|-----------|------|----------|
| scaffold-health | Standard | pass | scaffold-health.ps1 | 0 | post-implement | All files present |
| design-quality-check | new | pass | design-quality-check.ps1 | 0 | post-implement | New gate works |
