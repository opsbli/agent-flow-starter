<#
.SYNOPSIS
Install or upgrade agent-flow in a target project.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER Target
Parameter accepted by this script.

.PARAMETER Force
Parameter accepted by this script.

.EXAMPLE
scripts/install-agent-flow.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$starterRoot = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $starterRoot "agent-flow/scripts/install-agent-flow.ps1"

if (-not (Test-Path -LiteralPath $installer)) {
    throw "Canonical installer not found: $installer"
}

if ($Force) {
    & $installer -Target $Target -StarterRoot $starterRoot -Force
} else {
    & $installer -Target $Target -StarterRoot $starterRoot
}

# --- Post-install: ECC integration notice ---
Write-Host ""
Write-Host "=== ECC Integration (optional) ==="
$hasEcc = Test-Path -LiteralPath "$env:USERPROFILE\.pi\agent\npm\node_modules\ecc-universal"
if ($hasEcc) {
    Write-Host "  ECC detected on this system. Skills included:"
    Write-Host "  - agent-flow/ecc-integration.md (skill mapping table)"
    Write-Host "  - Use /af-scan, /af-design, /af-verify, /af-go in pi"
} else {
    Write-Host "  ECC not detected. To enable ECC skills:"
    Write-Host "    pi install npm:ecc-universal"
    Write-Host "  Then re-run this installer to get ecc-integration.md"
}



