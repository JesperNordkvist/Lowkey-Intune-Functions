function Set-LKRawAssignment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PolicyId,

        [Parameter(Mandatory)]
        [hashtable]$PolicyType,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [array]$Assignments
    )

    if ($PolicyType.AssignmentMethod -eq 'GroupAssignments') {
        # Scripts use the /assign action with a specific body format
        $assignPath = "$($PolicyType.Endpoint)/$PolicyId/assign"
        $groupAssignments = @($Assignments | ForEach-Object {
            @{
                '@odata.type' = '#microsoft.graph.deviceManagementScriptGroupAssignment'
                id            = "$PolicyId`_$($_.target.groupId)"
                targetGroupId = $_.target.groupId
            }
        })
        $body = @{
            deviceManagementScriptGroupAssignments = $groupAssignments
            deviceManagementScriptAssignments      = @()
        }
        Invoke-LKGraphRequest -Method POST -Uri $assignPath -ApiVersion $PolicyType.ApiVersion -Body $body | Out-Null
        return
    }

    # Standard assignment method: POST to /assign with full replacement
    $assignPath = "$($PolicyType.Endpoint)/$PolicyId/assign"
    $body = @{ assignments = $Assignments }

    Invoke-LKGraphRequest -Method POST -Uri $assignPath -ApiVersion $PolicyType.ApiVersion -Body $body | Out-Null
}
