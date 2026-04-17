function Resolve-LKGroupScope {
    <#
    .SYNOPSIS
        Determines whether a group contains users, devices, or both.
        Checks dynamic membership rule first, then samples members for assigned groups.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$GroupId
    )

    # Fetch group details
    try {
        $group = Invoke-LKGraphRequest -Method GET `
            -Uri "/groups/$GroupId`?`$select=displayName,membershipRule,membershipRuleProcessingState,groupTypes" `
            -ApiVersion 'v1.0'
    } catch {
        return 'Unknown'
    }

    # Dynamic group: parse the membership rule
    if ($group.membershipRuleProcessingState -eq 'On' -and $group.membershipRule) {
        $rule = $group.membershipRule
        if ($rule -match '\(device\.') { return 'Device' }
        if ($rule -match '\(user\.')   { return 'User' }
        return 'Unknown'
    }

    # Assigned group: probe user and device members via type-cast filters.
    # Type casts are unambiguous and avoid relying on @odata.type annotations
    # (which Graph sometimes omits from $select responses).
    $hasUsers = $false
    $hasDevices = $false
    try {
        $userProbe = Invoke-LKGraphRequest -Method GET `
            -Uri "/groups/$GroupId/members/microsoft.graph.user?`$top=1&`$select=id" `
            -ApiVersion 'v1.0'
        if ($userProbe.value -and $userProbe.value.Count -gt 0) { $hasUsers = $true }
    } catch {
        Write-Verbose "User-member probe failed for $GroupId`: $($_.Exception.Message)"
    }
    try {
        $deviceProbe = Invoke-LKGraphRequest -Method GET `
            -Uri "/groups/$GroupId/members/microsoft.graph.device?`$top=1&`$select=id" `
            -ApiVersion 'v1.0'
        if ($deviceProbe.value -and $deviceProbe.value.Count -gt 0) { $hasDevices = $true }
    } catch {
        Write-Verbose "Device-member probe failed for $GroupId`: $($_.Exception.Message)"
    }

    if ($hasDevices -and $hasUsers) { return 'Both' }
    if ($hasDevices) { return 'Device' }
    if ($hasUsers)   { return 'User' }

    # Empty group or mixed/unclassified members: fall back to name heuristic.
    # U/D/C tokens in the display name (e.g. 'SG-Intune-U-Pilot Users',
    # 'SG-Intune-D-Pilot Devices') reliably encode member scope.
    $groupName = $group.displayName
    if ($groupName) {
        if ($groupName -match '[-–]\s*U\s*[-–]')    { return 'User' }
        if ($groupName -match '[-–]\s*[DC]\s*[-–]') { return 'Device' }
    }

    return 'Unknown'
}
