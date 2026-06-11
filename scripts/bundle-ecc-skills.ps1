<#
.SYNOPSIS
Copy agent-flow-relevant ECC skills to pi-package/skills/ for distribution
.DESCRIPTION
ECC has 197 skills but only ~33 are useful for agent-flow workflows.
This script copies only the needed SKILL.md files.
#>
param()
$ErrorActionPreference = "Stop"
$starterRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not (Test-Path (Join-Path $starterRoot "agent-flow"))) {
    # PSScriptRoot may not resolve correctly in some shells
    $starterRoot = "$env:USERPROFILE\Documents\agent-flow-starter"
}
$eccSkills = "$env:USERPROFILE\.pi\agent\npm\node_modules\ecc-universal\skills"
$targetDir = "$starterRoot\pi-package\skills"
if (-not (Test-Path $eccSkills)) {
    Write-Host "ECC not found. Run: pi install npm:ecc-universal" -ForegroundColor Red
    exit 1
}
$needed = @(
    "search-first"
    "documentation-lookup"
    "api-design"
    "backend-patterns"
    "frontend-patterns"
    "database-migrations"
    "postgres-patterns"
    "error-handling"
    "docker-patterns"
    "deployment-patterns"
    "coding-standards"
    "mcp-server-patterns"
    "security-review"
    "security-scan"
    "python-patterns"
    "golang-patterns"
    "rust-patterns"
    "react-patterns"
    "java-coding-standards"
    "kotlin-patterns"
    "swiftui-patterns"
    "dart-flutter-patterns"
    "dotnet-patterns"
    "cpp-coding-standards"
    "nestjs-patterns"
    "fastapi-patterns"
    "verification-loop"
    "eval-harness"
    "e2e-testing"
    "tdd-workflow"
    "benchmark-optimization-loop"
    "continuous-learning-v2"
    "council"
)
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}
$copied = 0
$missing = @()
foreach ($name in $needed) {
    $src = "$eccSkills\$name"
    $dst = "$targetDir\$name"
    if (Test-Path $src) {
        $skillMd = "$src\SKILL.md"
        if (Test-Path $skillMd) {
            if (-not (Test-Path $dst)) {
                New-Item -ItemType Directory -Force -Path $dst | Out-Null
            }
            Copy-Item $skillMd "$dst\SKILL.md" -Force
            $copied++
        }
    } else {
        $missing += $name
    }
}
Write-Host ""
Write-Host "agent-flow skill bundle complete" -ForegroundColor Green
Write-Host "  Target: $targetDir"
Write-Host "  Copied: $copied skills"
Write-Host "  Missing: $($missing.Count)" -ForegroundColor Yellow
if ($missing.Count -gt 0) { Write-Host "  $($missing -join ', ')" }
Write-Host "  Size: $([math]::Round((Get-ChildItem -Recurse $targetDir -File | Measure-Object -Property Length -Sum).Sum / 1KB)) KB"
Write-Host "  (was 197 ECC skills, now $copied - $([math]::Round($copied/197*100))%)"
