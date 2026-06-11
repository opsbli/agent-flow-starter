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
    if ($text -match "(?i)\[x\]\s+Heavy") { return "Heavy" }
    if ($text -match "(?i)\[x\]\s+Standard") { return "Standard" }
    if ($text -match "(?i)\[x\]\s+Light") { return "Light" }
    return "Unknown"
}

function Get-KeyValue {
    param(
        [string]$Text,
        [string]$Key
    )
    $pattern = "(?im)^\s*$([regex]::Escape($Key))\s*:\s*(.+?)\s*$"
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return ""
}

function Test-Meaningful {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value -match "(?i)TODO|TBD|path/to|example|\{.+?\}") { return $false }
    return $true
}

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$scanPath = Join-Path $ChangeDir "CODE_SCAN.md"
if (-not (Test-Path -LiteralPath $scanPath)) {
    Write-Host "Scan check failed:"
    Write-Host " - Missing CODE_SCAN.md"
    exit 2
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $scanPath
$flow = Get-FlowLevel -Dir $ChangeDir
$issues = @()

$required = @("scan_time", "read_files", "write_files", "open_questions")
if ($flow -eq "Standard" -or $flow -eq "Heavy") {
    $required += @("related_modules", "similar_implementations", "reusable_abstractions", "test_baseline")
}

foreach ($key in $required) {
    $content = Get-KeyValue -Text $text -Key $key
    if (-not (Test-Meaningful -Value $content)) {
        $issues += "CODE_SCAN.md key '$key' is missing or still empty."
    }
}

if ($text -notmatch "(?im)read_files\s*:|##\s+read_files") {
    $issues += "CODE_SCAN.md must declare read_files."
}
if ($text -notmatch "(?im)write_files\s*:|##\s+write_files") {
    $issues += "CODE_SCAN.md must declare write_files."
}

if ($issues.Count -gt 0) {
    Write-Host "Scan check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Scan check passed for $flow change."
