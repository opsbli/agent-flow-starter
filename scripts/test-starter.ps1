param([switch]$KeepTemp)

$ErrorActionPreference = "Stop"

$starterRoot = Split-Path -Parent $PSScriptRoot
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agent-flow-starter-test-" + [guid]::NewGuid().ToString("N"))
$emptyTarget = Join-Path $tempRoot "empty-project"
$updateTarget = Join-Path $tempRoot "update-project"

function Assert-Path {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Expected path not found: $Path"
    }
}

function Get-DemoDesign {
    param(
        [string]$Verdict = "aligned",
        [string]$Source = "mixed",
        [string]$OpenQuestions = "none",
        [string]$Confirmation = "confirmed"
    )

@"
# Design

## API / Permission / Auth Decisions

Decision Status: accepted

| Item | Decision | Evidence / Reason |
|---|---|---|
| REST Path | unchanged | README.md documents no public API change |
| HTTP Method | unchanged | No endpoint behavior changes |
| Permission Code | not-applicable | No permission model touched |
| SaCheckPermission | not-applicable | No controller permission annotation touched |
| Anonymous Interface | not-applicable | No anonymous interface change |
| Login/Token | unchanged | No auth/session behavior change |
| Tenant/Data Permission | unchanged | No tenant/data scope change |
| State Machine Impact | no | No workflow/status transition touched |

State Machine Impact: no

## Design Alignment / Grill

Alignment Source: $Source

Open Questions: $OpenQuestions

| Question | AI Recommended Answer | Confirmation | Final Decision |
|---|---|---|---|
| Intent Risk | Demo intent is limited to README evidence. | $Confirmation | Keep scope limited. |
| Existing Code Fit | Reuse README and existing scripts. | $Confirmation | No new abstraction. |
| Unnecessary Abstraction | No abstraction is needed. | $Confirmation | Do not add one. |
| Protected Areas | No protected area is touched. | $Confirmation | Continue. |
| Boundary And Failure Modes | Failure is limited to test fixture behavior. | $Confirmation | Verify with scripts. |

Alignment Verdict: $Verdict

Skip Reason:
"@
}

function Get-DemoPlan {
@"
# Plan

> Plan Status: planned
> Last Reviewed: 2026-06-10
> Source: agent-flow/changes/demo-closure/CHANGE.md

## Current Baseline

README.md and existing agent-flow scripts are the baseline.

## Goals

- Prove the gate chain can close a demo Heavy change.

## Non-Goals

- No production code behavior changes.

## Execution Phases

### Phase 1 - Demo verification

Status: planned

Scope:

- Update only declared demo files.

read_files:

- README.md

write_files:

- README.md

Exit Criteria:

- AC-01 has evidence.

Verification:

- Run check-change.

## Closure Gates

- [x] CODE_SCAN complete
- [x] DESIGN reviewed
- [x] design-check passed
- [x] alignment-check passed or explicitly skipped
- [x] TASKS bounded by read/write files
- [x] Plan Audit completed and plan-check passed
- [x] Verification passed
- [x] AC evidence recorded
- [x] Drift checks passed or adjudicated
- [x] Closure audit acceptable
- [x] Knowledge/decision/log/baseline updated

## Risks

- Test-only fixture risk.

## Protected Area Review

| Area | Touched | Approval / Reason |
|---|---|---|
| API/Auth/Permission | no | not-applicable |

## Deferred But Adjudicated

| Item | Classification | Reason |
|---|---|---|
| none | not-applicable | no deferred item |
"@
}

function Get-DemoAudit {
@"
# Audit

## Plan Audit

Verdict: accept

Reviewer: self-test

Date: 2026-06-10

Checklist:

- [x] Current baseline checked against live code
- [x] Goals and Non-Goals clear
- [x] Code scan complete
- [x] Design check passed
- [x] Design Alignment completed
- [x] Protected areas identified
- [x] read_files/write_files bounded
- [x] Exit criteria verifiable
- [x] Risks mitigated

Findings:

- Plan accepted for self-test.

## Closure Audit

Verdict: acceptable

Reviewer: self-test

Date: 2026-06-10

Checklist:

- [x] Closure gates passed
- [x] Verification evidence recorded
- [x] AC coverage has evidence
- [x] scan-check completed
- [x] design-check completed
- [x] alignment-check completed
- [x] task-check completed
- [x] plan-check completed for Heavy changes
- [x] Drift checks completed
- [x] No undeclared files modified
- [x] task-boundary-check completed
- [x] manifest-check completed
- [x] emergency-check completed or explicitly skipped
- [x] blocked-check completed
- [x] evolution-check completed
- [x] closure-check completed
- [x] Knowledge/decision/log/baseline updated

Findings:

- Closure accepted for self-test.
"@
}

function Assert-NextStage {
    param(
        [string]$TargetRoot,
        [string]$ExpectedStage
    )

    $changeDir = Join-Path $TargetRoot "agent-flow/changes/demo-next-step"
    New-Item -ItemType Directory -Force -Path $changeDir | Out-Null
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md") -Value @"
# Change

- [ ] Light
- [x] Standard
- [ ] Heavy

## Summary

Demo change for next-step self-test.
"@
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "CODE_SCAN.md") -Value @"
# Code Scan

Relevant code was scanned for the demo change.
"@
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "STATE.md") -Value @"
# State

change_id: demo-next-step
flow: Standard
current_stage: intake
blocked: false
next_action: Complete REQUIREMENT.md with AC-01 style acceptance criteria.
"@

    $json = & (Join-Path $TargetRoot "agent-flow/scripts/next-step.ps1") -ChangeDir $changeDir
    $result = $json | ConvertFrom-Json
    if ($result.stage -ne $ExpectedStage) {
        throw "Expected next-step stage '$ExpectedStage', got '$($result.stage)'. Output: $json"
    }
    if ([string]::IsNullOrWhiteSpace($result.next_prompt)) {
        throw "next-step did not return a next_prompt."
    }
    if ($null -eq $result.PSObject.Properties["state_current_stage"]) {
        throw "next-step did not return state_current_stage."
    }
    & (Join-Path $TargetRoot "agent-flow/scripts/sync-state.ps1") -ChangeDir $changeDir
    & (Join-Path $TargetRoot "agent-flow/scripts/state-check.ps1") -ChangeDir $changeDir -ExpectedStage $ExpectedStage
}

function Assert-DesignAlignmentStage {
    param([string]$TargetRoot)

    $changeDir = Join-Path $TargetRoot "agent-flow/changes/demo-design-alignment"
    New-Item -ItemType Directory -Force -Path $changeDir | Out-Null
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md") -Value @"
# Change

- [ ] Light
- [x] Standard
- [ ] Heavy

## Summary

Demo change for design alignment self-test.
"@
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "CODE_SCAN.md") -Value "# Code Scan`n`nRelevant code was scanned."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "REQUIREMENT.md") -Value "# Requirement`n`n## Acceptance Criteria`n`n- AC-01: Demo criterion."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "DESIGN.md") -Value (Get-DemoDesign -Verdict "pending" -Source "pending" -OpenQuestions "pending" -Confirmation "pending")

    $json = & (Join-Path $TargetRoot "agent-flow/scripts/next-step.ps1") -ChangeDir $changeDir
    $result = $json | ConvertFrom-Json
    if ($result.stage -ne "design-alignment") {
        throw "Expected next-step stage 'design-alignment', got '$($result.stage)'. Output: $json"
    }
    if ($result.next_prompt -notmatch "Design Alignment") {
        throw "next-step did not recommend Design Alignment. Output: $json"
    }
}

function Assert-NewChangeAndAlignment {
    param([string]$TargetRoot)

    $changeRoot = Join-Path $TargetRoot "agent-flow/changes"
    & (Join-Path $TargetRoot "agent-flow/scripts/new-change.ps1") -Name "Demo Heavy Change" -Flow Heavy -ChangesRoot $changeRoot -TemplateRoot (Join-Path $TargetRoot "agent-flow/templates")

    $changeDir = Join-Path $changeRoot "demo-heavy-change"
    Assert-Path (Join-Path $changeDir "STATE.md")
    Assert-Path (Join-Path $changeDir "CHANGE.md")
    Assert-Path (Join-Path $changeDir "REVIEW.md")
    Assert-Path (Join-Path $changeDir "AUDIT.md")

    $change = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md")
    if ($change -notmatch "\[x\]\s+Heavy") {
        throw "new-change did not mark Heavy in CHANGE.md"
    }

    $designPath = Join-Path $changeDir "DESIGN.md"
    Set-Content -Encoding utf8 -LiteralPath $designPath -Value (Get-DemoDesign)

    & (Join-Path $TargetRoot "agent-flow/scripts/design-check.ps1") -ChangeDir $changeDir
    & (Join-Path $TargetRoot "agent-flow/scripts/alignment-check.ps1") -ChangeDir $changeDir
}

function Assert-GateScripts {
    param([string]$TargetRoot)

    $changeDir = Join-Path $TargetRoot "agent-flow/changes/demo-gates"
    New-Item -ItemType Directory -Force -Path $changeDir | Out-Null
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md") -Value "# Change`n`n- [ ] Light`n- [x] Standard`n- [ ] Heavy"
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "CODE_SCAN.md") -Value @"
# Code Scan

## 扫描时间
2026-06-10 10:00

## Machine Check
scan_time: 2026-06-10 10:00
related_modules: README.md
similar_implementations: README.md
reusable_abstractions: README contract
test_baseline: scripts/test-starter.ps1
read_files: README.md
write_files: README.md
open_questions: none

## 相关模块
- README.md

## 相似实现
| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| demo | `README.md` | existing entry pattern |

## 可复用抽象
- README contract.

## 禁止重复实现
- No duplicate entry module.

## 测试基线
- scripts/test-starter.ps1

## read_files
read_files:
  - README.md

## write_files
write_files:
  - README.md

## 未决问题
- none
"@
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "REQUIREMENT.md") -Value "# Requirement`n`n- AC-01: Demo criterion."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "DESIGN.md") -Value (Get-DemoDesign)
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "TASKS.md") -Value @"
# Tasks

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel |
|---|---|---|---|---|---|---|
| T001 | pending | AC-01 | `src/index.ts` | `README.md` | manual review | no |

## write_files 汇总

write_files:
  - README.md
"@

    & (Join-Path $TargetRoot "agent-flow/scripts/scan-check.ps1") -ChangeDir $changeDir
    if (-not $?) {
        throw "scan-check smoke test failed."
    }

    & (Join-Path $TargetRoot "agent-flow/scripts/task-check.ps1") -ChangeDir $changeDir
    if (-not $?) {
        throw "task-check smoke test failed."
    }

    & (Join-Path $TargetRoot "agent-flow/scripts/design-check.ps1") -ChangeDir $changeDir
    if (-not $?) {
        throw "design-check smoke test failed."
    }

    & (Join-Path $TargetRoot "agent-flow/scripts/alignment-check.ps1") -ChangeDir $changeDir
    if (-not $?) {
        throw "alignment-check smoke test failed."
    }

    $emptyEvidence = Join-Path $changeDir "empty-evidence"
    New-Item -ItemType Directory -Force -Path $emptyEvidence | Out-Null
    & (Join-Path $TargetRoot "agent-flow/scripts/ac-check.ps1") -ChangeDir $changeDir -TestRoot $emptyEvidence
    if ($LASTEXITCODE -eq 0) {
        throw "ac-check passed using REQUIREMENT.md as self-evidence."
    }

    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "VERIFY.md") -Value "# Verify`n`nAC-01 evidence: checked."
    & (Join-Path $TargetRoot "agent-flow/scripts/ac-check.ps1") -ChangeDir $changeDir -TestRoot $changeDir
    if (-not $?) {
        throw "ac-check did not pass after VERIFY.md evidence was added."
    }

    & (Join-Path $TargetRoot "agent-flow/scripts/blocked-check.ps1") -ChangeDir $changeDir -ProjectRoot $TargetRoot
    if (-not $?) {
        throw "blocked-check smoke test failed."
    }

    & (Join-Path $TargetRoot "agent-flow/scripts/code-drift-check.ps1") -ChangeDir $changeDir -ProjectRoot $TargetRoot
    if (-not $?) {
        throw "code-drift-check smoke test failed."
    }

    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "EVOLUTION.md") -Value @"
# Evolution

## Machine Check
problem: none
knowledge: none
adr: none
gate: none
template: none
no_change_reason: no change needed

## 本次 change 暴露的问题
- none

## 应写入 knowledge 的内容
- none

## 应新增或修改的 ADR
- none

## 应新增的 gate
- none

## 应调整的模板
- none

## 本次不调整的原因
- no change needed
"@
    & (Join-Path $TargetRoot "agent-flow/scripts/evolution-check.ps1") -ChangeDir $changeDir
    if (-not $?) {
        throw "evolution-check smoke test failed."
    }
}

function Assert-TaskBoundary {
    param([string]$TargetRoot)

    Push-Location $TargetRoot
    try {
        git init *> $null
        git config user.email "agent-flow@example.invalid"
        git config user.name "agent-flow test"
        git config core.autocrlf false
        git add -A *> $null
        git commit -m "baseline" *> $null
    } finally {
        Pop-Location
    }

    $changeDir = Join-Path $TargetRoot "agent-flow/changes/demo-boundary"
    New-Item -ItemType Directory -Force -Path $changeDir | Out-Null
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "TASKS.md") -Value "# Tasks`n`nwrite_files:`n  - README.md"
    Add-Content -Encoding utf8 -LiteralPath (Join-Path $TargetRoot "README.md") -Value "`nDeclared change."
    & (Join-Path $TargetRoot "agent-flow/scripts/task-boundary-check.ps1") -ChangeDir $changeDir -ProjectRoot $TargetRoot
    if (-not $?) {
        throw "task-boundary-check did not pass declared README.md change."
    }

    Add-Content -Encoding utf8 -LiteralPath (Join-Path $TargetRoot "package.json") -Value "`n"
    $boundaryOutput = & (Join-Path $TargetRoot "agent-flow/scripts/task-boundary-check.ps1") -ChangeDir $changeDir -ProjectRoot $TargetRoot *>&1
    if ($LASTEXITCODE -eq 0) {
        throw "task-boundary-check did not reject undeclared package.json change. Output: $boundaryOutput"
    }

    Push-Location $TargetRoot
    try {
        git add -A *> $null
        git commit -m "after boundary smoke" *> $null
    } finally {
        Pop-Location
    }
}

function Assert-ClosureCheck {
    param([string]$TargetRoot)

    $changeDir = Join-Path $TargetRoot "agent-flow/changes/demo-closure"
    New-Item -ItemType Directory -Force -Path $changeDir | Out-Null
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md") -Value "# Change`n`n- [ ] Light`n- [ ] Standard`n- [x] Heavy"
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "STATE.md") -Value "# State`n`nchange_id: demo-closure`nflow: Heavy`ncurrent_stage: closure-audit`nblocked: false`nnext_action: Run Closure Audit."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "CODE_SCAN.md") -Value @"
# Code Scan

## 扫描时间
2026-06-10 10:00

## Machine Check
scan_time: 2026-06-10 10:00
related_modules: README.md
similar_implementations: README.md
reusable_abstractions: README contract
test_baseline: scripts/test-starter.ps1
read_files: README.md
write_files: README.md
open_questions: none

## 相关模块
- README.md

## 相似实现
| 能力 | 参考文件 | 可复用点 |
|---|---|---|
| demo | `README.md` | existing entry pattern |

## 可复用抽象
- README contract.

## 禁止重复实现
- No duplicate entry module.

## 测试基线
- scripts/test-starter.ps1

## read_files
read_files:
  - README.md

## write_files
write_files:
  - README.md

## 未决问题
- none
"@
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "REQUIREMENT.md") -Value "# Requirement`n`n- AC-01: Demo."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "DESIGN.md") -Value (Get-DemoDesign)
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "PLAN.md") -Value (Get-DemoPlan)
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "TASKS.md") -Value @"
# Tasks

## Task Matrix

| Task | Status | AC | read_files | write_files | Verify | Parallel |
|---|---|---|---|---|---|---|
| T001 | completed | AC-01 | `README.md` | `README.md` | manual review | no |

## write_files 汇总

write_files:
  - README.md
"@
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "VERIFY.md") -Value @"
# Verify

## AC Evidence

| AC | Requirement Summary | Evidence Type | Evidence Location | Result | Residual Risk |
|---|---|---|---|---|---|
| AC-01 | Demo | manual | VERIFY.md | pass | none |

## Machine Gate Summary

| Gate | Required For | Result | Command | Exit Code | When | Evidence |
|---|---|---|---|---|---|---|
| scan-check | Heavy | pass | scan-check.ps1 -Strict | 0 | 2026-06-10 10:00 | strict scan passed |
| design-check | Heavy | pass | design-check.ps1 | 0 | 2026-06-10 10:00 | decisions accepted |
| alignment-check | Heavy | pass | alignment-check.ps1 | 0 | 2026-06-10 10:00 | alignment confirmed |
| task-check | Heavy | pass | task-check.ps1 | 0 | 2026-06-10 10:00 | T001 maps to AC-01 |
| plan-check | Heavy | pass | plan-check.ps1 | 0 | 2026-06-10 10:00 | plan audit accepted |
| ac-check | Heavy | pass | ac-check.ps1 | 0 | 2026-06-10 10:00 | AC-01 evidence present |
| code-drift-check | Heavy | pass | code-drift-check.ps1 | 0 | 2026-06-10 10:00 | no drift |
| blocked-check | Heavy | pass | blocked-check.ps1 | 0 | 2026-06-10 10:00 | no blocked operations |
| task-boundary-check | Heavy | pass | task-boundary-check.ps1 | 0 | 2026-06-10 10:00 | only change folder modified |
| manifest-check | all closure | pass | manifest-check.ps1 | 0 | 2026-06-10 10:00 | manifest valid |
| emergency-check | Heavy closure summary | skipped | emergency-check.ps1 | 0 | 2026-06-10 10:00 | not an Emergency change |
| evolution-check | Heavy | pass | evolution-check.ps1 | 0 | 2026-06-10 10:00 | no change needed recorded |
"@
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "REVIEW.md") -Value "# Review`n`nReviewed."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "REPORT.md") -Value "# Report`n`nDone."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "EVOLUTION.md") -Value @"
# Evolution

## Machine Check
problem: none
knowledge: none
adr: none
gate: none
template: none
no_change_reason: no change needed

## 本次 change 暴露的问题
- none

## 应写入 knowledge 的内容
- none

## 应新增或修改的 ADR
- none

## 应新增的 gate
- none

## 应调整的模板
- none

## 本次不调整的原因
- no change needed
"@
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "AUDIT.md") -Value (Get-DemoAudit)

    & (Join-Path $TargetRoot "agent-flow/scripts/closure-check.ps1") -ChangeDir $changeDir -ProjectRoot $TargetRoot
    if (-not $?) {
        throw "closure-check smoke test failed."
    }

    $checkResult = Join-Path $changeDir "CHECK_RESULT.json"
    & (Join-Path $TargetRoot "agent-flow/scripts/check-change.ps1") -ChangeDir $changeDir -ProjectRoot $TargetRoot -Closure -OutputPath $checkResult
    if (-not $?) {
        throw "check-change smoke test failed."
    }
    $result = Get-Content -Raw -Encoding utf8 -LiteralPath $checkResult | ConvertFrom-Json
    if (-not $result.passed) {
        throw "check-change JSON summary did not report passed=true."
    }
    if (-not ($result.gates | Where-Object { $_.gate -eq "emergency-check" })) {
        throw "check-change JSON summary missing emergency-check gate."
    }
}

try {
    Write-Host "== scaffold health =="
    & (Join-Path $starterRoot "agent-flow/scripts/scaffold-health.ps1")
    Push-Location $starterRoot
    try {
        bash agent-flow/scripts/scaffold-health.sh
    } finally {
        Pop-Location
    }

    Write-Host "== syntax =="
    $psFiles = Get-ChildItem -LiteralPath $starterRoot -Recurse -File -Filter "*.ps1"
    foreach ($file in $psFiles) {
        $null = [scriptblock]::Create((Get-Content -Raw -Encoding utf8 -LiteralPath $file.FullName))
    }
    Push-Location $starterRoot
    try {
        bash -lc "find agent-flow/scripts scripts -name '*.sh' -print0 | xargs -0 -n1 bash -n"
    } finally {
        Pop-Location
    }

    Write-Host "== install empty target =="
    New-Item -ItemType Directory -Force -Path $emptyTarget | Out-Null
    & (Join-Path $starterRoot "scripts/install-agent-flow.ps1") -Target $emptyTarget
    Assert-Path (Join-Path $emptyTarget "AGENTS.md")
    Assert-Path (Join-Path $emptyTarget "agent-flow/GO.md")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/next-step.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/next-step.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/sync-state.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/sync-state.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/state-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/state-check.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/scan-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/scan-check.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/task-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/task-check.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/task-boundary-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/task-boundary-check.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/manifest-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/manifest-check.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/emergency-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/emergency-check.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/evolution-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/evolution-check.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/closure-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/closure-check.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/check-change.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/check-change.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/new-change.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/new-change.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/alignment-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/alignment-check.sh")
    & (Join-Path $emptyTarget "agent-flow/scripts/init-project.ps1") -Target $emptyTarget
    & (Join-Path $emptyTarget "agent-flow/scripts/manifest-check.ps1") -ProjectRoot $emptyTarget
    & (Join-Path $emptyTarget "agent-flow/scripts/run-verify.ps1") -All
    Assert-NextStage -TargetRoot $emptyTarget -ExpectedStage "requirement"
    Assert-DesignAlignmentStage -TargetRoot $emptyTarget
    Assert-NewChangeAndAlignment -TargetRoot $emptyTarget
    Assert-GateScripts -TargetRoot $emptyTarget
    Assert-TaskBoundary -TargetRoot $emptyTarget
    Assert-ClosureCheck -TargetRoot $emptyTarget

    Write-Host "== update existing AGENTS.md =="
    New-Item -ItemType Directory -Force -Path $updateTarget | Out-Null
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $updateTarget "AGENTS.md") -Value @"
# Existing Rules

keep me

<!-- agent-flow:start -->
old block
<!-- agent-flow:end -->
"@
    & (Join-Path $starterRoot "scripts/install-agent-flow.ps1") -Target $updateTarget
    $agents = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $updateTarget "AGENTS.md")
    if ($agents -notmatch "keep me") { throw "Existing AGENTS.md content was not preserved." }
    if ($agents -match "old block") { throw "Old agent-flow block was not replaced." }
    if ($agents -notmatch "agent-flow/GO.md") { throw "New agent-flow block missing." }

    Write-Host "== residue scan =="
    $hits = rg -n "ops-pilot|RuoYi|ruoyi|ops-ai|ops-flow|ops-asset|ops-monitor|ops-workflow|inbound|入库|BusinessStatusEnum|wf_business_status" $starterRoot --glob "!scripts/test-starter.*"
    if ($LASTEXITCODE -eq 0) {
        throw "Project-specific residue found:`n$hits"
    }
    if ($LASTEXITCODE -ne 1) {
        exit $LASTEXITCODE
    }

    Write-Host "== docs/examples =="
    Assert-Path (Join-Path $starterRoot "docs/ADOPTION.md")
    Assert-Path (Join-Path $starterRoot "docs/PROMPTS.md")
    Assert-Path (Join-Path $starterRoot "examples/sample-change/VERIFY.md")
    Assert-Path (Join-Path $starterRoot ".github/workflows/scaffold-ci.yml")
    Assert-Path (Join-Path $starterRoot ".github/workflows/agent-flow-starter-check.yml")

    Write-Host "agent-flow starter self-test passed."
} finally {
    if (-not $KeepTemp) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Temp kept: $tempRoot"
    }
}
