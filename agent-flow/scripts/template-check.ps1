<#
.SYNOPSIS
Validate templates against artifact-schema.json — dynamically reads rules from schema.

.DESCRIPTION
Checks that required templates exist, the artifact schema is valid JSON,
and each artifact's required sections, text patterns, and machine-check keys
match the template content.

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
    "STATE.md", "CHANGE.md", "REQUIREMENT.md", "REQUIREMENT_ALIGNED.md",
    "CODE_SCAN.md", "DESIGN.md", "PLAN.md", "TASKS.md", "VERIFY.md",
    "REPORT.md", "REVIEW.md", "AUDIT.md", "EVOLUTION.md",
    "ADR.md", "CANCEL.md", "ROLLBACK.md", "INIT_CHECKLIST.md", "LOG_ENTRY.md",
    "VERSION"
)

foreach ($template in $requiredTemplates) {
    if (-not (Test-Path -LiteralPath (Join-Path $templateRoot $template))) {
        $issues += "Missing template file: $template"
    }
}

# Validate schema and dynamically check artifacts
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
        } else {
            # Dynamically validate each artifact defined in the schema
            foreach ($artifact in $schema.artifacts.PSObject.Properties) {
                $name = $artifact.Name
                $tplPath = Join-Path $templateRoot $name
                if (-not (Test-Path -LiteralPath $tplPath)) { continue }

                # Check requiredSections
                if ($artifact.Value.requiredSections) {
                    $content = Get-Content -Raw -Encoding utf8 -LiteralPath $tplPath
                    foreach ($section in $artifact.Value.requiredSections) {
                        if ($content -notmatch "(?m)^##\s+$([regex]::Escape($section))") {
                            $issues += "$name missing required section: $section"
                        }
                    }
                }

                # Check requiredText
                if ($artifact.Value.requiredText) {
                    $content = Get-Content -Raw -Encoding utf8 -LiteralPath $tplPath
                    foreach ($text in $artifact.Value.requiredText) {
                        if ($content -notmatch [regex]::Escape($text)) {
                            $issues += "$name missing required text: $text"
                        }
                    }
                }

                # Check machineCheckKeys
                if ($artifact.Value.machineCheckKeys) {
                    $content = Get-Content -Raw -Encoding utf8 -LiteralPath $tplPath
                    foreach ($key in $artifact.Value.machineCheckKeys) {
                        if ($content -notmatch "(?m)^$([regex]::Escape($key)):") {
                            $issues += "$name missing machine-check key: $key"
                        }
                    }
                }
            }
        }
    } catch {
        $issues += "artifact-schema.json is not valid JSON: $($_.Exception.Message)"
    }
}

# Check template VERSION matches schemaVersion
$tplVersionPath = Join-Path $templateRoot "VERSION"
$schemaVersionPath = Join-Path $root "agent-flow/rules/artifact-schema.json"
if ((Test-Path -LiteralPath $tplVersionPath) -and (Test-Path -LiteralPath $schemaVersionPath)) {
    $tv = (Get-Content -Raw -Encoding utf8 -LiteralPath $tplVersionPath).Trim()
    $schemaCheck = Get-Content -Raw -Encoding utf8 -LiteralPath $schemaVersionPath | ConvertFrom-Json
    $sv = "$($schemaCheck.schemaVersion)"
    if ($tv -ne $sv) {
        $issues += "Template VERSION ($tv) does not match artifact-schema.json schemaVersion ($sv)."
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Template check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Template check passed."
