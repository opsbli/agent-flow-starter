param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ChangeDir)) {
    throw "ChangeDir not found: $ChangeDir"
}

$design = Join-Path $ChangeDir "DESIGN.md"
if (-not (Test-Path $design)) {
    throw "DESIGN.md not found in $ChangeDir"
}

$text = Get-Content -Raw -Encoding utf8 $design
$issues = @()

if ($text -match "CREATE TABLE|ALTER TABLE|schema|数据设计") {
    if (-not ($text -match "migrations|migration|schema|sql|prisma|liquibase|flyway|迁移|回滚")) {
        $issues += "Design mentions schema/data changes but does not reference SQL migration or rollback."
    }
}

if ($text -match "@SaCheckPermission|权限|permission") {
    if (-not ($text -match "权限码|SaCheckPermission|匿名接口")) {
        $issues += "Design mentions permission but lacks explicit permission-code or anonymous-interface decision."
    }
}

if ($text -match "POST|GET|PUT|DELETE|路径|API") {
    if (-not ($text -match "/[a-zA-Z0-9{}_/:-]+")) {
        $issues += "Design mentions API but no route-like path was found."
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Drift check found issues:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Drift check passed."
