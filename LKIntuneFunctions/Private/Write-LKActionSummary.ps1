function Write-LKActionSummary {
    <#
    .SYNOPSIS
        Writes a colored action summary to the host before a confirmation prompt.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Action,

        [hashtable]$Details
    )

    Write-Host ''
    Write-Host "  [$Action]" -ForegroundColor Yellow
    foreach ($key in $Details.Keys) {
        $value = $Details[$key]
        if ($value) {
            Write-Host "  ${key}:  " -ForegroundColor Gray -NoNewline
            Write-Host "$value" -ForegroundColor White
        }
    }

    # Show tenant context from session
    if ($script:LKSession.Connected) {
        Write-Host "  Tenant:  " -ForegroundColor Gray -NoNewline
        Write-Host "$($script:LKSession.TenantName) ($($script:LKSession.Account))" -ForegroundColor Cyan
    }
    Write-Host ''
}
