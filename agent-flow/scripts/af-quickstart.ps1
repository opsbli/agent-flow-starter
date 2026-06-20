<#
.SYNOPSIS
Run the shortest useful agent-flow onboarding path.

.DESCRIPTION
Checks the scaffold, initializes manifest context if needed, creates a Light
demo change, and prints one recommended next command.
#>

param(
    [string]$Target = ".",
    [string]$DemoName = "hello-agent-flow",
    [switch]$SkipDemo
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($Target)
if (-not (Test-Path -LiteralPath $root)) {
    throw "Target not found: $root"
}

function Run-Step {
    param(
        [string]$Label,
        [scriptblock]$Action
    )

    Write-Host ""
    Write-Host "== $Label =="
    & $Action
}

function Get-RelativePathCompat {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )

    if ([System.IO.Path].GetMethod("GetRelativePath", [type[]]@([string], [string]))) {
        return [System.IO.Path]::GetRelativePath($BasePath, $TargetPath)
    }

    $baseFull = [System.IO.Path]::GetFullPath($BasePath)
    $targetFull = [System.IO.Path]::GetFullPath($TargetPath)
    if (-not $baseFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $baseFull += [System.IO.Path]::DirectorySeparatorChar
    }
    $baseUri = [System.Uri]::new($baseFull)
    $targetUri = [System.Uri]::new($targetFull)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace("/", [System.IO.Path]::DirectorySeparatorChar)
}

Write-Host "agent-flow quickstart"
Write-Host "Project: $root"

Run-Step "1. scaffold health" {
    $script = Join-Path $root "agent-flow/scripts/scaffold-health.ps1"
    if (-not (Test-Path -LiteralPath $script)) {
        throw "Missing $script. Install agent-flow first."
    }
    & $script
}

Run-Step "2. manifest check" {
    $script = Join-Path $root "agent-flow/scripts/manifest-check.ps1"
    if (-not (Test-Path -LiteralPath $script)) {
        throw "Missing $script. Run init-project after installation."
    }
    & $script
}

$changesRoot = Join-Path $root "agent-flow/changes"
$changeDir = Join-Path $changesRoot $DemoName
if (-not $SkipDemo) {
    Run-Step "3. demo change" {
        $script = Join-Path $root "agent-flow/scripts/new-change.ps1"
        if (-not (Test-Path -LiteralPath $script)) {
            throw "Missing $script."
        }
        $existing = @(
            Get-ChildItem -LiteralPath $changesRoot -Directory -Filter "*$DemoName" -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending
        )
        if ($existing.Count -gt 0) {
            $script:changeDir = $existing[0].FullName
        } else {
            $templateRoot = Join-Path $root "agent-flow/templates"
            & $script -Name $DemoName -Flow Light -ChangesRoot $changesRoot -TemplateRoot $templateRoot -Force
            $created = @(
                Get-ChildItem -LiteralPath $changesRoot -Directory -Filter "*$DemoName" -ErrorAction SilentlyContinue |
                    Sort-Object LastWriteTime -Descending
            )
            if ($created.Count -eq 0) { throw "new-change did not create a directory for $DemoName" }
            $script:changeDir = $created[0].FullName
        }
        $changePath = Join-Path $changeDir "CHANGE.md"
        if (Test-Path -LiteralPath $changePath) {
            @"
# Change: $DemoName

## One-line Requirement
First agent-flow demo change.

## Flow Level

- [x] Light
- [ ] Standard
- [ ] Heavy
- [ ] Emergency

## Classification Reason

Demo only; no production code changes.

## Goal

- Learn the minimum agent-flow loop.

## Non-goals

- No application code changes.

## Impact

- none
"@ | Set-Content -Encoding utf8 -LiteralPath $changePath
        }
        $displayDir = Get-RelativePathCompat -BasePath $root -TargetPath $changeDir
        Write-Host "Demo change ready: $displayDir"
    }
}

$relativeChangeDir = if ($SkipDemo) { "agent-flow/changes/$DemoName" } else { Get-RelativePathCompat -BasePath $root -TargetPath $changeDir }
$nextCommand = if ($SkipDemo) {
    "agent-flow/scripts/new-change.ps1 -Name <change-id> -Flow Standard"
} else {
    "agent-flow/scripts/next-step.ps1 -ChangeDir $relativeChangeDir"
}

Write-Host ""
Write-Host "Recommended next command:"
Write-Host "  $nextCommand"
Write-Host ""
Write-Host "Useful follow-ups:"
Write-Host "  agent-flow/scripts/check-change.ps1 -ChangeDir $relativeChangeDir"
Write-Host "  agent-flow/scripts/dashboard.ps1"
Write-Host "  Get-Content -Raw agent-flow/READING.md"
