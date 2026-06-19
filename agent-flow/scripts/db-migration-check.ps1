<#
.SYNOPSIS
Run the db-migration-check agent-flow gate.

.DESCRIPTION
Verifies that changes involving database schema modifications include rollback SQL
or rollback steps. For Heavy changes that touch migration/schema files, this gate
checks whether corresponding rollback files exist or the change explicitly declares
rollback as not-needed.

Part of the agent-flow scaffold toolchain. Run from the project root.

.PARAMETER ChangeDir
Path to the change directory.

.PARAMETER ProjectRoot
Path to the project root (default: current directory).

.EXAMPLE
agent-flow/scripts/db-migration-check.ps1 -ChangeDir agent-flow/changes/my-change
agent-flow/scripts/db-migration-check.ps1 -ChangeDir agent-flow/changes/my-change -ProjectRoot .
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ProjectRoot = "."
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectPath {
    param([string]$Path)
    $resolved = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { [System.IO.Path]::Combine((Get-Location).Path, $Path) }
    return [System.IO.Path]::GetFullPath($resolved)
}

# --- Resolve paths ---
$changeDirPath = Resolve-ProjectPath -Path $ChangeDir
if (-not (Test-Path -LiteralPath $changeDirPath)) {
    throw "ChangeDir not found: $changeDirPath"
}
$projectRootPath = Resolve-ProjectPath -Path $ProjectRoot

# --- Only run for Heavy changes ---
$changePath = Join-Path $changeDirPath "CHANGE.md"
$flow = "Unknown"
if (Test-Path -LiteralPath $changePath) {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $changePath
    if ($text -match "(?i)\[x\]\s+Heavy") { $flow = "Heavy" }
    elseif ($text -match "(?i)\[x\]\s+Standard") { $flow = "Standard" }
    elseif ($text -match "(?i)\[x\]\s+Light") { $flow = "Light" }
    elseif ($text -match "(?i)\[x\]\s+Emergency") { $flow = "Emergency" }
}

if ($flow -ne "Heavy" -and $flow -ne "Standard") {
    Write-Host "SKIP: db-migration-check is only relevant for Standard and Heavy changes (current: $flow)"
    exit 0
}

# --- Check TASKS.md write_files for migration/schema files ---
$tasksPath = Join-Path $changeDirPath "TASKS.md"
$hasMigrationFiles = $false
$rollbackFilesExist = $false
$migrationFiles = @()

if (Test-Path -LiteralPath $tasksPath) {
    $tasksText = Get-Content -Raw -Encoding utf8 -LiteralPath $tasksPath

    # Extract write_files
    $inWriteFiles = $false
    $writeFiles = @()
    foreach ($line in ($tasksText -split "`n")) {
        if ($line -match '^\s*write_files\s*:') {
            $inWriteFiles = $true
            continue
        }
        if ($inWriteFiles -and ($line -match '^\s*##\s+' -or $line -match '^\s*[A-Za-z0-9_-]+\s*:\s*$')) {
            $inWriteFiles = $false
        }
        if ($inWriteFiles -and $line -match '^\s*-\s+(.+)$') {
            $value = $matches[1].Trim().Trim([char[]]@([char]0x60, [char]0x27, [char]0x22))
            $writeFiles += $value
        }
    }

    # Check if any write_file looks like a migration/schema file
    $migrationPatterns = @('migration', 'schema', 'sql/', 'db/', 'database/', 'prisma/', 'flyway', 'liquibase', '.sql')
    foreach ($file in $writeFiles) {
        foreach ($pattern in $migrationPatterns) {
            if ($file -match [regex]::Escape($pattern) -or $file -like "*$pattern*") {
                $hasMigrationFiles = $true
                $migrationFiles += $file
                break
            }
        }
    }

    if ($hasMigrationFiles) {
        Write-Host "=== Database Migration Check ==="
        Write-Host "Migration/schema files declared in TASKS.md write_files:"
        $migrationFiles | ForEach-Object { Write-Host "  - $_" }

        # Check for corresponding rollback files
        foreach ($file in $migrationFiles) {
            $childPath = [string]$file
            $fullPath = Join-Path $projectRootPath $childPath
            $dir = Split-Path -Parent $fullPath
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension([string]$file)
            $ext = [System.IO.Path]::GetExtension([string]$file)

            # Common rollback naming patterns
            $rollbackCandidates = @(
                [System.IO.Path]::Combine($dir, "${baseName}__rollback${ext}")
                [System.IO.Path]::Combine($dir, "${baseName}_rollback${ext}")
                [System.IO.Path]::Combine($dir, "rollback_${baseName}${ext}")
                [System.IO.Path]::Combine($dir, "rollback-${baseName}${ext}")
                [System.IO.Path]::Combine($dir, "R${baseName}${ext}")
            )

            foreach ($rb in $rollbackCandidates) {
                if (Test-Path -LiteralPath $rb) {
                    Write-Host "  ✅ Rollback file found: $rb"
                    $rollbackFilesExist = $true
                    break
                }
            }
        }
    }
}

# --- Also check DESIGN.md for schema declarations ---
$designPath = Join-Path $changeDirPath "DESIGN.md"
$designDeclaresSchema = $false
if (Test-Path -LiteralPath $designPath) {
    $designText = Get-Content -Raw -Encoding utf8 -LiteralPath $designPath
    if ($designText -match '(?i)(CREATE\s+TABLE|ALTER\s+TABLE|schema\s+change|database\s+migration|new\s+table|new\s+column|add\s+column|drop\s+column|modify\s+column|sql\s+migration)') {
        $designDeclaresSchema = $true
    }
}

# --- Check for explicit rollback-not-needed declaration ---
$changeText = ""
if (Test-Path -LiteralPath $changePath) {
    $changeText = Get-Content -Raw -Encoding utf8 -LiteralPath $changePath
}

$explicitRollbackSkipped = $changeText -match '(?i)rollback:\s*not-needed' -or
                            $changeText -match '(?i)rollback:\s*schema-only-add' -or
                            $changeText -match '(?i)rollback:\s*none' -or
                            $changeText -match '(?i)rollback:\s*not\s*applicable'

if ($explicitRollbackSkipped) {
    Write-Host ""
    Write-Host "✅ Rollback explicitly declared as not-needed in CHANGE.md. Skipping rollback check."
    Write-Host "db-migration-check passed."
    exit 0
}

# --- Decision ---
Write-Host ""
Write-Host "============================================"

if ($hasMigrationFiles -and -not $rollbackFilesExist) {
    Write-Host "⚠️  WARNING: Migration/schema files found but no rollback files detected."
    Write-Host "  The following migration files lack detected rollback counterparts:"
    $migrationFiles | ForEach-Object { Write-Host "   - $_" }
    Write-Host ""
    Write-Host "  Recommended actions:"
    Write-Host "   1. Add rollback SQL files for each migration file."
    Write-Host "   2. Or declare 'rollback: not-needed' in CHANGE.md if rollback is genuinely not required."
    Write-Host "   3. Or declare 'rollback: schema-only-add' for additive-only schema changes."
    Write-Host ""
    Write-Host "NOTE: This check is heuristic. Review manually."
    exit 0  # Non-blocking — warnings only
}

if ($designDeclaresSchema -and -not $hasMigrationFiles) {
    Write-Host "⚠️  WARNING: DESIGN.md mentions schema changes but no migration files found in TASKS.md write_files."
    Write-Host "  If this change involves database schema changes, add migration files to write_files."
    Write-Host "  If this change does NOT involve schema changes, no action needed."
    Write-Host ""
    Write-Host "NOTE: This check is heuristic."
    exit 0  # Non-blocking
}

if ($hasMigrationFiles -and $rollbackFilesExist) {
    Write-Host "✅ Rollback files detected for all migration files. db-migration-check passed."
    exit 0
}

Write-Host "db-migration-check passed. No schema migration concerns detected."

if (-not $hasMigrationFiles -and -not $designDeclaresSchema) {
    Write-Host "(No migration files or schema declarations to check.)"
}
