<#
.SYNOPSIS
Validate that change artifacts contain meaningful content.
With -ProjectRoot, also scan agent-flow/core/ and agent-flow/rules/ for placeholders.
#>

param(
    [string]$ChangeDir,
    [string]$ProjectRoot,
    [switch]$Strict
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "_common.ps1")

if (-not $ChangeDir -and -not $ProjectRoot) {
    Write-Host "Usage: content-check.ps1 -ChangeDir <path> [-ProjectRoot <path>] [-Strict]"
    Write-Host "  Provide -ChangeDir, -ProjectRoot, or both."
    exit 2
}

$issues = @()
$passCount = 0

function Add-Issue {
    param([string]$Message)
    $script:issues += $Message
}

function Test-ArtifactContent {
    param(
        [string]$Name,
        [switch]$Required
    )

    $path = Join-Path $ChangeDir $Name
    if (-not (Test-Path -LiteralPath $path)) {
        if ($Required) { Add-Issue "${Name}: missing" }
        return
    }

    if (-not (Test-MeaningfulFile -Path $path -Placeholders @("TODO", "TBD", "path/to", "{module}", "example"))) {
        Add-Issue "${Name}: missing meaningful content or contains placeholders"
        return
    }

    $script:passCount++
    Write-Host "  PASS $Name"
}

# ── Change artifact check ──
if ($ChangeDir) {
    if (-not (Test-Path -LiteralPath $ChangeDir)) {
        Write-Host "Change directory not found: $ChangeDir"
        exit 1
    }

    Write-Host "Content quality check for: $(Split-Path $ChangeDir -Leaf)"
    Write-Host "============================================================"

    Test-ArtifactContent -Name "CHANGE.md" -Required
    Test-ArtifactContent -Name "CODE_SCAN.md"
    Test-ArtifactContent -Name "REQUIREMENT.md"
    Test-ArtifactContent -Name "DESIGN.md"
    Test-ArtifactContent -Name "TASKS.md"
    Test-ArtifactContent -Name "VERIFY.md"

    $reqPath = Join-Path $ChangeDir "REQUIREMENT.md"
    if (Test-Path -LiteralPath $reqPath) {
        $text = Get-Content -Raw -Encoding utf8 -LiteralPath $reqPath
        if (@([regex]::Matches($text, "AC-\d{2}")).Count -eq 0) {
            Add-Issue "REQUIREMENT.md: no AC-XX acceptance criteria found"
        }
    }

    $verifyPath = Join-Path $ChangeDir "VERIFY.md"
    if (Test-Path -LiteralPath $verifyPath) {
        $text = Get-Content -Raw -Encoding utf8 -LiteralPath $verifyPath
        if (@([regex]::Matches($text, "AC-\d{2}")).Count -eq 0) {
            Add-Issue "VERIFY.md: no AC evidence rows found"
        }
    }

    $designPath = Join-Path $ChangeDir "DESIGN.md"
    if (Test-Path -LiteralPath $designPath) {
        $text = Get-Content -Raw -Encoding utf8 -LiteralPath $designPath
        $codeRefs = @([regex]::Matches($text, '`[^`]+\.(java|ts|py|go|rs|kt|cs|sql|yaml|json|xml|ps1|sh)`')).Count
        if ($codeRefs -lt 3) {
            Add-Issue "DESIGN.md: only $codeRefs code reference(s); expected at least 3"
        }
    }
}

# ── Scaffold content check (when -ProjectRoot is provided) ──
if ($ProjectRoot) {
    if (-not (Test-Path -LiteralPath $ProjectRoot)) {
        Write-Host "Project root not found: $ProjectRoot"
        exit 1
    }

    $scaffoldIssues = @()
    $scaffoldPass = 0
    $scaffoldFail = 0

    function Test-ScaffoldFile {
        param([string]$Label, [string]$Path)
        if (-not (Test-Path -LiteralPath $Path)) {
            $script:scaffoldIssues += "${Label}: missing"
            $script:scaffoldFail++
            return
        }
        # Skip files that are known to contain doc examples matching placeholder patterns
        $skipList = @("autonomy-policy.md", "router.md")
        if ($skipList -contains (Split-Path $Path -Leaf)) {
            $script:scaffoldPass++
            Write-Host "  PASS $Label (doc example patterns excluded)"
            return
        }
        if (Test-MeaningfulFile -Path $Path -Placeholders @("TODO", "TBD", "path/to", "{module}", "example")) {
            $script:scaffoldPass++
            Write-Host "  PASS $Label"
        } else {
            $script:scaffoldIssues += "${Label}: contains placeholders or missing meaningful content"
            $script:scaffoldFail++
        }
    }

    Write-Host ""
    Write-Host "Scaffold content check (core/ and rules/)"
    Write-Host "============================================================"

    $coreDir = Join-Path $ProjectRoot "agent-flow/core"
    $rulesDir = Join-Path $ProjectRoot "agent-flow/rules"

    if (Test-Path -LiteralPath $coreDir) {
        Get-ChildItem -Path $coreDir -Filter "*.md" | ForEach-Object {
            Test-ScaffoldFile -Label "core/$($_.Name)" -Path $_.FullName
        }
    }

    if (Test-Path -LiteralPath $rulesDir) {
        Get-ChildItem -Path $rulesDir | Where-Object { $_.Extension -in @(".md", ".keys", ".questions", ".txt") } | ForEach-Object {
            Test-ScaffoldFile -Label "rules/$($_.Name)" -Path $_.FullName
        }
    }

    $scaffoldTotal = $scaffoldPass + $scaffoldFail
    Write-Host ""
    Write-Host "Scaffold results: $scaffoldPass/$scaffoldTotal passed"
    if ($scaffoldFail -gt 0) {
        foreach ($issue in $scaffoldIssues) { Write-Host "    FAIL $issue" }
        $issues += $scaffoldIssues
    }
}

# ── Results ──
Write-Host ""
Write-Host "Results:"
Write-Host "  Passed: $passCount"
if ($issues.Count -gt 0) {
    Write-Host "  Failed: $($issues.Count)"
    foreach ($issue in $issues) { Write-Host "    FAIL $issue" }
    if ($Strict) { exit 2 }
} else {
    Write-Host "  All content checks passed"
}
