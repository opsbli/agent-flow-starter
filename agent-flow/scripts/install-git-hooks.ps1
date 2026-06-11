<#
.SYNOPSIS
Install git pre-commit hook that runs incremental-verify before each commit.
.DESCRIPTION
Creates or updates .git/hooks/pre-commit to run agent-flow's incremental-verify.
#>
param(
    [string]$ProjectRoot = "."
)
$ErrorActionPreference = "Stop"
$hooksDir = Join-Path $ProjectRoot ".git" "hooks"
$hookFile = Join-Path $hooksDir "pre-commit"
if (-not (Test-Path $hooksDir)) {
    Write-Host "No .git/hooks directory found at $ProjectRoot. Not a git repository?" -ForegroundColor Yellow
    exit 1
}
$verifyScript = Join-Path $ProjectRoot "agent-flow" "scripts" "incremental-verify.ps1"
$verifyScriptSh = Join-Path $ProjectRoot "agent-flow" "scripts" "incremental-verify.sh"
$content = @"
#!/usr/bin/env sh
# agent-flow incremental-verify pre-commit hook
# Installed by agent-flow/scripts/install-git-hooks.ps1
# Run 'bash agent-flow/scripts/incremental-verify.sh' before each commit.

echo ""
echo "=== agent-flow: Running incremental verification ==="
if [ -f "$verifyScriptSh" ]; then
    bash "$verifyScriptSh"
    if [ \$? -ne 0 ]; then
        echo "❌ Verification failed. Commit blocked."
        echo "   Fix the issues above, or use 'git commit --no-verify' to bypass."
        exit 1
    fi
else
    echo "⚠️  incremental-verify.sh not found. Skipping."
fi
echo "✅ Verification passed. Proceeding with commit."
exit 0
"@
$content | Set-Content $hookFile -Encoding utf8
Write-Host "✅ Pre-commit hook installed: $hookFile" -ForegroundColor Green
Write-Host "  It runs 'incremental-verify.sh' before each commit."
Write-Host "  Use 'git commit --no-verify' to bypass."
