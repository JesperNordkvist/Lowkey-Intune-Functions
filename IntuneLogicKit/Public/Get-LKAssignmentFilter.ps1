function Get-LKAssignmentFilter {
    <#
    .SYNOPSIS
        Queries Intune assignment filters in the tenant.
    .EXAMPLE
        Get-LKAssignmentFilter
    .EXAMPLE
        Get-LKAssignmentFilter -Name "24H2" -NameMatch Contains
    .EXAMPLE
        Get-LKAssignmentFilter -DisplayAs Table
    #>
    [CmdletBinding()]
    param(
        [string[]]$Name,

        [ValidateSet('Contains', 'Exact', 'Wildcard', 'Regex')]
        [string]$NameMatch = 'Contains',

        [ValidateSet('List', 'Table')]
        [string]$DisplayAs = 'List'
    )

    Assert-LKSession

    if ($DisplayAs -eq 'Table') { $collector = [System.Collections.Generic.List[object]]::new() }

    $selectFields = 'id,displayName,description,platform,rule,assignmentFilterManagementType'
    $uri = "/deviceManagement/assignmentFilters?`$select=$selectFields"

    # Server-side filter for exact single name
    if ($Name -and $Name.Count -eq 1 -and $NameMatch -eq 'Exact') {
        $escaped = $Name[0].Replace("'", "''")
        $uri += "&`$filter=displayName eq '$escaped'"
    }

    try {
        $filters = Invoke-LKGraphRequest -Method GET -Uri $uri -ApiVersion 'beta' -All
    } catch {
        throw "Failed to query assignment filters: $($_.Exception.Message)"
    }

    if (-not $filters) { return }

    $clientSideFilter = $Name -and ($NameMatch -ne 'Exact' -or $Name.Count -gt 1)

    foreach ($f in $filters) {
        if ($clientSideFilter -and -not (Test-LKNameMatch -Value $f.displayName -Name $Name -NameMatch $NameMatch)) {
            continue
        }

        $obj = [PSCustomObject]@{
            PSTypeName     = 'LKAssignmentFilter'
            Id             = $f.id
            Name           = $f.displayName
            Description    = $f.description
            Platform       = $f.platform
            Rule           = $f.rule
            ManagementType = $f.assignmentFilterManagementType
        }

        if ($DisplayAs -eq 'Table') { $collector.Add($obj) } else { $obj }
    }

    if ($DisplayAs -eq 'Table' -and $collector.Count -gt 0) {
        $collector | Format-Table Name, Platform, Rule -AutoSize
    }
}
