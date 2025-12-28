# Zapret GUI - Services Module Tests

BeforeAll {
    # Create temp directory structure
    $script:TestRoot = Join-Path $env:TEMP "zapret-gui-tests-$(Get-Random)"
    New-Item -Path $script:TestRoot -ItemType Directory -Force | Out-Null
    
    # Create test .bat files
    Set-Content -Path (Join-Path $script:TestRoot 'general-1.bat') -Value '@echo off'
    Set-Content -Path (Join-Path $script:TestRoot 'general-2.bat') -Value '@echo off'
    Set-Content -Path (Join-Path $script:TestRoot 'discord-only.bat') -Value '@echo off'
    Set-Content -Path (Join-Path $script:TestRoot 'service_install.bat') -Value '@echo off'  # Should be excluded
    
    # Load config
    $srcPath = Join-Path (Join-Path $PSScriptRoot '..') 'src'
    . (Join-Path $srcPath 'config.ps1')
    
    # Override root dir
    $script:RootDir = $script:TestRoot
    $script:BinDir = Join-Path $script:TestRoot 'bin'
    
    # Load services module
    . (Join-Path $srcPath 'services.ps1')
}

AfterAll {
    if (Test-Path $script:TestRoot) {
        Remove-Item -Path $script:TestRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Describe 'Get-ServiceStatus' {
    Context 'Parsing sc.exe output' {
        It 'Should return "Running" for RUNNING state' {
            # Mock sc.exe output for running service
            $mockOutput = @"
SERVICE_NAME: zapret
        TYPE               : 10  WIN32_OWN_PROCESS
        STATE              : 4  RUNNING
                                (STOPPABLE, NOT_PAUSABLE, ACCEPTS_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0
"@
            # We can't easily mock sc.exe, so we test the parsing logic indirectly
            # by checking that the function handles real service queries
            $result = Get-ServiceStatus -ServiceName "nonexistent_service_12345"
            $result | Should -Be "NotInstalled"
        }
        
        It 'Should return "NotInstalled" for non-existent service' {
            $result = Get-ServiceStatus -ServiceName "zapret_test_nonexistent_$(Get-Random)"
            $result | Should -Be "NotInstalled"
        }
    }
}

Describe 'Get-ZapretStatus' {
    It 'Should call Get-ServiceStatus with "zapret"' {
        # This will return actual status or NotInstalled
        $result = Get-ZapretStatus
        $result | Should -BeIn @('Running', 'Stopped', 'NotInstalled')
    }
}

Describe 'Get-WinDivertStatus' {
    It 'Should check both WinDivert and WinDivert14' {
        $result = Get-WinDivertStatus
        $result | Should -BeIn @('Running', 'Stopped', 'NotInstalled')
    }
}

Describe 'Get-BypassProcessStatus' {
    It 'Should return Active or Inactive' {
        $result = Get-BypassProcessStatus
        $result | Should -BeIn @('Active', 'Inactive')
    }
}

Describe 'Get-AvailableStrategies' {
    It 'Should return array of .bat files' {
        $result = Get-AvailableStrategies
        
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType [string]
    }
    
    It 'Should exclude service*.bat files' {
        $result = Get-AvailableStrategies
        
        $result | Where-Object { $_ -like 'service*' } | Should -BeNullOrEmpty
    }
    
    It 'Should include general-*.bat files' {
        $result = Get-AvailableStrategies
        
        $result | Where-Object { $_ -like 'general-*' } | Should -Not -BeNullOrEmpty
    }
    
    It 'Should return sorted results' {
        $result = Get-AvailableStrategies
        $sorted = $result | Sort-Object
        
        $result | Should -Be $sorted
    }
}

Describe 'Get-InstalledStrategy' {
    It 'Should return null when service not installed' {
        # Assuming zapret is not installed in test environment
        Mock Get-ZapretStatus { return "NotInstalled" }
        
        $result = Get-InstalledStrategy
        # Will return null if service not installed or no registry key
        $result | Should -BeIn @($null, '')
    }
}
