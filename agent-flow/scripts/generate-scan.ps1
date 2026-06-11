<#
.SYNOPSIS
Auto-generate CODE_SCAN.md by detecting project type and running appropriate scans.
.DESCRIPTION
Detects project tech stack, runs relevant scans, and fills CODE_SCAN.md template.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ProjectRoot = "."
)
$ErrorActionPreference = "Stop"
$scanOut = Join-Path $ChangeDir "CODE_SCAN.md"
if (Test-Path $scanOut) {
    Write-Host "CODE_SCAN.md already exists. Edit manually or delete to regenerate." -ForegroundColor Yellow
    exit 0
}
Write-Host "Detecting project type..." -ForegroundColor Cyan

# --- Detect tech stack ---
$stack = @{}
$stackNames = @()
if (Test-Path (Join-Path $ProjectRoot "package.json")) { 
    $stack["node"] = $true; $stackNames += "Node.js"
    try {
        $pkg = Get-Content (Join-Path $ProjectRoot "package.json") -Raw | ConvertFrom-Json
        if ($pkg.scripts) { $stack["scripts"] = $pkg.scripts | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name }
    } catch {}
}
if (Test-Path (Join-Path $ProjectRoot "pom.xml")) { $stack["java"] = $true; $stackNames += "Java/Maven" }
if (Test-Path (Join-Path $ProjectRoot "build.gradle")) { $stack["java"] = $true; $stackNames += "Java/Gradle" }
if (Test-Path (Join-Path $ProjectRoot "Cargo.toml")) { $stack["rust"] = $true; $stackNames += "Rust" }
if (Test-Path (Join-Path $ProjectRoot "go.mod")) { $stack["go"] = $true; $stackNames += "Go" }
if (Test-Path (Join-Path $ProjectRoot "pyproject.toml")) { $stack["python"] = $true; $stackNames += "Python" }
if (Test-Path (Join-Path $ProjectRoot "requirements.txt")) { $stack["python"] = $true; $stackNames += "Python" }
if (Test-Path (Join-Path $ProjectRoot "Gemfile")) { $stack["ruby"] = $true; $stackNames += "Ruby" }
if (Test-Path (Join-Path $ProjectRoot "*.sln")) { $stack["dotnet"] = $true; $stackNames += ".NET" }

# --- Run scans ---
$scanResults = @{}
Write-Host "Running project scans..." -ForegroundColor Cyan

# Build files
$buildFiles = @()
Get-ChildItem $ProjectRoot -File | Where-Object { $_.Name -match '^(package\.json|pom\.xml|build\.gradle|Cargo\.toml|go\.mod|pyproject\.toml|requirements\.txt|Gemfile|\.sln|compose\.yml|Dockerfile)$' } | ForEach-Object {
    $buildFiles += $_.Name
}
$scanResults["Build Files"] = $buildFiles -join ", "

# Source directories
$srcDirs = @()
Get-ChildItem $ProjectRoot -Directory | Where-Object { $_.Name -match '^(src|app|server|client|lib|cmd|pkg|internal|core|api|web|frontend|backend|services|components)$' } | ForEach-Object {
    $srcDirs += $_.Name
}
$scanResults["Source Directories"] = $srcDirs -join ", "

# Entry points
$entries = @()
if ($stack["node"]) {
    $nodeEntry = "index.js"
    try {
        $pkg = Get-Content (Join-Path $ProjectRoot "package.json") -Raw | ConvertFrom-Json
        if ($pkg.main) { $nodeEntry = $pkg.main }
        elseif ($pkg.bin) { $nodeEntry = "$($pkg.bin)" }
    } catch {}
    $entries += "Node entry: $nodeEntry"
}
if ($stack["java"]) {
    $entries += "Java: check pom.xml/build.gradle for main class"
}
if ($stack["rust"]) { $entries += "Rust: src/main.rs or src/lib.rs" }
if ($stack["go"]) { $entries += "Go: main.go or cmd/" }
$scanResults["Entry Points"] = $entries -join "; "

# Module structure
$modules = @()
if ($stack["node"]) {
    Get-ChildItem (Join-Path $ProjectRoot "node_modules") -ErrorAction SilentlyContinue | Select-Object -First 20 | ForEach-Object { $modules += $_.Name }
}
if ($modules.Count -eq 0 -and $stack["java"]) {
    Get-ChildItem $ProjectRoot -Directory | Where-Object { Test-Path (Join-Path $_.FullName "pom.xml") } | ForEach-Object { $modules += $_.Name }
}
$scanResults["Key Dependencies/Modules"] = if ($modules.Count -gt 0) { $modules -join ", " } else { "(not scanned)" }

# Test directories
$testDirs = @()
Get-ChildItem $ProjectRoot -Directory -Recurse -Depth 2 | Where-Object { $_.Name -match '^(test|tests|__tests__|spec|integration-test|e2e)$' } | ForEach-Object {
    $testDirs += $_.FullName.Replace("$ProjectRoot\", "").Replace("$ProjectRoot/", "")
}
$scanResults["Test Directories"] = if ($testDirs.Count -gt 0) { $testDirs -join ", " } else { "(none detected)" }

# Config files
$configs = @()
Get-ChildItem $ProjectRoot -File | Where-Object { $_.Name -match '^\..*(config|rc|json|yml|yaml|env|ini|conf)$' } | ForEach-Object {
    $configs += $_.Name
}
$scanResults["Config Files"] = $configs -join ", "

# --- Extract change scope ---
$changeDesc = "New feature/module"
$stateMd = Join-Path $ChangeDir "STATE.md"
if (Test-Path $stateMd) {
    $s = Get-Content $stateMd -Raw -Encoding utf8 -ErrorAction SilentlyContinue
    if ($s -match "(?s)goal[:：]\s*(.+?)[\r\n]") { $changeDesc = $Matches[1].Trim() }
}

# --- Generate CODE_SCAN.md ---
@"
# CODE_SCAN

## Project Overview

| Field | Value |
|-------|-------|
| **Tech Stack** | $($stackNames -join ", ") |
| **Build Files** | $($scanResults["Build Files"]) |
| **Source Dirs** | $($scanResults["Source Directories"]) |
| **Entry Points** | $($scanResults["Entry Points"]) |
| **Test Dirs** | $($scanResults["Test Directories"]) |
| **Config Files** | $($scanResults["Config Files"]) |
| **Change Scope** | $changeDesc |

## Code-First Findings

### 1. Similar Implementations

> Search project for similar features/modules. Look for naming patterns, existing service classes, or utility functions.

$(if ($stack["node"]) { "Search: Get-ChildItem -Recurse -Filter '*service*' -Name" } else { "Search: find . -name '*service*' -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null | head -10" })

### 2. Reusable Abstractions

- (list existing utilities, base classes, common patterns found)

### 3. Database Schema / Migrations

$(if (Test-Path (Join-Path $ProjectRoot "migrations")) -or (Test-Path (Join-Path $ProjectRoot "prisma"))) { "- Migration directory found. Review existing schema." } else { "- (no migration directory detected)" })

### 4. API Routes / Endpoints

- (scan for route definitions, controllers, or API declarations)

### 5. Permission / Auth Models

- (check for auth middleware, permission annotations, Sa-Token config)

### 6. Test Patterns

- (review existing tests for style and coverage expectations)

## Protected Areas Check

- [ ] Database schema change?
- [ ] Auth/permission change?
- [ ] Public API contract change?
- [ ] Deployment/production config change?
- [ ] Destructive data operation?

## Scan Notes

- Stack auto-detected: $($stackNames -join ", ")
- $(Get-Date -Format 'yyyy-MM-dd HH:mm')
- Use @ecc-explorer for deeper codebase reconnaissance

---
*Generated by generate-scan.ps1 — edit to add actual findings*
"@ | Set-Content $scanOut -Encoding utf8
Write-Host "CODE_SCAN.md generated: $scanOut" -ForegroundColor Green
Write-Host "  Stack: $($stackNames -join ', ')"
Write-Host "  Next: edit CODE_SCAN.md with actual findings, then run scan-check"
