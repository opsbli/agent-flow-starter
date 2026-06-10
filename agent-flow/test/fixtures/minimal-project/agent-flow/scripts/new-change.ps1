param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [ValidateSet("Light", "Standard", "Heavy")]
    [string]$Flow = "Standard",
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

$changeId = Get-Slug -Value $Name
$changeDir = Join-Path $ChangesRoot $changeId

if ((Test-Path -LiteralPath $changeDir) -and -not $Force) {
    throw "Change already exists: $changeDir. Use -Force to overwrite template files."
}

New-Item -ItemType Directory -Force -Path $changeDir | Out-Null

$filesByFlow = @{
    Light = @("STATE.md", "CHANGE.md", "CODE_SCAN.md", "VERIFY.md", "REPORT.md")
    Standard = @("STATE.md", "CHANGE.md", "REQUIREMENT.md", "CODE_SCAN.md", "DESIGN.md", "TASKS.md", "VERIFY.md", "REPORT.md", "EVOLUTION.md")
    Heavy = @("STATE.md", "CHANGE.md", "REQUIREMENT.md", "CODE_SCAN.md", "DESIGN.md", "PLAN.md", "TASKS.md", "VERIFY.md", "REVIEW.md", "REPORT.md", "AUDIT.md", "EVOLUTION.md")
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
    }
    Set-Content -Encoding utf8 -LiteralPath $target -Value $text
}

Write-Host "Created agent-flow change: $changeDir"
Write-Host "Flow: $Flow"
Write-Host "Next: agent-flow/scripts/next-step.ps1 -ChangeDir $changeDir"
