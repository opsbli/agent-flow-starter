<#
.SYNOPSIS
Search agent-flow knowledge and decisions.

.DESCRIPTION
Lightweight repository-local search for reusable knowledge before adding new
entries. This is intentionally plain text so it works in any target project.

.PARAMETER Query
Text to search for.

.PARAMETER KnowledgeRoot
Path to the knowledge directory.

.PARAMETER DecisionRoot
Path to the decisions directory.

.EXAMPLE
agent-flow/scripts/knowledge-search.ps1 -Query "permission"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Query,
    [string]$KnowledgeRoot = "agent-flow/knowledge",
    [string]$DecisionRoot = "agent-flow/decisions"
)

$ErrorActionPreference = "Stop"

$roots = @($KnowledgeRoot, $DecisionRoot) | Where-Object { Test-Path -LiteralPath $_ }
if ($roots.Count -eq 0) {
    Write-Host "Knowledge search failed:"
    Write-Host " - No searchable roots found."
    exit 2
}

$hits = @()
foreach ($root in $roots) {
    $files = Get-ChildItem -LiteralPath $root -Recurse -File -Include "*.md" -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $matches = Select-String -LiteralPath $file.FullName -SimpleMatch -Pattern $Query -ErrorAction SilentlyContinue
        foreach ($match in $matches) {
            $relative = Resolve-Path -LiteralPath $file.FullName -Relative
            $hits += "{0}:{1}: {2}" -f $relative, $match.LineNumber, $match.Line.Trim()
        }
    }
}

if ($hits.Count -eq 0) {
    Write-Host "No knowledge matches for: $Query"
    exit 1
}

$hits | ForEach-Object { Write-Host $_ }
