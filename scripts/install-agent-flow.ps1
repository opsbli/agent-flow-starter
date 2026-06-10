param(
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$starterRoot = Split-Path -Parent $PSScriptRoot
$sourceFlow = Join-Path $starterRoot "agent-flow"

if (-not (Test-Path -LiteralPath $sourceFlow)) {
    throw "agent-flow source not found: $sourceFlow"
}

$targetRoot = [System.IO.Path]::GetFullPath($Target)
New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null

$targetFlow = Join-Path $targetRoot "agent-flow"
$preserveDirs = @("changes", "logs", "reports", "knowledge", "decisions")
$backupRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agent-flow-install-" + [guid]::NewGuid().ToString("N"))

if (Test-Path -LiteralPath $targetFlow) {
    New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
    foreach ($dir in $preserveDirs) {
        $from = Join-Path $targetFlow $dir
        if (Test-Path -LiteralPath $from) {
            Copy-Item -LiteralPath $from -Destination (Join-Path $backupRoot $dir) -Recurse -Force
        }
    }

    Remove-Item -LiteralPath $targetFlow -Recurse -Force
}

Copy-Item -LiteralPath $sourceFlow -Destination $targetFlow -Recurse -Force

$sourceCi = Join-Path $starterRoot ".github/workflows/scaffold-ci.yml"
if (Test-Path -LiteralPath $sourceCi) {
    $targetCiDir = Join-Path $targetRoot ".github/workflows"
    New-Item -ItemType Directory -Force -Path $targetCiDir | Out-Null
    Copy-Item -LiteralPath $sourceCi -Destination (Join-Path $targetCiDir "scaffold-ci.yml") -Force
}

if (Test-Path -LiteralPath $backupRoot) {
    foreach ($dir in $preserveDirs) {
        $from = Join-Path $backupRoot $dir
        if (Test-Path -LiteralPath $from) {
            Remove-Item -LiteralPath (Join-Path $targetFlow $dir) -Recurse -Force -ErrorAction SilentlyContinue
            Copy-Item -LiteralPath $from -Destination (Join-Path $targetFlow $dir) -Recurse -Force
        }
    }

    Remove-Item -LiteralPath $backupRoot -Recurse -Force -ErrorAction SilentlyContinue
}

$projectName = Split-Path -Leaf $targetRoot
$agentsTemplate = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $sourceFlow "templates/AGENTS.md")
$agentBlock = $agentsTemplate.Replace("{project-name}", $projectName)
$agentsPath = Join-Path $targetRoot "AGENTS.md"

if (Test-Path -LiteralPath $agentsPath) {
    $existing = Get-Content -Raw -Encoding utf8 -LiteralPath $agentsPath
    $pattern = "(?s)<!-- agent-flow:start -->.*?<!-- agent-flow:end -->"
    if ($existing -match $pattern) {
        $newContent = [regex]::Replace($existing, $pattern, ($agentBlock -replace "^[\s\S]*?(<!-- agent-flow:start -->)", '$1'))
    } else {
        $newContent = $existing.TrimEnd() + "`r`n`r`n" + $agentBlock + "`r`n"
    }
} else {
    $newContent = $agentBlock + "`r`n"
}

Set-Content -Encoding utf8 -LiteralPath $agentsPath -Value $newContent

& (Join-Path $targetFlow "scripts/scaffold-health.ps1")

Write-Host "agent-flow installed into $targetRoot"
Write-Host "Next: run agent-flow/scripts/init-project.ps1 in the target project, then review TODO values."
