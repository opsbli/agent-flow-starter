# Tasks

| Task ID | Status | AC | Read Files | Write Files | Verify | Parallel |
|---------|--------|----|-----------|-------------|--------|----------|
| T-01 | completed | AC-01 | agent-flow/manifest.yaml | agent-flow/manifest.yaml | manifest-check passed | no |
| T-02 | completed | AC-02 | .github/workflows/scaffold-ci.yml | .github/workflows/scaffold-ci.yml | YAML review | no |
| T-03 | completed | AC-01, AC-02, AC-03 | — | — | scaffold-health + manifest-check | no |

write_files:
  - agent-flow/manifest.yaml
  - .github/workflows/scaffold-ci.yml
