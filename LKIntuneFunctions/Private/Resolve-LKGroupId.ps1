function Resolve-LKGroupId {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$GroupName
    )

    $escaped = $GroupName.Replace("'", "''")
    $results = Invoke-LKGraphRequest -Method GET -Uri "/groups?`$filter=displayName eq '$escaped'&`$select=id,displayName" -ApiVersion 'v1.0' -All

    if (-not $results -or $results.Count -eq 0) {
        throw "Group '$GroupName' not found in Entra ID."
    }

    # Graph's eq filter is case-insensitive and pagination can return duplicates.
    # Deduplicate by ID and do a strict client-side name match.
    $unique = @{}
    foreach ($r in $results) {
        if ($r.displayName -ceq $GroupName -and -not $unique.ContainsKey($r.id)) {
            $unique[$r.id] = $r
        }
    }

    # Fall back to case-insensitive match if strict match found nothing
    if ($unique.Count -eq 0) {
        foreach ($r in $results) {
            if (-not $unique.ContainsKey($r.id)) {
                $unique[$r.id] = $r
            }
        }
    }

    if ($unique.Count -eq 0) {
        throw "Group '$GroupName' not found in Entra ID."
    }

    if ($unique.Count -gt 1) {
        $listing = ($unique.Values | ForEach-Object { "  - $($_.displayName) ($($_.id))" }) -join "`n"
        throw "Multiple groups found matching '$GroupName':`n$listing`nUse Get-LKGroup to find the exact name, or use -GroupId with the correct ID."
    }

    return ($unique.Values | Select-Object -First 1).id
}
