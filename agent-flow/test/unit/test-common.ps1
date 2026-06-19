<#
.SYNOPSIS
Pester tests for agent-flow _common.ps1 shared functions.
Run: Invoke-Pester agent-flow/test/unit/test-common.ps1
#>

BeforeAll {
    # Source the common functions
    . "$PSScriptRoot/../../scripts/_common.ps1"

    # Create temp directory for file-based tests
    $script:testDir = Join-Path $env:TEMP "af-test-$(Get-Random)"
    New-Item -ItemType Directory -Force -Path $script:testDir | Out-Null
}

AfterAll {
    if (Test-Path $script:testDir) {
        Remove-Item -Recurse -Force $script:testDir
    }
}

Describe "Get-FlowLevel" {

    It "returns Emergency when CHANGE.md has Emergency checked" {
        $dir = Join-Path $script:testDir "emergency"
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Set-Content -Path (Join-Path $dir "CHANGE.md") -Value @"
## Flow Level

- [x] Emergency
- [ ] Heavy
- [ ] Standard
- [ ] Light
"@
        $result = Get-FlowLevel -Dir $dir
        $result | Should -Be "Emergency"
    }

    It "returns Heavy when CHANGE.md has Heavy checked" {
        $dir = Join-Path $script:testDir "heavy"
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Set-Content -Path (Join-Path $dir "CHANGE.md") -Value @"
## Flow Level

- [ ] Emergency
- [x] Heavy
- [ ] Standard
- [ ] Light
"@
        $result = Get-FlowLevel -Dir $dir
        $result | Should -Be "Heavy"
    }

    It "returns Standard when CHANGE.md has Standard checked" {
        $dir = Join-Path $script:testDir "standard"
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Set-Content -Path (Join-Path $dir "CHANGE.md") -Value @"
## Flow Level

- [ ] Emergency
- [ ] Heavy
- [x] Standard
- [ ] Light
"@
        $result = Get-FlowLevel -Dir $dir
        $result | Should -Be "Standard"
    }

    It "returns Light when CHANGE.md has Light checked" {
        $dir = Join-Path $script:testDir "light"
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Set-Content -Path (Join-Path $dir "CHANGE.md") -Value @"
## Flow Level

- [ ] Emergency
- [ ] Heavy
- [ ] Standard
- [x] Light
"@
        $result = Get-FlowLevel -Dir $dir
        $result | Should -Be "Light"
    }

    It "returns Unknown when CHANGE.md does not exist" {
        $dir = Join-Path $script:testDir "nonexistent"
        $result = Get-FlowLevel -Dir $dir
        $result | Should -Be "Unknown"
    }

    It "returns Unknown when no level is checked" {
        $dir = Join-Path $script:testDir "unchecked"
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Set-Content -Path (Join-Path $dir "CHANGE.md") -Value "## Flow Level`n- [ ] Emergency`n- [ ] Heavy"
        $result = Get-FlowLevel -Dir $dir
        $result | Should -Be "Unknown"
    }
}

Describe "Test-Meaningful" {

    It "returns false for null or empty value" {
        Test-Meaningful -Value "" | Should -Be $false
        Test-Meaningful -Value $null | Should -Be $false
        Test-Meaningful -Value "   " | Should -Be $false
    }

    It "returns false for TODO pattern" {
        Test-Meaningful -Value "TODO" | Should -Be $false
        Test-Meaningful -Value "Still TODO: implement" | Should -Be $false
    }

    It "returns false for TBD pattern" {
        Test-Meaningful -Value "TBD" | Should -Be $false
    }

    It "returns false for path/to pattern" {
        Test-Meaningful -Value "path/to/something" | Should -Be $false
    }

    It "returns false for example placeholder" {
        Test-Meaningful -Value "example-project" | Should -Be $false
        Test-Meaningful -Value "an example of usage" | Should -Be $false
    }

    It "returns false for curly brace placeholder" {
        Test-Meaningful -Value "{module}" | Should -Be $false
    }

    It "returns true for meaningful value" {
        Test-Meaningful -Value "user-profile-module" | Should -Be $true
        Test-Meaningful -Value "PostgreSQL" | Should -Be $true
        Test-Meaningful -Value "mvn compile" | Should -Be $true
    }
}

Describe "Test-MeaningfulValue" {

    It "returns false for pending" {
        Test-MeaningfulValue -Value "pending" | Should -Be $false
    }

    It "returns false for value with slash (no AllowSlash)" {
        Test-MeaningfulValue -Value "src/main" | Should -Be $false
    }

    It "returns true for value with slash when AllowSlash is set" {
        Test-MeaningfulValue -Value "src/main" -AllowSlash | Should -Be $true
    }

    It "returns true for normal module path" {
        Test-MeaningfulValue -Value "user-service" | Should -Be $true
    }
}

Describe "Test-MeaningfulText" {

    It "returns false for 'not run'" {
        Test-MeaningfulText -Value "not run" | Should -Be $false
    }

    It "returns true for actual command output" {
        Test-MeaningfulText -Value "All 15 tests passed (3.2s)" | Should -Be $true
    }
}

Describe "Test-MeaningfulFile" {

    It "returns false when file does not exist" {
        Test-MeaningfulFile -Path (Join-Path $script:testDir "nonexistent.md") | Should -Be $false
    }

    It "returns false when file is empty" {
        $path = Join-Path $script:testDir "empty.md"
        Set-Content -Path $path -Value ""
        Test-MeaningfulFile -Path $path | Should -Be $false
    }

    It "returns false when file contains placeholder text" {
        $path = Join-Path $script:testDir "todo.md"
        Set-Content -Path $path -Value "TODO"
        Test-MeaningfulFile -Path $path -Placeholders @("TODO") | Should -Be $false
    }

    It "returns true for valid file without placeholders" {
        $path = Join-Path $script:testDir "valid.md"
        Set-Content -Path $path -Value "# Real Content`nThis is actual documentation."
        Test-MeaningfulFile -Path $path | Should -Be $true
    }
}
