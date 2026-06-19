<#
.SYNOPSIS
Detect drift between project structure and agent-flow/manifest.yaml.

.DESCRIPTION
Part of the agent-flow scaffold toolchain.
Scans the project for clues about backend framework, frontend framework,
database, cache, auth, and build system, then compares with manifest.yaml.
Reports mismatches and suggests updates.

.PARAMETER ProjectRoot
Project root path (default: current directory).

.PARAMETER Output
Output file path for the drift report.

.EXAMPLE
agent-flow/scripts/manifest-drift-check.ps1
#>

param(
    [string]$ProjectRoot = ".",
    [string]$Output = ""
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($ProjectRoot)
$manifestPath = Join-Path $root "agent-flow/manifest.yaml"

if (-not (Test-Path $manifestPath)) {
    Write-Host "No manifest.yaml found at $manifestPath" -ForegroundColor Yellow
    exit 0
}

# ── Read current manifest ──
$manifest = Get-Content -Raw -Encoding utf8 -LiteralPath $manifestPath

# ── Detect actual project structure ──
function HasFile($Path) { Test-Path -LiteralPath (Join-Path $root $Path) }

$detected = @{}
$mismatches = @()

# Backend detection
if (HasFile "pom.xml") { $detected.build = "Maven"; $detected.language = "Java" }
elseif (HasFile "build.gradle") { $detected.build = "Gradle"; $detected.language = "Java/Kotlin" }
elseif (HasFile "pyproject.toml") { $detected.build = "Python"; $detected.language = "Python" }
elseif (HasFile "go.mod") { $detected.build = "Go"; $detected.language = "Go" }
elseif (HasFile "Cargo.toml") { $detected.build = "Cargo"; $detected.language = "Rust" }
else { $detected.build = "unknown"; $detected.language = "unknown" }

# Frontend detection
if (HasFile "package.json") {
    $detected.hasFrontend = $true
    $depsText = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $root "package.json")
    if ($depsText -match '"vue"') { $detected.frontendFramework = "Vue" }
    elseif ($depsText -match '"react"') { $detected.frontendFramework = "React" }
    elseif ($depsText -match '"next"') { $detected.frontendFramework = "Next.js" }
    else { $detected.frontendFramework = "Node/Web" }
} else { $detected.hasFrontend = $false }

# Database detection
$dbDirs = @("migrations", "schema", "sql", "db", "database", "prisma", "sequelize", "typeorm")
$detected.hasDatabase = $false
foreach ($d in $dbDirs) {
    if (HasFile $d) { $detected.hasDatabase = $true; break }
}
# Check for common DB configs
if ($manifest -match "database:\s*\n\s+engine:\s*(.+?)\s*$") {
    $manifestDb = $matches[1].Trim()
    if ($manifestDb -ne "none" -and -not $detected.hasDatabase) {
        $mismatches += "manifest says DB engine '$manifestDb' but no SQL/migration paths found in project"
    }
    if ($manifestDb -eq "none" -and $detected.hasDatabase) {
        $mismatches += "manifest says no database, but migration/schema directories exist in project"
    }
}

# Auth detection
if ($manifest -match "auth:\s*\n\s+engine:\s*(.+?)\s*$") {
    $manifestAuth = $matches[1].Trim()
    # Check if auth-related files exist
    $authFiles = @("auth", "Auth", "oauth", "OAuth", "jwt", "JWT", "session", "permission")
    $foundAuth = $false
    foreach ($af in $authFiles) {
        $searchPath = Join-Path $root "src"
        if (Test-Path $searchPath) {
            $authMatches = Get-ChildItem -Recurse -File -LiteralPath $searchPath -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match $af } | Select-Object -First 1
            if ($authMatches) { $foundAuth = $true; break }
        }
    }
    if ($manifestAuth -ne "none" -and -not $foundAuth) {
        $mismatches += "manifest says auth engine '$manifestAuth' but no auth-related source files found"
    }
    if ($manifestAuth -eq "none" -and $foundAuth) {
        $mismatches += "manifest says no auth, but auth-related source files exist in project"
    }
}

# Frontend verification check
if ($detected.hasFrontend -and $manifest -match "verify_required:\s*false") {
    $mismatches += "Frontend package.json detected but manifest says verify_required: false"
}
if (-not $detected.hasFrontend -and $manifest -match "verify_required:\s*true") {
    $mismatches += "No frontend detected but manifest says verify_required: true"
}

# Build files check
$expectedBuildFiles = @("package.json", "pom.xml", "build.gradle", "pyproject.toml", "go.mod", "Cargo.toml", "pnpm-workspace.yaml", "tsconfig.json")
$registeredBuildFiles = @()
if ($manifest -match "(?s)build_files:\s*\n((?:\s+- .*\n?)*)") {
    $registeredBuildFiles = $matches[1] -split "`n" | ForEach-Object { $_ -replace "^\s*-\s*", "" } | Where-Object { $_ }
}
$missingFromManifest = @()
foreach ($f in $expectedBuildFiles) {
    if (HasFile $f -and ($registeredBuildFiles -notcontains $f)) {
        $missingFromManifest += $f
    }
}
if ($missingFromManifest.Count -gt 0) {
    $mismatches += "Build files exist but not registered in manifest.yaml: $($missingFromManifest -join ', ')"
}

# ── Build report ──
$reportLines = @(
    "# Manifest Drift Report",
    "",
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    "Project: $(Split-Path -Leaf $root)",
    "",
    "## Detected Project State",
    "",
    "| Aspect | Detected | Manifest Says |",
    "|--------|----------|--------------|",
    "| Build system | $($detected.build) | $(if($manifest -match 'build:\s*(.+?)\s*$'){$matches[1].Trim()}else{'unknown'}) |",
    "| Language | $($detected.language) | $(if($manifest -match 'language:\s*(.+?)\s*$'){$matches[1].Trim()}else{'unknown'}) |",
    "| Frontend | $(if($detected.hasFrontend){$detected.frontendFramework}else{'none'}) | $(if($manifest -match 'framework:\s*(.+?)\s*$'){$matches[1].Trim()}else{'unknown'}) |",
    ""
)

if ($mismatches.Count -gt 0) {
    $reportLines += "## ⚠️ Drift Detected"
    $reportLines += ""
    foreach ($m in $mismatches) {
        $reportLines += "- $m"
    }
    $reportLines += ""
    $reportLines += "## Recommended Actions"
    $reportLines += ""
    $reportLines += "1. Run \`agent-flow/scripts/init-wizard.ps1\` to re-initialize manifest.yaml"
    $reportLines += "2. Or manually update \`agent-flow/manifest.yaml\` to match actual project structure"
    $reportLines += "3. Run \`agent-flow/scripts/manifest-check.ps1\` after updating"
} else {
    $reportLines += "## ✅ No Drift Detected"
    $reportLines += ""
    $reportLines += "Project structure matches manifest.yaml. No updates needed."
}

$reportLines += ""
$reportLines += "---"
$reportLines += "*Generated by manifest-drift-check.ps1*"

$reportText = $reportLines -join "`r`n"

if ($Output) {
    $reportText | Set-Content -Path $Output -Encoding utf8
    Write-Host "Report written to: $Output"
} else {
    Write-Host $reportText
}
