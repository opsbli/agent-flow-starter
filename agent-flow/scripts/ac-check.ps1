param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$TestRoot = "."
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$requirement = Join-Path $ChangeDir "REQUIREMENT.md"
if (-not (Test-Path $requirement)) {
    throw "REQUIREMENT.md not found in $ChangeDir"
}

$content = Get-Content -Raw -Encoding utf8 $requirement
$acs = [regex]::Matches($content, "AC[-_ ]?\d{2,4}") | ForEach-Object { $_.Value.ToUpper().Replace("_", "-").Replace(" ", "-") } | Sort-Object -Unique

if ($acs.Count -eq 0) {
    throw "No AC ids found in $requirement"
}

$requirementFullPath = (Resolve-Path -LiteralPath $requirement).Path
$evidenceExtensions = @(".java", ".ts", ".tsx", ".js", ".md")
$allText = ""
Get-ChildItem -LiteralPath $TestRoot -Recurse -File |
    Where-Object {
        $evidenceExtensions -contains $_.Extension.ToLowerInvariant() -and
        (Resolve-Path -LiteralPath $_.FullName).Path -ne $requirementFullPath
    } |
    ForEach-Object { $allText += "`n" + (Get-Content -Raw -Encoding utf8 -LiteralPath $_.FullName) }

$missing = @()
foreach ($ac in $acs) {
    $compact = $ac.Replace("-", "")
    if ($allText -notmatch [regex]::Escape($ac) -and $allText -notmatch [regex]::Escape($compact)) {
        $missing += $ac
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Missing AC evidence:"
    $missing | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "AC check passed: $($acs.Count) AC ids have evidence."
