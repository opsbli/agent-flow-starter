param(
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [string]$StarterRoot,
    [switch]$Force
)

<#
.SYNOPSIS
Install or upgrade agent-flow scaffold into a target project.

.DESCRIPTION
Copies starter-owned files (core/, flows/, templates/, scripts/, rules/, test/, README.md,
UPGRADE.md, VERSION) into the target project's agent-flow/ directory.
Preserves project-owned files (changes/, logs/, reports/, knowledge/, decisions/)
by default.

.PARAMETER Target
Path to the target project root directory.

.PARAMETER StarterRoot
Path to agent-flow-starter root. Defaults to the parent of this script's directory.

.PARAMETER Force
Overwrite project-local customizations in starter-owned files without prompting.

.EXAMPLE
.\install-agent-flow.ps1 -Target "C:\Projects\my-app"

.EXAMPLE
.\install-agent-flow.ps1 -Target "C:\Projects\my-app" -StarterRoot "C:\agent-flow-starter" -Force
#>

$ErrorActionPreference = "Stop"

# Resolve starter root
if (-not $StarterRoot) {
    $StarterRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}
$StarterRoot = [System.IO.Path]::GetFullPath($StarterRoot)
if (-not (Test-Path -LiteralPath $StarterRoot)) {
    throw "Starter root not found: $StarterRoot"
}
if (-not (Test-Path -LiteralPath (Join-Path $StarterRoot "agent-flow"))) {
    throw "Starter root does not contain agent-flow/ directory: $StarterRoot"
}

# Resolve target
$Target = [System.IO.Path]::GetFullPath($Target)
if (-not (Test-Path -LiteralPath $Target)) {
    throw "Target project not found: $Target"
}

$targetAf = Join-Path $Target "agent-flow"
$sourceAf = Join-Path $StarterRoot "agent-flow"

Write-Host "Installing agent-flow from: $sourceAf"
Write-Host "Target project: $Target"
Write-Host ""

# --- Starter-owned: always overwrite ---
$starterOwned = @(
    "core",
    "flows",
    "templates",
    "scripts",
    "rules",
    "test",
    "README.md",
    "UPGRADE.md",
    "VERSION",
    "ADVANTAGES.md",
    "GO.md",
    "manifest.yaml"
)

# --- Project-owned: skip if exist ---
$projectOwned = @(
    "changes",
    "logs",
    "reports",
    "knowledge",
    "decisions"
)

# --- Merge manifest.yaml ---
function Merge-Manifest {
    param(
        [string]$SourceManifest,
        [string]$TargetManifest
    )

    if (-not (Test-Path -LiteralPath $TargetManifest)) {
        Copy-Item -LiteralPath $SourceManifest -Destination $TargetManifest
        Write-Host "  Created manifest.yaml (new)"
        return
    }

    if (-not $Force) {
        Write-Host "  manifest.yaml exists, checking for TODO_ values..."
        $targetText = Get-Content -Raw -Encoding utf8 -LiteralPath $TargetManifest
        $todoCount = [regex]::Matches($targetText, "TODO_").Count
        if ($todoCount -gt 0) {
            Write-Host "  WARNING: manifest.yaml has $todoCount unresolved TODO_ values."
            Write-Host "  Re-run init-project.ps1 to resolve them after install."
        }

        # If manifest has been filled in, preserve it by replacing only the version info
        Write-Host "  Preserving existing manifest.yaml (use -Force to overwrite)"
        return
    }

    Copy-Item -LiteralPath $SourceManifest -Destination $TargetManifest -Force
    Write-Host "  Overwrote manifest.yaml (-Force)"
}

# --- Ensure target agent-flow/ exists ---
if (-not (Test-Path -LiteralPath $targetAf)) {
    New-Item -ItemType Directory -Force -Path $targetAf | Out-Null
    Write-Host "Created agent-flow/ in target project"
}

# --- Copy starter-owned files ---
Write-Host ""
Write-Host "=== Installing starter-owned files ==="
foreach ($item in $starterOwned) {
    $sourcePath = Join-Path $sourceAf $item
    $targetPath = Join-Path $targetAf $item

    if (-not (Test-Path -LiteralPath $sourcePath)) {
        Write-Host "  SKIP (not found in starter): $item"
        continue
    }

    if ($item -eq "manifest.yaml") {
        Merge-Manifest -SourceManifest $sourcePath -TargetManifest $targetPath
        continue
    }

    $isDir = Test-Path -LiteralPath $sourcePath -PathType Container
    if ($isDir) {
        if (-not (Test-Path -LiteralPath $targetPath)) {
            New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
        }
        Get-ChildItem -LiteralPath $sourcePath -Recurse -File | ForEach-Object {
            $relPath = $_.FullName.Substring($sourcePath.Length + 1)
            if ($item -eq "test" -and $relPath -match "^(fixtures[\\/])") {
                return
            }
            $dest = Join-Path $targetPath $relPath
            $destDir = Split-Path -Parent $dest
            if (-not (Test-Path -LiteralPath $destDir)) {
                New-Item -ItemType Directory -Force -Path $destDir | Out-Null
            }
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
        }
        Write-Host "  UPDATED: $item/"
    } else {
        Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
        Write-Host "  UPDATED: $item"
    }
}

# --- Install CI workflow template ---
Write-Host ""
Write-Host "=== CI workflow ==="
$sourceCi = Join-Path $StarterRoot ".github/workflows/scaffold-ci.yml"
if (Test-Path -LiteralPath $sourceCi) {
    $targetCiDir = Join-Path $Target ".github/workflows"
    New-Item -ItemType Directory -Force -Path $targetCiDir | Out-Null
    Copy-Item -LiteralPath $sourceCi -Destination (Join-Path $targetCiDir "scaffold-ci.yml") -Force
    Write-Host "  UPDATED: .github/workflows/scaffold-ci.yml"
} else {
    Write-Host "  SKIP: starter has no .github/workflows/scaffold-ci.yml"
}

# --- Preserve project-owned files ---
Write-Host ""
Write-Host "=== Preserving project-owned files ==="
foreach ($item in $projectOwned) {
    $path = Join-Path $targetAf $item
    if (Test-Path -LiteralPath $path) {
        Write-Host "  PRESERVED: $item/"
    } else {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
        # Add .gitkeep in new project-owned directories
        $gitkeep = Join-Path $path ".gitkeep"
        if (-not (Test-Path -LiteralPath $gitkeep)) {
            Set-Content -LiteralPath $gitkeep -Value "" -Encoding utf8
        }
        Write-Host "  CREATED: $item/"
    }
}

# --- Install AGENTS.md block ---
Write-Host ""
Write-Host "=== AGENTS.md ==="
$agentsMd = Join-Path $Target "AGENTS.md"
$agentsTemplate = Join-Path $sourceAf "templates/AGENTS.md"

if (Test-Path -LiteralPath $agentsMd) {
    $agentsContent = Get-Content -Raw -Encoding utf8 -LiteralPath $agentsMd
    if ($agentsContent -match "<!-- agent-flow:start -->") {
        Write-Host "  AGENTS.md already has agent-flow block (preserved)"
    } else {
        $templateContent = Get-Content -Raw -Encoding utf8 -LiteralPath $agentsTemplate
        $addContent = "`n`n" + $templateContent
        Add-Content -LiteralPath $agentsMd -Value $addContent -Encoding utf8
        Write-Host "  Appended agent-flow block to AGENTS.md"
    }
} else {
    Copy-Item -LiteralPath $agentsTemplate -Destination $agentsMd
    Write-Host "  Created AGENTS.md from template"
}

# --- Done ---
Write-Host ""
Write-Host "=== Install complete ==="
Write-Host "From: $sourceAf"
Write-Host "To:   $targetAf"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  cd $Target"
Write-Host "  agent-flow/scripts/scaffold-health.ps1"
Write-Host "  agent-flow/scripts/init-project.ps1"
Write-Host ""
Write-Host "If you customized starter-owned files (core/, flows/, etc.),"
Write-Host "record those decisions in agent-flow/decisions/ before re-running install."
