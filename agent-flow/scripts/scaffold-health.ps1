$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

$required = @(
    "agent-flow/GO.md",
    "agent-flow/manifest.yaml",
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
    "agent-flow/templates/CHANGE.md",
    "agent-flow/templates/REQUIREMENT.md",
    "agent-flow/templates/CODE_SCAN.md",
    "agent-flow/templates/DESIGN.md",
    "agent-flow/templates/PLAN.md",
    "agent-flow/templates/TASKS.md",
    "agent-flow/templates/VERIFY.md",
    "agent-flow/templates/REPORT.md",
    "agent-flow/templates/AUDIT.md",
    "agent-flow/templates/LOG_ENTRY.md",
    "agent-flow/templates/INIT_CHECKLIST.md",
    "agent-flow/knowledge/known-good-baselines.md",
    "agent-flow/VERSION",
    "agent-flow/UPGRADE.md",
    "agent-flow/scripts/init-project.ps1",
    "agent-flow/scripts/init-project.sh",
    "agent-flow/scripts/verify-backend.ps1",
    "agent-flow/scripts/verify-module.ps1",
    "agent-flow/scripts/run-verify.ps1",
    "agent-flow/scripts/next-step.ps1",
    "agent-flow/scripts/ac-check.ps1",
    "agent-flow/scripts/drift-check.ps1",
    "agent-flow/scripts/scaffold-health.ps1",
    "agent-flow/scripts/verify-backend.sh",
    "agent-flow/scripts/verify-module.sh",
    "agent-flow/scripts/run-verify.sh",
    "agent-flow/scripts/next-step.sh",
    "agent-flow/scripts/ac-check.sh",
    "agent-flow/scripts/drift-check.sh",
    "agent-flow/scripts/scaffold-health.sh"
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
