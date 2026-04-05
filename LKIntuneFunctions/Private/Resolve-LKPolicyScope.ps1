function Resolve-LKPolicyScope {
    <#
    .SYNOPSIS
        Determines the effective user/device scope of a policy via Graph metadata.
        Falls back to the registry's static scope when runtime signals are unavailable.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$RawPolicy,

        [Parameter(Mandatory)]
        [hashtable]$PolicyType
    )

    # Fast path: types with a fixed, known scope
    if ($PolicyType.TargetScope -ne 'Both') {
        return $PolicyType.TargetScope
    }

    switch ($PolicyType.TypeName) {

        'SettingsCatalog' {
            # 1) Check templateFamily - endpoint security templates are device-scoped
            $family = $RawPolicy.templateReference.templateFamily
            if ($family -and $family -ne 'none') {
                if ($family -like 'endpointSecurity*') { return 'Device' }
            }

            # 2) Fetch first setting and inspect the settingDefinitionId prefix
            try {
                $settings = Invoke-LKGraphRequest -Method GET `
                    -Uri "/deviceManagement/configurationPolicies/$($RawPolicy.id)/settings?`$top=1" `
                    -ApiVersion 'beta'
                if ($settings -and $settings.Count -gt 0) {
                    $defId = $settings[0].settingInstance.settingDefinitionId
                    if ($defId -like 'device_*') { return 'Device' }
                    if ($defId -like 'user_*')   { return 'User' }
                }
            } catch {
                Write-Verbose "Resolve-LKPolicyScope: failed to fetch settings for SettingsCatalog policy $($RawPolicy.id): $($_.Exception.Message)"
            }

            return 'Both'
        }

        'EndpointSecurity' {
            # Cache template lookups within the module session
            if (-not $script:LKTemplateCache) { $script:LKTemplateCache = @{} }

            $templateId = $RawPolicy.templateId
            if ($templateId) {
                if (-not $script:LKTemplateCache.ContainsKey($templateId)) {
                    try {
                        $script:LKTemplateCache[$templateId] = Invoke-LKGraphRequest -Method GET `
                            -Uri "/deviceManagement/templates/$templateId" -ApiVersion 'beta'
                    } catch {
                        $script:LKTemplateCache[$templateId] = $null
                    }
                }

                $template = $script:LKTemplateCache[$templateId]
                if ($template) {
                    $deviceSubtypes = @(
                        'firewall', 'diskEncryption', 'attackSurfaceReduction',
                        'endpointDetectionResponse', 'antivirus', 'accountProtection'
                    )
                    if ($template.templateSubtype -in $deviceSubtypes) { return 'Device' }

                    $deviceTypes = @(
                        'securityBaseline', 'advancedThreatProtectionSecurityBaseline',
                        'microsoftEdgeSecurityBaseline'
                    )
                    if ($template.templateType -in $deviceTypes) { return 'Device' }
                }
            }

            return 'Device'
        }

        'GroupPolicyConfiguration' {
            # Check the classType on the first definition value
            try {
                $defValues = Invoke-LKGraphRequest -Method GET `
                    -Uri "/deviceManagement/groupPolicyConfigurations/$($RawPolicy.id)/definitionValues?`$expand=definition&`$top=1" `
                    -ApiVersion 'beta'
                if ($defValues -and $defValues.Count -gt 0) {
                    $classType = $defValues[0].definition.classType
                    if ($classType -eq 'user')    { return 'User' }
                    if ($classType -eq 'machine') { return 'Device' }
                }
            } catch {
                Write-Verbose "Resolve-LKPolicyScope: failed to fetch definition values for ADMX policy $($RawPolicy.id): $($_.Exception.Message)"
            }

            return 'Both'
        }

        'EnrollmentConfiguration' {
            $odataType = $RawPolicy.'@odata.type'
            if ($odataType -like '*Limit*')               { return 'User' }
            if ($odataType -like '*HelloForBusiness*')     { return 'User' }
            if ($odataType -like '*PlatformRestriction*')  { return 'Both' }
            return 'Both'
        }

        'DeviceConfiguration' {
            # Most device configs can be assigned to either, but some are clearly device-only
            $odataType = $RawPolicy.'@odata.type'
            $deviceOnly = @(
                '*windowsUpdateForBusinessConfiguration*',
                '*sharedPCConfiguration*',
                '*editionUpgradeConfiguration*',
                '*windowsDefenderAdvancedThreatProtection*',
                '*windowsKioskConfiguration*'
            )
            foreach ($pattern in $deviceOnly) {
                if ($odataType -like $pattern) { return 'Device' }
            }
            return 'Both'
        }

        default { return 'Both' }
    }
}
