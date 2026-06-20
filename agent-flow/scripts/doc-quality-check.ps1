<#
.SYNOPSIS
Scan public docs and scripts for mojibake and broken fenced code blocks.
#>

param([string]$ProjectRoot = ".")

$ErrorActionPreference = "Stop"
$root = [System.IO.Path]::GetFullPath($ProjectRoot)
$codepoints = @(0x9225, 0x9241, 0x923F, 0x9983, 0xFFFD, 0x93C3, 0x93C8, 0x6D93, 0x9350, 0x7F02, 0x5A34, 0x9428)
$patterns = $codepoints | ForEach-Object { [char]$_ }
$files = @(
    Get-ChildItem -LiteralPath $root -Recurse -File |
        Where-Object {
            $_.FullName -notmatch "\\.git\\" -and
            $_.FullName -notmatch "\\agent-flow\\test\\fixtures\\" -and
            $_.FullName -notmatch "\\agent-flow\\changes\\" -and
            $_.FullName -notmatch "\\agent-flow\\logs\\" -and
            $_.FullName -notmatch "\\agent-flow\\reports\\" -and
            $_.Extension -in @(".md", ".ps1", ".sh", ".yml", ".yaml")
        }
)

$issues = @()
foreach ($file in $files) {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $file.FullName
    foreach ($pattern in $patterns) {
        if ($text.Contains($pattern)) {
            $relative = [System.IO.Path]::GetRelativePath($root, $file.FullName)
            $hex = ([int][char]$pattern).ToString("X4")
            $issues += "Potential mojibake in ${relative}: U+$hex"
            break
        }
    }
    if ($file.Extension -eq ".md") {
        $fenceCount = @([regex]::Matches($text, '(?m)^```')).Count
        if (($fenceCount % 2) -ne 0) {
            $relative = [System.IO.Path]::GetRelativePath($root, $file.FullName)
            $issues += "Unbalanced markdown fences in $relative"
        }
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Doc quality check failed:"
    $issues | ForEach-Object { Write-Host " - $_" }
    exit 2
}

Write-Host "Doc quality check passed."
