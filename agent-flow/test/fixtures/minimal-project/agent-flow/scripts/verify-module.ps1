<#
.DEPRECATED
Use run-verify.ps1 directly instead:
  agent-flow/scripts/run-verify.ps1 -Name module_compile -Module <name>
  agent-flow/scripts/run-verify.ps1 -Name module_test -Module <name>
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Module,
    [switch]$SkipTests
)

Write-Warning "[DEPRECATED] Use run-verify.ps1 -Name module_compile|module_test -Module <name> instead"

$ErrorActionPreference = "Stop"

& "$PSScriptRoot/run-verify.ps1" -Name module_compile -Module $Module
if (-not $SkipTests) {
    & "$PSScriptRoot/run-verify.ps1" -Name module_test -Module $Module
}
