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
    param([string]$Text, [string]$Key)
    $pattern = "(?im)^\s*$([regex]::Escape($Key))\s*:\s*(.+?)\s*$"
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return ""
}

function Test-Meaningful {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value -match "(?i)TODO|TBD|\{.+?\}") { return $false }
    return $true
}

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$flow = Get-FlowLevel -Dir $ChangeDir
$path = Join-Path $ChangeDir "EVOLUTION.md"
if (-not (Test-Path -LiteralPath $path)) {
    if ($flow -eq "Light") {
        Write-Host "SKIP: Light change has no EVOLUTION.md."
        exit 0
    }
    Write-Host "Evolution check failed:"
    Write-Host " - Missing EVOLUTION.md"
    exit 2
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $path
$issues = @()
$required = @("problem", "knowledge", "adr", "gate", "template", "no_change_reason")

foreach ($key in $required) {
    $content = Get-KeyValue -Text $text -Key $key
    if (-not (Test-Meaningful -Value $content)) {
        $issues += "EVOLUTION.md key '$key' is missing or still empty."
    }
}

if ($text -notmatch "(?i)knowledge|ADR|gate|template|script|none|no change") {
    $issues += "EVOLUTION.md must record either concrete upgrades or explicit no-change decisions."
}

if ($issues.Count -gt 0) {
    Write-Host "Evolution check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Evolution check passed for $flow change."
