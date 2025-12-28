# Zapret GUI - XAML Validation Tests

BeforeAll {
    $srcPath = Join-Path (Join-Path $PSScriptRoot '..') 'src'
    $uiPath = Join-Path $srcPath 'ui'
    . (Join-Path $srcPath 'config.ps1')
    . (Join-Path $uiPath 'xaml.ps1')
}

Describe 'Get-MainWindowXaml' {
    Context 'XML Validity' {
        It 'Should return valid XML string' {
            $xaml = Get-MainWindowXaml -Version '1.0.0'
            
            { [xml]$xaml } | Should -Not -Throw
        }
        
        # Property 6: XAML Validity
        It 'Property 6: Should return valid XML for any version string' {
            # Feature: gui-tests, Property 6: XAML Validity
            # Validates: Requirements 6.1
            $versions = @('1.0.0', '2.1.3', '10.20.30', '0.0.1', '1.9.2', '')
            
            foreach ($v in $versions) {
                $xaml = Get-MainWindowXaml -Version $v
                { [xml]$xaml } | Should -Not -Throw -Because "Version '$v' should produce valid XML"
            }
        }
    }
    
    Context 'Required UI Elements' {
        BeforeAll {
            $script:Xaml = Get-MainWindowXaml -Version '1.0.0'
            $script:XmlDoc = [xml]$script:Xaml
            $script:Ns = @{ x = 'http://schemas.microsoft.com/winfx/2006/xaml' }
        }
        
        It 'Should have Window as root element' {
            $script:XmlDoc.Window | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have title bar with minimize and close buttons' {
            $script:Xaml | Should -Match 'Name="btnMin"'
            $script:Xaml | Should -Match 'Name="btnClose"'
        }
        
        It 'Should have status text blocks' {
            $script:Xaml | Should -Match 'Name="txtZapret"'
            $script:Xaml | Should -Match 'Name="txtWinDivert"'
            $script:Xaml | Should -Match 'Name="txtProcess"'
            $script:Xaml | Should -Match 'Name="txtStrategy"'
        }
        
        It 'Should have action buttons' {
            $script:Xaml | Should -Match 'Name="btnInstall"'
            $script:Xaml | Should -Match 'Name="btnRemove"'
            $script:Xaml | Should -Match 'Name="btnDiag"'
            $script:Xaml | Should -Match 'Name="btnTests"'
            $script:Xaml | Should -Match 'Name="btnUpdate"'
            $script:Xaml | Should -Match 'Name="btnHosts"'
            $script:Xaml | Should -Match 'Name="btnRefresh"'
        }
        
        It 'Should have settings buttons' {
            $script:Xaml | Should -Match 'Name="btnGameFilter"'
            $script:Xaml | Should -Match 'Name="btnAutoUpdate"'
            $script:Xaml | Should -Match 'Name="btnIPset"'
        }
        
        It 'Should have strategy combo box' {
            $script:Xaml | Should -Match 'Name="cmbStrategy"'
        }
        
        It 'Should have log area' {
            $script:Xaml | Should -Match 'Name="txtLog"'
            $script:Xaml | Should -Match 'Name="logScroll"'
            $script:Xaml | Should -Match 'Name="btnClear"'
            $script:Xaml | Should -Match 'Name="btnCopyLog"'
        }
    }
    
    Context 'Style Resources' {
        BeforeAll {
            $script:Xaml = Get-MainWindowXaml -Version '1.0.0'
        }
        
        It 'Should define MainButton style' {
            $script:Xaml | Should -Match 'x:Key="MainButton"'
        }
        
        It 'Should define WinButton style' {
            $script:Xaml | Should -Match 'x:Key="WinButton"'
        }
        
        It 'Should define CloseButton style' {
            $script:Xaml | Should -Match 'x:Key="CloseButton"'
        }
        
        It 'Should define Section style' {
            $script:Xaml | Should -Match 'x:Key="Section"'
        }
        
        It 'Should define Header style' {
            $script:Xaml | Should -Match 'x:Key="Header"'
        }
        
        It 'Should define Label style' {
            $script:Xaml | Should -Match 'x:Key="Label"'
        }
        
        It 'Should define CustomScrollViewer style' {
            $script:Xaml | Should -Match 'x:Key="CustomScrollViewer"'
        }
    }
    
    Context 'Window Properties' {
        BeforeAll {
            $script:Xaml = Get-MainWindowXaml -Version '1.0.0'
            $script:XmlDoc = [xml]$script:Xaml
        }
        
        It 'Should have correct window dimensions' {
            $script:XmlDoc.Window.Height | Should -Be '700'
            $script:XmlDoc.Window.Width | Should -Be '440'
        }
        
        It 'Should have transparent background for custom chrome' {
            $script:XmlDoc.Window.Background | Should -Be 'Transparent'
            $script:XmlDoc.Window.AllowsTransparency | Should -Be 'True'
            $script:XmlDoc.Window.WindowStyle | Should -Be 'None'
        }
        
        It 'Should be non-resizable' {
            $script:XmlDoc.Window.ResizeMode | Should -Be 'NoResize'
        }
    }
}
