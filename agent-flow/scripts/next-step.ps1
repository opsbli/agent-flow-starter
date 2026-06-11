<#
.SYNOPSIS
Inspect a change and print the next recommended agent-flow step.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.PARAMETER All
Parameter accepted by this script.

.PARAMETER ChangesRoot
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/next-step.ps1
#>

param(
    [string]$ChangeDir,
    [switch]$All,
    [string]$ChangesRoot = "agent-flow/changes"
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "_common.ps1")

function Get-AuditVerdict {
    param(
        [string]$AuditPath,
        [string]$Section
    )

    if (-not (Test-Path -LiteralPath $AuditPath)) {
        return ""
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $AuditPath
    $pattern = "(?s)##\s+$([regex]::Escape($Section)).*?Verdict:\s*([A-Za-z]+)"
    $match = [regex]::Match($text, $pattern)
    if ($match.Success) {
        return $match.Groups[1].Value.ToLowerInvariant()
    }
    return ""
}

function Get-DesignAlignmentVerdict {
    param([string]$DesignPath)

    if (-not (Test-Path -LiteralPath $DesignPath)) {
        return ""
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $DesignPath
    $match = [regex]::Match($text, "(?im)^\s*Alignment Verdict:\s*([A-Za-z-]+)\s*$")
    if ($match.Success) {
        return $match.Groups[1].Value.ToLowerInvariant()
    }
    return ""
}

function Get-DesignDecisionStatus {
    param([string]$DesignPath)

    if (-not (Test-Path -LiteralPath $DesignPath)) {
        return ""
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $DesignPath
    $match = [regex]::Match($text, "(?im)^\s*Decision Status:\s*([A-Za-z-]+)\s*$")
    if ($match.Success) {
        return $match.Groups[1].Value.ToLowerInvariant()
    }
    return ""
}

function Get-PlanStatus {
    param([string]$PlanPath)

    if (-not (Test-Path -LiteralPath $PlanPath)) {
        return ""
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $PlanPath
    $match = [regex]::Match($text, "(?im)^\s*>?\s*Plan Status:\s*([A-Za-z-]+)\s*$")
    if ($match.Success) {
        return $match.Groups[1].Value.ToLowerInvariant()
    }
    return ""
}

function Get-StateValue {
    param(
        [string]$StatePath,
        [string]$Key
    )

    if (-not (Test-Path -LiteralPath $StatePath)) {
        return ""
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $StatePath
    $match = [regex]::Match($text, "(?im)^\s*$([regex]::Escape($Key)):\s*(.+?)\s*$")
    if ($match.Success) {
        return $match.Groups[1].Value.Trim()
    }
    return ""
}

function Test-ListContains {
    param(
        [System.Collections.Generic.List[string]]$List,
        [string]$Value
    )
    return $List.Contains($Value)
}

function Analyze-Change {
    param([string]$Dir)

    if (-not (Test-Path -LiteralPath $Dir)) {
        throw "ChangeDir not found: $Dir"
    }

    $changeId = Split-Path -Leaf $Dir
    $flow = Get-FlowLevel -Dir $Dir
    $missing = New-Object System.Collections.Generic.List[string]
    $blocked = New-Object System.Collections.Generic.List[string]
    $stage = "unknown"
    $next = ""
    $prompt = ""
    $statePath = Join-Path $Dir "STATE.md"
    $stateCurrentStage = Get-StateValue -StatePath $statePath -Key "current_stage"
    $stateNextAction = Get-StateValue -StatePath $statePath -Key "next_action"
    $designDecisionStatus = ""
    $alignmentVerdict = ""
    $planVerdict = ""
    $planStatus = ""
    $closureVerdict = ""

    foreach ($file in @("STATE.md", "CHANGE.md", "CODE_SCAN.md", "VERIFY.md", "REPORT.md")) {
        if (-not (Test-MeaningfulFile -Path (Join-Path $Dir $file) -Placeholders @("Status: not started", "No implementation verification has run yet"))) {
            $missing.Add($file)
        }
    }

    if ($flow -eq "Unknown") {
        $stage = "intake"
        $next = "Confirm Light / Standard / Heavy / Emergency and complete CHANGE.md."
        $prompt = "Continue agent-flow change: $changeId. Read the existing artifacts, confirm the flow level as Light/Standard/Heavy/Emergency, and complete CHANGE.md. Do not implement code yet."
    } elseif (Test-ListContains -List $missing -Value "CHANGE.md") {
        $stage = "intake"
        $next = "Complete CHANGE.md."
        $prompt = "Continue agent-flow change: $changeId. Complete CHANGE.md with summary, goals, non-goals, impact, risks, and flow level."
    } elseif (Test-ListContains -List $missing -Value "CODE_SCAN.md") {
        $stage = "code-scan"
        $next = "Run code-first scan and complete CODE_SCAN.md."
        $prompt = "Continue agent-flow change: $changeId. Run a code-first scan and complete CODE_SCAN.md with related modules, similar implementations, reusable abstractions, read_files, write_files, and open questions. Do not implement code yet."
    } elseif ($flow -eq "Emergency") {
        foreach ($file in @("TASKS.md", "EVOLUTION.md")) {
            if (-not (Test-MeaningfulFile -Path (Join-Path $Dir $file) -Placeholders @("Status: not started", "TODO"))) {
                $missing.Add($file)
            }
        }

        if (Test-ListContains -List $missing -Value "TASKS.md") {
            $stage = "emergency-backfill"
            $next = "Backfill TASKS.md for the Emergency change."
            $prompt = "Continue agent-flow Emergency change: $changeId. Backfill TASKS.md with completed response tasks, AC mapping, read_files, write_files, verification command, and parallelization status. Then run emergency-check."
        } elseif (Test-ListContains -List $missing -Value "VERIFY.md") {
            $stage = "verify"
            $next = "Run verification and complete VERIFY.md."
            $prompt = "Continue agent-flow Emergency change: $changeId. Run relevant verification, complete VERIFY.md with AC Evidence and command results, and run emergency-check."
        } elseif (Test-ListContains -List $missing -Value "REPORT.md") {
            $stage = "report"
            $next = "Complete REPORT.md."
            $prompt = "Continue agent-flow Emergency change: $changeId. Complete REPORT.md with incident impact, delivered fix, verification, rollback notes, and residual risks."
        } elseif (Test-ListContains -List $missing -Value "EVOLUTION.md") {
            $stage = "evolution"
            $next = "Complete EVOLUTION.md and record Emergency follow-up lessons."
            $prompt = "Continue agent-flow Emergency change: $changeId. Complete EVOLUTION.md with what was bypassed, what must be backfilled, and any script/template lessons. Then run emergency-check and evolution-check."
        } else {
            $stage = "complete-or-review"
            $next = "Emergency backfill artifacts are ready. Run emergency-check and review manually."
            $prompt = "Continue agent-flow Emergency change: $changeId. Run emergency-check and relevant verification, then summarize remaining incident risk and backfill status."
        }
    } elseif ($flow -eq "Light") {
        if (Test-ListContains -List $missing -Value "VERIFY.md") {
            $stage = "verify"
            $next = "Run verification and complete VERIFY.md."
            $prompt = "Continue agent-flow change: $changeId. Run the relevant verification commands, complete VERIFY.md, and record AC evidence, skipped checks, and conclusions."
        } elseif (Test-ListContains -List $missing -Value "REPORT.md") {
            $stage = "report"
            $next = "Complete REPORT.md and close out."
            $prompt = "Continue agent-flow change: $changeId. Complete REPORT.md from CHANGE, CODE_SCAN, and VERIFY, including delivered changes, verification results, and residual risks."
        } else {
            $stage = "complete-or-review"
            $next = "Light artifacts are ready. Review manually, then close or record reusable lessons in EVOLUTION.md."
            $prompt = "Continue agent-flow change: $changeId. Review whether this Light change meets the definition of done, and record reusable lessons in knowledge or EVOLUTION if useful."
        }
    } else {
        foreach ($file in @("REQUIREMENT.md", "DESIGN.md", "TASKS.md", "EVOLUTION.md")) {
            if (-not (Test-MeaningfulFile -Path (Join-Path $Dir $file) -Placeholders @("Status: not started", "TODO"))) {
                $missing.Add($file)
            }
        }
        if ($flow -eq "Heavy") {
            foreach ($file in @("PLAN.md", "AUDIT.md", "REVIEW.md")) {
                if (-not (Test-MeaningfulFile -Path (Join-Path $Dir $file) -Placeholders @("Status: not run", "not run"))) {
                    $missing.Add($file)
                }
            }
        }

        $audit = Join-Path $Dir "AUDIT.md"
        $planPath = Join-Path $Dir "PLAN.md"
        $planVerdict = Get-AuditVerdict -AuditPath $audit -Section "Plan Audit"
        $planStatus = Get-PlanStatus -PlanPath $planPath
        $closureVerdict = Get-AuditVerdict -AuditPath $audit -Section "Closure Audit"
        $designPath = Join-Path $Dir "DESIGN.md"
        $alignmentVerdict = Get-DesignAlignmentVerdict -DesignPath $designPath
        $designDecisionStatus = Get-DesignDecisionStatus -DesignPath $designPath

        if (Test-ListContains -List $missing -Value "REQUIREMENT.md") {
            $stage = "requirement"
            $next = "Complete REQUIREMENT.md with AC-01 style acceptance criteria."
            $prompt = "Continue agent-flow change: $changeId. Based on CHANGE and CODE_SCAN, complete REQUIREMENT.md. Acceptance criteria must use AC-01, AC-02 style IDs. Do not implement code yet."
        } elseif (Test-ListContains -List $missing -Value "DESIGN.md") {
            $stage = "design"
            $next = "Complete DESIGN.md with API / Permission / Auth decisions."
            $prompt = "Continue agent-flow change: $changeId. Based on REQUIREMENT and CODE_SCAN, complete DESIGN.md with module boundaries, reusable abstractions, API/Permission/Auth decisions, state-machine impact, test strategy, and risks. Keep Decision Status pending until all decision rows have one final value and evidence. Do not implement code yet."
        } elseif ($designDecisionStatus -ne "accepted") {
            $stage = "design-decision"
            $next = "Finalize DESIGN.md decisions and run design-check."
            $prompt = "Continue agent-flow change: $changeId. Finalize DESIGN.md before alignment. Fill every API / Permission / Auth decision row with one final value, evidence or reason, and explicit State Machine Impact. Set Decision Status: accepted only after the decision block is complete. Then run design-check. Do not create PLAN.md, TASKS.md, or implement code yet."
        } elseif ($alignmentVerdict -ne "aligned" -and $alignmentVerdict -ne "skipped") {
            $stage = "design-alignment"
            if ($alignmentVerdict -eq "blocked") {
                $blocked.Add("Design Alignment is blocked; resolve open questions before planning or implementation.")
            }
            $next = "Run Design Alignment / Grill before PLAN.md, TASKS.md, or implementation."
            $prompt = "Continue agent-flow change: $changeId. Run Design Alignment / Grill before planning or implementation. Read REQUIREMENT.md, CODE_SCAN.md, and DESIGN.md. Interview me one question at a time until user intent, code facts, and the design are aligned. If a question can be answered by reading the codebase, read the codebase instead of asking me. For every question, provide your recommended answer. Update DESIGN.md after each confirmed answer. Required rows: Intent Risk, Existing Code Fit, Unnecessary Abstraction, Protected Areas, Boundary And Failure Modes. Set Alignment Source and Open Questions: none before Alignment Verdict: aligned. Run alignment-check after updating DESIGN.md. Do not create PLAN.md, TASKS.md, or implement code until Alignment Verdict is aligned or I explicitly accept skipped with Skip Reason."
        } elseif ($flow -eq "Heavy" -and ((Test-ListContains -List $missing -Value "PLAN.md") -or $planStatus -notin @("planned", "in-progress", "completed", "superseded", "deferred"))) {
            $stage = "plan"
            $next = "Complete PLAN.md."
            $prompt = "Continue agent-flow change: $changeId. Based on REQUIREMENT, CODE_SCAN, and DESIGN, complete PLAN.md with Current Baseline, Goals, Non-Goals, Execution Phases, read_files, write_files, Exit Criteria, Verification, Closure Gates, Risks, and Protected Area Review. Keep Plan Status planned when ready for Plan Audit."
        } elseif (Test-ListContains -List $missing -Value "TASKS.md") {
            $stage = "tasks"
            $next = "Complete TASKS.md with Task Matrix, status, read_files, and write_files."
            $prompt = "Continue agent-flow change: $changeId. Based on DESIGN, complete TASKS.md. Include a Task Matrix. Each task must include status, goal, AC mapping, read_files, write_files, verification command, and parallelization status. Then run task-check."
        } elseif ($flow -eq "Heavy" -and $planVerdict -ne "accept" -and $planVerdict -ne "conditional") {
            $stage = "plan-audit"
            $next = "Run Plan Audit."
            $prompt = "Continue agent-flow change: $changeId. Run Plan Audit against REQUIREMENT, CODE_SCAN, DESIGN, PLAN, and TASKS. Check design-check, alignment-check, protected areas, read/write boundaries, exit criteria, and risks. Mark every Plan Audit checklist item with [x] only when verified. Set Verdict: accept or conditional with Findings, then run plan-check. If verdict cannot be accept/conditional, stop and list required fixes."
        } elseif (Test-ListContains -List $missing -Value "VERIFY.md") {
            $stage = "verify"
            $next = "Run verification and complete VERIFY.md."
            $prompt = "Continue agent-flow change: $changeId. Run the relevant verification commands and complete VERIFY.md with command log, AC evidence, Machine Gate Summary, scan-check, task-check, code-drift-check, blocked-check, task-boundary-check, manifest-check, emergency-check, skipped checks, and conclusion."
        } elseif ($flow -eq "Heavy" -and (Test-ListContains -List $missing -Value "REVIEW.md")) {
            $stage = "review"
            $next = "Complete REVIEW.md."
            $prompt = "Continue agent-flow change: $changeId. Complete REVIEW.md from intent compliance, architecture compliance, code quality, and verification evidence."
        } elseif (Test-ListContains -List $missing -Value "REPORT.md") {
            $stage = "report"
            $next = "Complete REPORT.md."
            $prompt = "Continue agent-flow change: $changeId. Complete REPORT.md with delivered changes, verification results, residual risks, rollback advice, and follow-up items."
        } elseif ($flow -eq "Heavy" -and $closureVerdict -ne "acceptable" -and $closureVerdict -ne "accept" -and $closureVerdict -ne "conditional") {
            $stage = "closure-audit"
            $next = "Run Closure Audit."
            $prompt = "Continue agent-flow change: $changeId. Run Closure Audit. Check Closure Gates, VERIFY evidence, AC coverage, scan-check, task-check, code-drift-check, blocked-check, task-boundary-check, manifest-check, emergency-check, evolution-check, closure-check, CHECK_RESULT.json, and knowledge/decision/log/baseline updates."
        } elseif (Test-ListContains -List $missing -Value "EVOLUTION.md") {
            $stage = "evolution"
            $next = "Complete EVOLUTION.md and evaluate whether agent-flow should be upgraded."
            $prompt = "Continue agent-flow change: $changeId. Complete EVOLUTION.md and evaluate whether templates, scripts, knowledge, flows, or AGENTS.md should be upgraded. Only evaluate; do not edit framework files yet."
        } else {
            $stage = "complete-or-conditional"
            if ($closureVerdict -eq "conditional") {
                $blocked.Add("Closure Audit is conditional; decide whether to accept residual risk or add more verification.")
                $next = "Accept conditional closure or add verification to reach acceptable closure."
                $prompt = "Continue agent-flow change: $changeId. Read AUDIT, VERIFY, and REPORT, list residual risks from conditional closure, and propose two options: accept risk or add verification. Do not edit files."
            } else {
                $next = "Artifacts are ready. Review manually, then close the change."
                $prompt = "Continue agent-flow change: $changeId. Do a final read-only review, confirm whether the definition of done is met, and output the closeout summary."
            }
        }
    }

    [pscustomobject]@{
        change_id = $changeId
        flow = $flow
        stage = $stage
        state_current_stage = $stateCurrentStage
        state_next_action = $stateNextAction
        design_decision_status = $designDecisionStatus
        alignment_verdict = $alignmentVerdict
        plan_audit_verdict = $planVerdict
        plan_status = $planStatus
        missing = @($missing | Select-Object -Unique)
        blocked = @($blocked | Select-Object -Unique)
        next = $next
        next_prompt = $prompt
    }
}

if ($All) {
    if (-not (Test-Path -LiteralPath $ChangesRoot)) {
        throw "ChangesRoot not found: $ChangesRoot"
    }
    Get-ChildItem -LiteralPath $ChangesRoot -Directory |
        ForEach-Object { Analyze-Change -Dir $_.FullName } |
        ConvertTo-Json -Depth 5
} else {
    if ([string]::IsNullOrWhiteSpace($ChangeDir)) {
        throw "Use -ChangeDir <path> or -All."
    }
    Analyze-Change -Dir $ChangeDir | ConvertTo-Json -Depth 5
}



