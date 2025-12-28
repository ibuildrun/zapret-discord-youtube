# Zapret GUI - Theme Module Tests

BeforeAll {
    $srcPath = Join-Path (Join-Path $PSScriptRoot '..') 'src'
    $uiPath = Join-Path $srcPath 'ui'
    . (Join-Path $uiPath 'theme.ps1')
}

Describe 'Theme Configuration' {
    It 'Should have all required color properties' {
        $script:Theme | Should -Not -BeNullOrEmpty
        $script:Theme.Background | Should -Not -BeNullOrEmpty
        $script:Theme.Surface | Should -Not -BeNullOrEmpty
        $script:Theme.TextPrimary | Should -Not -BeNullOrEmpty
        $script:Theme.Success | Should -Not -BeNullOrEmpty
        $script:Theme.Warning | Should -Not -BeNullOrEmpty
        $script:Theme.Error | Should -Not -BeNullOrEmpty
    }
    
    It 'Should have valid hex color format' {
        $script:Theme.Background | Should -Match '^#[0-9a-fA-F]{6}$'
        $script:Theme.Success | Should -Match '^#[0-9a-fA-F]{6}$'
    }
}

Describe 'Format-StatusText' {
    Context 'Known status values' {
        It 'Should format "Running" as "RUNNING"' {
            Format-StatusText -Status 'Running' | Should -Be 'RUNNING'
        }
        
        It 'Should format "Active" as "ACTIVE"' {
            Format-StatusText -Status 'Active' | Should -Be 'ACTIVE'
        }
        
        It 'Should format "Stopped" as "STOPPED"' {
            Format-StatusText -Status 'Stopped' | Should -Be 'STOPPED'
        }
        
        It 'Should format "Inactive" as "INACTIVE"' {
            Format-StatusText -Status 'Inactive' | Should -Be 'INACTIVE'
        }
        
        It 'Should format "NotInstalled" as "NOT INSTALLED"' {
            Format-StatusText -Status 'NotInstalled' | Should -Be 'NOT INSTALLED'
        }
    }
    
    Context 'Unknown status' {
        It 'Should return "UNKNOWN" for unrecognized status' {
            Format-StatusText -Status 'SomeRandomStatus' | Should -Be 'UNKNOWN'
        }
        
        It 'Should return "UNKNOWN" for empty string' {
            Format-StatusText -Status '' | Should -Be 'UNKNOWN'
        }
    }
}

Describe 'Get-StatusColor' {
    Context 'Success states' {
        It 'Should return Success color for "Running"' {
            Get-StatusColor -Status 'Running' | Should -Be $script:Theme.Success
        }
        
        It 'Should return Success color for "Active"' {
            Get-StatusColor -Status 'Active' | Should -Be $script:Theme.Success
        }
    }
    
    Context 'Warning states' {
        It 'Should return Warning color for "Stopped"' {
            Get-StatusColor -Status 'Stopped' | Should -Be $script:Theme.Warning
        }
    }
    
    Context 'Muted states' {
        It 'Should return TextMuted color for "Inactive"' {
            Get-StatusColor -Status 'Inactive' | Should -Be $script:Theme.TextMuted
        }
        
        It 'Should return TextMuted color for "NotInstalled"' {
            Get-StatusColor -Status 'NotInstalled' | Should -Be $script:Theme.TextMuted
        }
    }
    
    Context 'Unknown status' {
        It 'Should return TextMuted color for unknown status' {
            Get-StatusColor -Status 'Unknown' | Should -Be $script:Theme.TextMuted
        }
    }
}

Describe 'Status Functions Consistency' {
    It 'Should have matching status values between Format and Color functions' {
        $statuses = @('Running', 'Active', 'Stopped', 'Inactive', 'NotInstalled')
        
        foreach ($status in $statuses) {
            # Both functions should handle all known statuses without error
            { Format-StatusText -Status $status } | Should -Not -Throw
            { Get-StatusColor -Status $status } | Should -Not -Throw
        }
    }
}
