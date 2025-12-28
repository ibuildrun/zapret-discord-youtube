# Zapret GUI - Updates Module Tests

BeforeAll {
    $srcPath = Join-Path (Join-Path $PSScriptRoot '..') 'src'
    . (Join-Path $srcPath 'config.ps1')
    . (Join-Path $srcPath 'updates.ps1')
}

Describe 'Compare-SemanticVersion' {
    Context 'When comparing equal versions' {
        It 'Should return 0 for identical versions' {
            Compare-SemanticVersion -V1 '1.0.0' -V2 '1.0.0' | Should -Be 0
        }
        
        It 'Should return 0 for versions with different segment counts but same value' {
            Compare-SemanticVersion -V1 '1.0' -V2 '1.0.0' | Should -Be 0
        }
    }
    
    Context 'When first version is greater' {
        It 'Should return 1 for major version difference' {
            Compare-SemanticVersion -V1 '2.0.0' -V2 '1.0.0' | Should -Be 1
        }
        
        It 'Should return 1 for minor version difference' {
            Compare-SemanticVersion -V1 '1.2.0' -V2 '1.1.0' | Should -Be 1
        }
        
        It 'Should return 1 for patch version difference' {
            Compare-SemanticVersion -V1 '1.0.2' -V2 '1.0.1' | Should -Be 1
        }
    }
    
    Context 'When second version is greater' {
        It 'Should return -1 for major version difference' {
            Compare-SemanticVersion -V1 '1.0.0' -V2 '2.0.0' | Should -Be -1
        }
        
        It 'Should return -1 for minor version difference' {
            Compare-SemanticVersion -V1 '1.1.0' -V2 '1.2.0' | Should -Be -1
        }
        
        It 'Should return -1 for patch version difference' {
            Compare-SemanticVersion -V1 '1.0.1' -V2 '1.0.2' | Should -Be -1
        }
    }
    
    Context 'Edge cases' {
        It 'Should handle single segment versions' {
            Compare-SemanticVersion -V1 '2' -V2 '1' | Should -Be 1
        }
        
        It 'Should handle double-digit versions' {
            Compare-SemanticVersion -V1 '1.10.0' -V2 '1.9.0' | Should -Be 1
        }
    }
}

Describe 'UpdateInfo Class' {
    It 'Should create object with default values' {
        $info = [UpdateInfo]::new()
        
        $info.Available | Should -Be $false
        $info.LatestVersion | Should -Be ''
        $info.CurrentVersion | Should -Be ''
        $info.ReleaseUrl | Should -Be ''
        $info.DownloadUrl | Should -Be ''
        $info.Error | Should -Be ''
    }
    
    It 'Should allow setting properties' {
        $info = [UpdateInfo]::new()
        $info.Available = $true
        $info.LatestVersion = '2.0.0'
        
        $info.Available | Should -Be $true
        $info.LatestVersion | Should -Be '2.0.0'
    }
}

# Property-based tests
Describe 'Compare-SemanticVersion Properties' {
    # Property 2: Version Comparison Reflexivity
    # For any valid semantic version string V, Compare-SemanticVersion(V, V) SHALL equal 0
    It 'Property 2: Should satisfy reflexivity (V == V returns 0)' {
        # Feature: gui-tests, Property 2: Version Comparison Reflexivity
        # Validates: Requirements 1.1
        $versions = @(
            '1.0.0', '2.1.3', '10.20.30', '0.0.1', 
            '1.9.2', '0.1.0', '99.99.99', '1.0', '5'
        )
        foreach ($v in $versions) {
            $result = Compare-SemanticVersion -V1 $v -V2 $v
            $result | Should -Be 0 -Because "Version '$v' compared to itself should equal 0"
        }
    }
    
    # Property 1: Version Comparison Transitivity
    # For any A, B, C: if A > B and B > C, then A > C
    It 'Property 1: Should satisfy transitivity (A > B and B > C implies A > C)' {
        # Feature: gui-tests, Property 1: Version Comparison Transitivity
        # Validates: Requirements 1.1, 1.2
        $testCases = @(
            @{ A = '3.0.0'; B = '2.0.0'; C = '1.0.0' },
            @{ A = '1.2.0'; B = '1.1.0'; C = '1.0.0' },
            @{ A = '1.0.3'; B = '1.0.2'; C = '1.0.1' },
            @{ A = '2.1.0'; B = '1.9.0'; C = '1.8.5' }
        )
        
        foreach ($case in $testCases) {
            $ab = Compare-SemanticVersion -V1 $case.A -V2 $case.B
            $bc = Compare-SemanticVersion -V1 $case.B -V2 $case.C
            $ac = Compare-SemanticVersion -V1 $case.A -V2 $case.C
            
            $ab | Should -Be 1 -Because "$($case.A) should be greater than $($case.B)"
            $bc | Should -Be 1 -Because "$($case.B) should be greater than $($case.C)"
            $ac | Should -Be 1 -Because "Transitivity: $($case.A) should be greater than $($case.C)"
        }
    }
}
