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

$changeDirPath = Resolve-ProjectPath -Path $ChangeDir
if (-not (Test-Path -LiteralPath $changeDirPath)) {
    throw "ChangeDir not found: $changeDirPath"
}

$projectRootPath = Resolve-ProjectPath -Path $ProjectRoot
$designPath = Join-Path $changeDirPath "DESIGN.md"
if (-not (Test-Path -LiteralPath $designPath)) {
    Write-Host "SKIP: No DESIGN.md in $changeDirPath (Light change or not yet created)"
    exit 0
}

$designText = Get-Content -Raw -Encoding utf8 -LiteralPath $designPath
$issues = @()

function Get-FilesFromDirs {
    param(
        [string[]]$Dirs,
        [string[]]$Extensions
    )

    $files = @()
    foreach ($dir in $Dirs) {
        $fullDir = Join-Path $projectRootPath $dir
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

# 1. Schema drift.
$tableMatches = [regex]::Matches($designText, '(?i)\b(?:CREATE|ALTER)\s+TABLE\s+[`"\''\[]?([A-Za-z_][A-Za-z0-9_]*)')
$declaredTables = $tableMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

if ($declaredTables.Count -gt 0) {
    Write-Host "--- Schema drift check ---"
    Write-Host "Tables declared in DESIGN.md: $($declaredTables -join ', ')"

    $schemaFiles = Get-FilesFromDirs -Dirs @("migrations", "schema", "sql", "db", "database", "prisma", "src/main/resources/db") -Extensions @(".sql", ".xml", ".yaml", ".yml", ".json", ".prisma", ".ts", ".js", ".java", ".kt")
    if ($schemaFiles.Count -eq 0) {
        Write-Host "  No schema/migration directories found. Skipping schema drift check."
    } else {
        $schemaText = Read-AllText -Files $schemaFiles
        foreach ($table in $declaredTables) {
            if ($schemaText -notmatch [regex]::Escape($table)) {
                $issues += "SCHEMA_DRIFT: Table '$table' declared in DESIGN.md but not found in schema/migration files."
            }
        }
    }
}

# 2. API route drift (heuristic only).
$routeMatches = [regex]::Matches($designText, '(?<![A-Za-z0-9_.-])(/[A-Za-z][A-Za-z0-9_{}/:.-]*)')
$declaredRoutes = $routeMatches |
    ForEach-Object { $_.Groups[1].Value } |
    Where-Object { $_ -notmatch '\.(md|ps1|sh|java|ts|tsx|js|jsx)$' -and $_ -notmatch '(node_modules|\.git)' } |
    Sort-Object -Unique

if ($declaredRoutes.Count -gt 0) {
    Write-Host ""
    Write-Host "--- API route drift check ---"
    Write-Host "Routes declared in DESIGN.md: $($declaredRoutes -join ', ')"
    Write-Host "  NOTE: Route drift check is heuristic. Review route matches manually."
}

# 3. Permission drift.
$declaredPerms = @()
$saMatches = [regex]::Matches($designText, '@SaCheckPermission\s*\(\s*["'']([^"'']+)["'']')
foreach ($match in $saMatches) {
    $declaredPerms += $match.Groups[1].Value
}
$permissionMatches = [regex]::Matches($designText, '(?im)\bpermission[-_ ]?code\b\s*[:|]\s*([A-Z][A-Z0-9_:.-]+)')
foreach ($match in $permissionMatches) {
    $declaredPerms += $match.Groups[1].Value
}
$declaredPerms = $declaredPerms | Sort-Object -Unique

if ($declaredPerms.Count -gt 0) {
    Write-Host ""
    Write-Host "--- Permission drift check ---"
    Write-Host "Permission codes declared in DESIGN.md: $($declaredPerms -join ', ')"

    $sourceFiles = Get-FilesFromDirs -Dirs @("src", "app", "modules", "services", "common", "shared", "packages") -Extensions @(".java", ".kt", ".ts", ".tsx", ".js", ".jsx", ".vue")
    if ($sourceFiles.Count -eq 0) {
        Write-Host "  No source directories found. Skipping permission drift check."
    } else {
        $sourceText = Read-AllText -Files $sourceFiles
        foreach ($permission in $declaredPerms) {
            if ($sourceText -notmatch [regex]::Escape($permission)) {
                $issues += "PERM_DRIFT: Permission code '$permission' declared in DESIGN.md but not found in source files."
            }
        }
    }
}

# 4. Workflow/status drift.
$mentionsWorkflowOrStatus = $designText -match '(?i)(workflow|state\s+machine|status\s+machine|Status\s+Vocabulary|Status\s+Mapping)'
$declaresNoWorkflowOrStatus = $designText -match '(?i)\b(no|not|without)\b.{0,80}(workflow|state\s+machine|status)'
if ($mentionsWorkflowOrStatus -and -not $declaresNoWorkflowOrStatus) {
    Write-Host ""
    Write-Host "--- Workflow/status drift check ---"

    if ($designText -notmatch '(?i)##\s*Status\s+Mapping') {
        $issues += "WORKFLOW_DRIFT: Design mentions workflow/status but lacks Status Mapping section."
    }
    if ($designText -notmatch '(?i)##\s*Legacy\s+Compatibility') {
        $issues += "WORKFLOW_DRIFT: Design mentions workflow/status but lacks Legacy Compatibility section."
    }
}

Write-Host ""
Write-Host "============================================"
if ($issues.Count -gt 0) {
    Write-Host "Code-drift check found $($issues.Count) issue(s):"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Code-drift check passed. No drift detected between DESIGN.md and live code."
