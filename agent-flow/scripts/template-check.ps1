<#
.SYNOPSIS
Validate starter templates and template metadata.

.DESCRIPTION
Checks that required templates, template version metadata, and the artifact
schema exist and contain the sections that downstream gates rely on.

.PARAMETER ProjectRoot
Project root that contains agent-flow/.

.EXAMPLE
agent-flow/scripts/template-check.ps1
#>

param([string]$ProjectRoot = ".")

$ErrorActionPreference = "Stop"

function Resolve-ProjectPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

$root = Resolve-ProjectPath -Path $ProjectRoot
$templateRoot = Join-Path $root "agent-flow/templates"
$schemaPath = Join-Path $root "agent-flow/rules/artifact-schema.json"
$issues = @()

$requiredTemplates = @(
    "STATE.md",
    "CHANGE.md",
    "REQUIREMENT.md",
    "REQUIREMENT_ALIGNED.md",
    "CODE_SCAN.md",
    "DESIGN.md",
    "PLAN.md",
    "TASKS.md",
    "VERIFY.md",
    "REPORT.md",
    "REVIEW.md",
    "AUDIT.md",
    "EVOLUTION.md",
    "ADR.md",
    "VERSION"
)

foreach ($template in $requiredTemplates) {
    if (-not (Test-Path -LiteralPath (Join-Path $templateRoot $template))) {
        $issues += "Missing template file: $template"
    }
}

if (-not (Test-Path -LiteralPath $schemaPath)) {
    $issues += "Missing artifact schema: agent-flow/rules/artifact-schema.json"
} else {
    try {
        $schema = Get-Content -Raw -Encoding utf8 -LiteralPath $schemaPath | ConvertFrom-Json
        if ([string]::IsNullOrWhiteSpace($schema.schemaVersion)) {
            $issues += "artifact-schema.json missing schemaVersion."
        }
        if ($null -eq $schema.artifacts) {
            $issues += "artifact-schema.json missing artifacts map."
        }
    } catch {
        $issues += "artifact-schema.json is not valid JSON: $($_.Exception.Message)"
    }
}

function Require-Text {
    param(
        [string]$TemplateName,
        [string]$Needle
    )
    $path = Join-Path $templateRoot $TemplateName
    if (-not (Test-Path -LiteralPath $path)) { return }
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $path
    if ($text -notmatch [regex]::Escape($Needle)) {
        $script:issues += "$TemplateName missing required text: $Needle"
    }
}

Require-Text -TemplateName "VERIFY.md" -Needle "## AC Evidence"
Require-Text -TemplateName "VERIFY.md" -Needle "## Coverage Summary"
Require-Text -TemplateName "VERIFY.md" -Needle "## Machine Gate Summary"
Require-Text -TemplateName "REQUIREMENT.md" -Needle "AC-01"
Require-Text -TemplateName "REQUIREMENT_ALIGNED.md" -Needle "## Confirmed Acceptance Criteria"
Require-Text -TemplateName "ADR.md" -Needle "Proposed / Accepted / Deprecated / Superseded"
Require-Text -TemplateName "ADR.md" -Needle "## Supersedes"
Require-Text -TemplateName "ADR.md" -Needle "## Superseded By"
Require-Text -TemplateName "EVOLUTION.md" -Needle "Improvement Tracker"

if ($issues.Count -gt 0) {
    Write-Host "Template check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Template check passed."
