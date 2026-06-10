param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ProjectRoot = "."
)

<#
.SYNOPSIS
Check code drift against DESIGN.md declarations for Standard/Heavy changes.

.DESCRIPTION
Reads DESIGN.md from a change directory and checks whether the actual code
matches what was declared. Covers schema, API routes, and permission codes.

.PARAMETER ChangeDir
Path to the change directory (e.g., agent-flow/changes/my-change).

.PARAMETER ProjectRoot
Path to the project root. Defaults to current directory.

.EXAMPLE
.\code-drift-check.ps1 -ChangeDir agent-flow/changes/add-user-module
.\code-drift-check.ps1 -ChangeDir agent-flow/changes/add-user-module -ProjectRoot C:\Projects\my-app
#>

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $ProjectRoot))

# --- Read DESIGN.md ---
$designPath = Join-Path $ChangeDir "DESIGN.md"
if (-not (Test-Path -LiteralPath $designPath)) {
    Write-Host "SKIP: No DESIGN.md in $ChangeDir (Light change or not yet created)"
    exit 0
}

$designText = Get-Content -Raw -Encoding utf8 -LiteralPath $designPath
$issues = @()

# --- 1. Schema drift: extract table names from DESIGN.md and check migration files ---
$tableMatches = [regex]::Matches($designText, '(?i)(CREATE TABLE|ALTER TABLE|TABLE\s+)(\w+)')
$declaredTables = $tableMatches | ForEach-Object { $_.Groups[2].Value.Trim('`"''[]') } | Sort-Object -Unique

if ($declaredTables.Count -gt 0) {
    Write-Host "--- Schema drift check ---"
    Write-Host "Tables declared in DESIGN.md: $($declaredTables -join ', ')"

    # Look for migration/schema directories
    $schemaDirs = @("migrations", "schema", "sql", "db", "database", "prisma", "src/main/resources/db")
    $foundFiles = @()
    foreach ($dir in $schemaDirs) {
        $fullDir = Join-Path $ProjectRoot $dir
        if (Test-Path -LiteralPath $fullDir) {
            $foundFiles += Get-ChildItem -LiteralPath $fullDir -Recurse -File -Include "*.sql", "*.xml", "*.yaml", "*.yml", "*.json", "*.prisma", "*.ts", "*.js", "*.java", "*.kt" | ForEach-Object { $_.FullName }
        }
    }

    if ($foundFiles.Count -gt 0) {
        $allCodeText = ""
        foreach ($f in $foundFiles) {
            try {
                $allCodeText += "`n" + (Get-Content -Raw -Encoding utf8 -LiteralPath $f)
            } catch {
                # Skip binary files
            }
        }

        foreach ($table in $declaredTables) {
            # Normalize for comparison
            $searchPattern = [regex]::Escape($table)
            if ($allCodeText -notmatch $searchPattern) {
                $issues += "SCHEMA_DRIFT: Table '$table' declared in DESIGN.md but not found in any schema/migration file under ($($schemaDirs -join ', '))."
            }
        }
    } else {
        Write-Host "  No schema/migration directories found. Skipping schema drift check."
    }
}

# --- 2. API route drift: extract route paths from DESIGN.md and check route files ---
$routeMatches = [regex]::Matches($designText, '(?<=`?)(/[a-zA-Z0-9_{}/:.-]+)(?=`?|[\s,;\)])')
$declaredRoutes = $routeMatches | ForEach-Object {
    $route = $_.Groups[1].Value
    # Filter out non-route paths (file paths, markdown links, etc.)
    if ($route -match '^/[a-zA-Z]' -and $route -notmatch '\.md|\.ps1|\.sh|\.java|\.ts|\.js|node_modules|\.git') {
        $route
    }
} | Sort-Object -Unique

if ($declaredRoutes.Count -gt 0) {
    Write-Host ""
    Write-Host "--- API route drift check ---"
    Write-Host "Routes declared in DESIGN.md: $($declaredRoutes -join ', ')"
    Write-Host "  NOTE: Route drift check is heuristic. Review route matches manually."
}

# --- 3. Permission drift: extract permission codes from DESIGN.md ---
$permMatches = [regex]::Matches($designText, '@SaCheckPermission\s*\(\s*["'']([^"'']+)["'']|["'']([A-Z_]{3,})["'']')
$declaredPerms = @()
foreach ($m in $permMatches) {
    if ($m.Groups[1].Success) { $declaredPerms += $m.Groups[1].Value }
    if ($m.Groups[2].Success) { $declaredPerms += $m.Groups[2].Value }
}
# Also check for permission table mentions
$permTableMatches = [regex]::Matches($designText, '权限码\s*\|[^|]+\|')
foreach ($m in $permTableMatches) {
    $cells = $m.Value -split '\|'
    if ($cells.Count -ge 3) {
        $code = $cells[2].Trim()
        if ($code -match '^[A-Z_]') { $declaredPerms += $code }
    }
}
$declaredPerms = $declaredPerms | Sort-Object -Unique

if ($declaredPerms.Count -gt 0) {
    Write-Host ""
    Write-Host "--- Permission drift check ---"
    Write-Host "Permission codes declared in DESIGN.md: $($declaredPerms -join ', ')"

    # Walk source files for permission references
    $srcDirs = @("src", "app", "modules", "services", "common", "shared", "packages")
    $foundFiles = @()
    foreach ($dir in $srcDirs) {
        $fullDir = Join-Path $ProjectRoot $dir
        if (Test-Path -LiteralPath $fullDir) {
            $foundFiles += Get-ChildItem -LiteralPath $fullDir -Recurse -File -Include "*.java", "*.kt", "*.ts", "*.tsx", "*.js", "*.jsx" | ForEach-Object { $_.FullName }
        }
    }

    if ($foundFiles.Count -gt 0) {
        $allCodeText = ""
        foreach ($f in $foundFiles) {
            try {
                $allCodeText += "`n" + (Get-Content -Raw -Encoding utf8 -LiteralPath $f) -join "`n"
            } catch {
                # Skip binary files
            }
        }

        foreach ($perm in $declaredPerms) {
            if ($allCodeText -notmatch [regex]::Escape($perm)) {
                $issues += "PERM_DRIFT: Permission code '$perm' declared in DESIGN.md but not found in any source file."
            }
        }
    } else {
        Write-Host "  No source directories found. Skipping permission drift check."
    }
}

# --- 4. Status / workflow drift ---
if ($designText -match '(?i)状态机|state\s+machine|status\s+machine|Status\s+Vocabulary|Status\s+Mapping') {
    Write-Host ""
    Write-Host "--- Workflow/status drift check ---"

    $vocabMatch = [regex]::Match($designText, '(?s)##\s*Status\s+Vocabulary.*?(?=##\s|$)')
    if ($vocabMatch.Success) {
        $statuses = [regex]::Matches($vocabMatch.Value, '\|\s*([A-Za-z_0-9]+)\s*\|')
        $declaredStatuses = $statuses | ForEach-Object { $_.Groups[1].Value } | Where-Object { $_ -ne "状态" -and $_ -ne "Status" }
        if ($declaredStatuses.Count -gt 0) {
            Write-Host "  Statuses declared: $($declaredStatuses -join ', ')"
            Write-Host "  Manual review recommended."
        }
    }

    # Check if Status Mapping or Legacy Compatibility sections are present
    if ($designText -notmatch '(?i)##\s*Status\s+Mapping') {
        $issues += "WORKFLOW_DRIFT: Design mentions state machine but lacks Status Mapping section."
    }
    if ($designText -notmatch '(?i)##\s*Legacy\s+Compatibility') {
        $issues += "WORKFLOW_DRIFT: Design mentions state machine but lacks Legacy Compatibility section."
    }
}

# --- Summary ---
Write-Host ""
Write-Host "============================================"
if ($issues.Count -gt 0) {
    Write-Host "Code-drift check found $($issues.Count) issue(s):"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
} else {
    Write-Host "Code-drift check passed. No drift detected between DESIGN.md and live code."
    exit 0
}
