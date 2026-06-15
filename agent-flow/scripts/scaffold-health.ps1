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
    "agent-flow/scripts/init-project.ps1",
    "agent-flow/scripts/init-project.sh",
    "agent-flow/scripts/_common.ps1",
    "agent-flow/scripts/_common.sh",
    "agent-flow/scripts/run-verify.ps1",
    "agent-flow/scripts/new-change.ps1",
    "agent-flow/scripts/next-step.ps1",
    "agent-flow/scripts/sync-state.ps1",
    "agent-flow/scripts/state-check.ps1",
    "agent-flow/scripts/design-check.ps1",
    "agent-flow/scripts/alignment-check.ps1",
    "agent-flow/scripts/plan-check.ps1",
    "agent-flow/scripts/scan-check.ps1",
    "agent-flow/scripts/task-check.ps1",
    "agent-flow/scripts/task-boundary-check.ps1",
    "agent-flow/scripts/manifest-check.ps1",
    "agent-flow/scripts/emergency-check.ps1",
    "agent-flow/scripts/evolution-check.ps1",
    "agent-flow/scripts/closure-check.ps1",
    "agent-flow/scripts/check-change.ps1",
    "agent-flow/scripts/ac-check.ps1",
    "agent-flow/scripts/coverage-check.ps1",
    "agent-flow/scripts/template-check.ps1",
    "agent-flow/scripts/knowledge-search.ps1",
    "agent-flow/scripts/drift-check.ps1",
    "agent-flow/scripts/scaffold-health.ps1",
    "agent-flow/scripts/run-verify.sh",
    "agent-flow/scripts/new-change.sh",
    "agent-flow/scripts/next-step.sh",
    "agent-flow/scripts/sync-state.sh",
    "agent-flow/scripts/state-check.sh",
    "agent-flow/scripts/design-check.sh",
    "agent-flow/scripts/alignment-check.sh",
    "agent-flow/scripts/plan-check.sh",
    "agent-flow/scripts/scan-check.sh",
    "agent-flow/scripts/task-check.sh",
    "agent-flow/scripts/task-boundary-check.sh",
    "agent-flow/scripts/manifest-check.sh",
    "agent-flow/scripts/emergency-check.sh",
    "agent-flow/scripts/evolution-check.sh",
    "agent-flow/scripts/closure-check.sh",
    "agent-flow/scripts/check-change.sh",
    "agent-flow/scripts/ac-check.sh",
    "agent-flow/scripts/coverage-check.sh",
    "agent-flow/scripts/template-check.sh",
    "agent-flow/scripts/knowledge-search.sh",
    "agent-flow/scripts/drift-check.sh",
    "agent-flow/scripts/scaffold-health.sh",
    "agent-flow/scripts/install-agent-flow.ps1",
    "agent-flow/scripts/install-agent-flow.sh",
    "agent-flow/scripts/code-drift-check.ps1",
    "agent-flow/scripts/code-drift-check.sh",
    "agent-flow/scripts/blocked-check.ps1",
    "agent-flow/scripts/blocked-check.sh",
    "agent-flow/test/README.md",
    "agent-flow/test/fixtures/minimal-project/README.md",
    "agent-flow/test/test-scripts/test-new-change.ps1",
    "agent-flow/test/test-scripts/test-new-change.sh",
    "agent-flow/test/test-scripts/test-next-step.ps1",
    "agent-flow/test/test-scripts/test-next-step.sh"
)

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


