# Zapret GUI - Settings Module Tests

BeforeAll {
    # Create temp directory structure
    $script:TestRoot = Join-Path $env:TEMP "zapret-gui-tests-$(Get-Random)"
    $script:TestUtils = Join-Path $script:TestRoot 'utils'
    $script:TestLists = Join-Path $script:TestRoot 'lists'
    
    New-Item -Path $script:TestUtils -ItemType Directory -Force | Out-Null
    New-Item -Path $script:TestLists -ItemType Directory -Force | Out-Null
    
    # Load config first to set up variables
    $srcPath = Join-Path (Join-Path $PSScriptRoot '..') 'src'
    . (Join-Path $srcPath 'config.ps1')
    
    # Override paths to use test directories
    $script:RootDir = $script:TestRoot
    $script:UtilsDir = $script:TestUtils
    $script:ListsDir = $script:TestLists
    
    # Load settings module
    . (Join-Path $srcPath 'settings.ps1')
}

AfterAll {
    # Cleanup temp directory
    if (Test-Path $script:TestRoot) {
        Remove-Item -Path $script:TestRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Describe 'Game Filter Settings' {
    BeforeEach {
        # Clean up before each test
        $file = Join-Path $script:TestUtils 'game_filter.enabled'
        if (Test-Path $file) { Remove-Item $file -Force }
    }
    
    Context 'Get-GameFilterStatus' {
        It 'Should return false when file does not exist' {
            Get-GameFilterStatus | Should -Be $false
        }
        
        It 'Should return true when file exists' {
            $file = Join-Path $script:TestUtils 'game_filter.enabled'
            New-Item -Path $file -ItemType File -Force | Out-Null
            
            Get-GameFilterStatus | Should -Be $true
        }
    }
    
    Context 'Set-GameFilter' {
        It 'Should create file when enabled' {
            Set-GameFilter -Enabled $true
            
            $file = Join-Path $script:TestUtils 'game_filter.enabled'
            Test-Path $file | Should -Be $true
        }
        
        It 'Should remove file when disabled' {
            # First enable
            Set-GameFilter -Enabled $true
            # Then disable
            Set-GameFilter -Enabled $false
            
            $file = Join-Path $script:TestUtils 'game_filter.enabled'
            Test-Path $file | Should -Be $false
        }
    }
    
    # Property 3: Game Filter Round-Trip
    It 'Property 3: Game Filter round-trip (set then get returns same value)' {
        # Feature: gui-tests, Property 3: Game Filter Round-Trip
        # Validates: Requirements 2.2
        foreach ($value in @($true, $false)) {
            Set-GameFilter -Enabled $value
            $result = Get-GameFilterStatus
            $result | Should -Be $value -Because "Setting GameFilter to $value then getting should return $value"
        }
    }
}

Describe 'Auto Update Settings' {
    BeforeEach {
        $file = Join-Path $script:TestUtils 'check_updates.enabled'
        if (Test-Path $file) { Remove-Item $file -Force }
    }
    
    Context 'Get-AutoUpdateStatus' {
        It 'Should return false when file does not exist' {
            Get-AutoUpdateStatus | Should -Be $false
        }
        
        It 'Should return true when file exists' {
            $file = Join-Path $script:TestUtils 'check_updates.enabled'
            New-Item -Path $file -ItemType File -Force | Out-Null
            
            Get-AutoUpdateStatus | Should -Be $true
        }
    }
    
    Context 'Set-AutoUpdate' {
        It 'Should create file when enabled' {
            Set-AutoUpdate -Enabled $true
            
            $file = Join-Path $script:TestUtils 'check_updates.enabled'
            Test-Path $file | Should -Be $true
        }
        
        It 'Should remove file when disabled' {
            Set-AutoUpdate -Enabled $true
            Set-AutoUpdate -Enabled $false
            
            $file = Join-Path $script:TestUtils 'check_updates.enabled'
            Test-Path $file | Should -Be $false
        }
    }
    
    # Property 4: Auto Update Round-Trip
    It 'Property 4: Auto Update round-trip (set then get returns same value)' {
        # Feature: gui-tests, Property 4: Auto Update Round-Trip
        # Validates: Requirements 2.4
        foreach ($value in @($true, $false)) {
            Set-AutoUpdate -Enabled $value
            $result = Get-AutoUpdateStatus
            $result | Should -Be $value -Because "Setting AutoUpdate to $value then getting should return $value"
        }
    }
}

Describe 'IPset Mode Settings' {
    BeforeEach {
        $ipsetFile = Join-Path $script:TestLists 'ipset-all.txt'
        $backupFile = Join-Path $script:TestLists 'ipset-all.txt.backup'
        if (Test-Path $ipsetFile) { Remove-Item $ipsetFile -Force }
        if (Test-Path $backupFile) { Remove-Item $backupFile -Force }
    }
    
    Context 'Get-IPsetMode' {
        It 'Should return "none" when file does not exist' {
            Get-IPsetMode | Should -Be 'none'
        }
        
        It 'Should return "any" when file contains 0.0.0.0/0' {
            $file = Join-Path $script:TestLists 'ipset-all.txt'
            Set-Content -Path $file -Value '0.0.0.0/0'
            
            Get-IPsetMode | Should -Be 'any'
        }
        
        It 'Should return "loaded" when file has other content' {
            $file = Join-Path $script:TestLists 'ipset-all.txt'
            Set-Content -Path $file -Value "192.168.1.0/24`n10.0.0.0/8"
            
            Get-IPsetMode | Should -Be 'loaded'
        }
    }
    
    Context 'Set-IPsetMode' {
        It 'Should remove file when set to "none"' {
            $file = Join-Path $script:TestLists 'ipset-all.txt'
            Set-Content -Path $file -Value 'test'
            
            Set-IPsetMode -Mode 'none'
            
            Test-Path $file | Should -Be $false
        }
        
        It 'Should set 0.0.0.0/0 when set to "any"' {
            Set-IPsetMode -Mode 'any'
            
            $file = Join-Path $script:TestLists 'ipset-all.txt'
            $content = Get-Content -Path $file -Raw
            $content.Trim() | Should -Be '0.0.0.0/0'
        }
    }
    
    Context 'Get-NextIPsetMode' {
        It 'Should return "any" when current is "none"' {
            Get-NextIPsetMode | Should -Be 'any'
        }
        
        It 'Should return "none" when current is "any" and no backup' {
            Set-IPsetMode -Mode 'any'
            Get-NextIPsetMode | Should -Be 'none'
        }
        
        It 'Should return "loaded" when current is "any" and backup exists' {
            # Create backup file
            $backupFile = Join-Path $script:TestLists 'ipset-all.txt.backup'
            Set-Content -Path $backupFile -Value '192.168.1.0/24'
            
            Set-IPsetMode -Mode 'any'
            Get-NextIPsetMode | Should -Be 'loaded'
        }
    }
    
    # Property 5: IPset Mode Cycling
    It 'Property 5: IPset mode cycling (none -> any -> none without backup)' {
        # Feature: gui-tests, Property 5: IPset Mode Cycling
        # Validates: Requirements 2.6
        
        # Start from none
        Get-IPsetMode | Should -Be 'none'
        
        # Cycle: none -> any
        $next = Get-NextIPsetMode
        $next | Should -Be 'any'
        Set-IPsetMode -Mode $next
        Get-IPsetMode | Should -Be 'any'
        
        # Cycle: any -> none (no backup)
        $next = Get-NextIPsetMode
        $next | Should -Be 'none'
        Set-IPsetMode -Mode $next
        Get-IPsetMode | Should -Be 'none'
    }
}
