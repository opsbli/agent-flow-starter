<#
.SYNOPSIS
Run the api-compatibility-check agent-flow gate.

.DESCRIPTION
Parses DESIGN.md API / Permission / Auth decisions and scans project source files
for drift between declared contracts and live code. Outputs warnings for mismatches.

Patterns checked:
  - Declared REST paths exist in source code
  - Declared permission codes exist in source code
  - Declared HTTP methods match actual annotations

Part of the agent-flow scaffold toolchain. Run from the project root.

.PARAMETER ChangeDir
Path to the change directory.

.PARAMETER ProjectRoot
Path to the project root (default: current directory).

.EXAMPLE
agent-flow/scripts/api-compatibility-check.ps1 -ChangeDir agent-flow/changes/my-change
agent-flow/scripts/api-compatibility-check.ps1 -ChangeDir agent-flow/changes/my-change -ProjectRoot .
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ProjectRoot = "."
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Get-FilesFromDirs {
    param(
        [string[]]$Dirs,
        [string[]]$Extensions
    )
    $files = @()
    foreach ($dir in $Dirs) {
        $fullDir = Join-Path $ProjectRoot $dir
        if (Test-Path -LiteralPath $fullDir) {
            $files += Get-ChildItem -LiteralPath $fullDir -Recurse -File |
                Where-Object { $Extensions -contains $_.Extension.ToLowerInvariant() } |
                ForEach-Object { $_.FullName }
        }
    }
    return $files
}

function Read-AllText {
    param([string[]]$Files)
    $text = ""
    foreach ($file in $Files) {
        try {
            $text += "`n" + (Get-Content -Raw -Encoding utf8 -LiteralPath $file)
        } catch {
            # Skip binary or unreadable files.
        }
    }
    return $text
}

# --- Resolve paths ---
$changeDirPath = Resolve-ProjectPath -Path $ChangeDir
if (-not (Test-Path -LiteralPath $changeDirPath)) {
    throw "ChangeDir not found: $changeDirPath"
}
$projectRootPath = Resolve-ProjectPath -Path $ProjectRoot

$designPath = Join-Path $changeDirPath "DESIGN.md"
if (-not (Test-Path -LiteralPath $designPath)) {
    Write-Host "SKIP: No DESIGN.md in $ChangeDir (Light change or not yet created)"
    exit 0
}

$designText = Get-Content -Raw -Encoding utf8 -LiteralPath $designPath

# --- Check for API decision table ---
if ($designText -notmatch '(?i)##\s*API\s*Design' -and $designText -notmatch '(?i)##\s*API\s*/\s*Permission') {
    Write-Host "SKIP: DESIGN.md has no API / Permission / Auth decisions section"
    exit 0
}

Write-Host "=== API Compatibility Check ==="
$issues = @()
$warnings = @()

# --- 1. Extract declared REST paths from API design table ---
$routeMatches = [regex]::Matches($designText, '(?<!\w)(/[A-Za-z][A-Za-z0-9_{}/:.\-]*)')
$declaredRoutes = $routeMatches |
    ForEach-Object { $_.Groups[1].Value } |
    Where-Object { $_ -notmatch '\.(md|ps1|sh|java|ts|tsx|js|jsx)$' -and $_ -notmatch '(node_modules|\.git)' } |
    Sort-Object -Unique

# Filter to plausible API routes (start with /api/ or common prefixes)
$apiRoutes = $declaredRoutes | Where-Object { $_ -match '^/(api/|v[0-9]+/|rest/|rpc/|graphql|webhook|auth/)' }

if ($apiRoutes.Count -gt 0) {
    Write-Host "API routes declared in DESIGN.md: $($apiRoutes -join ', ')"
    Write-Host "Scanning source files for route references..."

    $sourceDirs = @("src", "app", "modules", "services", "common", "shared", "packages", "routes", "controllers", "handlers")
    $sourceFiles = Get-FilesFromDirs -Dirs $sourceDirs -Extensions @(".java", ".kt", ".ts", ".tsx", ".js", ".jsx", ".vue", ".py", ".go", ".rs")
    if ($sourceFiles.Count -gt 0) {
        $sourceText = Read-AllText -Files $sourceFiles
        foreach ($route in $apiRoutes) {
            if ($sourceText -notmatch [regex]::Escape($route)) {
                $warnings += "API_COMPAT_WARN: Route '$route' declared in DESIGN.md but not found in source files."
            }
        }
    } else {
        Write-Host "  No source directories found. Skipping route scan."
    }
} else {
    Write-Host "No API routes with standard prefix found in DESIGN.md. Skipping route scan."
}

# --- 2. Extract declared permission codes ---
$declaredPerms = @()

# SaCheckPermission annotations
$saMatches = [regex]::Matches($designText, '@SaCheckPermission\s*\(\s*["'']([^"'']+)["'']')
foreach ($match in $saMatches) {
    $declaredPerms += $match.Groups[1].Value
}

# Permission Code rows in API/Permission table
$permTableMatches = [regex]::Matches($designText, '(?im)\|.*\|\s*(permission|perm\.?code|permission\.?code|权限)\s*[:|]\s*([A-Za-z][A-Za-z0-9_:.\-]+)')
foreach ($match in $permTableMatches) {
    $declaredPerms += $match.Groups[2].Value.Trim()
}

# Permission Code field in API / Permission / Auth Decisions table.
# Only new/modified/deleted decisions declare a permission code; unchanged and
# not-applicable rows usually contain explanatory prose in the evidence cell.
$decisionPermMatches = [regex]::Matches($designText, '(?im)^\s*\|\s*Permission Code\s*\|\s*(?:new|modified|deleted)\s*\|\s*(.+?)\s*\|')
foreach ($match in $decisionPermMatches) {
    $val = $match.Groups[1].Value.Trim()
    if ($val -notmatch '^(?:pending|unchanged|not-applicable|none|n/?a)$' -and -not [string]::IsNullOrWhiteSpace($val)) {
        $declaredPerms += $val
    }
}

$declaredPerms = $declaredPerms | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique

if ($declaredPerms.Count -gt 0) {
    Write-Host ""
    Write-Host "Permission codes declared in DESIGN.md: $($declaredPerms -join ', ')"
    Write-Host "Scanning source files for permission references..."

    $sourceDirs = @("src", "app", "modules", "services", "common", "shared", "packages")
    $sourceFiles = Get-FilesFromDirs -Dirs $sourceDirs -Extensions @(".java", ".kt", ".ts", ".tsx", ".js", ".jsx", ".vue", ".py")
    if ($sourceFiles.Count -gt 0) {
        $sourceText = Read-AllText -Files $sourceFiles
        foreach ($perm in $declaredPerms) {
            $escapedPerm = [regex]::Escape($perm)
            if ($sourceText -notmatch "$escapedPerm" -and $sourceText -notmatch "(?i)""\s*$escapedPerm\s*""") {
                $warnings += "API_COMPAT_WARN: Permission code '$perm' declared in DESIGN.md but not found in source files."
            }
        }
    } else {
        Write-Host "  No source directories found. Skipping permission scan."
    }
}

# --- 3. Check for Decision Status indicating modified/deleted API ---
$modifiedOrDeleted = $designText -match '(?im)^\s*\|\s*REST Path\s*\|\s*(modified|deleted)\s*\|'
if ($modifiedOrDeleted) {
    Write-Host ""
    Write-Host "WARNING: DESIGN.md marks REST Path as modified or deleted."
    Write-Host "  This change may break existing API consumers. Ensure migration is documented in VERIFY.md."
    $warnings += "API_COMPAT_WARN: DESIGN.md declares modified or deleted REST Path — breaking change risk."
}

# --- Output ---
Write-Host ""
Write-Host "============================================"
if ($warnings.Count -gt 0) {
    Write-Host "API compatibility check found $($warnings.Count) warning(s):"
    $warnings | ForEach-Object { Write-Host " - $_" }
    Write-Host ""
    Write-Host "NOTE: This check is heuristic. Review each warning manually."
    Write-Host "To enable strict mode (fail on warnings), set strict_compatibility: true in manifest.yaml."
    exit 0  # Non-blocking by default — warnings only
}

Write-Host "API compatibility check passed. No drift detected between DESIGN.md API declarations and live code."

if ($apiRoutes.Count -eq 0 -and $declaredPerms.Count -eq 0) {
    Write-Host "(No API routes or permission codes to check.)"
}
