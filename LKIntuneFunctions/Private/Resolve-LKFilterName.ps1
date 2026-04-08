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

    # Batch-resolve uncached IDs in groups of 15
    $batchSize = 15
    for ($i = 0; $i -lt $uncached.Count; $i += $batchSize) {
        $batch = $uncached[$i..[Math]::Min($i + $batchSize - 1, $uncached.Count - 1)]
        $filterClauses = $batch | ForEach-Object { "id eq '$_'" }
        $filter = $filterClauses -join ' or '
        $uri = "/deviceManagement/assignmentFilters?`$filter=$filter&`$select=id,displayName"

        try {
            $results = Invoke-LKGraphRequest -Method GET -Uri $uri -ApiVersion 'beta' -All
            foreach ($f in $results) {
                if ($f.id) {
                    $script:LKFilterNameCache[$f.id] = $f.displayName
                    $map[$f.id] = $f.displayName
                }
            }
        } catch {
            Write-Verbose "Failed to resolve filter names: $($_.Exception.Message)"
        }

        # Cache $null for IDs not found to avoid re-querying
        foreach ($id in $batch) {
            if (-not $script:LKFilterNameCache.ContainsKey($id)) {
                $script:LKFilterNameCache[$id] = $null
                $map[$id] = $null
            }
        }
    }

    return $map
}
