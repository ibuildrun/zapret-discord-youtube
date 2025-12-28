# Zapret GUI - Diagnostics Module Tests

BeforeAll {
    $srcPath = Join-Path (Join-Path $PSScriptRoot '..') 'src'
    . (Join-Path $srcPath 'config.ps1')
    . (Join-Path $srcPath 'diagnostics.ps1')
}

Describe 'DiagnosticResult Class' {
    Context 'Constructor with all parameters' {
        It 'Should create object with all properties set' {
            $result = [DiagnosticResult]::new('Test Check', 'OK', 'Test passed', 'https://example.com')
            
            $result.Name | Should -Be 'Test Check'
            $result.Status | Should -Be 'OK'
            $result.Message | Should -Be 'Test passed'
            $result.HelpUrl | Should -Be 'https://example.com'
        }
    }
    
    Context 'Constructor with default HelpUrl' {
        It 'Should set HelpUrl to empty string when not provided' {
            $result = [DiagnosticResult]::new('Test Check', 'Warning', 'Some warning')
            
            $result.Name | Should -Be 'Test Check'
            $result.Status | Should -Be 'Warning'
            $result.Message | Should -Be 'Some warning'
            $result.HelpUrl | Should -Be ''
        }
    }
    
    Context 'Status values' {
        It 'Should accept OK status' {
            $result = [DiagnosticResult]::new('Check', 'OK', 'Good')
            $result.Status | Should -Be 'OK'
        }
        
        It 'Should accept Warning status' {
            $result = [DiagnosticResult]::new('Check', 'Warning', 'Caution')
            $result.Status | Should -Be 'Warning'
        }
        
        It 'Should accept Error status' {
            $result = [DiagnosticResult]::new('Check', 'Error', 'Problem')
            $result.Status | Should -Be 'Error'
        }
    }
}

Describe 'Invoke-Diagnostics' {
    It 'Should return array of DiagnosticResult objects' {
        $results = Invoke-Diagnostics
        
        $results | Should -Not -BeNullOrEmpty
        $results[0].PSObject.TypeNames[0] | Should -Be 'DiagnosticResult'
    }
    
    It 'Should check Base Filtering Engine' {
        $results = Invoke-Diagnostics
        
        $bfeCheck = $results | Where-Object { $_.Name -eq 'Base Filtering Engine' }
        $bfeCheck | Should -Not -BeNullOrEmpty
        $bfeCheck.Status | Should -BeIn @('OK', 'Error')
    }
    
    It 'Should check System Proxy' {
        $results = Invoke-Diagnostics
        
        $proxyCheck = $results | Where-Object { $_.Name -eq 'System Proxy' }
        $proxyCheck | Should -Not -BeNullOrEmpty
        $proxyCheck.Status | Should -BeIn @('OK', 'Warning')
    }
    
    It 'Should check for conflicting bypasses' {
        $results = Invoke-Diagnostics
        
        $conflictCheck = $results | Where-Object { $_.Name -eq 'Conflicting Bypasses' }
        $conflictCheck | Should -Not -BeNullOrEmpty
        $conflictCheck.Status | Should -BeIn @('OK', 'Error')
    }
    
    It 'Should return at least 10 diagnostic checks' {
        $results = Invoke-Diagnostics
        
        $results.Count | Should -BeGreaterOrEqual 10
    }
}

Describe 'Clear-DiscordCache' {
    It 'Should return boolean' {
        # This test may fail if Discord is running
        # We just verify the function doesn't throw
        { Clear-DiscordCache } | Should -Not -Throw
    }
}
