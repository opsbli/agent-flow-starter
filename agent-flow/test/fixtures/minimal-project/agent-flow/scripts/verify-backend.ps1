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
