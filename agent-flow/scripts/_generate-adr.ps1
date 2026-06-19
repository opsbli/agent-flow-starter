<#
.SYNOPSIS
Generate an ADR file and update INDEX.md.

.DESCRIPTION
Creates a new ADR file with the next available number and updates the decisions
INDEX.md. Optionally reads context from DESIGN.md's ADR 候选 section.

.PARAMETER Title
ADR title (required).

.PARAMETER Status
ADR status: Proposed, Accepted, Deprecated, or Superseded (default: Proposed).

.PARAMETER Supersedes
ADR this one supersedes, e.g. ADR-0001.

.PARAMETER ChangeDir
Change directory to read DESIGN.md context from.

.PARAMETER DecisionsRoot
Decisions directory (default: agent-flow/decisions).

.EXAMPLE
agent-flow/scripts/generate-adr.ps1 -Title "Use State Machine Pattern for Approval" -ChangeDir agent-flow/changes/approval-workflow
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Title,
    [ValidateSet("Proposed", "Accepted", "Deprecated", "Superseded")]
    [string]$Status = "Proposed",
    [string]$Supersedes = "",
    [string]$ChangeDir = "",
    [string]$DecisionsRoot = "agent-flow/decisions"
)

$ErrorActionPreference = "Stop"

# Determine next ADR number
$decisionsDir = $DecisionsRoot
if (-not (Test-Path $decisionsDir)) { New-Item -ItemType Directory -Path $decisionsDir -Force | Out-Null }

$maxNum = 0
Get-ChildItem -Path "$decisionsDir/ADR-*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    $num = [int]($_.Name -replace 'ADR-0*(\d+).*', '$1')
    if ($num -gt $maxNum) { $maxNum = $num }
}
$nextNum = $maxNum + 1
$adrId = "ADR-$($nextNum.ToString('0000'))"

# Slug
$slug = $Title.ToLower() -replace '[^a-z0-9]+', '-' -replace '^-', '' -replace '-$', ''
if (-not $slug) { $slug = "untitled" }

$adrFile = Join-Path $decisionsDir "$adrId-$slug.md"
if (Test-Path $adrFile) { throw "ADR file already exists: $adrFile" }

# Extract context from change_dir
$background = "TBD — describe the context that led to this decision."
if ($ChangeDir -and (Test-Path (Join-Path $ChangeDir "DESIGN.md"))) {
    $designText = Get-Content -Raw -Encoding utf8 (Join-Path $ChangeDir "DESIGN.md")
    if ($designText -match '(?s)## ADR 候选(.*?)(?=## )') {
        $candidateText = $matches[1].Trim()
        if ($candidateText -and $candidateText -notmatch '^(none|无)$') {
            $background = $candidateText
        }
    }
}

# Create ADR file
$content = @"
# $adrId: $Title

## 状态

$Status

## Supersedes

$(if ($Supersedes) { $Supersedes } else { "none" })

## Superseded By

none

## 背景

$background

## 决策

TBD — describe the chosen approach.

## 备选方案

TBD — list alternatives that were considered.

## 取舍

TBD — explain the trade-offs.

## 后果

TBD — describe the consequences of this decision.

## 触发 change

$(if ($ChangeDir) { $ChangeDir } else { "TBD" })

## 日期

$(Get-Date -Format 'yyyy-MM-dd')

## 索引维护

- [ ] 已更新 \`$DecisionsRoot/INDEX.md\`
- [ ] Status / Supersedes / Superseded By 与索引一致
"@

$content | Set-Content -Path $adrFile -Encoding utf8
Write-Host "Created: $adrFile"

# Update INDEX.md
$indexFile = Join-Path $decisionsDir "INDEX.md"
if (Test-Path $indexFile) {
    $indexContent = Get-Content -Raw -Encoding utf8 $indexFile
    $newRow = "| $adrId | $Title | $Status | $(if ($Supersedes) { $Supersedes } else { 'none' }) | none | $(if ($ChangeDir) { $ChangeDir } else { 'TBD' }) | $(Get-Date -Format 'yyyy-MM-dd') |"

    if ($indexContent -match '(?m)^\| ADR-') {
        # Add after the last ADR row
        $lastAdrRow = [regex]::Match($indexContent, '(?m)^\| ADR-.*$', 'RightToLeft').Value
        $indexContent = $indexContent.Replace($lastAdrRow, "$lastAdrRow`r`n$newRow")
    } elseif ($indexContent -match '(?m)^\|-+\|-+') {
        # Add after table header separator
        $indexContent = $indexContent -replace '(?m)^(\|-+\|-+)', "`$1`r`n$newRow"
    } else {
        $indexContent += "`r`n$newRow"
    }

    $indexContent | Set-Content -Path $indexFile -Encoding utf8
    Write-Host "Updated: $indexFile"
} else {
    Write-Host "WARNING: INDEX.md not found at $indexFile. Create it manually."
}

Write-Host ""
Write-Host "ADR $adrId created successfully."
