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

$flow = Get-FlowLevel -Dir $ChangeDir
if ($flow -eq "Light") {
    Write-Host "Alignment check skipped: Light change."
    exit 0
}

if ($flow -eq "Unknown") {
    throw "Cannot determine flow level from CHANGE.md. Mark one of Light / Standard / Heavy."
}

$design = Join-Path $ChangeDir "DESIGN.md"
if (-not (Test-Path -LiteralPath $design)) {
    throw "DESIGN.md not found in $ChangeDir"
}

$verdict = Get-AlignmentVerdict -DesignPath $design
if ($verdict -eq "aligned") {
    Write-Host "Alignment check passed: Alignment Verdict is aligned."
    exit 0
}

if ($verdict -eq "skipped") {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $design
    if ($text -match "(?im)^\s*Skip Reason:\s*\S") {
        Write-Host "Alignment check passed: Alignment Verdict is skipped with reason."
        exit 0
    }
    Write-Host "Alignment Verdict is skipped, but Skip Reason is missing."
    exit 2
}

if ([string]::IsNullOrWhiteSpace($verdict)) {
    Write-Host "Alignment Verdict missing in DESIGN.md."
} else {
    Write-Host "Alignment Verdict is not accepted: $verdict"
}
Write-Host "Use 'Alignment Verdict: aligned' or 'Alignment Verdict: skipped' with 'Skip Reason: ...'."
exit 2
