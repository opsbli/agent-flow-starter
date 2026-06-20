<#
.SYNOPSIS
Pester unit tests for task-check core functions.
Compatible with Pester 3.x.
Run: Invoke-Pester agent-flow/test/unit/test-task-check.ps1
#>

# ---- Setup ----
. "$PSScriptRoot/../../scripts/_common.ps1"

# Inline the key functions from task-check.ps1
function Get-AcIds {
    param([string]$Text)
    @([regex]::Matches($Text, "AC-\d{2}") | ForEach-Object { $_.Value } | Select-Object -Unique)
}

function Test-VerifyEvidence {
    param(
        [string]$VerifyText,
        [string]$TaskId,
        [string[]]$AcIds
    )
    if ([string]::IsNullOrWhiteSpace($VerifyText)) { return $false }
    if ($VerifyText -match [regex]::Escape($TaskId)) { return $true }
    foreach ($ac in $AcIds) {
        if ($VerifyText -match [regex]::Escape($ac)) { return $true }
    }
    return $false
}

# ---- Tests ----

Describe "Get-AcIds" {
    It "extracts AC-01 from text" {
        $result = @(Get-AcIds -Text "AC-01: do something")
        ($result -join ',') | Should Be "AC-01"
    }

    It "extracts multiple AC ids" {
        $result = @(Get-AcIds -Text "AC-01, AC-02, AC-03")
        $result.Count | Should Be 3
        ($result -join ',') | Should Be "AC-01,AC-02,AC-03"
    }

    It "returns unique values only" {
        $result = @(Get-AcIds -Text "AC-01, AC-01, AC-02")
        $result.Count | Should Be 2
    }

    It "returns empty when no AC ids" {
        $result = @(Get-AcIds -Text "No AC references here")
        $result.Count | Should Be 0
    }

    It "handles two-digit numbers (AC-01 through AC-99)" {
        $result = @(Get-AcIds -Text "AC-01 AC-99 AC-42")
        $result.Count | Should Be 3
        ($result -join ',') | Should Match "AC-01"
    }

    It "does not match single-digit AC-1 format (AC-01 required)" {
        $result = @(Get-AcIds -Text "AC-1 is wrong, AC-01 is right")
        $result.Count | Should Be 1
        ($result -join ',') | Should Be "AC-01"
    }
}

Describe "Test-VerifyEvidence" {
    It "returns true when verify text contains task id" {
        Test-VerifyEvidence -VerifyText "T-01: completed" -TaskId "T-01" -AcIds @() | Should Be $true
    }

    It "returns true when verify text contains AC id" {
        Test-VerifyEvidence -VerifyText "AC-01 verified" -TaskId "T-02" -AcIds @("AC-01") | Should Be $true
    }

    It "returns false when neither task id nor AC id found" {
        Test-VerifyEvidence -VerifyText "Some other content" -TaskId "T-01" -AcIds @("AC-01") | Should Be $false
    }

    It "returns false for empty verify text" {
        Test-VerifyEvidence -VerifyText "" -TaskId "T-01" -AcIds @("AC-01") | Should Be $false
    }

    It "returns false for whitespace-only verify text" {
        Test-VerifyEvidence -VerifyText "   " -TaskId "T-01" -AcIds @() | Should Be $false
    }

    It "returns true when any AC id matches" {
        Test-VerifyEvidence -VerifyText "AC-03 done" -TaskId "T-01" -AcIds @("AC-01", "AC-02", "AC-03") | Should Be $true
    }

    It "returns true with empty AcIds when task id matches" {
        Test-VerifyEvidence -VerifyText "T-42 passes" -TaskId "T-42" -AcIds @() | Should Be $true
    }
}

