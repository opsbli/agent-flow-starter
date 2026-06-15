<#
.SYNOPSIS
Shared helpers for agent-flow gate scripts.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.NOTES
This script does not accept parameters.

.EXAMPLE
agent-flow/scripts/_common.ps1
#>

function Get-FlowLevel {
    param([string]$Dir)

    $change = Join-Path $Dir "CHANGE.md"
    if (-not (Test-Path -LiteralPath $change)) {
        return "Unknown"
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $change
    if ($text -match "(?i)\[x\]\s+Emergency") { return "Emergency" }
    if ($text -match "(?i)\[x\]\s+Heavy") { return "Heavy" }
    if ($text -match "(?i)\[x\]\s+Standard") { return "Standard" }
    if ($text -match "(?i)\[x\]\s+Light") { return "Light" }
    return "Unknown"
}

function Get-RuleList {
    param([string]$Name)

    $path = Join-Path (Split-Path -Parent $PSScriptRoot) "rules/$Name"
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Rule file not found: $path"
    }

    Get-Content -Encoding utf8 -LiteralPath $path |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") }
}

function Test-Meaningful {
    param(
        [string]$Value,
        [string]$InvalidPattern = "(?i)TODO|TBD|path/to|(^|[^A-Za-z])example([^A-Za-z]|$)|\{.+?\}"
    )

    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value -match $InvalidPattern) { return $false }
    return $true
}

function Test-MeaningfulValue {
    param(
        [string]$Value,
        [switch]$AllowSlash
    )

    if (-not (Test-Meaningful -Value $Value -InvalidPattern "(?i)TODO|TBD|pending|\{.+?\}")) { return $false }
    if (-not $AllowSlash -and $Value -match "\s/\s") { return $false }
    return $true
}

function Test-MeaningfulText {
    param([string]$Value)

    return (Test-Meaningful -Value $Value -InvalidPattern "(?i)TODO|TBD|\{.+?\}|not run")
}

function Test-MeaningfulFile {
    param(
        [string]$Path,
        [string[]]$Placeholders = @()
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $Path
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $false
    }

    foreach ($placeholder in $Placeholders) {
        if ($text.Contains($placeholder)) {
            return $false
        }
    }

    return $true
}

