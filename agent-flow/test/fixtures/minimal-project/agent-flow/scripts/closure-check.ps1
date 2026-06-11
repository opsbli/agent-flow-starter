param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ProjectRoot = "."
)

$ErrorActionPreference = "Stop"

function Test-MeaningfulFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $Path
    return -not [string]::IsNullOrWhiteSpace($text)
}

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

function Get-ClosureVerdict {
    param([string]$AuditPath)
    if (-not (Test-Path -LiteralPath $AuditPath)) { return "" }
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $AuditPath
    $match = [regex]::Match($text, '(?is)##\s+Closure Audit.*?Verdict:\s*([A-Za-z]+)')
    if ($match.Success) { return $match.Groups[1].Value.ToLowerInvariant() }
    return ""
}

function Resolve-ProjectPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$projectRootPath = Resolve-ProjectPath -Path $ProjectRoot
$changeDirPath = Resolve-ProjectPath -Path $ChangeDir
$flow = Get-FlowLevel -Dir $changeDirPath
$issues = @()

foreach ($file in @("CHANGE.md", "CODE_SCAN.md", "VERIFY.md", "REPORT.md")) {
    if (-not (Test-MeaningfulFile -Path (Join-Path $changeDirPath $file))) {
        $issues += "Missing or empty required closure file: $file"
    }
}

if ($flow -eq "Standard" -or $flow -eq "Heavy") {
    foreach ($file in @("REQUIREMENT.md", "DESIGN.md", "TASKS.md", "EVOLUTION.md")) {
        if (-not (Test-MeaningfulFile -Path (Join-Path $changeDirPath $file))) {
            $issues += "Missing or empty Standard/Heavy closure file: $file"
        }
    }
}

if ($flow -eq "Heavy") {
    foreach ($file in @("PLAN.md", "REVIEW.md", "AUDIT.md")) {
        if (-not (Test-MeaningfulFile -Path (Join-Path $changeDirPath $file))) {
            $issues += "Missing or empty Heavy closure file: $file"
        }
    }

    $verdict = Get-ClosureVerdict -AuditPath (Join-Path $changeDirPath "AUDIT.md")
    if ($verdict -ne "acceptable" -and $verdict -ne "accept" -and $verdict -ne "conditional") {
        $issues += "Closure Audit verdict must be acceptable, accept, or conditional."
    }
}

$verifyText = if (Test-Path -LiteralPath (Join-Path $changeDirPath "VERIFY.md")) { Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $changeDirPath "VERIFY.md") } else { "" }
$auditText = if (Test-Path -LiteralPath (Join-Path $changeDirPath "AUDIT.md")) { Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $changeDirPath "AUDIT.md") } else { "" }
$reportText = if (Test-Path -LiteralPath (Join-Path $changeDirPath "REPORT.md")) { Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $changeDirPath "REPORT.md") } else { "" }

if ($verifyText -notmatch "AC Evidence") {
    $issues += "VERIFY.md must include AC Evidence."
}

if ($flow -eq "Heavy") {
    foreach ($gate in @("scan-check", "task-check", "ac-check", "code-drift-check", "blocked-check", "task-boundary-check", "manifest-check", "evolution-check")) {
        if (($verifyText + "`n" + $auditText) -notmatch [regex]::Escape($gate)) {
            $issues += "Heavy closure must mention gate result: $gate"
        }
    }

    if ($auditText -match "(?i)Verdict:\s*conditional" -and (($verifyText + "`n" + $auditText + "`n" + $reportText) -notmatch "(?i)residual risk|残余风险|剩余风险")) {
        $issues += "Conditional closure must document residual risk."
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Closure check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Closure check passed for $flow change."
