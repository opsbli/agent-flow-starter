<#
.SYNOPSIS
Run incremental verification: only checks relevant to recently changed files.
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

try {
    $changedFiles = @()
    $gitDir = Join-Path $ProjectRoot ".git"
    if (Test-Path -LiteralPath $gitDir) {
        $diff = & git diff --name-only 2>&1 | Out-String
        $staged = & git diff --cached --name-only 2>&1 | Out-String
        $changedFiles = ($diff + $staged) -split "`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    }

    Write-Host "Incremental Verify: $($changedFiles.Count) changed files" -ForegroundColor Cyan
    $changedFiles | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

    $checks = @()
    $hasTs = $changedFiles | Where-Object { $_ -match '\.(ts|tsx)$' }
    $hasJs = $changedFiles | Where-Object { $_ -match '\.(js|jsx|mjs|cjs)$' }
    $hasPy = $changedFiles | Where-Object { $_ -match '\.py$' }
    $hasGo = $changedFiles | Where-Object { $_ -match '\.go$' }
    $hasRs = $changedFiles | Where-Object { $_ -match '\.rs$' }
    $hasConfig = $changedFiles | Where-Object { $_ -match '(package\.json|tsconfig|eslint|prettier|biome)' }

    if ($hasTs -or $hasConfig) {
        if (Test-Path -LiteralPath "tsconfig.json") {
            $checks += @{name="TypeScript Check"; cmd={ & npx tsc --noEmit 2>&1 | Out-String; $LASTEXITCODE -eq 0 }}
        }
    }

    if (($hasTs -or $hasJs) -and (Test-Path ".eslintrc*" -PathType Leaf -ErrorAction SilentlyContinue)) {
        $checks += @{name="ESLint"; cmd={ & npx eslint --quiet $changedFiles 2>&1 | Out-String; $LASTEXITCODE -eq 0 }}
    }

    if ($hasGo) {
        $checks += @{name="Go Vet"; cmd={ & go vet ./... 2>&1 | Out-String; $LASTEXITCODE -eq 0 }}
        $checks += @{name="Go Build"; cmd={ & go build ./... 2>&1 | Out-String; $LASTEXITCODE -eq 0 }}
    }

    if ($hasRs) {
        $checks += @{name="Cargo Check"; cmd={ & cargo check 2>&1 | Out-String; $LASTEXITCODE -eq 0 }}
    }

    if ($hasPy) {
        $checks += @{name="Python Syntax"; cmd={
            $ok = $true
            foreach ($f in $hasPy) {
                & python -m py_compile $f 2>&1 | Out-String
                if ($LASTEXITCODE -ne 0) { $ok = $false }
            }
            $ok
        }}
    }

    if ($changedFiles.Count -gt 0) {
        $checks += @{name="Secrets Check"; cmd={
            $secretOut = & Select-String -Path $changedFiles -Pattern 'sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{36,}|-----BEGIN.*PRIVATE KEY-----' -ErrorAction SilentlyContinue
            (-not $secretOut)
        }}
    }

    if ($hasTs -or $hasJs) {
        $checks += @{name="Console.log Check"; cmd={
            $consoleOut = & Select-String -Path $changedFiles -Pattern 'console\.(log|debug)' -ErrorAction SilentlyContinue
            (-not $consoleOut)
        }}
    }

    $passed = 0
    $failed = 0
    $skipped = 0
    $results = @{}
    foreach ($c in $checks) {
        Write-Host "  Running $($c.name)..." -ForegroundColor Gray
        $success = & $c.cmd
        if ($success) {
            $passed++
            $results[$c.name] = "PASS"
        } else {
            $failed++
            $results[$c.name] = "FAIL"
        }
    }

    Write-Host ""
    Write-Host "=== Incremental Verify Results ===" -ForegroundColor Cyan
    foreach ($k in $results.Keys) {
        $label = if ($results[$k] -eq "PASS") { "[PASS]" } else { "[FAIL]" }
        Write-Host "  $label $k : $($results[$k])" -ForegroundColor $(if ($results[$k] -eq "PASS") { "Green" } else { "Red" })
    }
    Write-Host ""
    Write-Host "  $passed passed, $failed failed, $skipped skipped" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
    if ($failed -gt 0) {
        Write-Host "  [FAIL] Some checks failed. Fix before committing." -ForegroundColor Red
    }
} finally {
    Pop-Location
}
