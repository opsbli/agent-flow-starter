<#
.SYNOPSIS
Run the task-boundary-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.PARAMETER ProjectRoot
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/task-boundary-check.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ProjectRoot = "."
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Normalize-PathText {
    param([string]$Path)
    return ($Path -replace '\\', '/').Trim().Trim([char[]]@([char]0x60, [char]0x27, [char]0x22))
}

function Get-RelativePath {
    param(
        [string]$Root,
        [string]$Path
    )
    $rootUri = [System.Uri](([System.IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'))
    $pathUri = [System.Uri]([System.IO.Path]::GetFullPath($Path))
    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString())
}

function Get-WriteFiles {
    param([string]$TasksPath)
    if (-not (Test-Path -LiteralPath $TasksPath)) {
        return @()
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $TasksPath
    $files = @()
    $inWriteFiles = $false
    foreach ($line in ($text -split "`n")) {
        if ($line -match '^\s*write_files\s*:') {
            $inWriteFiles = $true
            continue
        }
        if ($inWriteFiles -and ($line -match '^\s*##\s+' -or $line -match '^\s*[A-Za-z0-9_-]+\s*:\s*$')) {
            $inWriteFiles = $false
        }
        if ($inWriteFiles -and $line -match '^\s*-\s+(.+)$') {
            $files += (Normalize-PathText $matches[1])
        }
    }
    return $files | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
}

$projectRootPath = Resolve-ProjectPath -Path $ProjectRoot
$changeDirPath = Resolve-ProjectPath -Path $ChangeDir
if (-not (Test-Path -LiteralPath $changeDirPath)) {
    throw "ChangeDir not found: $changeDirPath"
}

$tasksPath = Join-Path $changeDirPath "TASKS.md"
$allowed = @(Get-WriteFiles -TasksPath $tasksPath)
$changeRel = Normalize-PathText (Get-RelativePath -Root $projectRootPath -Path $changeDirPath)

Push-Location $projectRootPath
try {
    git rev-parse --is-inside-work-tree *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "SKIP: task-boundary-check requires a git worktree."
        exit 0
    }

    $changed = @()
    $changed += git diff --name-only
    $changed += git diff --cached --name-only
    $changed += git ls-files --others --exclude-standard
    $changed = $changed | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { Normalize-PathText $_ } | Sort-Object -Unique
} finally {
    Pop-Location
}

$violations = @()
foreach ($file in $changed) {
    if ($file -eq $changeRel -or $file.StartsWith("$changeRel/")) {
        continue
    }

    $matched = $false
    foreach ($entry in $allowed) {
        $entry = Normalize-PathText $entry
        if ($file -eq $entry -or $file.StartsWith($entry.TrimEnd('/') + '/')) {
            $matched = $true
            break
        }
    }

    if (-not $matched) {
        $violations += $file
    }
}

if ($violations.Count -gt 0) {
    Write-Host "Task boundary check failed. Files changed outside TASKS.md write_files:"
    $violations | ForEach-Object { Write-Host " - $_" }
    if ($allowed.Count -eq 0) {
        Write-Host "No write_files entries were found in TASKS.md."
    }
    exit 2
}

Write-Host "Task boundary check passed: changed files are within write_files or the change folder."



