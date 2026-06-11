param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeDir,
    [string]$ProjectRoot = ".",
    [switch]$Closure
)

$ErrorActionPreference = "Continue"
$scriptDir = $PSScriptRoot
$failed = 0

function Invoke-Gate {
    param(
        [string]$GateName,
        [string]$GatePath,
        [object[]]$GateArgs = @()
    )
    if (-not (Test-Path -LiteralPath $GatePath)) {
        Write-Host "Gate missing: $GateName ($GatePath)"
        $script:failed = 1
        return
    }
    Write-Host "== $GateName =="
    $global:LASTEXITCODE = 0
    & $GatePath @GateArgs
    if (-not $? -or $LASTEXITCODE -ne 0) {
        Write-Host "Gate failed: $GateName"
        $script:failed = 1
    }
}

function Test-File {
    param([string]$Path)
    return (Test-Path -LiteralPath (Join-Path $ChangeDir $Path))
}

Invoke-Gate -GateName "sync-state" -GatePath (Join-Path $scriptDir "sync-state.ps1") -GateArgs @($ChangeDir)
Invoke-Gate -GateName "state-check" -GatePath (Join-Path $scriptDir "state-check.ps1") -GateArgs @($ChangeDir)

if (Test-File "CODE_SCAN.md") {
    Invoke-Gate -GateName "scan-check" -GatePath (Join-Path $scriptDir "scan-check.ps1") -GateArgs @($ChangeDir)
}
if (Test-File "DESIGN.md") {
    Invoke-Gate -GateName "alignment-check" -GatePath (Join-Path $scriptDir "alignment-check.ps1") -GateArgs @($ChangeDir)
}
if (Test-File "TASKS.md") {
    Invoke-Gate -GateName "task-check" -GatePath (Join-Path $scriptDir "task-check.ps1") -GateArgs @($ChangeDir)
    Invoke-Gate -GateName "task-boundary-check" -GatePath (Join-Path $scriptDir "task-boundary-check.ps1") -GateArgs @($ChangeDir, $ProjectRoot)
}
if ((Test-File "REQUIREMENT.md") -and (Test-File "VERIFY.md")) {
    Invoke-Gate -GateName "ac-check" -GatePath (Join-Path $scriptDir "ac-check.ps1") -GateArgs @($ChangeDir)
}
if (Test-File "DESIGN.md") {
    Invoke-Gate -GateName "code-drift-check" -GatePath (Join-Path $scriptDir "code-drift-check.ps1") -GateArgs @($ChangeDir, $ProjectRoot)
}
if (Test-File "TASKS.md") {
    Invoke-Gate -GateName "blocked-check" -GatePath (Join-Path $scriptDir "blocked-check.ps1") -GateArgs @($ChangeDir, $ProjectRoot)
}
Invoke-Gate -GateName "manifest-check" -GatePath (Join-Path $scriptDir "manifest-check.ps1") -GateArgs @($ProjectRoot)

if (Test-File "EVOLUTION.md") {
    Invoke-Gate -GateName "evolution-check" -GatePath (Join-Path $scriptDir "evolution-check.ps1") -GateArgs @($ChangeDir)
}
if ($Closure -or ((Test-File "VERIFY.md") -and (Test-File "REPORT.md"))) {
    Invoke-Gate -GateName "closure-check" -GatePath (Join-Path $scriptDir "closure-check.ps1") -GateArgs @($ChangeDir, $ProjectRoot)
}

if ($failed -ne 0) {
    Write-Host "check-change failed."
    exit 2
}

Write-Host "check-change passed."
