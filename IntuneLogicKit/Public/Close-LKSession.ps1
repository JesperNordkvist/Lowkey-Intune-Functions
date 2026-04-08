function Close-LKSession {
    <#
    .SYNOPSIS
        Disconnects from Microsoft Graph and ends the current session.
    .DESCRIPTION
        Terminates the Graph connection, clears in-memory session state, and removes the
        persisted session file. Run this when you are finished working to ensure no stale
        credentials are reused in a later session.
    .EXAMPLE
        Close-LKSession
    #>
    [CmdletBinding()]
    param ()

    if (Get-Module Microsoft.Graph.Authentication) {
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    }

    $script:LKSession = @{
        Connected   = $false
        TenantId    = $null
        TenantName  = $null
        Account     = $null
        Scopes      = @()
        ConnectedAt = $null
    }

    if (Test-Path $script:LKSessionPath) {
        Remove-Item $script:LKSessionPath -Force
    }

    Write-Host 'Session ended and Graph connection closed.' -ForegroundColor Green
}
