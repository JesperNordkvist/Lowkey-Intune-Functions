function Resolve-LKFilterId {
    <#
    .SYNOPSIS
        Resolves an assignment filter display name to its ID.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FilterName
    )

    $escaped = $FilterName.Replace("'", "''")
    $uri = "/deviceManagement/assignmentFilters?`$filter=displayName eq '$escaped'&`$select=id,displayName"

    try {
        $results = @(Invoke-LKGraphRequest -Method GET -Uri $uri -ApiVersion 'beta' -All)
    } catch {
        throw "Failed to query assignment filters: $($_.Exception.Message)"
    }

    if ($results.Count -eq 0) {
        throw "Assignment filter '$FilterName' not found."
    }
    if ($results.Count -gt 1) {
        throw "Multiple assignment filters found matching '$FilterName'. Use an exact name."
    }

    return $results[0].id
}
