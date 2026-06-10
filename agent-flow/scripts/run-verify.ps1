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

function Get-VerificationCommand {
    param([string]$Key)

    $pattern = "(?m)^\s+$([regex]::Escape($Key)):\s*(.+?)\s*$"
    $match = [regex]::Match($manifestText, $pattern)
    if (-not $match.Success) {
        return $null
    }

    $command = $match.Groups[1].Value.Trim().Trim("'").Trim('"')
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
