<#
.SYNOPSIS
Verify that required agent-flow scaffold files exist.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.NOTES
This script does not accept parameters.

.EXAMPLE
agent-flow/scripts/scaffold-health.ps1
#>

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

$required = @(
    "agent-flow/GO.md",
    "agent-flow/FAQ.md",
    "agent-flow/READING.md",
    "agent-flow/manifest.yaml",
    "agent-flow/project-profiles.json",
    "agent-flow/rules/gates.txt",
    "agent-flow/rules/artifact-schema.json",
    "agent-flow/rules/code-scan-light.keys",
    "agent-flow/rules/code-scan-standard-heavy.keys",
    "agent-flow/rules/design-decision.keys",
    "agent-flow/rules/design-alignment.questions",
    "agent-flow/rules/gate-tiers.md",
    "agent-flow/rules/plan-required.keys",
    "agent-flow/rules/plan-audit.keys",
    "agent-flow/rules/evolution.keys",
    "agent-flow/rules/closure-heavy-gates.keys",
    "agent-flow/core/principles.md",
    "agent-flow/core/source-of-truth.md",
    "agent-flow/core/autonomy-policy.md",
    "agent-flow/core/router.md",
    "agent-flow/core/code-first-context.md",
    "agent-flow/core/memory.md",
    "agent-flow/core/plan-guide.md",
    "agent-flow/core/audit.md",
    "agent-flow/core/logging.md",
    "agent-flow/core/evolution.md",
    "agent-flow/flows/light.md",
    "agent-flow/flows/standard.md",
    "agent-flow/flows/heavy.md",
    "agent-flow/flows/emergency.md",
    "agent-flow/templates/STATE.md",
    "agent-flow/templates/CHANGE.md",
    "agent-flow/templates/REQUIREMENT.md",
    "agent-flow/templates/REQUIREMENT_ALIGNED.md",
    "agent-flow/templates/CODE_SCAN.md",
    "agent-flow/templates/DESIGN.md",
    "agent-flow/templates/PLAN.md",
    "agent-flow/templates/TASKS.md",
    "agent-flow/templates/VERIFY.md",
    "agent-flow/templates/REPORT.md",
    "agent-flow/templates/REVIEW.md",
    "agent-flow/templates/AUDIT.md",
    "agent-flow/templates/LOG_ENTRY.md",
    "agent-flow/templates/INIT_CHECKLIST.md",
    "agent-flow/templates/CANCEL.md",
    "agent-flow/templates/ROLLBACK.md",
    "agent-flow/templates/VERSION",
    "agent-flow/knowledge/INDEX.md",
    "agent-flow/knowledge/improvement-tracker.md",
    "agent-flow/knowledge/known-good-baselines.md",
    "agent-flow/decisions/INDEX.md",
    "agent-flow/decisions/README.md",
    "agent-flow/VERSION",
    "agent-flow/UPGRADE.md",
    "agent-flow/scripts/_common.ps1",
    "agent-flow/scripts/_common.sh",
    "agent-flow/test/README.md",
    "agent-flow/test/fixtures/minimal-project/README.md",
    "agent-flow/test/test-scripts/test-new-change.ps1",
    "agent-flow/test/test-scripts/test-new-change.sh",
    "agent-flow/test/test-scripts/test-next-step.ps1",
    "agent-flow/test/test-scripts/test-next-step.sh",
    "agent-flow/test/test-scripts/test-gate-smoke.ps1",
    "agent-flow/test/test-scripts/test-gate-smoke.sh",
    "agent-flow/test/test-scripts/test-check-change.ps1",
    "agent-flow/test/test-scripts/test-check-change.sh"
)

$gateRulesPath = Join-Path $projectRoot "agent-flow/rules/gates.txt"
if (-not (Test-Path -LiteralPath $gateRulesPath)) {
    Write-Host "Missing scaffold files:"
    Write-Host " - agent-flow/rules/gates.txt"
    exit 2
}

$gateScripts = @(
    Get-Content -Encoding utf8 -LiteralPath $gateRulesPath |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") }
)

$required = @($required + $gateScripts | Sort-Object -Unique)

$missing = @()
foreach ($file in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $file))) {
        $missing += $file
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Missing scaffold files:"
    $missing | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "agent-flow scaffold health check passed."

# --- Manifest Completeness Advisory (non-blocking) ---
$manifest = Join-Path $projectRoot "agent-flow/manifest.yaml"
if (Test-Path -LiteralPath $manifest) {
  $content = Get-Content -Raw -LiteralPath $manifest
  $unknownCount = ([regex]::Matches($content, ':\s*(unknown|TODO|TBD)\s*$')).Count
  $noneCount = ([regex]::Matches($content, ':\s*none\s*$')).Count
  $initializedCount = ([regex]::Matches($content, 'kind:\s*initialized')).Count
  $totalFields = ([regex]::Matches($content, '(?m)^\s+[a-z_]+:')).Count

  if ($initializedCount -gt 0) {
    Write-Host "!  Manifest completeness: project.kind is still 'initialized'."
    Write-Host "   Run 'agent-flow/scripts/init-project.ps1' to auto-detect your project type."
  }

  if ($unknownCount -gt 0 -or $noneCount -gt 5) {
    $pct = 0
    if ($totalFields -gt 0) {
      $pct = [Math]::Round(($unknownCount + $noneCount) * 100.0 / $totalFields, 0)
    }
    Write-Host "!  Manifest completeness: $unknownCount unknown/TODO + $noneCount none fields ($pct% of $totalFields fields)"
    Write-Host "   Fill in backend/frontend/database sections for accurate risk routing."
    Write-Host "   Unknown fields cause design-check and code-drift-check to skip context-aware validation."
  }
}


