<#
.SYNOPSIS
Smart error recovery assistant for agent-flow gate failures.
Analyzes gate errors and suggests/auto-applies fixes.

.DESCRIPTION
Part of the agent-flow scaffold toolchain.
Detects common gate failures and provides actionable recovery steps.

.PARAMETER Gate
The gate that failed (e.g., alignment-check, task-check, plan-check).

.PARAMETER ChangeDir
Path to the change directory.

.PARAMETER AutoFix
Automatically apply the suggested fix (where safe).

.PARAMETER ListGates
List all known gates with their recovery strategies.

.EXAMPLE
agent-flow/scripts/recover.ps1 -Gate alignment-check -ChangeDir agent-flow/changes/my-change

.EXAMPLE
agent-flow/scripts/recover.ps1 -Gate alignment-check -ChangeDir agent-flow/changes/my-change -AutoFix

.EXAMPLE
agent-flow/scripts/recover.ps1 -ListGates
#>

param(
    [string]$Gate = "",
    [string]$ChangeDir = "",
    [switch]$AutoFix,
    [switch]$ListGates
)

$ErrorActionPreference = "Stop"

# ── Known gate recovery strategies ──
$strategies = @{
    "alignment-check" = @{
        description = "Design Alignment requires ≥3 user-confirmed questions"
        diagnose = {
            param($dir)
            $designFile = Join-Path $dir "DESIGN.md"
            if (-not (Test-Path $designFile)) { return "DESIGN.md not found. Create it first." }
            $text = Get-Content -Raw -Encoding utf8 -LiteralPath $designFile
            $match = [regex]::Match($text, "(?im)Alignment Verdict:\s*(\S+)")
            $verdict = if ($match.Success) { $match.Groups[1].Value } else { "missing" }

            $confirmedCount = @([regex]::Matches($text, "user-confirmed")).Count
            return "Verdict: $verdict | user-confirmed questions: $confirmedCount"
        }
        autoFix = {
            param($dir)
            $designFile = Join-Path $dir "DESIGN.md"
            $text = Get-Content -Raw -Encoding utf8 -LiteralPath $designFile

            # If verdict is missing, append template
            if ($text -notmatch "(?im)Alignment Verdict") {
                $text += @"

## Design Alignment / Grill

| # | Question | AI Recommendation | User Response | Confirmation |
|---|----------|------------------|---------------|--------------|
| 1 | Is the design consistent with existing module patterns? | [AI recommendation] | [user response] | code-confirmed |
| 2 | Are there performance implications? | [AI recommendation] | [user response] | code-confirmed |
| 3 | Is the error handling complete? | [AI recommendation] | [user response] | code-confirmed |

**Alignment Verdict**: pending
"@
                Set-Content -Encoding utf8 -LiteralPath $designFile -Value $text
                return "Added Design Alignment template to DESIGN.md. Fill in the questions with user responses."
            }
            return "DESIGN.md already has Alignment section. Ensure ≥3 questions have 'user-confirmed'."
        }
        help = "Run alignment-check with the change directory. Open DESIGN.md and ensure the Design Alignment / Grill section has ≥3 user-confirmed questions. Then re-run alignment-check."
    }

    "scan-check" = @{
        description = "Code scan validation — required files or content missing"
        diagnose = {
            param($dir)
            $scanFile = Join-Path $dir "CODE_SCAN.md"
            if (-not (Test-Path $scanFile)) { return "CODE_SCAN.md not found. Run code-first scan first." }
            $text = Get-Content -Raw -Encoding utf8 -LiteralPath $scanFile
            $hasReadFiles = $text -match "(?i)read.files|只读"
            $hasWriteFiles = $text -match "(?i)write.files|允许写"
            return "Read files section: $(if($hasReadFiles){'✅'}else{'❌'}) | Write files section: $(if($hasWriteFiles){'✅'}else{'❌'})"
        }
        autoFix = { param($dir) return "No automatic fix for scan-check. Manually add read_files and write_files sections." }
        help = "Open CODE_SCAN.md and ensure it has read_files, write_files, and similar modules sections."
    }

    "task-check" = @{
        description = "Task Matrix validation — each task needs status, AC mapping, read_files, write_files"
        diagnose = {
            param($dir)
            $tasksFile = Join-Path $dir "TASKS.md"
            if (-not (Test-Path $tasksFile)) { return "TASKS.md not found." }
            $text = Get-Content -Raw -Encoding utf8 -LiteralPath $tasksFile
            $taskCount = @([regex]::Matches($text, "^\|\s*\d+\s+\|")).Count
            return "Tasks found: $taskCount"
        }
        autoFix = { param($dir) return "No automatic fix. Manually ensure each task has status, AC, read_files, write_files, and verify." }
        help = "Open TASKS.md and ensure each task row has: status, AC mapping, read_files, write_files, verification command."
    }

    "plan-check" = @{
        description = "Plan validation — Plan Audit required before implementation"
        diagnose = {
            param($dir)
            $auditFile = Join-Path $dir "AUDIT.md"
            $planFile = Join-Path $dir "PLAN.md"
            $status = @{}
            if (Test-Path $auditFile) { $status.audit = "exists" }
            else { $status.audit = "missing" }
            if (Test-Path $planFile) { $status.plan = "exists" }
            else { $status.plan = "missing" }
            return "AUDIT.md: $($status.audit) | PLAN.md: $($status.plan)"
        }
        autoFix = { param($dir) return "No automatic fix. Complete PLAN.md then run Plan Audit to get 'accept' verdict." }
        help = "Complete PLAN.md with phases and gates, then run Plan Audit in AUDIT.md and get 'accept' verdict."
    }

    "code-drift-check" = @{
        description = "Design vs code drift — implemented code deviates from DESIGN.md"
        diagnose = {
            param($dir)
            return "Run the script to see specific drift details."
        }
        autoFix = { param($dir) return "No automatic fix. Either update DESIGN.md to match code, or update code to match DESIGN.md." }
        help = "Compare actual code changes with DESIGN.md declarations. Either update the design doc or fix the code."
    }

    "evolution-check" = @{
        description = "Evolution validation — EVOLUTION.md required for Standard/Heavy"
        diagnose = {
            param($dir)
            $evoFile = Join-Path $dir "EVOLUTION.md"
            if (-not (Test-Path $evoFile)) { return "EVOLUTION.md not found." }
            return "EVOLUTION.md exists."
        }
        autoFix = {
            param($dir)
            $evoFile = Join-Path $dir "EVOLUTION.md"
            if (Test-Path $evoFile) { return "EVOLUTION.md already exists." }
            # Try to auto-generate from evolution-suggest
            $suggestScript = Join-Path $PSScriptRoot "evolution-suggest.ps1"
            if (Test-Path $suggestScript) {
                & $suggestScript -ChangeDir $dir -Output $evoFile
                return "Auto-generated EVOLUTION.md from change analysis."
            }
            return "evolution-suggest.ps1 not found. Create EVOLUTION.md manually."
        }
        help = "Create EVOLUTION.md with: what went well, what was formality, knowledge to capture, templates to update."
    }
}

# ── List all gates ──
if ($ListGates) {
    Write-Host "Known gates with recovery strategies:" -ForegroundColor Cyan
    foreach ($key in $strategies.Keys | Sort-Object) {
        $s = $strategies[$key]
        Write-Host "  $key" -NoNewline -ForegroundColor White
        Write-Host " - $($s.description)" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Usage: recover.ps1 -Gate <gate-name> -ChangeDir <path> [-AutoFix]" -ForegroundColor Cyan
    return
}

# ── Validate ──
if (-not $Gate) {
    Write-Host "Specify a gate name: recover.ps1 -Gate <gate-name> -ChangeDir <path>" -ForegroundColor Yellow
    Write-Host "Use -ListGates to see all available gates." -ForegroundColor Cyan
    exit 1
}

if (-not $strategies.ContainsKey($Gate)) {
    Write-Host "Unknown gate: $Gate" -ForegroundColor Red
    Write-Host "Run recover.ps1 -ListGates to see supported gates." -ForegroundColor Cyan
    exit 1
}

$strategy = $strategies[$Gate]

Write-Host "Recover: $Gate" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor DarkGray
Write-Host $strategy.description -ForegroundColor Yellow
Write-Host ""

# ── Diagnose ──
if ($ChangeDir -and (Test-Path $ChangeDir)) {
    Write-Host "Diagnosis:" -ForegroundColor Cyan
    $diagnosis = & $strategy.diagnose $ChangeDir
    Write-Host "  $diagnosis" -ForegroundColor White
    Write-Host ""
}

# ── Auto-fix ──
if ($AutoFix) {
    Write-Host "Applying auto-fix..." -ForegroundColor Yellow
    $fixResult = & $strategy.autoFix $ChangeDir
    Write-Host "  $fixResult" -ForegroundColor Green
    Write-Host ""
    Write-Host "After applying, re-run the gate:" -ForegroundColor Cyan
    Write-Host "  bash agent-flow/scripts/$Gate.sh --change-dir $ChangeDir" -ForegroundColor White
} else {
    Write-Host "Recovery steps:" -ForegroundColor Cyan
    Write-Host "  $($strategy.help)" -ForegroundColor White
    Write-Host ""
    Write-Host "To auto-fix (where supported):" -ForegroundColor Cyan
    Write-Host "  recover.ps1 -Gate $Gate -ChangeDir $ChangeDir -AutoFix" -ForegroundColor White
    Write-Host ""
    Write-Host "Then re-run the gate:" -ForegroundColor Cyan
    Write-Host "  bash agent-flow/scripts/$Gate.sh --change-dir $ChangeDir" -ForegroundColor White
}
