<#
.SYNOPSIS
Run the alignment-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/alignment-check.ps1
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

function Get-AlignmentVerdict {
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

function Get-AlignmentSection {
    param([string]$Text)

    $match = [regex]::Match($Text, '(?ims)^\s*##\s+Design Alignment / Grill\s*$([\s\S]*?)(?=^\s*##\s+|\z)')
    if ($match.Success) {
        return $match.Groups[1].Value
    }
    return ""
}

$flow = Get-FlowLevel -Dir $ChangeDir
if ($flow -eq "Light" -or $flow -eq "Emergency") {
    Write-Host "SKIP: alignment-check is not required for $flow changes."
    exit 0
}

if ($flow -eq "Unknown") {
    throw "Cannot determine flow level from CHANGE.md. Mark one of Light / Standard / Heavy / Emergency."
}

$design = Join-Path $ChangeDir "DESIGN.md"
if (-not (Test-Path -LiteralPath $design)) {
    throw "DESIGN.md not found in $ChangeDir"
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $design
$section = Get-AlignmentSection -Text $text
$verdict = Get-AlignmentVerdict -DesignPath $design
$issues = @()

if ([string]::IsNullOrWhiteSpace($section)) {
    $issues += "DESIGN.md missing 'Design Alignment / Grill' section."
}

if ($verdict -eq "skipped") {
    if ($text -match "(?im)^\s*Skip Reason:\s*\S") {
        Write-Host "alignment-check passed: skipped with explicit reason."
        exit 0
    }
    Write-Host "Alignment Verdict is skipped, but Skip Reason is missing."
    exit 2
}

if ($verdict -ne "aligned") {
    if ([string]::IsNullOrWhiteSpace($verdict)) {
        $issues += "Alignment Verdict missing in DESIGN.md."
    } else {
        $issues += "Alignment Verdict is not accepted: $verdict"
    }
}

if ($verdict -eq "aligned") {
    if ($section -notmatch "(?im)^\s*Alignment Source:\s*(code-confirmed|user-confirmed|mixed)\s*$") {
        $issues += "Alignment Source must be code-confirmed, user-confirmed, or mixed."
    }
    if ($section -notmatch "(?im)^\s*Open Questions:\s*none\s*$") {
        $issues += "Open Questions must be 'none' before Alignment Verdict is aligned."
    }
    foreach ($question in Get-RuleList -Name "design-alignment.questions") {
        $line = ($section -split "\r?\n") |
            Where-Object { $_ -match "^\s*\|" -and $_ -match "\|\s*$([regex]::Escape($question))\s*\|" } |
            Select-Object -First 1
        if ([string]::IsNullOrWhiteSpace($line)) {
            $issues += "Missing alignment question row: $question"
        } elseif ($line -notmatch "(?i)\|\s*confirmed\s*\|") {
            $issues += "Alignment question is not confirmed: $question"
        }
    }
}

if ($issues.Count -gt 0) {
    Write-Host "alignment-check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    Write-Host "Use 'Alignment Verdict: aligned' after required questions are confirmed, or 'Alignment Verdict: skipped' with Skip Reason."
    exit 2
}

Write-Host "alignment-check passed."



