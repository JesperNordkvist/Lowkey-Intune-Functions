function Search-LKSetting {
    <#
    .SYNOPSIS
        Searches Intune policies for settings matching a query.
    .DESCRIPTION
        Scans policies across all or specific policy types, retrieves their configured
        settings, and returns matches where the setting name (or optionally value)
        matches the search term. Useful for answering "which policies configure this setting?"
    .EXAMPLE
        Search-LKSetting -Setting "BitLocker"
        Searches all policy types for settings with "BitLocker" in the name.
    .EXAMPLE
        Search-LKSetting -Setting "Password" -PolicyType CompliancePolicy, DeviceConfiguration
        Searches only compliance and device configuration policies for password-related settings.
    .EXAMPLE
        Search-LKSetting -Setting "Firewall*" -SettingMatch Wildcard
        Uses wildcard matching against setting names.
    .EXAMPLE
        Search-LKSetting -Setting "Enabled" -SearchValues
        Searches within setting values as well as names.
    .EXAMPLE
        Search-LKSetting -Setting "Encryption" -PolicyName "Baseline*" -PolicyNameMatch Wildcard
        Searches for encryption settings only in policies whose names match "Baseline*".
    .EXAMPLE
        Search-LKSetting -Setting "BitLocker" -DisplayAs List | Select-Object PolicyName, SettingName, Value
        Returns objects for pipeline processing.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Setting,

        [ValidateSet('Contains', 'Exact', 'Wildcard', 'Regex')]
        [string]$SettingMatch = 'Contains',

        [ValidateSet(
            'DeviceConfiguration', 'SettingsCatalog', 'CompliancePolicy', 'EndpointSecurity',
            'AppProtectionIOS', 'AppProtectionAndroid', 'AppProtectionWindows',
            'AppConfiguration', 'EnrollmentConfiguration', 'PolicySet',
            'GroupPolicyConfiguration', 'PlatformScript', 'Remediation',
            'DriverUpdate', 'App', 'AutopilotDeploymentProfile'
        )]
        [string[]]$PolicyType,

        [string[]]$PolicyName,

        [ValidateSet('Contains', 'Exact', 'Wildcard', 'Regex')]
        [string]$PolicyNameMatch = 'Contains',

        [switch]$SearchValues,

        [ValidateSet('List', 'Table')]
        [string]$DisplayAs = 'Table'
    )

    Assert-LKSession

    if ($DisplayAs -eq 'Table') { $collector = [System.Collections.Generic.List[object]]::new() }

    $types = if ($PolicyType) {
        $script:LKPolicyTypes | Where-Object { $_.TypeName -in $PolicyType }
    } else {
        $script:LKPolicyTypes
    }

    $totalTypes = $types.Count
    $currentType = 0

    foreach ($type in $types) {
        $currentType++
        Write-Progress -Activity 'Searching Intune policy settings' `
            -Status "$($type.DisplayName) ($currentType of $totalTypes)" `
            -PercentComplete (($currentType / $totalTypes) * 100)

        try {
            $rawPolicies = Invoke-LKGraphRequest -Method GET -Uri $type.Endpoint -ApiVersion $type.ApiVersion -All
        } catch {
            Write-Warning "Failed to query $($type.DisplayName): $($_.Exception.Message)"
            continue
        }

        if (-not $rawPolicies) { continue }

        # Pre-filter by policy name if specified
        if ($PolicyName) {
            $nameProp = $type.NameProperty
            $rawPolicies = @($rawPolicies | Where-Object {
                $_.$nameProp -and (Test-LKNameMatch -Value $_.$nameProp -Name $PolicyName -NameMatch $PolicyNameMatch)
            })
        }

        $policyCount = $rawPolicies.Count
        $currentPolicy = 0

        foreach ($raw in $rawPolicies) {
            $currentPolicy++
            $nameProp = $type.NameProperty
            $pName = $raw.$nameProp
            if (-not $pName) { continue }

            Write-Progress -Activity 'Searching Intune policy settings' `
                -Status "$($type.DisplayName): $pName ($currentPolicy of $policyCount)" `
                -PercentComplete (($currentType / $totalTypes) * 100)

            try {
                $settings = Get-LKPolicySettings -PolicyId $raw.id -PolicyType $type -RawPolicy $raw
            } catch {
                Write-Verbose "Failed to fetch settings for '$pName': $($_.Exception.Message)"
                continue
            }

            if (-not $settings -or $settings.Count -eq 0) { continue }

            foreach ($s in $settings) {
                $nameHit = Test-LKNameMatch -Value $s.Name -Name $Setting -NameMatch $SettingMatch
                $valueHit = $false
                if ($SearchValues -and $null -ne $s.Value) {
                    $valueHit = Test-LKNameMatch -Value "$($s.Value)" -Name $Setting -NameMatch $SettingMatch
                }

                if (-not $nameHit -and -not $valueHit) { continue }

                $obj = [PSCustomObject]@{
                    PSTypeName  = 'LKSettingMatch'
                    PolicyName  = $pName
                    PolicyId    = $raw.id
                    PolicyType  = $type.TypeName
                    DisplayType = $type.DisplayName
                    SettingName = $s.Name
                    Value       = $s.Value
                    Category    = $s.Category
                }

                if ($DisplayAs -eq 'Table') { $collector.Add($obj) } else { $obj }
            }
        }
    }

    Write-Progress -Activity 'Searching Intune policy settings' -Completed

    if ($DisplayAs -eq 'Table') {
        if ($collector.Count -gt 0) {
            # Build display-friendly rows with truncation
            $displayData = $collector | ForEach-Object {
                $dispValue = if ($null -eq $_.Value -or "$($_.Value)" -eq '') { '(not set)' }
                             elseif ("$($_.Value)" -eq 'True')  { 'Enabled' }
                             elseif ("$($_.Value)" -eq 'False') { 'Disabled' }
                             else { "$($_.Value)".TrimEnd('.') }

                [PSCustomObject]@{
                    PolicyName  = if ($_.PolicyName.Length -gt 40) { $_.PolicyName.Substring(0, 37) + '...' } else { $_.PolicyName }
                    DisplayType = $_.DisplayType
                    SettingName = if ($_.SettingName.Length -gt 45) { $_.SettingName.Substring(0, 42) + '...' } else { $_.SettingName }
                    Value       = if ($dispValue.Length -gt 40) { $dispValue.Substring(0, 37) + '...' } else { $dispValue }
                }
            }

            Write-LKTable -Data $displayData -Columns @('PolicyName', 'DisplayType', 'SettingName', 'Value') -ColorRules @{
                'Value' = {
                    param($val)
                    switch ($val) {
                        'Enabled'   { 'Green' }
                        'Disabled'  { 'DarkGray' }
                        '(not set)' { 'DarkGray' }
                        default     { 'White' }
                    }
                }
            }
            Write-Host "  $($collector.Count) matching setting(s) found." -ForegroundColor Gray
            Write-Host ''
        } else {
            Write-Host ''
            Write-Host "  No settings found matching '$($Setting -join "', '")'." -ForegroundColor DarkGray
            Write-Host ''
        }
    }
}
