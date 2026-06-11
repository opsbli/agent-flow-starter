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



