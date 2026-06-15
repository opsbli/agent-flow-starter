<#
.SYNOPSIS
Run verification commands from manifest.yaml.

.DESCRIPTION
Reads verification commands from agent-flow/manifest.yaml and executes them.
Supports backend_compile, backend_test, module_compile, module_test,
frontend_typecheck, frontend_test, frontend_lint.

NOTE: verify-backend.ps1 and verify-module.ps1 are deprecated.
Use this script directly instead.

.PARAMETER Name
Verification key from manifest.yaml (e.g., backend_compile, backend_test).

.PARAMETER All
Run all verification commands.

.PARAMETER Module
Module name for module_compile/module_test (replaces {module} in command).

.PARAMETER Manifest
Path to manifest.yaml. Default: agent-flow/manifest.yaml

.EXAMPLE
.\run-verify.ps1 -Name backend_compile
.\run-verify.ps1 -Name backend_test
.\run-verify.ps1 -Name module_compile -Module my-module
.\run-verify.ps1 -All
#>

param(
    [string]$Name,
    [switch]$All,
    [string]$Module,
    [string]$Manifest = "agent-flow/manifest.yaml"
)

$ErrorActionPreference = "Stop"

if (-not $All -and [string]::IsNullOrWhiteSpace($Name)) {
    throw "Use -Name <verification-key> or -All."
}

if (-not (Test-Path -LiteralPath $Manifest)) {
    throw "Manifest not found: $Manifest"
}

$manifestText = Get-Content -Raw -Encoding utf8 -LiteralPath $Manifest

function Remove-YamlWrappingQuotes {
    param([string]$Value)

    $trimmed = $Value.Trim()
    if ($trimmed.Length -ge 2) {
        $first = $trimmed[0]
        $last = $trimmed[$trimmed.Length - 1]
        if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
            return $trimmed.Substring(1, $trimmed.Length - 2)
        }
    }
    return $trimmed
}

function Get-VerificationCommand {
    param([string]$Key)

    $pattern = "(?m)^\s+$([regex]::Escape($Key)):\s*(.+?)\s*$"
    $match = [regex]::Match($manifestText, $pattern)
    if (-not $match.Success) {
        return $null
    }

    $command = Remove-YamlWrappingQuotes -Value $match.Groups[1].Value
    if ([string]::IsNullOrWhiteSpace($command)) {
        return $null
    }
    if ($command -match "^(TODO_|N/A$|NONE$|none$|null$)") {
        return $null
    }
    return $command
}

function Invoke-Verification {
    param([string]$Key)

    $command = Get-VerificationCommand -Key $Key
    if (-not $command) {
        Write-Host "Skipping ${Key}: no runnable command in $Manifest"
        return
    }

    if ($command.Contains("{module}")) {
        if ([string]::IsNullOrWhiteSpace($Module)) {
            Write-Host "Skipping ${Key}: command requires -Module"
            return
        }
        $command = $command.Replace("{module}", $Module)
    }

    Write-Host "Running ${Key}: $command"
    Invoke-Expression $command
}

if ($All) {
    @(
        "backend_compile",
        "backend_test",
        "module_compile",
        "module_test",
        "frontend_typecheck",
        "frontend_test",
        "frontend_lint"
    ) | ForEach-Object { Invoke-Verification -Key $_ }
} else {
    Invoke-Verification -Key $Name
}
