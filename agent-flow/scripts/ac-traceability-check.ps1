<#
.SYNOPSIS
Verify AC traceability: each AC-XX from REQUIREMENT.md must appear in DESIGN.md,
TASKS.md, VERIFY.md, and REPORT.md.
.DESCRIPTION
Part of the agent-flow scaffold toolchain. Reads REQUIREMENT.md to find all AC IDs,
then checks each downstream artifact for mentions of those IDs.
.PARAMETER ChangeDir
Path to the change directory (e.g., agent-flow/changes/my-change).
.PARAMETER Repair
If set, annotates missing AC references into VERIFY.md (appends a TODO section).
.EXAMPLE
agent-flow/scripts/ac-traceability-check.ps1 -ChangeDir agent-flow/changes/my-change
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [switch]$Repair
)
$ErrorActionPreference = "Stop"

$files = @{
    requirement = Join-Path $ChangeDir "REQUIREMENT.md"
    design      = Join-Path $ChangeDir "DESIGN.md"
    tasks       = Join-Path $ChangeDir "TASKS.md"
    verify      = Join-Path $ChangeDir "VERIFY.md"
    report      = Join-Path $ChangeDir "REPORT.md"
}

# 1. Extract ACs from REQUIREMENT.md (source of truth for what ACs exist)
if (-not (Test-Path $files.requirement)) {
    Write-Host "⚠️  REQUIREMENT.md not found — cannot verify AC traceability. Skipping." -ForegroundColor Yellow
    exit 0
}

$reqContent = Get-Content $files.requirement -Raw -Encoding utf8 -ErrorAction SilentlyContinue
$allAcs = [regex]::Matches($reqContent, 'AC-\d+') | ForEach-Object { $_.Value } | Sort-Object -Unique
$acCount = $allAcs.Count
if ($acCount -eq 0) {
    Write-Host "ℹ️  No AC-XX references found in REQUIREMENT.md. Traceability check not applicable." -ForegroundColor Cyan
    exit 0
}

Write-Host "🔍 AC Traceability Check" -ForegroundColor Cyan
Write-Host "   Change: $ChangeDir"
Write-Host "   REQ ACs: $acCount ($($allAcs -join ', '))"
Write-Host ""

# 2. Check each downstream artifact
$artifacts = @{
    "DESIGN.md"   = $files.design
    "TASKS.md"    = $files.tasks
    "VERIFY.md"   = $files.verify
    "REPORT.md"   = $files.report
}

$results = @{}
foreach ($label in $artifacts.Keys) {
    $path = $artifacts[$label]
    if (-not (Test-Path $path)) {
        Write-Host "   ⏭️  $label — not present (skipped)" -ForegroundColor DarkYellow
        continue
    }
    $content = Get-Content $path -Raw -Encoding utf8 -ErrorAction SilentlyContinue
    $missing = @()
    foreach ($ac in $allAcs) {
        if ($content -notmatch [regex]::Escape($ac)) {
            $missing += $ac
        }
    }
    $results[$label] = @{
        path = $path
        missing = $missing
        totalMissing = $missing.Count
        content = $content
    }
    if ($missing.Count -eq 0) {
        Write-Host "   ✅ $label — all ACs present ($acCount/$acCount)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $label — missing $($missing.Count) AC(s): $($missing -join ', ')" -ForegroundColor Red
    }
}

# 3. Summary
Write-Host ""
$totalMissing = ($results.Values | ForEach-Object { $_.totalMissing } | Measure-Object -Sum).Sum
if ($totalMissing -eq 0) {
    Write-Host "✅ AC Traceability: PASS (all $acCount ACs traced through all artifacts)" -ForegroundColor Green
} else {
    Write-Host "❌ AC Traceability: FAIL ($totalMissing missing AC references)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Traceability Matrix:" -ForegroundColor Yellow
    Write-Host ""

    # Header
    Write-Host ("{0,-20}" -f "AC ID") -NoNewline
    foreach ($label in @("DESIGN.md", "TASKS.md", "VERIFY.md", "REPORT.md")) {
        Write-Host ("{0,-15}" -f $label) -NoNewline
    }
    Write-Host ""

    foreach ($ac in $allAcs) {
        Write-Host ("{0,-20}" -f $ac) -NoNewline
        foreach ($label in @("DESIGN.md", "TASKS.md", "VERIFY.md", "REPORT.md")) {
            if ($results.ContainsKey($label) -and $results[$label].missing -contains $ac) {
                Write-Host ("{0,-15}" -f "❌") -NoNewline -ForegroundColor Red
            } elseif ($results.ContainsKey($label) -and -not ($results[$label].missing -contains $ac)) {
                Write-Host ("{0,-15}" -f "✅") -NoNewline -ForegroundColor Green
            } else {
                Write-Host ("{0,-15}" -f "⏭️") -NoNewline -ForegroundColor DarkYellow
            }
        }
        Write-Host ""
    }

    # 4. Repair mode
    if ($Repair -and (Test-Path $files.verify)) {
        Write-Host ""
        Write-Host "🔧 Repair mode: annotating missing ACs into VERIFY.md..." -ForegroundColor Yellow
        $verifyContent = $results["VERIFY.md"].content
        $missingInVerify = $results["VERIFY.md"].missing
        if ($missingInVerify.Count -gt 0) {
            $addendum = @"
## AC Traceability (auto-annotated by ac-traceability-check)

> The following ACs are defined in REQUIREMENT.md but not yet referenced in VERIFY.md.
> Fill in verification evidence before declaring completion.

| AC | Verification Evidence |
|----|-----------------------|
"@
            foreach ($ac in $missingInVerify) {
                $addendum += "`n| $ac | (TODO: add verification evidence) |"
            }
            $verifyContent += "`n`n$addendum"
            Set-Content -Path $files.verify -Value $verifyContent -Encoding utf8 -NoNewline
            Write-Host "✅ VERIFY.md annotated with $($missingInVerify.Count) missing AC(s)." -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "💡 Tip: AC IDs must be consistent. Use AC-01, AC-02 format in all change artifacts." -ForegroundColor DarkCyan
