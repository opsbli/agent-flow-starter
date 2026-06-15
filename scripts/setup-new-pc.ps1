<#
.SYNOPSIS
Bootstrap pi, bundled ECC assets, and agent-flow on a new Windows machine.

.DESCRIPTION
This helper installs:
  1. pi, unless -NoPi is provided.
  2. Bundled ECC skills, unless -NoEcc is provided.
  3. Bundled pi extensions, agents, and prompt templates.
  4. agent-flow into the target project.

.PARAMETER Target
Target project directory.

.PARAMETER StarterRepo
Local starter path or a Git URL. Defaults to this repository.

.PARAMETER NoPi
Skip pi installation.

.PARAMETER NoEcc
Skip bundled ECC skill installation.

.EXAMPLE
scripts/setup-new-pc.ps1 -Target D:\Projects\my-app
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [string]$StarterRepo,
    [switch]$NoPi,
    [switch]$NoEcc
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Text)
    Write-Host "`n==> $Text" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Text)
    Write-Host "  [OK] $Text" -ForegroundColor Green
}

function Write-Skip {
    param([string]$Text)
    Write-Host "  [SKIP] $Text" -ForegroundColor Yellow
}

function Write-Warn {
    param([string]$Text)
    Write-Host "  [WARN] $Text" -ForegroundColor Magenta
}

function Copy-ExistingFile {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (Test-Path -LiteralPath $Source) {
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
        return $true
    }
    return $false
}

if ($StarterRepo) {
    if (Test-Path -LiteralPath $StarterRepo -PathType Container) {
        $starterRoot = (Resolve-Path $StarterRepo).Path
    } else {
        $cloneDir = Join-Path $env:TEMP "agent-flow-starter-install"
        if (Test-Path -LiteralPath $cloneDir) {
            Remove-Item -LiteralPath $cloneDir -Recurse -Force
        }
        Write-Step "Cloning agent-flow-starter from $StarterRepo"
        git clone --depth 1 $StarterRepo $cloneDir
        if ($LASTEXITCODE -ne 0) { throw "Failed to clone agent-flow-starter." }
        $starterRoot = $cloneDir
    }
} else {
    $starterRoot = Split-Path -Parent $PSScriptRoot
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  agent-flow + ECC bootstrap" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starter root: $starterRoot"
Write-Host "Target project: $Target"

if (-not $NoPi) {
    Write-Step "Step 1/4: Checking pi"
    $piPath = Get-Command "pi" -ErrorAction SilentlyContinue
    if (-not $piPath) {
        Write-Host "  pi not found. Installing..."
        npm install -g --ignore-scripts "@earendil-works/pi-coding-agent"
        if ($LASTEXITCODE -ne 0) { throw "pi installation failed." }
        Write-Ok "pi installed"
    } else {
        Write-Ok "pi available: $($piPath.Source)"
    }
} else {
    Write-Skip "Skipping pi installation (-NoPi)"
}

if (-not $NoEcc) {
    Write-Step "Step 2/4: Installing bundled ECC skills"
    $bundleDir = Join-Path $starterRoot "pi-package\skills"
    $targetSkillsDir = Join-Path $env:USERPROFILE ".pi\agent\skills"
    New-Item -ItemType Directory -Force -Path $targetSkillsDir | Out-Null

    if (Test-Path -LiteralPath $bundleDir) {
        $count = 0
        foreach ($dir in Get-ChildItem -LiteralPath $bundleDir -Directory) {
            $src = Join-Path $dir.FullName "SKILL.md"
            if (Test-Path -LiteralPath $src) {
                $dstDir = Join-Path $targetSkillsDir $dir.Name
                New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
                Copy-Item -LiteralPath $src -Destination (Join-Path $dstDir "SKILL.md") -Force
                $count++
            }
        }
        Write-Ok "Installed $count bundled skills"
    } else {
        Write-Warn "Bundled skills not found: $bundleDir"
        Write-Host "  Trying full ECC package via pi..."
        & pi install npm:ecc-universal
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "ECC installed via pi"
        } else {
            Write-Warn "ECC installation did not complete"
        }
    }
} else {
    Write-Skip "Skipping ECC installation (-NoEcc)"
}

Write-Step "Step 3/4: Installing pi integration files"

$piAgentDir = Join-Path $env:USERPROFILE ".pi\agent"
$extDir = Join-Path $piAgentDir "extensions"
$agentsDir = Join-Path $piAgentDir "agents"
$promptsDir = Join-Path $piAgentDir "prompts"
foreach ($dir in @($extDir, $agentsDir, $promptsDir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

$bridgeExt = Join-Path $starterRoot "pi-package\extensions\ecc-bridge.ts"
if (Copy-ExistingFile -Source $bridgeExt -Destination (Join-Path $extDir "ecc-bridge.ts")) {
    Write-Ok "Installed ecc-bridge.ts"
} else {
    Write-Warn "ecc-bridge.ts not found"
}

$agentFiles = @(
    "ecc-architect.md",
    "ecc-build.md",
    "ecc-explorer.md",
    "ecc-perf.md",
    "ecc-planner.md",
    "ecc-reviewer.md",
    "ecc-security.md",
    "ecc-tdd.md"
)
$agentSourceDir = Join-Path $starterRoot "pi-package\agents"
$agentCount = 0
foreach ($file in $agentFiles) {
    $src = Join-Path $agentSourceDir $file
    if (Copy-ExistingFile -Source $src -Destination (Join-Path $agentsDir $file)) {
        $agentCount++
    }
}
Write-Ok "Installed $agentCount ECC agent files"

$templateFiles = @(
    "af-go.md",
    "af-scan.md",
    "af-design.md",
    "af-verify.md",
    "ecc-build.md",
    "ecc-checkpoint.md",
    "ecc-docs.md",
    "ecc-plan.md",
    "ecc-quality.md",
    "ecc-refactor.md",
    "ecc-review.md",
    "ecc-security.md",
    "ecc-tdd.md"
)
$tplSourceDir = Join-Path $starterRoot "pi-package\prompts"
$templateCount = 0
foreach ($file in $templateFiles) {
    $src = Join-Path $tplSourceDir $file
    if (Copy-ExistingFile -Source $src -Destination (Join-Path $promptsDir $file)) {
        $templateCount++
    }
}
Write-Ok "Installed $templateCount prompt templates"

Write-Step "Step 4/4: Installing agent-flow into target project"

$afInstaller = Join-Path $starterRoot "agent-flow\scripts\install-agent-flow.ps1"
if (Test-Path -LiteralPath $afInstaller) {
    & $afInstaller -Target $Target -StarterRoot $starterRoot -Force
    if ($LASTEXITCODE -ne 0) { throw "agent-flow installation failed." }
    Write-Ok "agent-flow installed into $Target"
} else {
    Write-Warn "agent-flow installer not found: $afInstaller"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  [OK] Bootstrap complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next:"
Write-Host "  cd $Target"
Write-Host "  pi"
Write-Host "  In pi, ask: follow agent-flow for this request: <request>"
Write-Host ""
Write-Host "Useful commands:"
Write-Host "  /af-go <request>     - run the full workflow"
Write-Host "  /af-scan <request>   - code-first scan"
Write-Host "  /af-design <feature> - design"
Write-Host "  /af-verify           - verification gates"
Write-Host "  /ecc-review          - code review"
Write-Host "  /ecc-security        - security scan"
Write-Host "  /ecc-quality         - quality gates"
Write-Host "  /ecc-plan            - plan generation"
