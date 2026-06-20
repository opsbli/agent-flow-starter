<#
.SYNOPSIS
Run the actionlint-check agent-flow gate.

.DESCRIPTION
Validates GitHub Actions workflow YAML files using actionlint.
Checks .github/workflows/*.yml for syntax errors, missing required fields,
and common pitfalls.

Non-blocking: warns but does not fail — actionlint may not be installed
in all environments.

Part of the agent-flow scaffold toolchain. Run from the project root.

.PARAMETER ProjectRoot
Path to the project root (default: current directory).

.EXAMPLE
agent-flow/scripts/actionlint-check.ps1
agent-flow/scripts/actionlint-check.ps1 -ProjectRoot .
#>

param(
    [string]$ProjectRoot = "."
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectPath {
    param([string]$Path)
    $resolved = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { [System.IO.Path]::Combine((Get-Location).Path, $Path) }
    return [System.IO.Path]::GetFullPath($resolved)
}

$projectRootPath = Resolve-ProjectPath -Path $ProjectRoot

Write-Host "=== GitHub Actions Workflow Validation (actionlint) ==="

# Find workflow files
$workflowDir = Join-Path $projectRootPath ".github/workflows"
if (-not (Test-Path -LiteralPath $workflowDir)) {
    Write-Host "SKIP: No .github/workflows directory found at $workflowDir"
    exit 0
}

$wfFiles = @(Get-ChildItem -Path $workflowDir -Filter "*.yml" -ErrorAction SilentlyContinue) +
           @(Get-ChildItem -Path $workflowDir -Filter "*.yaml" -ErrorAction SilentlyContinue)

if ($wfFiles.Count -eq 0) {
    Write-Host "SKIP: No workflow YAML files found in $workflowDir"
    exit 0
}

Write-Host "Found $($wfFiles.Count) workflow file(s) in $workflowDir"

# Check if actionlint is available
$actionlintAvailable = $null -ne (Get-Command "actionlint" -ErrorAction SilentlyContinue)

if (-not $actionlintAvailable) {
    Write-Host "⚠️  actionlint not installed. Skipping validation."
    Write-Host ""
    Write-Host "  To install:"
    Write-Host "    brew install actionlint                          # macOS"
    Write-Host "    go install github.com/rhysd/actionlint/cmd/actionlint@latest  # Go"
    Write-Host "    conda install -c conda-forge actionlint           # Conda"
    Write-Host ""
    Write-Host "actionlint-check skipped (tool not available)."
    exit 0
}

# Run actionlint
$issues = 0
foreach ($wf in $wfFiles) {
    $wfName = $wf.Name
    Write-Host ""
    Write-Host "--- $wfName ---"

    $result = & actionlint --format='{{range $}}{{println .}}' $wf.FullName 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0 -and $result) {
        $result | ForEach-Object { Write-Host $_ }
        $lineCount = @($result).Count
        $issues += $lineCount
    } else {
        Write-Host "  ✅ No issues found"
    }
}

Write-Host ""
Write-Host "============================================"
Write-Host "actionlint-check: $issues issue(s) found in $($wfFiles.Count) workflow file(s)."
Write-Host ""
Write-Host "  This check is advisory (non-blocking). Review warnings above."
Write-Host "  To suppress specific rule warnings, add a comment:"
Write-Host "    # actionlint-ignore: <rule-id>"
Write-Host ""

exit 0
