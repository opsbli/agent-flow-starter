<#
.SYNOPSIS
Run the scan-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.PARAMETER ProjectRoot
Parameter accepted by this script.

.PARAMETER Strict
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/scan-check.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ProjectRoot = ".",
    [switch]$Strict
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")

function Resolve-ProjectPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Get-KeyValue {
    param(
        [string]$Text,
        [string]$Key
    )
    $pattern = "(?im)^\s*$([regex]::Escape($Key))\s*:\s*(.+?)\s*$"
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return ""
}

function Normalize-Entry {
    param([string]$Value)
    return ($Value -replace "\\", "/").Trim().Trim([char[]]@([char]0x60, [char]0x27, [char]0x22))
}

function Split-InlineEntries {
    param([string]$Value)
    $Value -split "[,;]" |
        ForEach-Object { Normalize-Entry $_ } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
}

function Get-ListEntries {
    param(
        [string]$Text,
        [string]$Key
    )

    $entries = @()
    $inline = Get-KeyValue -Text $Text -Key $Key
    if (Test-Meaningful -Value $inline) {
        $entries += Split-InlineEntries -Value $inline
    }

    $inSection = $false
    foreach ($line in ($Text -split "\r?\n")) {
        if ($line -match "^\s*$([regex]::Escape($Key))\s*:\s*$") {
            $inSection = $true
            continue
        }
        if ($inSection -and ($line -match "^\s*##\s+" -or $line -match "^\s*[A-Za-z0-9_-]+\s*:\s*$")) {
            $inSection = $false
        }
        if ($inSection -and $line -match "^\s*-\s+(.+?)\s*$") {
            $entries += Normalize-Entry $matches[1]
        }
    }

    $entries | Where-Object {
        $v = $_.Trim()
        $v -and $v -notmatch "^(?i)(none|n/a|na|no-change|no change)$"
    } | Select-Object -Unique
}

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$projectRootPath = Resolve-ProjectPath -Path $ProjectRoot
$scanPath = Join-Path $ChangeDir "CODE_SCAN.md"
if (-not (Test-Path -LiteralPath $scanPath)) {
    Write-Host "Scan check failed:"
    Write-Host " - Missing CODE_SCAN.md"
    exit 2
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $scanPath
$flow = Get-FlowLevel -Dir $ChangeDir
$issues = @()

$required = @(Get-RuleList -Name "code-scan-light.keys")
if ($flow -eq "Standard" -or $flow -eq "Heavy") {
    $required += @(Get-RuleList -Name "code-scan-standard-heavy.keys")
}

foreach ($key in $required) {
    $content = Get-KeyValue -Text $text -Key $key
    if (-not (Test-Meaningful -Value $content)) {
        $issues += "CODE_SCAN.md key '$key' is missing or still empty."
    }
}

foreach ($key in @("read_files", "write_files")) {
    if (($text -notmatch "(?im)^\s*$key\s*:") -and ($text -notmatch "(?im)^##\s+$key\s*$")) {
        $issues += "CODE_SCAN.md must declare $key."
    }
}

if ($Strict) {
    foreach ($file in (Get-ListEntries -Text $text -Key "read_files")) {
        $path = Join-Path $projectRootPath $file
        if (-not (Test-Path -LiteralPath $path)) {
            $issues += "Strict read_files path does not exist: $file"
        }
    }
    foreach ($file in (Get-ListEntries -Text $text -Key "write_files")) {
        $path = Join-Path $projectRootPath $file
        $parent = Split-Path -Parent $path
        if (-not (Test-Path -LiteralPath $path) -and -not (Test-Path -LiteralPath $parent)) {
            $issues += "Strict write_files path or parent does not exist: $file"
        }
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Scan check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

if ($Strict) {
    Write-Host "Scan check passed for $flow change (strict)."
} else {
    Write-Host "Scan check passed for $flow change."
}



