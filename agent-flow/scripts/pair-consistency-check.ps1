# pair-consistency-check.ps1 — detects line-count divergence between .ps1/.sh pairs
param(
  [string]$ScriptsDir = "agent-flow/scripts",
  [int]$Threshold = 30
)

if (-not (Test-Path $ScriptsDir)) {
  Write-Error "Scripts directory not found: $ScriptsDir"
  exit 2
}

$issues = @()
$pairs = 0
$diverged = 0

Write-Host "=== Pair Consistency Check ==="
Write-Host "Threshold: ${Threshold}% line count divergence"
Write-Host ""

$ps1Files = Get-ChildItem -Path $ScriptsDir -Filter "*.ps1" -File

foreach ($ps1 in $ps1Files) {
  $base = $ps1.BaseName
  if ($base.StartsWith("_")) { continue }

  $sh = Join-Path $ScriptsDir "${base}.sh"
  if (-not (Test-Path $sh)) {
    $issues += "MISSING_PARTNER: $($ps1.Name) has no .sh counterpart"
    continue
  }

  $pairs++
  $ps1Lines = (Get-Content $ps1.FullName | Measure-Object -Line).Lines
  $shLines = (Get-Content $sh | Measure-Object -Line).Lines

  if ($ps1Lines -eq 0 -or $shLines -eq 0) {
    $issues += "EMPTY_SCRIPT: $base (.ps1=$ps1Lines lines, .sh=$shLines lines)"
    continue
  }

  $bigger = [Math]::Max($ps1Lines, $shLines)
  $smaller = [Math]::Min($ps1Lines, $shLines)

  if ($bigger -gt 0) {
    $pct = [Math]::Round(($bigger - $smaller) * 100.0 / $bigger, 0)

    if ($pct -gt $Threshold) {
      $diverged++
      $issues += "DIVERGED: $base — .ps1=$ps1Lines lines, .sh=$shLines lines ($pct% divergence)"
      Write-Host "  ! $base`: .ps1=$ps1Lines lines, .sh=$shLines lines ($pct%)"
    }
  }
}

$shFiles = Get-ChildItem -Path $ScriptsDir -Filter "*.sh" -File
foreach ($sh in $shFiles) {
  $base = $sh.BaseName
  if ($base.StartsWith("_")) { continue }
  $ps1Path = Join-Path $ScriptsDir "${base}.ps1"
  if (-not (Test-Path $ps1Path)) {
    $issues += "MISSING_PARTNER: $($sh.Name) has no .ps1 counterpart"
  }
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host "Pairs checked: $pairs"
Write-Host "Diverged pairs (>${Threshold}%): $diverged"
Write-Host "Total issues: $($issues.Count)"

if ($issues.Count -gt 0) {
  Write-Host ""
  Write-Host "=== Issues ==="
  $issues | ForEach-Object { Write-Host " - $_" }
  Write-Host ""
  Write-Host "Suggestion: prioritize pairs with the largest divergence for refactoring."
  exit 2
}

Write-Host ""
Write-Host "pair-consistency-check passed."
