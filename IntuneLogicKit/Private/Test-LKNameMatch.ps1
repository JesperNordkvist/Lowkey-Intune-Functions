function Test-LKNameMatch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Value,

        [Parameter(Mandatory)]
        [string[]]$Name,

        [ValidateSet('Contains', 'Exact', 'Wildcard', 'Regex')]
        [string]$NameMatch = 'Contains'
    )

    foreach ($pattern in $Name) {
        switch ($NameMatch) {
            'Contains' {
                if ($Value -like "*$pattern*") { return $true }
            }
            'Exact' {
                if ($Value -eq $pattern) { return $true }
            }
            'Wildcard' {
                if ($Value -like $pattern) { return $true }
            }
            'Regex' {
                if ($Value -match $pattern) { return $true }
            }
        }
    }

    return $false
}
