<#
.SYNOPSIS
Check agent-flow script registry coverage and legacy gate derivation.
#>

param(
    [string]$ProjectRoot = ".",
    [switch]$Check,
    [switch]$Write
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($ProjectRoot)
$manifestPath = Join-Path $root "agent-flow/manifest.yaml"
$gateRulesPath = Join-Path $root "agent-flow/rules/gates.txt"
$scriptsDir = Join-Path $root "agent-flow/scripts"

if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Missing manifest: $manifestPath" }
if (-not (Test-Path -LiteralPath $gateRulesPath)) { throw "Missing gate registry: $gateRulesPath" }
if (-not (Test-Path -LiteralPath $scriptsDir)) { throw "Missing scripts dir: $scriptsDir" }

$manifest = Get-Content -Raw -Encoding utf8 -LiteralPath $manifestPath
$publicScripts = @(
    Get-ChildItem -LiteralPath $scriptsDir -File |
        Where-Object { $_.Extension -in @(".ps1", ".sh") -and -not $_.BaseName.StartsWith("_") } |
        ForEach-Object { "agent-flow/scripts/$($_.Name)" } |
        Sort-Object -Unique
)
$classified = @(
    [regex]::Matches($manifest, "(?m)^\s+-\s+(agent-flow/scripts/[^\s#]+)\s*$") |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique
)
$gateRegistry = @(
    Get-Content -Encoding utf8 -LiteralPath $gateRulesPath |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith("#") } |
        Sort-Object -Unique
)

$issues = @()
foreach ($script in $publicScripts) {
    if ($classified -notcontains $script) { $issues += "Unclassified public script: $script" }
    if ($gateRegistry -notcontains $script) { $issues += "Public script missing from gates.txt: $script" }
}
foreach ($entry in $classified) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $entry))) { $issues += "Classified script missing on disk: $entry" }
}

if ($Write) {
    $header = @(
        "# One required public script per line. Keep paths relative to project root.",
        "# Internal shared libraries such as _common.ps1/.sh are checked by scaffold-health, not listed here.",
        "# This file is synchronized from the public script inventory by registry-sync.",
        ""
    )
    ($header + $publicScripts) | Set-Content -Encoding utf8 -LiteralPath $gateRulesPath
    Write-Host "Updated agent-flow/rules/gates.txt from public script inventory."
}

if ($issues.Count -gt 0) {
    Write-Host "Registry sync check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Registry sync check passed."
