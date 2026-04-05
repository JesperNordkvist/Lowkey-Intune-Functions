function Get-LKRawAssignment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PolicyId,

        [Parameter(Mandatory)]
        [hashtable]$PolicyType
    )

    $path = if ($PolicyType.AssignmentMethod -eq 'GroupAssignments') {
        "$($PolicyType.Endpoint)/$PolicyId/groupAssignments"
    } else {
        "$($PolicyType.Endpoint)/$PolicyId$($PolicyType.AssignmentPath)"
    }

    $results = Invoke-LKGraphRequest -Method GET -Uri $path -ApiVersion $PolicyType.ApiVersion -All

    if (-not $results) { return @() }

    # Normalize GroupAssignments format to Standard target structure
    if ($PolicyType.AssignmentMethod -eq 'GroupAssignments') {
        $results = @($results | ForEach-Object {
            @{
                id     = $_.id
                target = @{
                    '@odata.type' = '#microsoft.graph.groupAssignmentTarget'
                    groupId       = $_.targetGroupId
                }
            }
        })
    }

    return $results
}
