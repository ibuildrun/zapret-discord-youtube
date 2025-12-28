# Zapret GUI - Test Runner
# Runs all Pester tests for GUI modules

param(
    [switch]$CI,
    [string]$OutputPath = "test-results.xml"
)

$ErrorActionPreference = "Stop"

# Check and install Pester if needed
$pester = Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version -ge '5.0.0' }
if (-not $pester) {
    Write-Host "Installing Pester 5.x..." -ForegroundColor Yellow
    
    $tempPath = Join-Path $env:TEMP "PesterModule"
    if (-not (Test-Path "$tempPath\Pester\5.7.1")) {
        Save-Module -Name Pester -Path $tempPath -MinimumVersion 5.0.0 -Force
    }
    
    # Import from temp location
    Import-Module "$tempPath\Pester\5.7.1\Pester.psd1" -Force
} else {
    Import-Module Pester -MinimumVersion 5.0.0
}

# Configure Pester
$config = New-PesterConfiguration

$config.Run.Path = $PSScriptRoot
$config.Run.Exit = [bool]$CI

$config.Output.Verbosity = if ([bool]$CI) { 'Normal' } else { 'Detailed' }

$config.TestResult.Enabled = $true
$config.TestResult.OutputPath = Join-Path $PSScriptRoot $OutputPath
$config.TestResult.OutputFormat = 'NUnitXml'

$config.CodeCoverage.Enabled = $false

# Run tests
Write-Host "`nRunning Zapret GUI Tests...`n" -ForegroundColor Cyan

$result = Invoke-Pester -Configuration $config

# Summary
Write-Host "`n" -NoNewline
if ($result.FailedCount -eq 0) {
    Write-Host "All tests passed!" -ForegroundColor Green
} else {
    Write-Host "$($result.FailedCount) test(s) failed" -ForegroundColor Red
}

Write-Host "Results: $($result.PassedCount) passed, $($result.FailedCount) failed, $($result.SkippedCount) skipped"
Write-Host "Report saved to: $OutputPath"

exit $result.FailedCount
