<#
.SYNOPSIS
Run the plan-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/plan-check.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

function Get-Section {
    param(
        [string]$Text,
        [string]$Heading
    )

    $pattern = '(?ims)^\s*##\s+' + [regex]::Escape($Heading) + '\s*$([\s\S]*?)(?=^\s*##\s+|\z)'
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) { return $match.Groups[1].Value }
    return ""
}

$flow = Get-FlowLevel -Dir $ChangeDir
if ($flow -ne "Heavy") {
    Write-Host "SKIP: plan-check is only required for Heavy changes."
    exit 0
}

$plan = Join-Path $ChangeDir "PLAN.md"
$audit = Join-Path $ChangeDir "AUDIT.md"
if (-not (Test-Path -LiteralPath $plan)) { throw "PLAN.md not found in $ChangeDir" }
if (-not (Test-Path -LiteralPath $audit)) { throw "AUDIT.md not found in $ChangeDir" }

$planText = Get-Content -Raw -Encoding utf8 -LiteralPath $plan
$auditText = Get-Content -Raw -Encoding utf8 -LiteralPath $audit
$issues = @()

foreach ($key in Get-RuleList -Name "plan-required.keys") {
    if ($planText -notmatch [regex]::Escape($key)) {
        $issues += "PLAN.md missing required key or section: $key"
    }
}

if ($planText -match "(?i)\{.+?\}|TODO|TBD") {
    $issues += "PLAN.md still contains placeholders."
}

$status = [regex]::Match($planText, "(?im)^\s*>?\s*Plan Status:\s*([A-Za-z-]+)\s*$")
if (-not $status.Success) {
    $issues += "PLAN.md missing Plan Status."
} elseif ($status.Groups[1].Value.ToLowerInvariant() -notin @("planned", "in-progress", "completed", "superseded", "deferred")) {
    $issues += "Plan Status must be planned/in-progress/completed/superseded/deferred before Plan Audit passes."
}

$planAudit = Get-Section -Text $auditText -Heading "Plan Audit"
if (-not (Test-MeaningfulText -Value $planAudit)) {
    $issues += "AUDIT.md missing meaningful Plan Audit section."
} else {
    $verdict = [regex]::Match($planAudit, "(?im)^\s*Verdict:\s*(accept|conditional)\s*$")
    if (-not $verdict.Success) {
        $issues += "Plan Audit verdict must be accept or conditional."
    }
    foreach ($field in @("Reviewer", "Date")) {
        $fieldMatch = [regex]::Match($planAudit, "(?im)^\s*${field}:\s*(.+?)\s*$")
        if (-not $fieldMatch.Success -or -not (Test-MeaningfulText -Value $fieldMatch.Groups[1].Value)) {
            $issues += "Plan Audit missing meaningful ${field}."
        }
    }
    foreach ($item in Get-RuleList -Name "plan-audit.keys") {
        if ($planAudit -notmatch "(?im)^\s*-\s+\[x\]\s+$([regex]::Escape($item))\s*$") {
            $issues += "Plan Audit checklist item is not checked: $item"
        }
    }
    if ($planAudit -match "(?im)^\s*-\s+\[\s\]\s+") {
        $issues += "Plan Audit still has unchecked checklist items."
    }
    if ($planAudit -match "(?im)^\s*Verdict:\s*conditional\s*$") {
        $findings = [regex]::Match($planAudit, "(?ims)Findings:\s*([\s\S]+?)(?=^\s*##\s+|\z)")
        if (-not $findings.Success -or -not (Test-MeaningfulText -Value $findings.Groups[1].Value)) {
            $issues += "Conditional Plan Audit must include findings and residual risk."
        }
    }
}

if ($issues.Count -gt 0) {
    Write-Host "plan-check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "plan-check passed."



