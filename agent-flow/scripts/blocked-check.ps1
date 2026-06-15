<#
.SYNOPSIS
Run the blocked-check agent-flow script.
.DESCRIPTION
Detects if the change violates manifest.yaml blocked_if rules.
Detection modes: auto (static analysis) + manual (requires human review).
Auto-detected violations: hard_delete_without_approval, disable_security_filter.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ChangeDir
Parameter accepted by this script.

.PARAMETER ProjectRoot
Parameter accepted by this script.

.PARAMETER Manifest
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/blocked-check.ps1
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ProjectRoot = ".",
    [string]$Manifest = "agent-flow/manifest.yaml"
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Get-WriteFiles {
    param([string]$TasksPath)

    if (-not (Test-Path -LiteralPath $TasksPath)) {
        return @()
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $TasksPath
    $files = @()
    $inWriteFiles = $false
    foreach ($line in ($text -split "`n")) {
        if ($line -match '^\s*write_files\s*:') {
            $inWriteFiles = $true
            continue
        }
        if ($inWriteFiles -and ($line -match '^\s*##\s+' -or $line -match '^\s*[A-Za-z0-9_-]+\s*:\s*$')) {
            $inWriteFiles = $false
        }
        if ($inWriteFiles -and $line -match '^\s*-\s+(.+)$') {
            $value = $matches[1].Trim()
            $files += $value.Trim([char[]]@([char]0x60, [char]0x27, [char]0x22))
        }
    }
    return $files | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
}

$projectRootPath = Resolve-ProjectPath -Path $ProjectRoot
$manifestPath = Join-Path $projectRootPath $Manifest
if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Host "SKIP: Manifest not found at $manifestPath"
    exit 0
}

$manifestText = Get-Content -Raw -Encoding utf8 -LiteralPath $manifestPath
$blockedRules = @()
$inBlocked = $false
foreach ($line in ($manifestText -split "`n")) {
    if ($line -match '^\s*blocked_if:\s*$') {
        $inBlocked = $true
        continue
    }
    if ($inBlocked -and $line.Trim() -match '^-\s+(.+)$') {
        $blockedRules += $matches[1].Trim()
        continue
    }
    if ($inBlocked -and -not [string]::IsNullOrWhiteSpace($line)) {
        break
    }
}

if ($blockedRules.Count -eq 0) {
    Write-Host "SKIP: No blocked_if rules defined in manifest.yaml"
    exit 0
}

$changeDirPath = Resolve-ProjectPath -Path $ChangeDir
if (-not (Test-Path -LiteralPath $changeDirPath)) {
    throw "ChangeDir not found: $changeDirPath"
}

Write-Host "=== Blocked-if check ==="
Write-Host "Blocked rules active: $($blockedRules -join ', ')"
Write-Host ""

$allText = ""
Get-ChildItem -LiteralPath $changeDirPath -Filter "*.md" -File |
    ForEach-Object {
        $allText += "`n" + (Get-Content -Raw -Encoding utf8 -LiteralPath $_.FullName)
    }

$tasksPath = Join-Path $changeDirPath "TASKS.md"
foreach ($relativeFile in (Get-WriteFiles -TasksPath $tasksPath)) {
    $normalizedRelativeFile = ($relativeFile -replace '\\', '/')
    if ($normalizedRelativeFile -in @("agent-flow/scripts/blocked-check.ps1", "agent-flow/scripts/blocked-check.sh")) {
        continue
    }

    $fullPath = Join-Path $projectRootPath $relativeFile
    if (Test-Path -LiteralPath $fullPath) {
        try {
            $allText += "`n" + (Get-Content -Raw -Encoding utf8 -LiteralPath $fullPath)
        } catch {
            # Skip binary files.
        }
    }
}

# Rule identifiers such as payment_bypass are metadata, not risky code evidence.
$scanText = $allText
foreach ($rule in $blockedRules) {
    if (-not [string]::IsNullOrWhiteSpace($rule)) {
        $scanText = [regex]::Replace($scanText, "\b$([regex]::Escape($rule))\b", "blocked_rule_id", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
}
$allText = $scanText

$issues = @()
foreach ($rule in $blockedRules) {
    switch ($rule) {
        "hard_delete_without_approval" {
            if ($scanText -match '(?i)(DELETE\s+FROM|DROP\s+TABLE|TRUNCATE|DELETE\s+WHERE)') {
                if ($allText -notmatch '(?i)(approval|approved|reviewed|批准|确认|审核通过|#\s*CANCEL)') {
                    $issues += "BLOCKED: hard_delete_without_approval - Found destructive SQL/operation without explicit approval marker."
                }
            }
        }
        "disable_security_filter" {
            if ($scanText -match '(?i)(\.disable\(\)|\.permitAll\(\)|SecurityConfig|security\.ignoring|disable.*security|security.*bypass)') {
                if ($allText -notmatch '(?i)(#\s*EMERGENCY|#\s*APPROVED|approved.*security|security review|安全审核)') {
                    $issues += "BLOCKED: disable_security_filter - Found security filter disable/circumvention pattern without explicit approval."
                }
            }
        }
        "bypass_auth_for_production" {
            if ($scanText -match '(?i)(permitAll\(\)|\.anonymous\(\)|skipAuth|withoutAuth|noAuth|bypassAuth|@Anonymous)' -and
                $allText -match '(?i)(production|prod|live|public.?api|anonymous.*interface|生产|公开接口)') {
                $issues += "BLOCKED: bypass_auth_for_production - Found auth bypass pattern combined with production/public route reference."
            }
        }
        "direct_production_data_mutation" {
            if ($scanText -match '(?i)(UPDATE\s+.*SET|INSERT\s+INTO)\s+\w+' -and
                $allText -match '(?i)(production|prod|live|direct|execute|jdbcTemplate|Statement|native.*sql|生产|原生SQL)') {
                $issues += "BLOCKED: direct_production_data_mutation - Found direct data mutation pattern combined with production/native execution."
            }
        }
        "payment_bypass" {
            if ($allText -match '(?i)(payment|billing|charge|invoice|order.*paid|支付|账单|扣费|chargeback)' -and
                $allText -match '(?i)(skip|bypass|force|override|mark.*paid|绕过|跳过|直接.*完成)') {
                $issues += "BLOCKED: payment_bypass - Found payment/billing logic modification with bypass pattern."
            }
        }
        default {
            $searchTerm = $rule -replace '_', ' '
            if ($scanText -match [regex]::Escape($searchTerm)) {
                $issues += "BLOCKED: $rule - Rule triggered by text match in change artifacts."
            }
        }
    }
}

Write-Host ""
Write-Host "============================================"
if ($issues.Count -gt 0) {
    Write-Host "Blocked-if check found $($issues.Count) violation(s):"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Blocked-if check passed. No blocked operations detected."



