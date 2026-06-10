param([switch]$SkipTests)

$ErrorActionPreference = "Stop"

& "$PSScriptRoot/run-verify.ps1" -Name backend_compile
if (-not $SkipTests) {
    & "$PSScriptRoot/run-verify.ps1" -Name backend_test
}
