<#
.SYNOPSIS
Run incremental verification — only checks relevant to recently changed files.
.DESCRIPTION
Detects what changed (git diff), determines relevant checks, and runs only those.
#>
param(
    [string]$ProjectRoot = ".",
    [string]$ChangeDir,
    [switch]$AutoFormat
)
$ErrorActionPreference = "Stop"
Push-Location $ProjectRoot

# --- Detect changed files ---
$changedFiles = @()
$gitDir = Join-Path $ProjectRoot ".git"
if (Test-Path $gitDir) {
    $diff = & git diff --name-only 2>&1 | Out-String
    $staged = & git diff --cached --name-only 2>&1 | Out-String
    $changedFiles = ($diff + $staged) -split "`n" | Where-Object { $_ -ne "" }
}
Write-Host "Incremental Verify — $($changedFiles.Count) changed files" -ForegroundColor Cyan
$changedFiles | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

# --- Determine relevant checks ---
$checks = @()
$hasTs = $changedFiles | Where-Object { $_ -match '\.(ts|tsx)$' }
$hasJs = $changedFiles | Where-Object { $_ -match '\.(js|jsx|mjs|cjs)$' }
$hasPy = $changedFiles | Where-Object { $_ -match '\.py$' }
$hasGo = $changedFiles | Where-Object { $_ -match '\.go$' }
$hasRs = $changedFiles | Where-Object { $_ -match '\.rs$' }
$hasJson = $changedFiles | Where-Object { $_ -match '\.json$' }
$hasYaml = $changedFiles | Where-Object { $_ -match '\.(yaml|yml)$' }
$hasMd = $changedFiles | Where-Object { $_ -match '\.md$' }
$hasConfig = $changedFiles | Where-Object { $_ -match '(package\.json|tsconfig|eslint|prettier|biome)' }

# TypeScript check
if ($hasTs -or $hasConfig) {
    if (Test-Path "tsconfig.json") {
        $checks += @{name="TypeScript Check"; cmd={ & npx tsc --noEmit 2>&1 | Out-String; $LASTEXITCODE -eq 0 }}
    }
}
# ESLint
if (($hasTs -or $hasJs) -and (Test-Path ".eslintrc*" -PathType Leaf -ErrorAction SilentlyContinue)) {
    $checks += @{name="ESLint"; cmd={ & npx eslint --quiet $changedFiles 2>&1 | Out-String; $LASTEXITCODE -eq 0 }}
}
# Go vet
if ($hasGo) {
    $checks += @{name="Go Vet"; cmd={ & go vet ./... 2>&1 | Out-String; $LASTEXITCODE -eq 0 }}
    $checks += @{name="Go Build"; cmd={ & go build ./... 2>&1 | Out-String; $LASTEXITCODE -eq 0 }}
}
# Rust check
if ($hasRs) {
    $checks += @{name="Cargo Check"; cmd={ & cargo check 2>&1 | Out-String; $LASTEXITCODE -eq 0 }}
}
# Python syntax
if ($hasPy) {
    $checks += @{name="Python Syntax"; cmd={ $global:result = $true; foreach ($f in $hasPy) { & python -m py_compile $f 2>&1 | Out-String; if ($LASTEXITCODE -ne 0) { $global:result = $false } }; $global:result }}
}
# Secrets in changed files
$checks += @{name="Secrets Check"; cmd={
    $secretOut = & Select-String -Path $changedFiles -Pattern 'sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{36,}|-----BEGIN.*PRIVATE KEY-----' -ErrorAction SilentlyContinue
    (-not $secretOut)
}}
# Console.log warning
if ($hasTs -or $hasJs) {
    $checks += @{name="Console.log Check"; cmd={
        $consoleOut = & Select-String -Path $changedFiles -Pattern 'console\.(log|debug)' -ErrorAction SilentlyContinue
        (-not $consoleOut)
    }}
}

# --- Run checks ---
$passed = 0; $failed = 0; $skipped = 0
$results = @{}
foreach ($c in $checks) {
    Write-Host "  Running $($c.name)..." -ForegroundColor Gray
    $success = & $c.cmd
    if ($success) { $passed++; $results[$c.name] = "PASS" } else { $failed++; $results[$c.name] = "FAIL" }
}

# --- Report ---
Write-Host ""
Write-Host "=== Incremental Verify Results ===" -ForegroundColor Cyan
foreach ($k in $results.Keys) {
    $icon = if ($results[$k] -eq "PASS") { "✅" } else { "❌" }
    Write-Host "  $icon $k : $($results[$k])" -ForegroundColor $(if ($results[$k] -eq "PASS") { "Green" } else { "Red" })
}
Write-Host ""
Write-Host "  $passed passed, $failed failed, $skipped skipped" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
if ($failed -gt 0) { Write-Host "  ❌ Some checks failed. Fix before committing." -ForegroundColor Red }
Pop-Location
