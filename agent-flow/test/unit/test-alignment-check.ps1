<#
.SYNOPSIS
Pester unit tests for alignment-check core parser functions.
Compatible with Pester 3.x.
Run: Invoke-Pester agent-flow/test/unit/test-alignment-check.ps1
#>

# ---- Setup ----
. "$PSScriptRoot/../../scripts/_common.ps1"

$script:testDir = Join-Path $env:TEMP "af-test-align-$(Get-Random)"
New-Item -ItemType Directory -Force -Path $script:testDir | Out-Null

# Inline the key parser functions from alignment-check.ps1
function Get-AlignmentVerdict {
    param([string]$DesignPath)

    if (-not (Test-Path -LiteralPath $DesignPath)) {
        return ""
    }

    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $DesignPath
    $match = [regex]::Match($text, "(?im)^\s*Alignment Verdict:\s*([A-Za-z-]+)\s*$")
    if ($match.Success) {
        return $match.Groups[1].Value.ToLowerInvariant()
    }
    return ""
}

function Get-AlignmentSection {
    param([string]$Text)

    $match = [regex]::Match($Text, '(?ims)^\s*##\s+Design Alignment / Grill\s*$([\s\S]*?)(?=^\s*##\s+|\z)')
    if ($match.Success) {
        return $match.Groups[1].Value
    }
    return ""
}

# ---- Tests ----

Describe "Get-AlignmentVerdict" {
    It "extracts 'aligned' from a valid DESIGN.md" {
        $path = Join-Path $script:testDir "design-aligned.md"
        Set-Content -Path $path -Value @"
# Design

Alignment Verdict: aligned

Some content
"@
        Get-AlignmentVerdict -DesignPath $path | Should Be "aligned"
    }

    It "extracts 'skipped' with reason" {
        $path = Join-Path $script:testDir "design-skipped.md"
        Set-Content -Path $path -Value @"
# Design

Alignment Verdict: skipped
Skip Reason: User approved skip
"@
        Get-AlignmentVerdict -DesignPath $path | Should Be "skipped"
    }

    It "returns empty for missing verdict" {
        $path = Join-Path $script:testDir "design-no-verdict.md"
        Set-Content -Path $path -Value "# Design (no verdict section)"
        Get-AlignmentVerdict -DesignPath $path | Should Be ""
    }

    It "returns empty when DESIGN.md does not exist" {
        Get-AlignmentVerdict -DesignPath "nonexistent.md" | Should Be ""
    }

    It "handles case variations: Aligned, ALIGNED" {
        $path = Join-Path $script:testDir "design-case.md"
        Set-Content -Path $path -Value @"
Alignment Verdict: ALIGNED
"@
        Get-AlignmentVerdict -DesignPath $path | Should Be "aligned"
    }

    It "extracts 'blocked' verdict" {
        $path = Join-Path $script:testDir "design-blocked.md"
        Set-Content -Path $path -Value @"
Alignment Verdict: blocked
Blocked Reason: Pending user confirmation
"@
        Get-AlignmentVerdict -DesignPath $path | Should Be "blocked"
    }
}

Describe "Get-AlignmentSection" {
    It "extracts the Design Alignment section" {
        $text = @"
# Design

## Design Alignment / Grill

Question 1: Is the module boundary correct?
Confirmation: user-confirmed

Question 2: Does this conflict with existing routes?
Confirmation: code-confirmed

## Plan

Some plan content
"@
        $section = Get-AlignmentSection -Text $text
        $section | Should Not BeNullOrEmpty
        $section | Should Match "Question 1"
        $section | Should Match "Question 2"
        $section | Should Not Match "Plan"
    }

    It "returns empty when no Alignment section exists" {
        $text = "# Design`n## Plan`nNo alignment here"
        Get-AlignmentSection -Text $text | Should Be ""
    }

    It "extracts section at end of file without trailing heading" {
        $text = @"
# Design

## Design Alignment / Grill

Only one question here.
Confirmation: user-confirmed
"@
        $section = Get-AlignmentSection -Text $text
        $section | Should Not BeNullOrEmpty
        $section.Trim() | Should Be "Only one question here.`nConfirmation: user-confirmed"
    }

    It "counts user-confirmed questions" {
        $text = @"
# Design

## Design Alignment / Grill

Question 1: test
Confirmation: user-confirmed

Question 2: test
Confirmation: user-confirmed

Question 3: test
Confirmation: code-confirmed
"@
        $section = Get-AlignmentSection -Text $text
        $userConfirmed = [regex]::Matches($section, "user-confirmed").Count
        $userConfirmed | Should Be 2
        $codeConfirmed = [regex]::Matches($section, "code-confirmed").Count
        $codeConfirmed | Should Be 1
    }
}

# ---- Cleanup ----
if (Test-Path $script:testDir) {
    Remove-Item -Recurse -Force $script:testDir
}


