function Resolve-LKFilterName {
    <#
    .SYNOPSIS
        Batch-resolves assignment filter IDs to display names with caching.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$FilterIds
    )

    $map = @{}
    $validIds = @($FilterIds | Where-Object { $_ })
    if ($validIds.Count -eq 0) { return $map }

    # Return cached results and identify uncached IDs
    $uncached = @()
    foreach ($id in $validIds) {
        if ($script:LKFilterNameCache.ContainsKey($id)) {
            $map[$id] = $script:LKFilterNameCache[$id]
        } else {
            $uncached += $id
        }
    }

    if ($uncached.Count -eq 0) { return $map }

    # Resolve uncached IDs individually
    foreach ($id in $uncached) {
        try {
            $f = Invoke-LKGraphRequest -Method GET -Uri "/deviceManagement/assignmentFilters/$id`?`$select=id,displayName" -ApiVersion 'beta'
            $script:LKFilterNameCache[$id] = $f.displayName
            $map[$id] = $f.displayName
        } catch {
            Write-Verbose "Failed to resolve filter $id`: $($_.Exception.Message)"
            $script:LKFilterNameCache[$id] = $null
            $map[$id] = $null
        }
    }

    return $map
}
