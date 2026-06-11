param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ProjectRoot = ".",
    [switch]$Closure,
    [switch]$Json,
    [string]$OutputPath
)

$ErrorActionPreference = "Continue"
$scriptDir = $PSScriptRoot
$failed = 0
$results = @()

function Add-Result {
    param(
        [string]$GateName,
        [string]$Status,
        [bool]$Required,
        [int]$ExitCode,
        [string]$Reason = ""
    )
    $script:results += [pscustomobject]@{
        gate = $GateName
        status = $Status
        required = $Required
        exit_code = $ExitCode
        reason = $Reason
    }
}

function Invoke-Gate {
    param(
        [string]$GateName,
        [string]$GatePath,
        [object[]]$GateArgs = @(),
        [hashtable]$NamedArgs = $null,
        [bool]$Required = $true
    )
    if (-not (Test-Path -LiteralPath $GatePath)) {
        Write-Host "Gate missing: $GateName ($GatePath)"
        Add-Result -GateName $GateName -Status "missing" -Required $Required -ExitCode 127 -Reason "script not found"
        if ($Required) { $script:failed = 1 }
        return
    }

    Write-Host "== $GateName =="
    $global:LASTEXITCODE = 0
    if ($null -ne $NamedArgs) {
        $output = & $GatePath @NamedArgs 2>&1
    } else {
        $output = & $GatePath @GateArgs 2>&1
    }
    $success = $?
    $exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    if ($output) {
        $output | ForEach-Object { Write-Host $_ }
    }

    $outputText = ($output | Out-String)
    $status = "pass"
    $reason = ""
    if ($outputText -match "(?im)^\s*SKIP:") {
        $status = "skipped"
        $reason = (($outputText -split "\r?\n") | Where-Object { $_ -match "(?i)^\s*SKIP:" } | Select-Object -First 1).Trim()
    } elseif (-not $success -or $exitCode -ne 0) {
        $status = "fail"
        $reason = "gate exited with code $exitCode"
        Write-Host "Gate failed: $GateName"
        $script:failed = 1
    }
    Add-Result -GateName $GateName -Status $status -Required $Required -ExitCode $exitCode -Reason $reason
}

function Skip-Gate {
    param(
        [string]$GateName,
        [string]$Reason
    )
    Add-Result -GateName $GateName -Status "skipped" -Required $false -ExitCode 0 -Reason $Reason
}

function Test-File {
    param([string]$Path)
    return (Test-Path -LiteralPath (Join-Path $ChangeDir $Path))
}

function Write-Summary {
    $summary = [pscustomobject]@{
        schema_version = "1.0"
        generated_at = (Get-Date).ToString("o")
        change_dir = $ChangeDir
        project_root = $ProjectRoot
        closure = [bool]$Closure
        passed = ($script:failed -eq 0)
        gates = @($script:results)
    }
    $jsonText = $summary | ConvertTo-Json -Depth 6
    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        Set-Content -Encoding utf8 -LiteralPath $OutputPath -Value $jsonText
        Write-Host "Wrote check result: $OutputPath"
    }
    if ($Json) {
        Write-Output $jsonText
    }
}

Invoke-Gate -GateName "sync-state" -GatePath (Join-Path $scriptDir "sync-state.ps1") -GateArgs @($ChangeDir)
Invoke-Gate -GateName "state-check" -GatePath (Join-Path $scriptDir "state-check.ps1") -GateArgs @($ChangeDir)

if (Test-File "CODE_SCAN.md") {
    Invoke-Gate -GateName "scan-check" -GatePath (Join-Path $scriptDir "scan-check.ps1") -NamedArgs @{ ChangeDir = $ChangeDir; ProjectRoot = $ProjectRoot; Strict = $true }
} else {
    Skip-Gate -GateName "scan-check" -Reason "CODE_SCAN.md not present"
}

if (Test-File "CHANGE.md") {
    Invoke-Gate -GateName "emergency-check" -GatePath (Join-Path $scriptDir "emergency-check.ps1") -GateArgs @($ChangeDir)
} else {
    Skip-Gate -GateName "emergency-check" -Reason "CHANGE.md not present"
}

if (Test-File "DESIGN.md") {
    Invoke-Gate -GateName "alignment-check" -GatePath (Join-Path $scriptDir "alignment-check.ps1") -GateArgs @($ChangeDir)
} else {
    Skip-Gate -GateName "alignment-check" -Reason "DESIGN.md not present"
}

if (Test-File "TASKS.md") {
    Invoke-Gate -GateName "task-check" -GatePath (Join-Path $scriptDir "task-check.ps1") -GateArgs @($ChangeDir)
    Invoke-Gate -GateName "task-boundary-check" -GatePath (Join-Path $scriptDir "task-boundary-check.ps1") -GateArgs @($ChangeDir, $ProjectRoot)
} else {
    Skip-Gate -GateName "task-check" -Reason "TASKS.md not present"
    Skip-Gate -GateName "task-boundary-check" -Reason "TASKS.md not present"
}

if ((Test-File "REQUIREMENT.md") -and (Test-File "VERIFY.md")) {
    Invoke-Gate -GateName "ac-check" -GatePath (Join-Path $scriptDir "ac-check.ps1") -GateArgs @($ChangeDir)
} else {
    Skip-Gate -GateName "ac-check" -Reason "REQUIREMENT.md or VERIFY.md not present"
}

if (Test-File "DESIGN.md") {
    Invoke-Gate -GateName "code-drift-check" -GatePath (Join-Path $scriptDir "code-drift-check.ps1") -GateArgs @($ChangeDir, $ProjectRoot)
} else {
    Skip-Gate -GateName "code-drift-check" -Reason "DESIGN.md not present"
}

if (Test-File "TASKS.md") {
    Invoke-Gate -GateName "blocked-check" -GatePath (Join-Path $scriptDir "blocked-check.ps1") -GateArgs @($ChangeDir, $ProjectRoot)
} else {
    Skip-Gate -GateName "blocked-check" -Reason "TASKS.md not present"
}

Invoke-Gate -GateName "manifest-check" -GatePath (Join-Path $scriptDir "manifest-check.ps1") -GateArgs @($ProjectRoot)

if (Test-File "EVOLUTION.md") {
    Invoke-Gate -GateName "evolution-check" -GatePath (Join-Path $scriptDir "evolution-check.ps1") -GateArgs @($ChangeDir)
} else {
    Skip-Gate -GateName "evolution-check" -Reason "EVOLUTION.md not present"
}

if ($Closure -or ((Test-File "VERIFY.md") -and (Test-File "REPORT.md"))) {
    Invoke-Gate -GateName "closure-check" -GatePath (Join-Path $scriptDir "closure-check.ps1") -GateArgs @($ChangeDir, $ProjectRoot)
} else {
    Skip-Gate -GateName "closure-check" -Reason "closure not requested and VERIFY.md/REPORT.md not both present"
}

Write-Summary

if ($failed -ne 0) {
    Write-Host "check-change failed."
    exit 2
}

Write-Host "check-change passed."
