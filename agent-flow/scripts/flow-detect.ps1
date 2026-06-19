<#
.SYNOPSIS
Auto-detect the appropriate flow level (Light/Standard/Heavy) for a change.

.DESCRIPTION
Part of the agent-flow scaffold toolchain.
Analyzes CHANGE.md content against risk rules and suggests
the appropriate flow level with explanations.
Reduces dependency on AI judgment for flow classification.

.PARAMETER ChangeDir
Path to the change directory.

.PARAMETER Strict
Enable strict mode — any matching risk factor forces Heavy.

.PARAMETER Output
Output file path for the classification report.

.EXAMPLE
agent-flow/scripts/flow-detect.ps1 -ChangeDir agent-flow/changes/my-change

.EXAMPLE
agent-flow/scripts/flow-detect.ps1 -ChangeDir agent-flow/changes/my-change -Strict
#>

param(
    [string]$ChangeDir = "",
    [switch]$Strict,
    [string]$Output = ""
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))

if (-not $ChangeDir) {
    Write-Host "Specify a change directory: flow-detect.ps1 -ChangeDir <path>" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $ChangeDir)) {
    Write-Host "Change directory not found: $ChangeDir" -ForegroundColor Red
    exit 1
}

# ── Read CHANGE.md ──
$changeFile = Join-Path $ChangeDir "CHANGE.md"
$changeText = ""
if (Test-Path $changeFile) {
    $changeText = Get-Content -Raw -Encoding utf8 -LiteralPath $changeFile
}

# ── Read CODE_SCAN.md (if exists) ──
$scanFile = Join-Path $ChangeDir "CODE_SCAN.md"
$scanText = ""
if (Test-Path $scanFile) {
    $scanText = Get-Content -Raw -Encoding utf8 -LiteralPath $scanFile
}

# ── Risk factor detection ──
$riskFactors = @()
$reasoning = @()

# Heavy triggers from manifest.yaml (built-in)
$heavyTriggers = @(
    @{ name = "new_module_or_package"; patterns = @("新模块", "new module", "新包", "new package", "新增.*模块", "新增.*包"); severity = 3 }
    @{ name = "schema_change"; patterns = @("schema", "数据库", "database", "迁移", "migration", "DDL", "DML", "ALTER", "CREATE TABLE"); severity = 3 }
    @{ name = "auth_or_permission_change"; patterns = @("权限", "permission", "auth", "认证", "角色", "role", "匿名", "登录", "token"); severity = 3 }
    @{ name = "public_api_change"; patterns = @("API", "接口", "contract", "契约", "REST", "endpoint", "暴露"); severity = 3 }
    @{ name = "state_machine_change"; patterns = @("状态机", "state machine", "工作流", "workflow", "状态.*流转", "status.*transition"); severity = 3 }
    @{ name = "cache_or_token_change"; patterns = @("缓存", "cache", "Redis", "Token", "令牌"); severity = 2 }
    @{ name = "websocket_or_realtime_change"; patterns = @("WebSocket", "websocket", "实时", "realtime", "长连接", "SSE"); severity = 3 }
    @{ name = "workflow_change"; patterns = @("工作流", "workflow", "审批", "approval", "流转"); severity = 3 }
    @{ name = "deployment_or_production_config"; patterns = @("部署", "deploy", "生产", "production", "配置", "config.*(yml|json|env)"); severity = 3 }
    @{ name = "production_incident_risk"; patterns = @("P0", "P1", "生产事故", "线上故障", "数据丢失", "data loss", "安全漏洞"); severity = 3 }
)

# Light indicators
$lightIndicators = @(
    @{ name = "文案修改"; patterns = @("文案", "文案修改", "文字", "copy", "文本"); weight = 1 }
    @{ name = "单文件修复"; patterns = @("单文件", "single file", "修.*bug", "bugfix", "修复.*bug"); weight = 1 }
    @{ name = "低风险样式"; patterns = @("样式", "样式调整", "CSS", "style", "颜色", "间距"); weight = 1 }
    @{ name = "已有测试覆盖"; patterns = @("已有测试", "已有.*覆盖", "测试.*已存在"); weight = 1 }
)

# ── Analyze ──
$textToAnalyze = $changeText + " " + $scanText
$maxSeverity = 0
$matchedRiskNames = @()

foreach ($trigger in $heavyTriggers) {
    foreach ($pattern in $trigger.patterns) {
        if ($textToAnalyze -match $pattern) {
            $riskFactors += $trigger
            $matchedRiskNames += $trigger.name
            if ($trigger.severity -gt $maxSeverity) { $maxSeverity = $trigger.severity }
            break
        }
    }
}

$lightScore = 0
$matchedLightNames = @()
foreach ($indicator in $lightIndicators) {
    foreach ($pattern in $indicator.patterns) {
        if ($textToAnalyze -match $pattern) {
            $lightScore += $indicator.weight
            $matchedLightNames += $indicator.name
            break
        }
    }
}

# ── Classify ──
$suggestedFlow = "Standard"
$confidence = "medium"

if ($riskFactors.Count -ge 2 -or $maxSeverity -ge 3 -or $Strict) {
    $suggestedFlow = "Heavy"
    $confidence = "high"
    $reasoning += "High risk: $($riskFactors.Count) risk factors detected (max severity $maxSeverity)"
} elseif ($riskFactors.Count -eq 1 -and $maxSeverity -le 2) {
    $suggestedFlow = "Standard"
    $confidence = "medium"
    $reasoning += "Low risk factor detected: $($matchedRiskNames[0])"
} elseif ($lightScore -ge 2) {
    $suggestedFlow = "Light"
    $confidence = "medium"
    $reasoning += "Light indicators: $($matchedLightNames -join ', ')"
} elseif ($riskFactors.Count -eq 0 -and $lightScore -eq 0) {
    $suggestedFlow = "Standard"
    $confidence = "low"
    $reasoning += "No clear indicators — defaulting to Standard. Review CHANGE.md for completeness."
} else {
    $reasoning += "Mixed signals — defaulting to $suggestedFlow"
}

# ── Build report ──
$reportLines = @(
    "# Flow Level Detection",
    "",
    "Change: $(Split-Path $ChangeDir -Leaf)",
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    "",
    "## Classification",
    "",
    "| Aspect | Value |",
    "|--------|-------|",
    "| **Suggested Flow** | **$suggestedFlow** |",
    "| Confidence | $confidence |",
    "| Risk factors found | $($riskFactors.Count) |",
    "| Light indicators | $lightScore |",
    ""
)

if ($riskFactors.Count -gt 0) {
    $reportLines += "## Risk Factors Detected"
    $reportLines += ""
    $reportLines += "| Risk | Severity | Matched Pattern |"
    $reportLines += "|------|----------|-----------------|"
    foreach ($rf in ($riskFactors | Sort-Object severity -Descending | Get-Unique -AsString)) {
        $reportLines += "| $($rf.name) | $($rf.severity)/3 | \`$($rf.patterns[0])\` |"
    }
    $reportLines += ""
}

if ($matchedLightNames.Count -gt 0) {
    $reportLines += "## Light Indicators"
    $reportLines += ""
    foreach ($ln in $matchedLightNames) {
        $reportLines += "- $ln"
    }
    $reportLines += ""
}

$reportLines += "## Reasoning"
$reportLines += ""
foreach ($r in $reasoning) {
    $reportLines += "- $r"
}
$reportLines += ""

# Heavy checklist
if ($suggestedFlow -eq "Heavy") {
    $reportLines += "## Required for Heavy Flow"
    $reportLines += ""
    $reportLines += "The following are mandatory before implementation:"
    $reportLines += ""
    $reportLines += "- [ ] PLAN.md — execution phases and gates"
    $reportLines += "- [ ] Plan Audit (Verdict: accept)"
    $reportLines += "- [ ] Closure Audit before marking done"
    $reportLines += "- [ ] All 12 artifacts (incl. PLAN.md, AUDIT.md, REVIEW.md)"
    $reportLines += "- [ ] TDD enforcement (RED→GREEN→REFACTOR per task)"
    $reportLines += ""
}

$reportLines += "## Notes"
$reportLines += ""
if ($confidence -eq "low") {
    $reportLines += "⚠️ Low confidence — review CHANGE.md to add more context about risk, scope, and impact."
} else {
    $reportLines += "Review this classification and adjust the [x] checkbox in CHANGE.md if needed."
}
$reportLines += ""
$reportLines += "---"
$reportLines += "*Generated by flow-detect.ps1*"

$reportText = $reportLines -join "`r`n"

if ($Output) {
    $reportText | Set-Content -Path $Output -Encoding utf8
    Write-Host "Report written to: $Output"
} else {
    Write-Host $reportText
}
