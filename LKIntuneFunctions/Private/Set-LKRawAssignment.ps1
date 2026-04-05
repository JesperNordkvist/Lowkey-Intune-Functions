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
        # Scripts use individual groupAssignment resources
        # Clear existing and re-create
        $existing = Get-LKRawAssignment -PolicyId $PolicyId -PolicyType $PolicyType
        foreach ($assignment in $existing) {
            $deletePath = "$($PolicyType.Endpoint)/$PolicyId/groupAssignments/$($assignment.id)"
            Invoke-LKGraphRequest -Method DELETE -Uri $deletePath -ApiVersion $PolicyType.ApiVersion | Out-Null
        }
        foreach ($assignment in $Assignments) {
            $createPath = "$($PolicyType.Endpoint)/$PolicyId/groupAssignments"
            # Convert Standard target format back to GroupAssignments format
            $body = @{ targetGroupId = $assignment.target.groupId }
            Invoke-LKGraphRequest -Method POST -Uri $createPath -ApiVersion $PolicyType.ApiVersion -Body $body | Out-Null
        }
        return
    }

    # Standard assignment method: POST to /assign with full replacement
    $assignPath = "$($PolicyType.Endpoint)/$PolicyId/assign"
    $body = @{ assignments = $Assignments }

    Invoke-LKGraphRequest -Method POST -Uri $assignPath -ApiVersion $PolicyType.ApiVersion -Body $body | Out-Null
}
