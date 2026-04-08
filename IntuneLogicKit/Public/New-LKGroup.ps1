function New-LKGroup {
    <#
    .SYNOPSIS
        Creates a new Entra ID security group for Intune.
    .EXAMPLE
        New-LKGroup -Name 'SG-Intune-TestDevices' -Description 'Test device group'
    .EXAMPLE
        New-LKGroup -Name 'SG-Intune-TestUsers' -Description 'Test users' -GroupType User
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Description = '',

        [ValidateSet('Device', 'User')]
        [string]$GroupType = 'Device'
    )

    Assert-LKSession

    # Check if group already exists
    try {
        $existing = Resolve-LKGroupId -GroupName $Name
        if ($existing) {
            Write-Warning "Group '$Name' already exists (Id: $existing)."
            return Get-LKGroup -Name $Name -NameMatch Exact
        }
    } catch {
        # Group not found - this is expected, proceed with creation
    }

    $mailNickname = ($Name -replace '[^a-zA-Z0-9]', '').ToLower()
    if (-not $mailNickname) { $mailNickname = 'group' }

    Write-LKActionSummary -Action 'CREATE GROUP' -Details ([ordered]@{
        Name        = $Name
        Description = if ($Description) { $Description } else { '(none)' }
        Type        = "$GroupType security group (Assigned)"
    })

    if ($PSCmdlet.ShouldProcess($Name, 'Create security group')) {
        $body = @{
            displayName     = $Name
            description     = $Description
            mailEnabled     = $false
            mailNickname    = $mailNickname
            securityEnabled = $true
            groupTypes      = @()
        }

        try {
            $result = Invoke-LKGraphRequest -Method POST -Uri '/groups' -ApiVersion 'v1.0' -Body $body
        } catch {
            throw "Failed to create group '$Name': $($_.Exception.Message)"
        }

        $membershipType = if ($result.membershipRuleProcessingState -eq 'On') { 'Dynamic' } else { 'Assigned' }

        [PSCustomObject]@{
            PSTypeName     = 'LKGroup'
            Id             = $result.id
            Name           = $result.displayName
            Description    = $result.description
            GroupType      = 'Security'
            MembershipType = $membershipType
            MembershipRule = $result.membershipRule
        }
    }
}
