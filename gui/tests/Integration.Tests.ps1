# Zapret GUI - Integration Tests

Describe 'Module Loading' {
    BeforeAll {
        $script:SrcPath = Join-Path (Join-Path $PSScriptRoot '..') 'src'
        $script:UiPath = Join-Path $script:SrcPath 'ui'
    }
    
    It 'Should load config.ps1 without errors' {
        { . (Join-Path $script:SrcPath 'config.ps1') } | Should -Not -Throw
    }
    
    It 'Should load updates.ps1 without errors' {
        { . (Join-Path $script:SrcPath 'updates.ps1') } | Should -Not -Throw
    }
    
    It 'Should load settings.ps1 without errors' {
        { . (Join-Path $script:SrcPath 'settings.ps1') } | Should -Not -Throw
    }
    
    It 'Should load services.ps1 without errors' {
        { . (Join-Path $script:SrcPath 'services.ps1') } | Should -Not -Throw
    }
    
    It 'Should load diagnostics.ps1 without errors' {
        { . (Join-Path $script:SrcPath 'diagnostics.ps1') } | Should -Not -Throw
    }
    
    It 'Should load ui/theme.ps1 without errors' {
        { . (Join-Path $script:UiPath 'theme.ps1') } | Should -Not -Throw
    }
    
    It 'Should load ui/xaml.ps1 without errors' {
        { . (Join-Path $script:UiPath 'xaml.ps1') } | Should -Not -Throw
    }
    
    It 'Should load ui/dialogs.ps1 without errors' {
        { . (Join-Path $script:UiPath 'dialogs.ps1') } | Should -Not -Throw
    }
}

Describe 'All Modules Together' {
    BeforeAll {
        $script:SrcPath = Join-Path (Join-Path $PSScriptRoot '..') 'src'
        $script:UiPath = Join-Path $script:SrcPath 'ui'
        
        # Load all modules in correct order
        . (Join-Path $script:SrcPath 'config.ps1')
        . (Join-Path $script:UiPath 'theme.ps1')
        . (Join-Path $script:UiPath 'xaml.ps1')
        . (Join-Path $script:UiPath 'dialogs.ps1')
        . (Join-Path $script:SrcPath 'updates.ps1')
        . (Join-Path $script:SrcPath 'settings.ps1')
        . (Join-Path $script:SrcPath 'services.ps1')
        . (Join-Path $script:SrcPath 'diagnostics.ps1')
    }
    
    It 'Should have Config variable defined' {
        $script:Config | Should -Not -BeNullOrEmpty
        $script:Config.Version | Should -Not -BeNullOrEmpty
    }
    
    It 'Should have Theme variable defined' {
        $script:Theme | Should -Not -BeNullOrEmpty
    }
    
    It 'Should have all required functions available' {
        Get-Command -Name 'Get-MainWindowXaml' -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        Get-Command -Name 'Compare-SemanticVersion' -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        Get-Command -Name 'Get-GameFilterStatus' -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        Get-Command -Name 'Get-ServiceStatus' -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        Get-Command -Name 'Invoke-Diagnostics' -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        Get-Command -Name 'Format-StatusText' -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }
}

Describe 'WPF Window Creation' {
    BeforeAll {
        $script:SrcPath = Join-Path (Join-Path $PSScriptRoot '..') 'src'
        $script:UiPath = Join-Path $script:SrcPath 'ui'
        
        # Load required modules
        . (Join-Path $script:SrcPath 'config.ps1')
        . (Join-Path $script:UiPath 'xaml.ps1')
        
        # Load WPF assemblies
        Add-Type -AssemblyName PresentationFramework -ErrorAction SilentlyContinue
        Add-Type -AssemblyName PresentationCore -ErrorAction SilentlyContinue
    }
    
    It 'Should create Window object from XAML' {
        $xaml = Get-MainWindowXaml -Version $script:Config.Version
        
        # Parse XAML
        $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
        
        { 
            $window = [System.Windows.Markup.XamlReader]::Load($reader)
            $window | Should -Not -BeNullOrEmpty
            $window | Should -BeOfType [System.Windows.Window]
            
            # Close window immediately (don't show)
            $window.Close()
        } | Should -Not -Throw
    }
    
    It 'Should find all named elements in Window' {
        $xaml = Get-MainWindowXaml -Version $script:Config.Version
        $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
        $window = [System.Windows.Markup.XamlReader]::Load($reader)
        
        # Check key elements exist
        $window.FindName('btnInstall') | Should -Not -BeNullOrEmpty
        $window.FindName('btnRemove') | Should -Not -BeNullOrEmpty
        $window.FindName('txtZapret') | Should -Not -BeNullOrEmpty
        $window.FindName('cmbStrategy') | Should -Not -BeNullOrEmpty
        $window.FindName('txtLog') | Should -Not -BeNullOrEmpty
        
        $window.Close()
    }
}
