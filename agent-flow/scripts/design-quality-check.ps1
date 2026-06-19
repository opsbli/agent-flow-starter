<#
.SYNOPSIS
Run the design-quality-check agent-flow gate.

.DESCRIPTION
Checks DESIGN.md for quality indicators: reuse analysis completeness,
evidence of existing abstraction review, and absence of placeholder values.
Optional gate — outputs warnings for improvement opportunities.

Part of the agent-flow scaffold toolchain.

.PARAMETER ChangeDir
Path to the change directory.

.PARAMETER ProjectRoot
Path to the project root (default: current directory).

.EXAMPLE
agent-flow/scripts/design-quality-check.ps1 -ChangeDir agent-flow/changes/my-change
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ProjectRoot = "."
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) { return [System.IO.Path]::GetFullPath($Path) }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Test-MeaningfulValue {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    return ($Value.Trim() -notmatch "(?i)^(TODO|TBD|pending|none|n/a|na|null|not-applicable|path/to|\{.+?\}|example)$")
}

$changeDirPath = Resolve-ProjectPath -Path $ChangeDir
$designPath = [System.IO.Path]::Combine($changeDirPath, "DESIGN.md")
if (-not (Test-Path -LiteralPath $designPath)) {
    Write-Host "SKIP: No DESIGN.md in $ChangeDir"
    exit 0
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $designPath
$warnings = @()

Write-Host "=== Design Quality Check ==="

# 1. Check reuse analysis section
$hasReuseSection = $text -match '(?im)##\s*复用现有抽象|##\s*Reuse|##\s*reusable_abstractions|##\s*Existing Code Fit'
$hasNoReuseReason = $text -match "(?im)##\s*不复用的原因|##\s*No.*Reuse|##\s*Don't Reuse"

if (-not $hasReuseSection) {
    $warnings += "DESIGN-QA: No reuse analysis section found. Add '复用现有抽象' section to document existing abstractions checked."
} elseif (-not $hasNoReuseReason) {
    $warnings += "DESIGN-QA: Reuse analysis present but no '不复用的原因' section. When choosing not to reuse an abstraction, document why."
}

# 2. Check standards_snapshot reference
$hasStandardsRef = $text -match '(?im)standards_snapshot|docs/standards|code convention|编码规范|project standard'
if (-not $hasStandardsRef) {
    $warnings += "DESIGN-QA: No reference to project standards or standards_snapshot. Consider documenting which conventions apply."
}

# 3. Check for placeholder values
$placeholderCount = 0
$placeholderPatterns = @('\bpending\b', '\bTBD\b', '\bTODO\b', 'path/to', '\bexample\b', '\{.*?\}')
foreach ($pattern in $placeholderPatterns) {
    $matches = [regex]::Matches($text, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $placeholderCount += $matches.Count
}
if ($placeholderCount -gt 0) {
    $warnings += "DESIGN-QA: $placeholderCount placeholder value(s) found (pending/TBD/TODO/example). Resolve before implementation."
}

# 4. Check AC mapping in testing strategy
$hasTestingStrategy = $text -match '(?im)##\s*测试策略|##\s*Testing|##\s*Test Strategy'
$hasACMappingsInTest = $text -match '(?im)\|.*AC-\d+.*\|.*test|test.*\|.*AC-\d+'
if (-not $hasTestingStrategy) {
    $warnings += "DESIGN-QA: No testing strategy section found. Add '测试策略' with AC-to-test mappings."
} elseif (-not $hasACMappingsInTest) {
    $warnings += "DESIGN-QA: Testing strategy present but no AC-to-test mappings found. Each AC should map to a test file or verification method."
}

# 5. Check API decision table completeness
if ($text -match '(?im)##\s*API.*Design|##\s*API.*Permission') {
    $hasEmptyDecisions = $text -match '(?im)\|\s*REST Path\s*\|\s*pending\s*\|'
    if ($hasEmptyDecisions) {
        $warnings += "DESIGN-QA: API decisions table has pending values. Finalize before implementation."
    }
}

# Output
Write-Host ""
Write-Host "============================================"
if ($warnings.Count -gt 0) {
    Write-Host "Design quality check found $($warnings.Count) suggestion(s):"
    $warnings | ForEach-Object { Write-Host " - $_" }
    Write-Host ""
    Write-Host "NOTE: This is a non-blocking quality advisory. Review each suggestion."
    exit 0
}

Write-Host "Design quality check passed. No quality concerns detected."
