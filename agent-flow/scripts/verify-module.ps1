param(
    [Parameter(Mandatory = $true)]
    [string]$Module,
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"

& "$PSScriptRoot/run-verify.ps1" -Name module_compile -Module $Module
if (-not $SkipTests) {
    & "$PSScriptRoot/run-verify.ps1" -Name module_test -Module $Module
}
