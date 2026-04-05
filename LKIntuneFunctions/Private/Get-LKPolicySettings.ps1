function Get-LKPolicySettings {
    <#
    .SYNOPSIS
        Fetches the configured settings for a policy based on its type.
        Returns a flat array of hashtables with Name, Value, and Category keys.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PolicyId,

        [Parameter(Mandatory)]
        [hashtable]$PolicyType,

        [object]$RawPolicy
    )

    switch ($PolicyType.TypeName) {

        'SettingsCatalog' {
            return Get-LKSettingsCatalogSettings -PolicyId $PolicyId
        }

        'CompliancePolicy' {
            return Get-LKFlatSettings -RawPolicy $RawPolicy -ExcludeProperties @(
                'id', '@odata.type', 'displayName', 'description', 'version',
                'createdDateTime', 'lastModifiedDateTime', 'roleScopeTagIds',
                'assignments', 'scheduledActionsForRule'
            )
        }

        'DeviceConfiguration' {
            return Get-LKFlatSettings -RawPolicy $RawPolicy -ExcludeProperties @(
                'id', '@odata.type', 'displayName', 'description', 'version',
                'createdDateTime', 'lastModifiedDateTime', 'roleScopeTagIds',
                'assignments', 'supportsScopeTags'
            )
        }

        'EndpointSecurity' {
            return Get-LKEndpointSecuritySettings -PolicyId $PolicyId
        }

        'GroupPolicyConfiguration' {
            return Get-LKAdmxSettings -PolicyId $PolicyId
        }

        'AppProtectionIOS'     { return Get-LKFlatSettings -RawPolicy $RawPolicy -ExcludeCommon }
        'AppProtectionAndroid' { return Get-LKFlatSettings -RawPolicy $RawPolicy -ExcludeCommon }
        'AppProtectionWindows' { return Get-LKFlatSettings -RawPolicy $RawPolicy -ExcludeCommon }
        'AppConfiguration'     { return Get-LKFlatSettings -RawPolicy $RawPolicy -ExcludeCommon }

        default {
            return Get-LKFlatSettings -RawPolicy $RawPolicy -ExcludeCommon
        }
    }
}

function Get-LKSettingsCatalogSettings {
    [CmdletBinding()]
    param([string]$PolicyId)

    try {
        $settings = Invoke-LKGraphRequest -Method GET `
            -Uri "/deviceManagement/configurationPolicies/$PolicyId/settings" `
            -ApiVersion 'beta' -All
    } catch {
        Write-Verbose "Failed to fetch Settings Catalog settings: $($_.Exception.Message)"
        return @()
    }

    if (-not $settings) { return @() }

    $results = [System.Collections.ArrayList]::new()
    foreach ($setting in $settings) {
        Expand-LKSettingInstance -Instance $setting.settingInstance -Results $results -Depth 0
    }
    return @($results)
}

function Expand-LKSettingInstance {
    [CmdletBinding()]
    param(
        [object]$Instance,
        [System.Collections.ArrayList]$Results,
        [int]$Depth
    )

    if (-not $Instance) { return }

    $defId = $Instance.settingDefinitionId
    # Extract a human-readable name from the definition ID (e.g., "device_vendor_msft_policy_config_update_allowautoupdate")
    $friendlyName = if ($defId) {
        ($defId -split '_' | Select-Object -Skip 1) -join ' '
    } else {
        'Unknown Setting'
    }

    $odataType = $Instance.'@odata.type'

    switch -Wildcard ($odataType) {
        '*choiceSettingInstance' {
            $valueId = $Instance.choiceSettingValue.value
            $displayValue = if ($valueId) { ($valueId -split '_') | Select-Object -Last 1 } else { '(not set)' }
            $Results.Add(@{ Name = $friendlyName; Value = $displayValue; Category = 'Settings Catalog' }) | Out-Null

            # Recurse into children
            if ($Instance.choiceSettingValue.children) {
                foreach ($child in $Instance.choiceSettingValue.children) {
                    Expand-LKSettingInstance -Instance $child -Results $Results -Depth ($Depth + 1)
                }
            }
        }
        '*simpleSettingInstance' {
            $val = $Instance.simpleSettingValue.value
            if ($null -eq $val) { $val = $Instance.simpleSettingValue.valueState }
            $Results.Add(@{ Name = $friendlyName; Value = $val; Category = 'Settings Catalog' }) | Out-Null
        }
        '*simpleSettingCollectionInstance' {
            $vals = @($Instance.simpleSettingCollectionValue | ForEach-Object { $_.value })
            $Results.Add(@{ Name = $friendlyName; Value = ($vals -join ', '); Category = 'Settings Catalog' }) | Out-Null
        }
        '*groupSettingInstance' {
            if ($Instance.groupSettingValue.children) {
                foreach ($child in $Instance.groupSettingValue.children) {
                    Expand-LKSettingInstance -Instance $child -Results $Results -Depth ($Depth + 1)
                }
            }
        }
        '*groupSettingCollectionInstance' {
            $idx = 0
            foreach ($group in $Instance.groupSettingCollectionValue) {
                $idx++
                if ($group.children) {
                    foreach ($child in $group.children) {
                        Expand-LKSettingInstance -Instance $child -Results $Results -Depth ($Depth + 1)
                    }
                }
            }
        }
        default {
            # Fallback: try to extract value from known patterns
            $val = $Instance.value
            if ($null -ne $val) {
                $Results.Add(@{ Name = $friendlyName; Value = $val; Category = 'Settings Catalog' }) | Out-Null
            }
        }
    }
}

function Get-LKEndpointSecuritySettings {
    [CmdletBinding()]
    param([string]$PolicyId)

    try {
        $categories = Invoke-LKGraphRequest -Method GET `
            -Uri "/deviceManagement/intents/$PolicyId/categories" `
            -ApiVersion 'beta' -All
    } catch {
        Write-Verbose "Failed to fetch Endpoint Security categories: $($_.Exception.Message)"
        return @()
    }

    if (-not $categories) { return @() }

    $results = [System.Collections.ArrayList]::new()
    foreach ($category in $categories) {
        $categoryName = $category.displayName
        try {
            $catSettings = Invoke-LKGraphRequest -Method GET `
                -Uri "/deviceManagement/intents/$PolicyId/categories/$($category.id)/settings" `
                -ApiVersion 'beta' -All
        } catch {
            Write-Verbose "Failed to fetch settings for category '$categoryName': $($_.Exception.Message)"
            continue
        }

        foreach ($s in $catSettings) {
            $val = $s.value
            if ($null -eq $val -and $s.valueJson) {
                $val = $s.valueJson
            }
            if ($val -is [System.Collections.IEnumerable] -and $val -isnot [string]) {
                $val = ($val | ForEach-Object { "$_" }) -join ', '
            }
            $results.Add(@{
                Name     = ($s.definitionId -replace '^.*_', '')
                Value    = $val
                Category = $categoryName
            }) | Out-Null
        }
    }
    return @($results)
}

function Get-LKAdmxSettings {
    [CmdletBinding()]
    param([string]$PolicyId)

    try {
        $defValues = Invoke-LKGraphRequest -Method GET `
            -Uri "/deviceManagement/groupPolicyConfigurations/$PolicyId/definitionValues?`$expand=definition" `
            -ApiVersion 'beta' -All
    } catch {
        Write-Verbose "Failed to fetch ADMX settings: $($_.Exception.Message)"
        return @()
    }

    if (-not $defValues) { return @() }

    $results = [System.Collections.ArrayList]::new()
    foreach ($dv in $defValues) {
        $def = $dv.definition
        $settingName = if ($def.displayName) { $def.displayName } else { $def.id }
        $category = if ($def.categoryPath) { $def.categoryPath } else { 'ADMX' }

        $results.Add(@{
            Name     = $settingName
            Value    = if ($dv.enabled) { 'Enabled' } else { 'Disabled' }
            Category = $category
        }) | Out-Null
    }
    return @($results)
}

function Get-LKFlatSettings {
    <#
    .SYNOPSIS
        Extracts key/value settings from the raw policy object by flattening its properties.
    #>
    [CmdletBinding()]
    param(
        [object]$RawPolicy,
        [string[]]$ExcludeProperties,
        [switch]$ExcludeCommon
    )

    if (-not $RawPolicy) { return @() }

    $commonExclusions = @(
        'id', '@odata.type', 'displayName', 'name', 'description', 'version',
        'createdDateTime', 'lastModifiedDateTime', 'roleScopeTagIds',
        'assignments', 'isAssigned', '@odata.context'
    )

    $exclusions = if ($ExcludeCommon) { $commonExclusions } else { @() }
    if ($ExcludeProperties) { $exclusions += $ExcludeProperties }

    $results = [System.Collections.ArrayList]::new()

    foreach ($prop in $RawPolicy.PSObject.Properties) {
        if ($prop.Name -in $exclusions) { continue }
        if ($prop.Name.StartsWith('@')) { continue }

        $val = $prop.Value
        if ($null -eq $val) { continue }

        # Skip complex nested objects that aren't useful as flat settings
        if ($val -is [System.Collections.IDictionary]) {
            # Flatten one level for simple nested objects
            foreach ($key in $val.Keys) {
                $subVal = $val[$key]
                if ($null -ne $subVal -and $subVal -isnot [System.Collections.IDictionary]) {
                    $results.Add(@{ Name = "$($prop.Name).$key"; Value = $subVal; Category = 'Configuration' }) | Out-Null
                }
            }
            continue
        }

        if ($val -is [System.Collections.IEnumerable] -and $val -isnot [string]) {
            $val = ($val | ForEach-Object { "$_" }) -join ', '
        }

        $results.Add(@{ Name = $prop.Name; Value = $val; Category = 'Configuration' }) | Out-Null
    }

    return @($results)
}
