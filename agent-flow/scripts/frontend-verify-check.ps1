<#
.SYNOPSIS
Enforce frontend verification evidence in VERIFY.md.

.DESCRIPTION
When manifest.yaml declares a frontend framework, this gate checks that:
1. VERIFY.md exists and contains frontend verification evidence
2. If verify_required is true, frontend evidence must appear in AC Evidence table
3. Chrome DevTools checklist items are addressed

Exit codes:
  0 = frontend verification satisfied (or no frontend)
  1 = frontend verification required but evidence missing
  2 = manifest.yaml not found

.NOTES
Part of the agent-flow gate chain. Registered in manifest.yaml.
#>

param(
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$manifestPath = Join-Path $root "agent-flow/manifest.yaml"

if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Host "❌ Manifest not found: $manifestPath" -ForegroundColor Red
    exit 2
}

# Parse manifest.yaml
$manifest = Get-Content -Raw -Encoding utf8 -LiteralPath $manifestPath
$hasFrontend = $manifest -match 'frontend:\s*\n\s+framework:\s*(?!none)(\S+)'
$verifyRequired = $manifest -match 'frontend:\s*\n(?:\s+[^:]+:\s*[^\n]*\n)*\s+verify_required:\s*true'

if (-not $hasFrontend) {
    Write-Host "✓ No frontend framework declared — skipping frontend verification" -ForegroundColor Green
    exit 0
}

$framework = if ($matches[1]) { $matches[1] } else { "unknown" }
Write-Host "Frontend framework detected: $framework" -ForegroundColor Cyan

if (-not $ChangeDir) {
    Write-Host "❌ -ChangeDir is required when frontend.framework is not none" -ForegroundColor Red
    exit 1
}

$changePath = [System.IO.Path]::GetFullPath((Join-Path $root $ChangeDir))
$verifyPath = Join-Path $changePath "VERIFY.md"

if (-not (Test-Path -LiteralPath $verifyPath)) {
    Write-Host "❌ VERIFY.md not found at $verifyPath" -ForegroundColor Red
    Write-Host "  Frontend changes require VERIFY.md with verification evidence."
    exit 1
}

$verifyContent = Get-Content -Raw -Encoding utf8 -LiteralPath $verifyPath

# Check 1: AC Evidence table must exist
$hasAcTable = $verifyContent -match '\| AC-\d+'
if (-not $hasAcTable) {
    Write-Host "⚠️  No AC Evidence table found in VERIFY.md" -ForegroundColor Yellow
    if ($verifyRequired) {
        Write-Host "❌ verify_required=true — frontend AC Evidence is mandatory" -ForegroundColor Red
        exit 1
    }
}

# Check 2: Frontend-specific keywords in VERIFY.md
$frontendKeywords = @(
    "DevTools",
    "Chrome DevTools",
    "Network",
    "Console",
    "Elements",
    "视觉",
    "UI",
    "联调",
    "e2e",
    "E2E",
    "browser",
    "Browser",
    "前端验证",
    "typecheck",
    "tsc",
    "lint",
    "component test"
)

$foundKeywords = $frontendKeywords | Where-Object { $verifyContent -match [regex]::Escape($_) }
if ($foundKeywords.Count -eq 0) {
    Write-Host "⚠️  No frontend verification keywords found in VERIFY.md" -ForegroundColor Yellow
    Write-Host "  Expected at least one of: DevTools, Console, UI, 联调, e2e, typecheck, lint"
    if ($verifyRequired) {
        Write-Host "❌ verify_required=true — frontend evidence is mandatory" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ Frontend verification evidence found: $($foundKeywords -join ', ')" -ForegroundColor Green
}

# Check 3: Chrome DevTools specific checks for verify_required
if ($verifyRequired) {
    $devToolChecks = @(
        "Network 无 4xx",
        "Console 无报错",
        "Elements",
        "Application"
    )
    $missingChecks = $devToolChecks | Where-Object { -not ($verifyContent -match [regex]::Escape($_)) }
    if ($missingChecks.Count -gt 0) {
        Write-Host "⚠️  Missing some DevTools check evidence: $($missingChecks -join ', ')" -ForegroundColor Yellow
        Write-Host "  Refer to agent-flow/core/frontend-fit.md for the complete checklist."
    }
}

Write-Host "✓ Frontend verification check passed" -ForegroundColor Green
exit 0
