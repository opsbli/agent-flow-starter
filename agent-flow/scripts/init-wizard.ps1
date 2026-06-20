<#
.SYNOPSIS
Interactive initialization wizard for agent-flow. Guides through project setup with
smart defaults and contextual questions.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root.
Auto-detects project type, then interactively fills gaps and asks about
database, cache, auth, and frontend verification requirements.

.PARAMETER Target
Project root directory (default: current directory).

.PARAMETER NonInteractive
Skip interactive prompts, use auto-detected defaults only.

.EXAMPLE
agent-flow/scripts/init-wizard.ps1

.EXAMPLE
agent-flow/scripts/init-wizard.ps1 -Target D:\Projects\my-app

.EXAMPLE
agent-flow/scripts/init-wizard.ps1 -NonInteractive
#>

param(
    [string]$Target = ".",
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($Target)
if (-not (Test-Path -LiteralPath $root)) {
    throw "Target not found: $root"
}

# ──────────────────────────────────────────────
# Step 1: Auto-detection
# ──────────────────────────────────────────────

function HasFile($Path) { Test-Path -LiteralPath (Join-Path $root $Path) }
function ExistingDirs([string[]]$Candidates) {
    $Candidates | Where-Object { Test-Path -LiteralPath (Join-Path $root $_) }
}

$projectName = Split-Path -Leaf $root
$build = "unknown"
$backendLanguage = "unknown"
$backendFramework = "unknown"
$backendCompile = "TODO_BACKEND_COMPILE_COMMAND"
$backendTest = "TODO_BACKEND_TEST_COMMAND"
$moduleCompile = "TODO_MODULE_COMPILE_COMMAND"
$moduleTest = "TODO_MODULE_TEST_COMMAND"

if (HasFile "pom.xml") {
    $build = "Maven"; $backendLanguage = "Java"; $backendFramework = "Java"
    $backendCompile = "mvn compile -DskipTests -q"; $backendTest = "mvn test -q"
    $moduleCompile = "mvn compile -pl {module} -am -DskipTests -q"; $moduleTest = "mvn test -pl {module} -am -q"
} elseif (HasFile "build.gradle") {
    $build = "Gradle"; $backendLanguage = "Java/Kotlin"; $backendFramework = "Gradle"
    $backendCompile = "./gradlew build -x test"; $backendTest = "./gradlew test"
    $moduleCompile = "./gradlew :{module}:build -x test"; $moduleTest = "./gradlew :{module}:test"
} elseif (HasFile "pyproject.toml") {
    $build = "Python"; $backendLanguage = "Python"; $backendFramework = "Python"
    $backendCompile = "python -m compileall ."; $backendTest = "pytest"
} elseif (HasFile "go.mod") {
    $build = "Go"; $backendLanguage = "Go"; $backendFramework = "Go"
    $backendCompile = "go vet ./..."; $backendTest = "go test ./..."
} elseif (HasFile "Cargo.toml") {
    $build = "Cargo"; $backendLanguage = "Rust"; $backendFramework = "Rust"
    $backendCompile = "cargo check"; $backendTest = "cargo test"
}

$frontendLanguage = "none"; $frontendFramework = "none"; $frontendRepo = "none"
$frontendTypecheck = "TODO_FRONTEND_TYPECHECK_COMMAND"
$frontendTest = "TODO_FRONTEND_TEST_COMMAND"
$frontendLint = "TODO_FRONTEND_LINT_COMMAND"

if (HasFile "package.json") {
    $frontendLanguage = "JavaScript/TypeScript"
    $frontendRepo = "."
    $depsText = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $root "package.json")
    if ($depsText -match '"vue"') { $frontendFramework = "Vue" }
    elseif ($depsText -match '"react"') { $frontendFramework = "React" }
    elseif ($depsText -match '"next"') { $frontendFramework = "Next.js" }
    else { $frontendFramework = "Node/Web" }

    $pm = if (HasFile "pnpm-lock.yaml") { "pnpm" } elseif (HasFile "yarn.lock") { "yarn" } else { "npm run" }
    $scripts = (Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $root "package.json") | ConvertFrom-Json).scripts
    if ($scripts) {
        if ($scripts.typecheck) { $frontendTypecheck = "$pm typecheck" }
        if ($scripts.test) { $frontendTest = "$pm test" }
        if ($scripts.lint) { $frontendLint = "$pm lint" }
    }
}

# ──────────────────────────────────────────────
# Step 2: Interactive configuration
# ──────────────────────────────────────────────

function Ask-Question {
    param([string]$Prompt, [string]$Default = "", [string[]]$Options = @())
    if ($NonInteractive) { return $Default }

    $optionText = ""
    if ($Options.Count -gt 0) {
        $optionText = " (" + ($Options -join "/") + ")"
    }
    $defaultText = if ($Default) { " [$Default]" } else { "" }
    $response = Read-Host "${Prompt}${optionText}${defaultText}"
    if ([string]::IsNullOrWhiteSpace($response)) { return $Default }
    if ($Options.Count -gt 0 -and $Options -notcontains $response) {
        Write-Host "  Please choose from: $($Options -join ', ')" -ForegroundColor Yellow
        return Ask-Question -Prompt $Prompt -Default $Default -Options $Options
    }
    return $response
}

function Ask-YesNo {
    param([string]$Prompt, [bool]$Default = $true)
    if ($NonInteractive) { return $Default }
    $defaultStr = if ($Default) { "Y/n" } else { "y/N" }
    $response = Read-Host "${Prompt} ($defaultStr)"
    if ([string]::IsNullOrWhiteSpace($response)) { return $Default }
    return $response -match '^(y|yes)$'
}

Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   agent-flow Project Initialization     ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "Project: $projectName"
Write-Host ""

# Database
$dbEngine = Ask-Question -Prompt "Database engine" -Default "none" -Options @("none", "PostgreSQL", "MySQL", "SQLite", "MongoDB", "Redis", "Other")

# Cache
$cacheEngine = Ask-Question -Prompt "Cache engine" -Default "none" -Options @("none", "Redis", "Memcached", "Local", "Other")

# Auth
$authEngine = Ask-Question -Prompt "Auth engine" -Default "none" -Options @("none", "JWT", "Session", "OAuth", "SaaS", "Other")

# Frontend verification
$feVerify = Ask-YesNo -Prompt "Will changes affect user-visible UI?" -Default $true

# Heavy-if schema changes
$schemaChange = Ask-YesNo -Prompt "Does this project modify database schema?" -Default $false

# TDD enforcement
$tddMode = Ask-YesNo -Prompt "Enforce TDD (test-first) for all code?" -Default $true

Write-Host "`nConfiguration summary:" -ForegroundColor Green
Write-Host "  Database : $dbEngine"
Write-Host "  Cache    : $cacheEngine"
Write-Host "  Auth     : $authEngine"
Write-Host "  Frontend verification : $(if($feVerify){'Yes'}else{'No'})"
Write-Host "  Schema changes        : $(if($schemaChange){'Yes'}else{'No'})"
Write-Host "  TDD enforced          : $(if($tddMode){'Yes'}else{'No'})"

$confirm = Ask-YesNo -Prompt "Apply this configuration?" -Default $true
if (-not $confirm) {
    Write-Host "Initialization cancelled." -ForegroundColor Yellow
    exit 0
}

# ──────────────────────────────────────────────
# Step 3: Generate configuration files
# ──────────────────────────────────────────────

$backendEntry = ExistingDirs @("src", "app", "server", "backend", "cmd", "internal")
$common = ExistingDirs @("common", "shared", "lib", "libs", "utils", "core", "packages")
$business = ExistingDirs @("modules", "services", "features", "apps", "packages", "src")
$tests = ExistingDirs @("test", "tests", "src/test", "__tests__")
$sqlPaths = ExistingDirs @("migrations", "schema", "sql", "db", "database", "prisma")

if ($backendEntry.Count -eq 0) { $backendEntry = @("TODO_BACKEND_ENTRY") }
if ($common.Count -eq 0) { $common = @("TODO_COMMON_CODE_PATH") }
if ($business.Count -eq 0) { $business = @("TODO_BUSINESS_MODULE_PATH") }
if ($tests.Count -eq 0) { $tests = @("TODO_TEST_PATH") }
if ($sqlPaths.Count -eq 0) { $sqlPaths = @("TODO_SQL_PATH") }

$buildFiles = @("package.json", "pnpm-workspace.yaml", "tsconfig.json", "vite.config.ts",
    "pom.xml", "build.gradle", "pyproject.toml", "go.mod", "Cargo.toml") |
    Where-Object { HasFile $_ }
if ($buildFiles.Count -eq 0) { $buildFiles = @("TODO_BUILD_FILE") }

$heavyRules = @(
    "new_module_or_package"
    if ($schemaChange) { "schema_change" }
    "auth_or_permission_change"
    "public_api_change"
    "state_machine_change"
    "cache_or_token_change"
    "websocket_or_realtime_change"
    "workflow_change"
    "cross_repo_frontend_backend"
    "deployment_or_production_config"
    "production_incident_risk"
) | Where-Object { $_ -ne $null }

function YamlList([string[]]$Items, [string]$Indent = "    ") {
    ($Items | ForEach-Object { "$Indent- $_" }) -join "`n"
}

$gateRulesPath = Join-Path $root "agent-flow/rules/gates.txt"
if (-not (Test-Path -LiteralPath $gateRulesPath)) {
    throw "Gate registry not found: $gateRulesPath"
}
$gateLines = (
    Get-Content -Encoding utf8 -LiteralPath $gateRulesPath |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") } |
        ForEach-Object { "  - $_" }
) -join "`n"
$registryGateLines = ($gateLines -split "`n" | ForEach-Object { "  $_" }) -join "`n"

$manifest = @"
project:
  name: $projectName
  kind: initialized
  backend:
    framework: $backendFramework
    language: $backendLanguage
    build: $build
    root_module: $projectName
  frontend:
    framework: $frontendFramework
    language: $frontendLanguage
    repo: $frontendRepo
    verify_required: $($feVerify.ToString().ToLower())
  database:
    engine: $dbEngine
    sql_paths:
$(YamlList $sqlPaths "      ")
  cache:
    engine: $cacheEngine
  auth:
    engine: $authEngine

code_map:
  backend_entry:
$(YamlList $backendEntry "    ")
  common:
$(YamlList $common "    ")
  business_modules:
$(YamlList $business "    ")
  build_files:
$(YamlList $buildFiles "    ")
  tests:
$(YamlList $tests "    ")

change_storage:
  root: agent-flow/changes
  knowledge: agent-flow/knowledge
  decisions: agent-flow/decisions
  reports: agent-flow/reports

risk_rules:
  heavy_if:
$(YamlList $heavyRules "    ")
  destructive_gate:
    delete_lines_gte: 5
    public_contract_change: true
    build_file_change: true
    schema_change: $($schemaChange.ToString().ToLower())
  blocked_if:
    - hard_delete_without_approval
    - disable_security_filter
    - bypass_auth_for_production
    - direct_production_data_mutation
    - payment_bypass

verification:
  backend_compile: $backendCompile
  backend_test: $backendTest
  module_compile: $moduleCompile
  module_test: $moduleTest
  frontend_typecheck: $frontendTypecheck
  frontend_test: $frontendTest
  frontend_lint: $frontendLint
  tdd_enforced: $($tddMode.ToString().ToLower())

script_registry:
  gates:
$registryGateLines
  tools: []
  generators: []
  deprecated: []

gates:
$gateLines
"@

$manifestPath = Join-Path $root "agent-flow/manifest.yaml"
Set-Content -Encoding utf8 -LiteralPath $manifestPath -Value $manifest

# Update module-map.md
$moduleRows = ($business | ForEach-Object { '| {0} | `{1}` | TODO | initialized |' -f (Split-Path -Leaf $_), $_ }) -join "`n"
Set-Content -Encoding utf8 -LiteralPath (Join-Path $root "agent-flow/knowledge/module-map.md") -Value @"
# Module Map

## Current Modules

| Module | Path | Responsibility | Notes |
|---|---|---|---|
$moduleRows

## Entry Points

| Entry | Path | Purpose |
|---|---|---|
$(($backendEntry | ForEach-Object { '| {0} | `{1}` | TODO |' -f (Split-Path -Leaf $_), $_ }) -join "`n")

## New Module Registry

| Module | Path | Responsibility | Registration Point | Change |
|---|---|---|---|---|
"@

# Update reuse-map.md
Set-Content -Encoding utf8 -LiteralPath (Join-Path $root "agent-flow/knowledge/reuse-map.md") -Value @"
# Reuse Map

> Before writing new code, check here, then check the codebase. Add new reusable discoveries after each change.

| Capability | Existing Location | How To Reuse | Notes |
|---|---|---|---|
| Project common code | $($common -join ', ') | Scan before adding new helpers | initialized |
"@

# Update verification.md
Set-Content -Encoding utf8 -LiteralPath (Join-Path $root "agent-flow/knowledge/verification.md") -Value @"
# Verification Knowledge

## Backend

~~~text
$backendCompile
$backendTest
~~~

## Frontend

~~~text
$frontendTypecheck
$frontendTest
$frontendLint
~~~

## Gates

Windows:

~~~powershell
agent-flow/scripts/scaffold-health.ps1
agent-flow/scripts/manifest-check.ps1
agent-flow/scripts/scan-check.ps1 -ChangeDir agent-flow/changes/<change-id> -ProjectRoot . -Strict
agent-flow/scripts/design-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/alignment-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/task-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/plan-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/emergency-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/evolution-check.ps1 -ChangeDir agent-flow/changes/<change-id>
agent-flow/scripts/check-change.ps1 -ChangeDir agent-flow/changes/<change-id> -OutputPath agent-flow/changes/<change-id>/CHECK_RESULT.json
agent-flow/scripts/run-verify.ps1 -All
~~~

Linux/macOS:

~~~bash
bash agent-flow/scripts/scaffold-health.sh
bash agent-flow/scripts/manifest-check.sh
bash agent-flow/scripts/scan-check.sh --change-dir agent-flow/changes/<change-id> --project-root . --strict
bash agent-flow/scripts/design-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/alignment-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/task-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/plan-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/emergency-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/evolution-check.sh --change-dir agent-flow/changes/<change-id>
bash agent-flow/scripts/check-change.sh --change-dir agent-flow/changes/<change-id> --output agent-flow/changes/<change-id>/CHECK_RESULT.json
bash agent-flow/scripts/run-verify.sh --all
~~~

## Evidence Requirement

\`VERIFY.md\` must record commands, results, failure summaries, skipped checks, AC evidence, and Machine Gate Summary rows with Result, Command, Exit Code, When, and Evidence.
"@

# Update AGENTS.md Project Context
$agentsPath = Join-Path $root "AGENTS.md"
if (Test-Path -LiteralPath $agentsPath) {
    $agents = Get-Content -Raw -Encoding utf8 -LiteralPath $agentsPath
    $context = @"
## Project Context

- Project name: $projectName
- Backend: $backendLanguage / $backendFramework / $build
- Frontend: $frontendLanguage / $frontendFramework
- Database: $dbEngine
- Auth: $authEngine
- Cache: $cacheEngine
- Backend entries: $($backendEntry -join ', ')
- Common/shared paths: $($common -join ', ')
- Business modules: $($business -join ', ')
- Build files: $($buildFiles -join ', ')
- Tests: $($tests -join ', ')
- Database/schema paths: $($sqlPaths -join ', ')
- TDD mode: $(if($tddMode){'Enforced — test-first required'}else{'Optional'})
- Protected areas: schema, auth/permission, public API contracts, build/module registration, deployment, destructive data operations

## Default Workflow
"@
    $agents = [regex]::Replace($agents, "(?s)## Project Context.*?## Default Workflow", $context)
    Set-Content -Encoding utf8 -LiteralPath $agentsPath -Value $agents
}

# Run scaffold health
& (Join-Path $root "agent-flow/scripts/scaffold-health.ps1")

Write-Host "`n✅ agent-flow initialized for $projectName" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Review agent-flow/manifest.yaml — check TODO items"
Write-Host "  2. Run agent-flow/scripts/manifest-check.ps1"
Write-Host "  3. Run agent-flow/scripts/scaffold-health.ps1"
Write-Host "  4. Start a change: agent-flow/scripts/new-change.ps1 -Name my-feature -Flow Standard"
Write-Host "  5. Tell your AI: '按 agent-flow 流程处理这个需求：...'"
Write-Host ""
