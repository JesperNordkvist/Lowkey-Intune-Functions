function Test-LKModuleVersion {
    <#
    .SYNOPSIS
        Checks GitHub for a newer module release and prompts the user to update.
    #>
    try {
        $manifestPath = Join-Path $PSScriptRoot '..\IntuneLogicKit.psd1'
        $manifest = Import-PowerShellDataFile $manifestPath
        $currentVersion = [version]$manifest.ModuleVersion

        $releaseUrl = "https://api.github.com/repos/$script:LKGitHubRepo/releases/latest"
        $releaseInfo = Invoke-RestMethod -Uri $releaseUrl -TimeoutSec 5 -ErrorAction Stop
        $latestTag = $releaseInfo.tag_name -replace '^v', ''
        $latestVersion = [version]$latestTag

        if ($latestVersion -gt $currentVersion) {
            Write-Host ''
            Write-Host "  Update available: v$latestVersion (installed: v$currentVersion)" -ForegroundColor Yellow
            $response = Read-Host '  Install update now? (Y/N)'
            if ($response -match '^[Yy]') {
                Update-LKModule -Confirm:$false
            } else {
                Write-Host "  Run Update-LKModule when you're ready." -ForegroundColor DarkGray
                Write-Host ''
            }
        }
    } catch {
        # Version check is non-critical - fail silently
    }
}
