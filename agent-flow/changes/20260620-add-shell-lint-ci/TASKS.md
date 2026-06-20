# Tasks

## Task Matrix

| Task ID | Status | AC | Read Files | Write Files | Verify | Parallel |
|---------|--------|----|-----------|-------------|--------|----------|
| T-01 | completed | AC-01, AC-04 | .github/workflows/scaffold-ci.yml | .github/workflows/scaffold-ci.yml | scaffold-health passed | no |
| T-02 | completed | AC-02, AC-04 | .github/workflows/scaffold-ci.yml | .github/workflows/scaffold-ci.yml | scaffold-health passed | no |
| T-03 | completed | AC-03 | .github/workflows/scaffold-ci.yml | .github/workflows/scaffold-ci.yml | `continue-on-error: true` present in both new jobs | yes |
| T-04 | completed | AC-01, AC-02, AC-03, AC-04 | — | — | scaffold-health + manifest-check + template-check all passed | no |

## Task Details

### T-01: 新增 static-analysis job (shellcheck) ✅

在 `file-consistency` job 之后插入 `static-analysis` job：
- `runs-on: ubuntu-latest`
- `needs: scaffold-health`
- `continue-on-error: true`
- `shellcheck --severity=warning --format=gcc` 扫描 `agent-flow/scripts/*.sh` + `agent-flow/test/test-scripts/*.sh`
- Step Summary 输出 warning 计数

### T-02: 新增 static-analysis-ps1 job (PSScriptAnalyzer) ✅

新增 `static-analysis-ps1` job：
- `runs-on: windows-latest`
- `needs: scaffold-health`
- `continue-on-error: true`
- `Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser`
- `Invoke-ScriptAnalyzer -Path agent-flow/scripts,agent-flow/test/test-scripts -Recurse -Severity Warning`
- Step Summary 输出 warning 计数

### T-03: 确认 continue-on-error 设置 ✅

两个新 job 均已设置 `continue-on-error: true`。

### T-04: 运行全套验证 ✅

- scaffold-health: passed
- manifest-check: passed
- template-check: passed

write_files:
  - .github/workflows/scaffold-ci.yml
  - agent-flow/manifest.yaml
  - agent-flow/rules/gates.txt
