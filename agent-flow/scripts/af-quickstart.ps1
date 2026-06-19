<#
.SYNOPSIS
One-command agent-flow quickstart. Initializes project and creates a demo change.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root.
Performs:
  1. Scaffold health check
  2. Project initialization (interactive wizard)
  3. Creates a sample Light change
  4. Guides user through next steps

.PARAMETER Target
Project root directory (default: current directory).

.PARAMETER DemoName
Name for the demo change (default: hello-agent-flow).

.EXAMPLE
agent-flow/scripts/af-quickstart.ps1

.EXAMPLE
agent-flow/scripts/af-quickstart.ps1 -Target D:\Projects\my-app
#>

param(
    [string]$Target = ".",
    [string]$DemoName = "hello-agent-flow"
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($Target)
if (-not (Test-Path -LiteralPath $root)) {
    throw "Target not found: $root"
}

Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   agent-flow Quickstart                 ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Scaffold health ──
Write-Host "Step 1/4: Checking scaffold health..." -ForegroundColor Yellow
$healthScript = Join-Path $root "agent-flow/scripts/scaffold-health.ps1"
if (Test-Path $healthScript) {
    & $healthScript
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
        Write-Host "Scaffold health check failed. Run init-wizard first:" -ForegroundColor Red
        Write-Host "  agent-flow/scripts/init-wizard.ps1" -ForegroundColor Cyan
        exit 1
    }
    Write-Host "  ✅ Scaffold healthy" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ scaffold-health.ps1 not found. Is agent-flow installed?" -ForegroundColor Yellow
    Write-Host "  Run install-agent-flow.ps1 first."
    exit 1
}
Write-Host ""

# ── Step 2: Verify manifest ──
Write-Host "Step 2/4: Checking manifest configuration..." -ForegroundColor Yellow
$manifestPath = Join-Path $root "agent-flow/manifest.yaml"
$manifestCheck = Join-Path $root "agent-flow/scripts/manifest-check.ps1"
if (Test-Path $manifestCheck) {
    & $manifestCheck
} elseif (Test-Path $manifestPath) {
    Write-Host "  ✅ manifest.yaml exists" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ No manifest.yaml found. Run init-wizard to create one:"
    Write-Host "    agent-flow/scripts/init-wizard.ps1"
}
Write-Host ""

# ── Step 3: Create demo change ──
Write-Host "Step 3/4: Creating demo change '$DemoName'..." -ForegroundColor Yellow
$newChangeScript = Join-Path $root "agent-flow/scripts/new-change.ps1"
if (Test-Path $newChangeScript) {
    & $newChangeScript -Name $DemoName -Flow Light
    $changeDir = Join-Path $root "agent-flow/changes/$DemoName"
    if (Test-Path $changeDir) {
        # Auto-fill basic CHANGE.md content
        $changePath = Join-Path $changeDir "CHANGE.md"
        if (Test-Path $changePath) {
            $content = @"
# Change: $DemoName

## 一句话需求

初次使用 agent-flow 的演示 change。

## 流程级别

- [x] Light
- [ ] Standard
- [ ] Heavy
- [ ] Emergency

## 分级理由

演示用途，不涉及代码修改。

## 目标

- 完成 agent-flow 的首次完整使用流程

## 非目标

- 无实际代码修改

## 影响范围

- 无
"@
            Set-Content -Encoding utf8 -LiteralPath $changePath -Value $content
        }
        Write-Host "  ✅ Demo change created: $DemoName" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠️ new-change.ps1 not found. Cannot create demo."
}

# ── Step 4: Show next steps ──
Write-Host "Step 4/4: Next steps guide" -ForegroundColor Yellow
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   ✅ Quickstart Complete!                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your demo change is ready at:" -ForegroundColor White
Write-Host "  agent-flow/changes/$DemoName/"
Write-Host ""
Write-Host "Recommended learning path:" -ForegroundColor Cyan
Write-Host "  Phase 1 (5 min) : Read docs/learning-path.md" -ForegroundColor Gray
Write-Host "  Phase 2 (15 min): Complete this Light change"
Write-Host "  Phase 3 (30 min): Try a Standard change"
Write-Host "  Phase 4 (45 min): Try a Heavy change"
Write-Host ""
Write-Host "To continue this change, run:" -ForegroundColor Cyan
Write-Host "  agent-flow/scripts/next-step.ps1 -ChangeDir agent-flow/changes/$DemoName"
Write-Host ""
Write-Host "Or tell your AI:" -ForegroundColor Cyan
Write-Host "  '继续 agent-flow change: $DemoName'" -ForegroundColor White
Write-Host ""
Write-Host "Quick commands:" -ForegroundColor Cyan
Write-Host "  Dashboard  : agent-flow/scripts/dashboard.ps1"
Write-Host "  Suggestions: agent-flow/scripts/evolution-suggest.ps1 -ProjectRoot ."
Write-Host "  All gates  : agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/$DemoName"
Write-Host ""
