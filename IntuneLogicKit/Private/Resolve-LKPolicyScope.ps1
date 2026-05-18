function Resolve-LKPolicyScope {
    <#
    .SYNOPSIS
        Determines the effective assignment scope (User/Device/Both) of a policy.
        This reflects which group types a policy can validly be assigned to,
        not the CSP scope (HKLM vs HKCU) of its underlying settings.
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
            # Settings Catalog definition ID prefixes (device_ / user_) indicate CSP scope
            # (HKLM vs HKCU), NOT assignment scope. Intune fully supports cross-scope:
            #   - device_ CSP policies assigned to user groups (applies HKLM when user signs in)
            #   - user_ CSP policies assigned to device groups (applies to all users on device)
            # OIB deliberately assigns device_ CSP policies to user groups for Autopilot timing.
            # Fall through to name-based heuristic.
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
            # ADMX (Group Policy) configurations contain definitions of mixed
            # class: 'user' (HKCU) and 'machine' (HKLM). A policy carrying both
            # classes can be validly assigned to user groups AND device groups,
            # so it must resolve to 'Both'. Inspecting only the first definition
            # value misclassified mixed policies and produced false mismatches.
            if (-not $script:LKAdmxClassCache) { $script:LKAdmxClassCache = @{} }

            $policyId = $RawPolicy.id
            if ($policyId -and -not $script:LKAdmxClassCache.ContainsKey($policyId)) {
                try {
                    # Enumerate every definition value, but pull only each linked
                    # definition's classType so the payload stays small on ADMX
                    # policies that carry hundreds of settings.
                    $defValues = Invoke-LKGraphRequest -Method GET `
                        -Uri "/deviceManagement/groupPolicyConfigurations/$policyId/definitionValues?`$expand=definition(`$select=classType)" `
                        -ApiVersion 'beta' -All
                    $script:LKAdmxClassCache[$policyId] = @(
                        $defValues |
                            ForEach-Object { $_.definition.classType } |
                            Where-Object { $_ } |
                            Sort-Object -Unique
                    )
                } catch {
                    Write-Verbose "Resolve-LKPolicyScope: failed to fetch definition values for ADMX policy $($policyId): $($_.Exception.Message)"
                    $script:LKAdmxClassCache[$policyId] = @()
                }
            }

            # Direct assignment keeps the result an array; a single-element
            # array returned from an if-expression would unroll to a scalar.
            $classTypes = @()
            if ($policyId) { $classTypes = @($script:LKAdmxClassCache[$policyId]) }

            switch ($classTypes.Count) {
                0 { }  # No class info resolved - fall through to name-based heuristic
                1 {
                    if ($classTypes[0] -eq 'user')    { return 'User' }
                    if ($classTypes[0] -eq 'machine') { return 'Device' }
                }
                default {
                    # Mixed user + machine ADMX settings - valid for either target
                    return 'Both'
                }
            }
            # Fall through to name-based heuristic
        }

        'EnrollmentConfiguration' {
            $odataType = $RawPolicy.'@odata.type'
            if ($odataType -like '*Limit*')               { return 'User' }
            if ($odataType -like '*HelloForBusiness*')     { return 'User' }
            # Fall through to name-based heuristic
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
            # Fall through to name-based heuristic
        }

        default { }  # Fall through to name-based heuristic below
    }

    # Final fallback: infer scope from naming convention
    # Common patterns: "- U -", "-U-", "- D -", "-D-", "- C -", "-C-"
    #   U = User-scoped, D/C = Device-scoped (C = Computer)
    $nameProp = $PolicyType.NameProperty
    $policyName = $RawPolicy.$nameProp
    if ($policyName) {
        if ($policyName -match '[-–]\s*U\s*[-–]') { return 'User' }
        if ($policyName -match '[-–]\s*[DC]\s*[-–]') { return 'Device' }
    }

    return 'Both'
}
