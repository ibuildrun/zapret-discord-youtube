# Zapret GUI - Update Functions

class UpdateInfo {
    [bool]$Available
    [string]$LatestVersion
    [string]$CurrentVersion
    [string]$ReleaseUrl
    [string]$DownloadUrl
    [string]$Error
    
    UpdateInfo() {
        $this.Available = $false
        $this.LatestVersion = ""
        $this.CurrentVersion = ""
        $this.ReleaseUrl = ""
        $this.DownloadUrl = ""
        $this.Error = ""
    }
}

function Compare-SemanticVersion {
    param([string]$V1, [string]$V2)
    
    # Clean version strings (remove 'v' prefix if present)
    $V1 = $V1.TrimStart('v').Trim()
    $V2 = $V2.TrimStart('v').Trim()
    
    # Handle empty versions
    if ([string]::IsNullOrWhiteSpace($V1)) { return -1 }
    if ([string]::IsNullOrWhiteSpace($V2)) { return 1 }
    
    try {
        $p1 = $V1.Split('.') | ForEach-Object { [int]$_ }
        $p2 = $V2.Split('.') | ForEach-Object { [int]$_ }
        
        $max = [Math]::Max($p1.Count, $p2.Count)
        
        # Pad arrays to same length
        $arr1 = @($p1)
        $arr2 = @($p2)
        while ($arr1.Count -lt $max) { $arr1 += 0 }
        while ($arr2.Count -lt $max) { $arr2 += 0 }
        
        for ($i = 0; $i -lt $max; $i++) {
            if ($arr1[$i] -gt $arr2[$i]) { return 1 }
            if ($arr1[$i] -lt $arr2[$i]) { return -1 }
        }
        return 0
    }
    catch {
        # Fallback to string comparison
        return [string]::Compare($V1, $V2)
    }
}

function Get-RemoteVersion {
    param([string]$Url)
    
    try {
        $request = [System.Net.WebRequest]::Create($Url)
        $request.Timeout = 10000
        $request.Headers.Add("Cache-Control", "no-cache")
        
        $response = $request.GetResponse()
        $stream = $response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $version = $reader.ReadToEnd().Trim()
        $reader.Close()
        $response.Close()
        
        return $version
    }
    catch {
        return $null
    }
}

function Test-NewVersionAvailable {
    $result = [UpdateInfo]::new()
    $result.CurrentVersion = $script:Config.Version
    
    try {
        # Get upstream version
        $upstreamVersion = Get-RemoteVersion -Url $script:Config.GitHubVersionUrl
        
        if (-not $upstreamVersion) {
            $result.Error = "Failed to fetch version info"
            return $result
        }
        
        $result.LatestVersion = $upstreamVersion
        $result.ReleaseUrl = "$($script:Config.GitHubReleaseUrl)$upstreamVersion"
        $result.DownloadUrl = "$($script:Config.GitHubDownloadUrl)$upstreamVersion.rar"
        
        # Compare versions properly
        # Update available only if upstream is NEWER (cmp > 0)
        # If our version is higher (cmp < 0) - we're ahead, no update needed
        $cmp = Compare-SemanticVersion -V1 $upstreamVersion -V2 $script:Config.Version
        $result.Available = ($cmp -gt 0)
        
        return $result
    }
    catch [System.Net.WebException] {
        $result.Error = "Network error"
        return $result
    }
    catch {
        $result.Error = $_.Exception.Message
        return $result
    }
}
