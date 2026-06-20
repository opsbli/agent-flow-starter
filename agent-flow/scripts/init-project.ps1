<#
.SYNOPSIS
Run the init-project agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER Target
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/init-project.ps1
#>

param([string]$Target = ".")

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($Target)
if (-not (Test-Path -LiteralPath $root)) {
    throw "Target not found: $root"
}

$projectName = Split-Path -Leaf $root

function HasFile($Path) {
    Test-Path -LiteralPath (Join-Path $root $Path)
}

function ExistingDirs([string[]]$Candidates) {
    $Candidates | Where-Object { Test-Path -LiteralPath (Join-Path $root $_) }
}

# --- External profile detection ---
# Try project-profiles.json first for extensibility.
# Fall back to hardcoded patterns if file not found or no profile matches.
$profileMatched = $false
$profilePath = Join-Path $PSScriptRoot "..\project-profiles.json"
$profilePath = [System.IO.Path]::GetFullPath($profilePath)

if (Test-Path -LiteralPath $profilePath) {
    try {
        $profilesJson = Get-Content -Raw -Encoding utf8 -LiteralPath $profilePath | ConvertFrom-Json
        foreach ($p in $profilesJson.profiles) {
            $profileFiles = $p.indicators.files
            $matchMode = $p.indicators.match_mode
            if (-not $matchMode) { $matchMode = "any" }

            $allMatch = $true
            $anyMatch = $false
            foreach ($f in $profileFiles) {
                if ($f -match '\*') {
                    # Wildcard pattern like *.csproj
                    $dir = Split-Path -Parent $f
                    if ([string]::IsNullOrWhiteSpace($dir)) { $dir = "." }
                    $pattern = Split-Path -Leaf $f
                    $found = Get-ChildItem -LiteralPath $root -Filter $pattern -File -ErrorAction SilentlyContinue
                    if ($found) { $anyMatch = $true }
                    else { $allMatch = $false }
                } elseif (HasFile $f) {
                    $anyMatch = $true
                } else {
                    $allMatch = $false
                }
            }

            $matched = if ($matchMode -eq 'all') { $allMatch } else { $anyMatch }
            if ($matched) {
                Write-Host "  Detected profile: $($p.name) (via project-profiles.json)"
                $profileMatched = $true
                $build = $p.name
                if ($p.backend.framework) { $backendFramework = $p.backend.framework }
                if ($p.backend.language) { $backendLanguage = $p.backend.language }
                if ($p.backend.compile) { $backendCompile = $p.backend.compile }
                if ($p.backend.test) { $backendTest = $p.backend.test }
                if ($p.backend.module_compile) { $moduleCompile = $p.backend.module_compile }
                if ($p.backend.module_test) { $moduleTest = $p.backend.module_test }
                break  # First match wins
            }
        }
    } catch {
        Write-Host "  Warning: Failed to parse $profilePath, falling back to built-in detection. Error: $_"
    }
}

# --- Fallback: hardcoded detection (only if no external profile matched) ---
if (-not $profileMatched) {
    $build = "unknown"
    $backendFramework = "unknown"
    $backendLanguage = "unknown"
    $backendCompile = "TODO_BACKEND_COMPILE_COMMAND"
    $backendTest = "TODO_BACKEND_TEST_COMMAND"
    $moduleCompile = "TODO_MODULE_COMPILE_COMMAND"
    $moduleTest = "TODO_MODULE_TEST_COMMAND"

if (HasFile "pom.xml") {
    $build = "Maven"
    $backendLanguage = "Java"
    $backendFramework = "Java"
    $backendCompile = "mvn compile -DskipTests -q"
    $backendTest = "mvn test -q"
    $moduleCompile = "mvn compile -pl {module} -am -DskipTests -q"
    $moduleTest = "mvn test -pl {module} -am -q"
} elseif (HasFile "build.gradle" -or HasFile "settings.gradle" -or HasFile "build.gradle.kts") {
    $build = "Gradle"
    $backendLanguage = "Java/Kotlin"
    $backendFramework = "Gradle project"
    $backendCompile = "./gradlew build -x test"
    $backendTest = "./gradlew test"
    $moduleCompile = "./gradlew :{module}:build -x test"
    $moduleTest = "./gradlew :{module}:test"
} elseif (HasFile "pyproject.toml" -or HasFile "requirements.txt") {
    $build = "Python"
    $backendLanguage = "Python"
    $backendFramework = "Python"
    $backendCompile = "python -m compileall ."
    $backendTest = "pytest"
} elseif (HasFile "go.mod") {
    $build = "Go"
    $backendLanguage = "Go"
    $backendFramework = "Go"
    $backendCompile = "go test ./... -run TestNonExistent"
    $backendTest = "go test ./..."
} elseif (HasFile "Cargo.toml") {
    $build = "Cargo"
    $backendLanguage = "Rust"
    $backendFramework = "Rust"
    $backendCompile = "cargo check"
    $backendTest = "cargo test"
}
}  # end of if (-not $profileMatched) fallback block

$frontendFramework = "none"
$frontendLanguage = "none"
$frontendRepo = "none"
$frontendTypecheck = "TODO_FRONTEND_TYPECHECK_COMMAND"
$frontendTest = "TODO_FRONTEND_TEST_COMMAND"
$frontendLint = "TODO_FRONTEND_LINT_COMMAND"

if (HasFile "package.json") {
    $frontendLanguage = "JavaScript/TypeScript"
    $frontendRepo = "."
    $package = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $root "package.json") | ConvertFrom-Json
    $depsText = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $root "package.json")
    if ($depsText -match '"vue"') { $frontendFramework = "Vue" }
    elseif ($depsText -match '"react"') { $frontendFramework = "React" }
    elseif ($depsText -match '"next"') { $frontendFramework = "Next.js" }
    else { $frontendFramework = "Node/Web" }

    $pm = if (HasFile "pnpm-lock.yaml") { "pnpm" } elseif (HasFile "yarn.lock") { "yarn" } else { "npm run" }
    $scripts = $package.scripts
    if ($scripts) {
        if ($scripts.PSObject.Properties.Name -contains "type-check") { $frontendTypecheck = "$pm type-check" }
        elseif ($scripts.PSObject.Properties.Name -contains "typecheck") { $frontendTypecheck = "$pm typecheck" }
        if ($scripts.PSObject.Properties.Name -contains "test") { $frontendTest = "$pm test" }
        if ($scripts.PSObject.Properties.Name -contains "lint") { $frontendLint = "$pm lint" }
        elseif ($scripts.PSObject.Properties.Name -contains "lint:eslint") { $frontendLint = "$pm lint:eslint" }
    }
}

$frontendCandidates = @(
    "apps/web",
    "apps/frontend",
    "web",
    "frontend",
    "client",
    "packages/web",
    "packages/frontend"
) | Where-Object { HasFile (Join-Path $_ "package.json") }
if ($frontendCandidates.Count -gt 0) {
    $frontendRepo = $frontendCandidates -join ", "
} elseif (HasFile "pnpm-workspace.yaml") {
    $frontendRepo = "workspace"
}

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

$buildFiles = @("package.json", "pnpm-workspace.yaml", "pnpm-lock.yaml", "package-lock.json", "yarn.lock", "tsconfig.json", "vite.config.ts", "next.config.js", "pom.xml", "build.gradle", "settings.gradle", "pyproject.toml", "requirements.txt", "go.mod", "Cargo.toml") |
    Where-Object { HasFile $_ }
if ($buildFiles.Count -eq 0) { $buildFiles = @("TODO_BUILD_FILE") }

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
  database:
    engine: TODO_DATABASE_OR_NONE
    sql_paths:
$(YamlList $sqlPaths "      ")
  cache:
    engine: TODO_CACHE_OR_NONE
  auth:
    engine: TODO_AUTH_OR_NONE

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
    - new_module_or_package
    - schema_change
    - auth_or_permission_change
    - public_api_change
    - state_machine_change
    - cache_or_token_change
    - websocket_or_realtime_change
    - workflow_change
    - cross_repo_frontend_backend
    - deployment_or_production_config
    - production_incident_risk
  destructive_gate:
    delete_lines_gte: 5
    public_contract_change: true
    build_file_change: true
    schema_change: true
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

script_registry:
  gates:
$registryGateLines
  tools: []
  generators: []
  deprecated: []

gates:
$gateLines
"@

Set-Content -Encoding utf8 -LiteralPath (Join-Path $root "agent-flow/manifest.yaml") -Value $manifest

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

Set-Content -Encoding utf8 -LiteralPath (Join-Path $root "agent-flow/knowledge/reuse-map.md") -Value @"
# Reuse Map

> Before writing new code, check here, then check the codebase. Add new reusable discoveries after each change.

| Capability | Existing Location | How To Reuse | Notes |
|---|---|---|---|
| Project common code | $($common -join ', ') | Scan before adding new helpers | initialized |
"@

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

`VERIFY.md` must record commands, results, failure summaries, skipped checks, AC evidence, and Machine Gate Summary rows with Result, Command, Exit Code, When, and Evidence.
"@

$agentsPath = Join-Path $root "AGENTS.md"
if (Test-Path -LiteralPath $agentsPath) {
    $agents = Get-Content -Raw -Encoding utf8 -LiteralPath $agentsPath
    $context = @"
## Project Context

- Project name: $projectName
- Backend: $backendLanguage / $backendFramework / $build
- Frontend: $frontendLanguage / $frontendFramework
- Backend entries: $($backendEntry -join ', ')
- Common/shared paths: $($common -join ', ')
- Business modules: $($business -join ', ')
- Build files: $($buildFiles -join ', ')
- Tests: $($tests -join ', ')
- Database/schema paths: $($sqlPaths -join ', ')
- Protected areas: schema, auth/permission, public API contracts, build/module registration, deployment, destructive data operations

## Default Workflow
"@
    $agents = [regex]::Replace($agents, "(?s)## Project Context.*?## Default Workflow", $context)
    Set-Content -Encoding utf8 -LiteralPath $agentsPath -Value $agents
}

& (Join-Path $root "agent-flow/scripts/scaffold-health.ps1")

Write-Host "agent-flow initialized for $projectName"



