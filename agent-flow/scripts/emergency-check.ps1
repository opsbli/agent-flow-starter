param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"

function Get-FlowLevel {
    param([string]$Dir)
    $change = Join-Path $Dir "CHANGE.md"
    if (-not (Test-Path -LiteralPath $change)) { return "Unknown" }
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $change
    if ($text -match "(?i)\[x\]\s+Emergency") { return "Emergency" }
    if ($text -match "(?i)\[x\]\s+Heavy") { return "Heavy" }
    if ($text -match "(?i)\[x\]\s+Standard") { return "Standard" }
    if ($text -match "(?i)\[x\]\s+Light") { return "Light" }
    return "Unknown"
}

function Get-Field {
    param(
        [string]$Text,
        [string]$Key
    )
    $pattern = "(?im)^\s*-?\s*$([regex]::Escape($Key))\s*:\s*(.+?)\s*$"
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return ""
}

function Test-Meaningful {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value -match "(?i)TODO|TBD|\{.+?\}|pending-user|your-name") { return $false }
    return $true
}

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$flow = Get-FlowLevel -Dir $ChangeDir
if ($flow -ne "Emergency") {
    Write-Host "SKIP: emergency-check only applies to Emergency changes."
    exit 0
}

$changePath = Join-Path $ChangeDir "CHANGE.md"
if (-not (Test-Path -LiteralPath $changePath)) {
    Write-Host "Emergency check failed:"
    Write-Host " - Missing CHANGE.md"
    exit 2
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $changePath
$issues = @()

$level = Get-Field -Text $text -Key "Level"
$approvedBy = Get-Field -Text $text -Key "Approved by"
$bypassReason = Get-Field -Text $text -Key "Bypass reason"
$deadline = Get-Field -Text $text -Key "Backfill deadline"
$status = Get-Field -Text $text -Key "Backfill status"

if ($level -notmatch "(?i)^(P0|P1)$") {
    $issues += "Emergency Level must be P0 or P1."
}
if (-not (Test-Meaningful -Value $approvedBy)) {
    $issues += "Emergency Approved by must name an accountable approver."
}
if (-not (Test-Meaningful -Value $bypassReason)) {
    $issues += "Emergency Bypass reason must explain why the full flow was skipped."
}
if (-not (Test-Meaningful -Value $deadline)) {
    $issues += "Emergency Backfill deadline must be set."
}
if ($status -notmatch "^(?i)pending|done|waived$") {
    $issues += "Emergency Backfill status must be pending, done, or waived."
}

foreach ($file in @("CODE_SCAN.md", "TASKS.md", "VERIFY.md", "REPORT.md", "EVOLUTION.md")) {
    $path = Join-Path $ChangeDir $file
    if (-not (Test-Path -LiteralPath $path)) {
        $issues += "Emergency change must include $file."
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Emergency check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Emergency check passed."
