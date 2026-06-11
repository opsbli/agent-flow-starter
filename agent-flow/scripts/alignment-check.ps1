param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

function Get-FlowLevel {
    param([string]$Dir)

    $change = Join-Path $Dir "CHANGE.md"
    if (-not (Test-Path -LiteralPath $change)) {
        return "Unknown"
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $change
    if ($text -match "(?i)\[x\]\s+Heavy") { return "Heavy" }
    if ($text -match "(?i)\[x\]\s+Standard") { return "Standard" }
    if ($text -match "(?i)\[x\]\s+Light") { return "Light" }
    return "Unknown"
}

function Get-RuleList {
    param([string]$Name)

    $path = Join-Path (Split-Path -Parent $PSScriptRoot) "rules/$Name"
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Rule file not found: $path"
    }

    Get-Content -Encoding utf8 -LiteralPath $path |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") }
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
if ($flow -eq "Light") {
    Write-Host "SKIP: alignment-check is not required for Light changes."
    exit 0
}

if ($flow -eq "Unknown") {
    throw "Cannot determine flow level from CHANGE.md. Mark one of Light / Standard / Heavy."
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
