<#
.SYNOPSIS
Run the manifest-check agent-flow script.

.DESCRIPTION
Part of the agent-flow scaffold toolchain. Run from the project root unless a path parameter says otherwise.

.PARAMETER ProjectRoot
Parameter accepted by this script.

.PARAMETER Manifest
Parameter accepted by this script.

.PARAMETER StrictTodo
Parameter accepted by this script.

.EXAMPLE
agent-flow/scripts/manifest-check.ps1
#>

param(
    [string]$ProjectRoot = ".",
    [string]$Manifest = "agent-flow/manifest.yaml",
    [switch]$StrictTodo
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

$projectRootPath = Resolve-ProjectPath -Path $ProjectRoot
$manifestPath = Join-Path $projectRootPath $Manifest
if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Host "Manifest not found: $manifestPath"
    exit 2
}

$text = Get-Content -Raw -Encoding utf8 -LiteralPath $manifestPath
$issues = @()
$warnings = @()

function Get-TodoItems {
    param([string]$Text)

    $items = @()
    $lines = $Text -split "\r?\n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($match in [regex]::Matches($lines[$i], "TODO_[A-Z0-9_]+")) {
            $items += [pscustomobject]@{
                Placeholder = $match.Value
                Line = $i + 1
                Text = $lines[$i].Trim()
            }
        }
    }
    return $items
}

function Get-TodoCategory {
    param([string]$Placeholder)

    if ($Placeholder -match "_COMMAND$") { return "verification commands" }
    if ($Placeholder -match "_OR_NONE$") { return "explicit none decisions" }
    if ($Placeholder -match "(_PATH|_ENTRY|_MODULE|_BUILD_FILE|_TEST_PATH|_COMMON_CODE_PATH)$") { return "project map paths" }
    return "review manually"
}

function Write-TodoGuidance {
    param([object[]]$TodoItems)

    if ($TodoItems.Count -eq 0) { return }

    Write-Host ""
    Write-Host "Manifest TODO guidance:"
    foreach ($category in @("project map paths", "verification commands", "explicit none decisions", "review manually")) {
        $group = @($TodoItems | Where-Object { (Get-TodoCategory -Placeholder $_.Placeholder) -eq $category })
        if ($group.Count -eq 0) { continue }
        Write-Host " - ${category}:"
        foreach ($item in $group) {
            Write-Host "   * $($item.Placeholder) at line $($item.Line): $($item.Text)"
        }
    }

    Write-Host "Next steps:"
    Write-Host "  1. Run init-project after the project skeleton and build files exist."
    Write-Host "  2. Replace TODO_* values with concrete paths, commands, or explicit none/N/A."
    Write-Host "  3. Use -StrictTodo in CI only after project context is expected to be fully initialized."
}

function Get-PublicScriptEntries {
    param([string]$Root)

    $scriptsDir = Join-Path $Root "agent-flow/scripts"
    if (-not (Test-Path -LiteralPath $scriptsDir)) { return @() }

    return @(
        Get-ChildItem -LiteralPath $scriptsDir -File |
            Where-Object { $_.Extension -in @(".ps1", ".sh") -and -not $_.BaseName.StartsWith("_") } |
            Sort-Object Name |
            ForEach-Object { "agent-flow/scripts/$($_.Name)" }
    )
}

function Get-ListEntriesFromBlock {
    param(
        [string]$Block,
        [int]$Indent
    )

    $prefix = [regex]::Escape(" " * $Indent)
    return @(
        $Block -split "\r?\n" |
            Where-Object { $_ -match "^$prefix-\s+(agent-flow/scripts/[^\s#]+)\s*$" } |
            ForEach-Object { ([regex]::Match($_, "^\s*-\s+(agent-flow/scripts/[^\s#]+)\s*$")).Groups[1].Value }
    )
}

function Get-LegacyGateEntries {
    param([string]$Text)

    $match = [regex]::Match($Text, "(?ms)^gates:\s*\r?\n((?:  - [^\r\n]+\r?\n?)*)")
    if (-not $match.Success) { return @() }
    return @(Get-ListEntriesFromBlock -Block $match.Groups[1].Value -Indent 2)
}

function Get-RegistryGateEntries {
    param([string]$Text)

    $match = [regex]::Match($Text, "(?ms)^script_registry:\s*\r?\n  gates:\s*\r?\n((?:    - [^\r\n]+\r?\n?)*)")
    if (-not $match.Success) { return @() }
    return @(Get-ListEntriesFromBlock -Block $match.Groups[1].Value -Indent 4)
}

foreach ($section in @("project:", "code_map:", "change_storage:", "risk_rules:", "verification:", "script_registry:", "gates:")) {
    if ($text -notmatch "(?m)^$([regex]::Escape($section))") {
        $issues += "Missing required section: $section"
    }
}

foreach ($category in @("gates:", "tools:", "generators:", "deprecated:")) {
    if ($text -notmatch "(?m)^\s+$([regex]::Escape($category))") {
        $issues += "Missing script_registry.$($category.TrimEnd(':'))"
    }
}

foreach ($rule in @("heavy_if:", "destructive_gate:", "blocked_if:")) {
    if ($text -notmatch "(?m)^\s+$([regex]::Escape($rule))") {
        $issues += "Missing risk_rules.$($rule.TrimEnd(':'))"
    }
}

$requiredBlocked = @(
    "hard_delete_without_approval",
    "disable_security_filter",
    "bypass_auth_for_production",
    "direct_production_data_mutation",
    "payment_bypass"
)
foreach ($rule in $requiredBlocked) {
    if ($text -notmatch "(?m)^\s+-\s+$([regex]::Escape($rule))(\s+#.*)?\s*$") {
        $issues += "Missing blocked_if rule: $rule"
    }
}

$gateRulesPath = Join-Path $projectRootPath "agent-flow/rules/gates.txt"
$gateRulesFound = Test-Path -LiteralPath $gateRulesPath
if (Test-Path -LiteralPath $gateRulesPath) {
    $requiredGates = @(
        Get-Content -Encoding utf8 -LiteralPath $gateRulesPath |
            ForEach-Object { $_.Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") }
    )
} else {
    $warnings += "agent-flow/rules/gates.txt not found; deriving public scripts from agent-flow/scripts."
    $requiredGates = @(Get-PublicScriptEntries -Root $projectRootPath)
}

$publicScripts = @(Get-PublicScriptEntries -Root $projectRootPath)
$registered = @{}
foreach ($gate in $requiredGates) {
    $registered[$gate] = $true
}
if ($gateRulesFound) {
    foreach ($script in $publicScripts) {
        if (-not $registered.ContainsKey($script)) {
            $issues += "Public script missing from gate registry: $script"
        }
    }
}

$manifestScriptEntries = @(
    [regex]::Matches($text, "(?m)^\s+-\s+(agent-flow/scripts/[^\s#]+)\s*$") |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique
)

$registryGateEntries = @(Get-RegistryGateEntries -Text $text)
$legacyGateEntries = @(Get-LegacyGateEntries -Text $text)
$registryGateSet = @{}
$legacyGateSet = @{}
foreach ($entry in $registryGateEntries) { $registryGateSet[$entry] = $true }
foreach ($entry in $legacyGateEntries) { $legacyGateSet[$entry] = $true }
foreach ($entry in $registryGateEntries) {
    if (-not $legacyGateSet.ContainsKey($entry)) {
        $issues += "Legacy gates section is not generated from script_registry.gates; missing: $entry"
    }
}
foreach ($entry in $legacyGateEntries) {
    if (-not $registryGateSet.ContainsKey($entry)) {
        $issues += "Legacy gates section has entry outside script_registry.gates: $entry"
    }
}

foreach ($entry in $manifestScriptEntries) {
    if (-not (Test-Path -LiteralPath (Join-Path $projectRootPath $entry))) {
        $issues += "Manifest script entry does not exist: $entry"
    }
}

foreach ($gate in $requiredGates) {
    if ($text -notmatch "(?m)^\s+-\s+$([regex]::Escape($gate))\s*$") {
        $issues += "Missing script registry entry: $gate"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $projectRootPath $gate))) {
        $issues += "Registered script file does not exist: $gate"
    }
}

$todoItems = @(Get-TodoItems -Text $text)
$todoCount = $todoItems.Count
if ($todoCount -gt 0) {
    $message = "Manifest has $todoCount unresolved TODO_ value(s)."
    if ($StrictTodo) { $issues += $message } else { $warnings += $message }
}

if ($warnings.Count -gt 0) {
    Write-Host "Manifest warnings:"
    $warnings | ForEach-Object { Write-Host " - $_" }
}

if ($issues.Count -gt 0) {
    Write-Host "Manifest check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    Write-TodoGuidance -TodoItems $todoItems
    exit 2
}

Write-TodoGuidance -TodoItems $todoItems
Write-Host "Manifest check passed."



