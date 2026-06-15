<#
.SYNOPSIS
Run the new-change agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER Name
Parameter accepted by this script.

.PARAMETER Flow
Parameter accepted by this script.

.PARAMETER ChangesRoot
Parameter accepted by this script.

.PARAMETER TemplateRoot
Parameter accepted by this script.

.PARAMETER Force
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/new-change.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [ValidateSet("Light", "Standard", "Heavy", "Emergency")]
    [string]$Flow = "Standard",
    [string]$Prefix = "",
    [string]$ChangesRoot = "agent-flow/changes",
    [string]$TemplateRoot = "agent-flow/templates",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Get-Slug {
    param([string]$Value)
    $slug = $Value.Trim().ToLowerInvariant()
    $slug = [regex]::Replace($slug, "[\s_]+", "-")
    $slug = [regex]::Replace($slug, "[^a-z0-9-]", "")
    $slug = [regex]::Replace($slug, "-{2,}", "-").Trim("-")
    if ([string]::IsNullOrWhiteSpace($slug)) {
        throw "Name must contain at least one ASCII letter or number."
    }
    return $slug
}

# Auto-prefix: detect from manifest.yaml if not provided
if ([string]::IsNullOrWhiteSpace($Prefix)) {
    $flowRoot = Split-Path $ChangesRoot -Parent
    if ([string]::IsNullOrWhiteSpace($flowRoot)) {
        $flowRoot = "agent-flow"
    }
    $manifest = Join-Path $flowRoot "manifest.yaml"
    if (Test-Path $manifest) {
        $m = Get-Content $manifest -Raw -Encoding utf8 -ErrorAction SilentlyContinue
        if ($m -match 'name:\s*(\S+)') { $Prefix = $Matches[1] }
    }
}

$datePrefix = Get-Date -Format 'yyyyMMdd'
$slugName = Get-Slug -Value $Name
$changeId = if ($Prefix) { "$datePrefix-$Prefix-$slugName" } else { "$datePrefix-$slugName" }
$changeDir = Join-Path $ChangesRoot $changeId

if ((Test-Path -LiteralPath $changeDir) -and -not $Force) {
    throw "Change already exists: $changeDir. Use -Force to overwrite template files."
}

New-Item -ItemType Directory -Force -Path $changeDir | Out-Null

Write-Host ""
Write-Host "Created change: $changeId"
Write-Host "   Flow level: $Flow"
Write-Host ""

$filesByFlow = @{
    Light = @("STATE.md", "CHANGE.md", "CODE_SCAN.md", "VERIFY.md", "REPORT.md")
    Standard = @("STATE.md", "CHANGE.md", "REQUIREMENT.md", "CODE_SCAN.md", "DESIGN.md", "TASKS.md", "VERIFY.md", "REPORT.md", "EVOLUTION.md")
    Heavy = @("STATE.md", "CHANGE.md", "REQUIREMENT.md", "CODE_SCAN.md", "DESIGN.md", "PLAN.md", "TASKS.md", "VERIFY.md", "REVIEW.md", "REPORT.md", "AUDIT.md", "EVOLUTION.md")
    Emergency = @("STATE.md", "CHANGE.md", "CODE_SCAN.md", "TASKS.md", "VERIFY.md", "REPORT.md", "EVOLUTION.md")
}

foreach ($file in $filesByFlow[$Flow]) {
    $source = Join-Path $TemplateRoot $file
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Template not found: $source"
    }

    $target = Join-Path $changeDir $file
    if ((Test-Path -LiteralPath $target) -and -not $Force) {
        continue
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $source
    $text = $text.Replace("{change-id}", $changeId)
    $text = $text.Replace("{flow}", $Flow)
    $text = $text.Replace("{frontend-path}", "TODO_FRONTEND_PATH_OR_NONE")
    if ($file -eq "CHANGE.md") {
        $text = $text -replace "- \[ \] Light", ("- [{0}] Light" -f ($(if ($Flow -eq "Light") { "x" } else { " " })))
        $text = $text -replace "- \[ \] Standard", ("- [{0}] Standard" -f ($(if ($Flow -eq "Standard") { "x" } else { " " })))
        $text = $text -replace "- \[ \] Heavy", ("- [{0}] Heavy" -f ($(if ($Flow -eq "Heavy") { "x" } else { " " })))
        $text = $text -replace "- \[ \] Emergency", ("- [{0}] Emergency" -f ($(if ($Flow -eq "Emergency") { "x" } else { " " })))
    }
    Set-Content -Encoding utf8 -LiteralPath $target -Value $text
}

Write-Host "Created agent-flow change: $changeDir"
Write-Host "Flow: $Flow"
Write-Host "Next: agent-flow/scripts/next-step.ps1 -ChangeDir $changeDir"



