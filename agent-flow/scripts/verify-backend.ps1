<#
.SYNOPSIS
Run the verify-backend agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER SkipTests
Skip backend_test and only run backend_compile.

.EXAMPLE
agent-flow/scripts/verify-backend.ps1
#>

<#
.DEPRECATED
Use run-verify.ps1 directly instead:
  agent-flow/scripts/run-verify.ps1 -Name backend_compile
  agent-flow/scripts/run-verify.ps1 -Name backend_test
#>

param([switch]$SkipTests)

Write-Warning "[DEPRECATED] Use run-verify.ps1 -Name backend_compile|backend_test instead"

$ErrorActionPreference = "Stop"

& "$PSScriptRoot/run-verify.ps1" -Name backend_compile
if (-not $SkipTests) {
    & "$PSScriptRoot/run-verify.ps1" -Name backend_test
}



