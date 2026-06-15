<#
.SYNOPSIS
Run the manifest-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ProjectRoot
Parameter accepted by this script.

.PARAMETER Manifest
Parameter accepted by this script.

.PARAMETER StrictTodo
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/manifest-check.ps1
#>

param(
    [string]$ProjectRoot = ".",
    [string]$Manifest = "agent-flow/manifest.yaml",
    [switch]$StrictTodo
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

$projectRootPath = Resolve-ProjectPath -Path $ProjectRoot
$manifestPath = Join-Path $projectRootPath $Manifest
if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Host "Manifest not found: $manifestPath"
    exit 2
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $manifestPath
$issues = @()
$warnings = @()

function Get-TodoItems {
    param([string]$Text)

    $items = @()
    $lines = $Text -split "\r?\n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($match in [regex]::Matches($lines[$i], "TODO_[A-Z0-9_]+")) {
            $items += [pscustomobject]@{
                Placeholder = $match.Value
                Line = $i + 1
                Text = $lines[$i].Trim()
            }
        }
    }
    return $items
}

function Get-TodoCategory {
    param([string]$Placeholder)

    if ($Placeholder -match "_COMMAND$") { return "verification commands" }
    if ($Placeholder -match "_OR_NONE$") { return "explicit none decisions" }
    if ($Placeholder -match "(_PATH|_ENTRY|_MODULE|_BUILD_FILE|_TEST_PATH|_COMMON_CODE_PATH)$") { return "project map paths" }
    return "review manually"
}

function Write-TodoGuidance {
    param([object[]]$TodoItems)

    if ($TodoItems.Count -eq 0) { return }

    Write-Host ""
    Write-Host "Manifest TODO guidance:"
    foreach ($category in @("project map paths", "verification commands", "explicit none decisions", "review manually")) {
        $group = @($TodoItems | Where-Object { (Get-TodoCategory -Placeholder $_.Placeholder) -eq $category })
        if ($group.Count -eq 0) { continue }
        Write-Host " - ${category}:"
        foreach ($item in $group) {
            Write-Host "   * $($item.Placeholder) at line $($item.Line): $($item.Text)"
        }
    }

    Write-Host "Next steps:"
    Write-Host "  1. Run init-project after the project skeleton and build files exist."
    Write-Host "  2. Replace TODO_* values with concrete paths, commands, or explicit none/N/A."
    Write-Host "  3. Use -StrictTodo in CI only after project context is expected to be fully initialized."
}

foreach ($section in @("project:", "code_map:", "change_storage:", "risk_rules:", "verification:", "gates:")) {
    if ($text -notmatch "(?m)^$([regex]::Escape($section))") {
        $issues += "Missing required section: $section"
    }
}

foreach ($rule in @("heavy_if:", "destructive_gate:", "blocked_if:")) {
    if ($text -notmatch "(?m)^\s+$([regex]::Escape($rule))") {
        $issues += "Missing risk_rules.$($rule.TrimEnd(':'))"
    }
}

$requiredBlocked = @(
    "hard_delete_without_approval",
    "disable_security_filter",
    "bypass_auth_for_production",
    "direct_production_data_mutation",
    "payment_bypass"
)
foreach ($rule in $requiredBlocked) {
    if ($text -notmatch "(?m)^\s+-\s+$([regex]::Escape($rule))(\s+#.*)?\s*$") {
        $issues += "Missing blocked_if rule: $rule"
    }
}

$requiredGates = @(
    "agent-flow/scripts/init-project.ps1",
    "agent-flow/scripts/init-project.sh",
    "agent-flow/scripts/install-agent-flow.ps1",
    "agent-flow/scripts/install-agent-flow.sh",
    "agent-flow/scripts/new-change.ps1",
    "agent-flow/scripts/new-change.sh",
    "agent-flow/scripts/next-step.ps1",
    "agent-flow/scripts/next-step.sh",
    "agent-flow/scripts/sync-state.ps1",
    "agent-flow/scripts/sync-state.sh",
    "agent-flow/scripts/state-check.ps1",
    "agent-flow/scripts/state-check.sh",
    "agent-flow/scripts/design-check.ps1",
    "agent-flow/scripts/design-check.sh",
    "agent-flow/scripts/alignment-check.ps1",
    "agent-flow/scripts/alignment-check.sh",
    "agent-flow/scripts/plan-check.ps1",
    "agent-flow/scripts/plan-check.sh",
    "agent-flow/scripts/scan-check.ps1",
    "agent-flow/scripts/scan-check.sh",
    "agent-flow/scripts/task-check.ps1",
    "agent-flow/scripts/task-check.sh",
    "agent-flow/scripts/task-boundary-check.ps1",
    "agent-flow/scripts/task-boundary-check.sh",
    "agent-flow/scripts/manifest-check.ps1",
    "agent-flow/scripts/manifest-check.sh",
    "agent-flow/scripts/emergency-check.ps1",
    "agent-flow/scripts/emergency-check.sh",
    "agent-flow/scripts/evolution-check.ps1",
    "agent-flow/scripts/evolution-check.sh",
    "agent-flow/scripts/closure-check.ps1",
    "agent-flow/scripts/closure-check.sh",
    "agent-flow/scripts/check-change.ps1",
    "agent-flow/scripts/check-change.sh",
    "agent-flow/scripts/run-verify.ps1",
    "agent-flow/scripts/run-verify.sh",
    "agent-flow/scripts/verify-backend.ps1",
    "agent-flow/scripts/verify-backend.sh",
    "agent-flow/scripts/verify-module.ps1",
    "agent-flow/scripts/verify-module.sh",
    "agent-flow/scripts/ac-check.ps1",
    "agent-flow/scripts/ac-check.sh",
    "agent-flow/scripts/coverage-check.ps1",
    "agent-flow/scripts/coverage-check.sh",
    "agent-flow/scripts/code-drift-check.ps1",
    "agent-flow/scripts/code-drift-check.sh",
    "agent-flow/scripts/blocked-check.ps1",
    "agent-flow/scripts/blocked-check.sh",
    "agent-flow/scripts/template-check.ps1",
    "agent-flow/scripts/template-check.sh",
    "agent-flow/scripts/knowledge-search.ps1",
    "agent-flow/scripts/knowledge-search.sh",
    "agent-flow/scripts/drift-check.ps1",
    "agent-flow/scripts/drift-check.sh",
    "agent-flow/scripts/scaffold-health.ps1",
    "agent-flow/scripts/scaffold-health.sh"
)

$gateRulesPath = Join-Path $projectRootPath "agent-flow/rules/gates.txt"
if (Test-Path -LiteralPath $gateRulesPath) {
    $requiredGates = @(
        Get-Content -Encoding utf8 -LiteralPath $gateRulesPath |
            ForEach-Object { $_.Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") }
    )
} else {
    $warnings += "agent-flow/rules/gates.txt not found; using built-in gate list."
}

foreach ($gate in $requiredGates) {
    if ($text -notmatch "(?m)^\s+-\s+$([regex]::Escape($gate))\s*$") {
        $issues += "Missing gate entry: $gate"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $projectRootPath $gate))) {
        $issues += "Gate file does not exist: $gate"
    }
}

$todoItems = @(Get-TodoItems -Text $text)
$todoCount = $todoItems.Count
if ($todoCount -gt 0) {
    $message = "Manifest has $todoCount unresolved TODO_ value(s)."
    if ($StrictTodo) { $issues += $message } else { $warnings += $message }
}

if ($warnings.Count -gt 0) {
    Write-Host "Manifest warnings:"
    $warnings | ForEach-Object { Write-Host " - $_" }
}

if ($issues.Count -gt 0) {
    Write-Host "Manifest check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    Write-TodoGuidance -TodoItems $todoItems
    exit 2
}

Write-TodoGuidance -TodoItems $todoItems
Write-Host "Manifest check passed."



