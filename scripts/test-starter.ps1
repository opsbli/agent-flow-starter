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

    $json = & (Join-Path $TargetRoot "agent-flow/scripts/next-step.ps1") -ChangeDir $changeDir
    $result = $json | ConvertFrom-Json
    if ($result.stage -ne $ExpectedStage) {
        throw "Expected next-step stage '$ExpectedStage', got '$($result.stage)'. Output: $json"
    }
    if ([string]::IsNullOrWhiteSpace($result.next_prompt)) {
        throw "next-step did not return a next_prompt."
    }
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
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/new-change.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/new-change.sh")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/alignment-check.ps1")
    Assert-Path (Join-Path $emptyTarget "agent-flow/scripts/alignment-check.sh")
    & (Join-Path $emptyTarget "agent-flow/scripts/init-project.ps1") -Target $emptyTarget
    & (Join-Path $emptyTarget "agent-flow/scripts/run-verify.ps1") -All
    Assert-NextStage -TargetRoot $emptyTarget -ExpectedStage "requirement"
    Assert-DesignAlignmentStage -TargetRoot $emptyTarget
    Assert-NewChangeAndAlignment -TargetRoot $emptyTarget

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

    Write-Host "agent-flow starter self-test passed."
} finally {
    if (-not $KeepTemp) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Temp kept: $tempRoot"
    }
}
