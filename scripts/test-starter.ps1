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
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "DESIGN.md") -Value "# Design`n`n## Design Alignment / Grill`n`nAlignment Verdict: pending"

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
    $design = Get-Content -Raw -Encoding utf8 -LiteralPath $designPath
    $design = $design -replace "Alignment Verdict: pending", "Alignment Verdict: aligned"
    Set-Content -Encoding utf8 -LiteralPath $designPath -Value $design

    & (Join-Path $TargetRoot "agent-flow/scripts/alignment-check.ps1") -ChangeDir $changeDir
}

function Assert-GateScripts {
    param([string]$TargetRoot)

    $changeDir = Join-Path $TargetRoot "agent-flow/changes/demo-gates"
    New-Item -ItemType Directory -Force -Path $changeDir | Out-Null
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "REQUIREMENT.md") -Value "# Requirement`n`n- AC-01: Demo criterion."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "DESIGN.md") -Value "# Design`n`nNo schema, permission, auth, workflow, or status change."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "TASKS.md") -Value "# Tasks`n`nwrite_files:`n  - README.md"

    & (Join-Path $TargetRoot "agent-flow/scripts/ac-check.ps1") -ChangeDir $changeDir -TestRoot $changeDir
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
}

function Assert-ClosureCheck {
    param([string]$TargetRoot)

    $changeDir = Join-Path $TargetRoot "agent-flow/changes/demo-closure"
    New-Item -ItemType Directory -Force -Path $changeDir | Out-Null
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "CHANGE.md") -Value "# Change`n`n- [ ] Light`n- [ ] Standard`n- [x] Heavy"
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "CODE_SCAN.md") -Value "# Code Scan`n`nScanned."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "REQUIREMENT.md") -Value "# Requirement`n`n- AC-01: Demo."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "DESIGN.md") -Value "# Design`n`nAlignment Verdict: aligned"
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "PLAN.md") -Value "# Plan`n`nPlan."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "TASKS.md") -Value "# Tasks`n`nwrite_files:`n  - README.md"
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "VERIFY.md") -Value "# Verify`n`n## AC Evidence`n`n| AC | Evidence |`n|---|---|`n| AC-01 | pass |`n`nac-check pass`ncode-drift-check pass`nblocked-check pass`ntask-boundary-check pass"
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "REVIEW.md") -Value "# Review`n`nReviewed."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "REPORT.md") -Value "# Report`n`nDone."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "EVOLUTION.md") -Value "# Evolution`n`nNo change."
    Set-Content -Encoding utf8 -LiteralPath (Join-Path $changeDir "AUDIT.md") -Value "# Audit`n`n## Closure Audit`n`nVerdict: acceptable`n`nac-check pass`ncode-drift-check pass`nblocked-check pass`ntask-boundary-check pass"

    & (Join-Path $TargetRoot "agent-flow/scripts/closure-check.ps1") -ChangeDir $changeDir -ProjectRoot $TargetRoot
    if (-not $?) {
        throw "closure-check smoke test failed."
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
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/task-boundary-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/task-boundary-check.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/manifest-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/manifest-check.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/closure-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/closure-check.sh")
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
