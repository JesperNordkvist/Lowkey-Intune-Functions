function Get-LKPolicyOverview {
    <#
    .SYNOPSIS
        Displays a formatted overview of all policies and their assignments at a glance.
    .DESCRIPTION
        Queries all (or filtered) policies, fetches their assignments, and renders a
        color-coded summary with one line per assignment, grouped by policy.

        Policies with no assignments are shown in dark gray.
        Excludes are highlighted in magenta, broad targets in dark yellow.
    .EXAMPLE
        Get-LKPolicyOverview
        Shows all policies and their assignments.
    .EXAMPLE
        Get-LKPolicyOverview -PolicyType SettingsCatalog
        Shows only Settings Catalog policies.
    .EXAMPLE
        Get-LKPolicyOverview -Name "XW365 - Win - SC"
        Shows policies matching the name filter.
    .EXAMPLE
        Get-LKPolicyOverview -Unassigned
        Shows only policies that have no assignments.
    #>
    [CmdletBinding()]
    param(
        [string[]]$Name,

        [ValidateSet('Contains', 'Exact', 'Wildcard', 'Regex')]
        [string]$NameMatch = 'Contains',

        [ValidateSet(
            'DeviceConfiguration', 'SettingsCatalog', 'CompliancePolicy', 'EndpointSecurity',
            'AppProtectionIOS', 'AppProtectionAndroid', 'AppProtectionWindows',
            'AppConfiguration', 'EnrollmentConfiguration', 'PolicySet',
            'GroupPolicyConfiguration', 'PlatformScript', 'Remediation',
            'DriverUpdate', 'App', 'AutopilotDeploymentProfile'
        )]
        [string[]]$PolicyType,

        [switch]$Unassigned
    )

    Assert-LKSession

    # Build Get-LKPolicy params
    $policyParams = @{}
    if ($Name) { $policyParams['Name'] = $Name; $policyParams['NameMatch'] = $NameMatch }
    if ($PolicyType) { $policyParams['PolicyType'] = $PolicyType }

    $policies = @(Get-LKPolicy @policyParams)
    if ($policies.Count -eq 0) {
        Write-Warning "No policies found."
        return
    }

    $totalPolicies = $policies.Count
    $currentPolicy = 0
    $groupNameCache = @{}

    # Collect all data first, then render
    $policyData = [System.Collections.Generic.List[object]]::new()

    foreach ($pol in $policies) {
        $currentPolicy++
        Write-Progress -Activity 'Building policy overview' `
            -Status "$($pol.Name) ($currentPolicy of $totalPolicies)" `
            -PercentComplete (($currentPolicy / $totalPolicies) * 100)

        try {
            $typeEntry = $script:LKPolicyTypes | Where-Object { $_.TypeName -eq $pol.PolicyType }
            $rawAssignments = Get-LKRawAssignment -PolicyId $pol.Id -PolicyType $typeEntry
        } catch {
            $rawAssignments = @()
        }

        $assignments = @()
        foreach ($a in $rawAssignments) {
            $target = $a.target
            if (-not $target) { continue }

            $odataType = $target.'@odata.type'

            $assignmentType = switch -Wildcard ($odataType) {
                '*exclusionGroupAssignmentTarget'   { 'Exclude'; break }
                '*groupAssignmentTarget'            { 'Include'; break }
                '*allDevicesAssignmentTarget'        { 'AllDevices'; break }
                '*allUsersAssignmentTarget'          { 'AllUsers'; break }
                '*allLicensedUsersAssignmentTarget'  { 'AllLicensedUsers'; break }
                default                              { 'Unknown' }
            }

            $groupId   = $target.groupId
            $groupName = $null

            if ($groupId) {
                if ($groupNameCache.ContainsKey($groupId)) {
                    $groupName = $groupNameCache[$groupId]
                } else {
                    try {
                        $grp = Invoke-LKGraphRequest -Method GET `
                            -Uri "/groups/$groupId`?`$select=displayName" -ApiVersion 'v1.0'
                        $groupName = if ($grp.displayName) { $grp.displayName } else { $groupId }
                    } catch {
                        $groupName = $groupId
                    }
                    $groupNameCache[$groupId] = $groupName
                }
            }

            # Capture assignment filter
            $filterId   = $target.deviceAndAppManagementAssignmentFilterId
            $filterType = $target.deviceAndAppManagementAssignmentFilterType
            $filterName = $null
            if ($filterId) {
                $resolved = Resolve-LKFilterName -FilterIds @($filterId)
                $filterName = $resolved[$filterId]
            }

            $assignments += @{
                Type       = $assignmentType
                GroupName  = $groupName
                Intent     = $a.intent
                FilterName = $filterName
                FilterType = $filterType
            }
        }

        $policyData.Add(@{
            Name        = $pol.Name
            DisplayType = $pol.DisplayType
            Assignments = $assignments
        })
    }

    Write-Progress -Activity 'Building policy overview' -Completed

    # Render
    $separator = [string]([char]0x2500) * 78
    Write-Host ''
    Write-Host $separator -ForegroundColor DarkGray
    Write-Host "  POLICY OVERVIEW" -ForegroundColor Cyan
    Write-Host $separator -ForegroundColor DarkGray

    $totalAssigned   = @($policyData | Where-Object { $_.Assignments.Count -gt 0 }).Count
    $totalUnassigned = @($policyData | Where-Object { $_.Assignments.Count -eq 0 }).Count
    Write-Host ''
    Write-Host "  Policies: " -ForegroundColor Gray -NoNewline
    Write-Host "$($policyData.Count) total" -ForegroundColor White -NoNewline
    Write-Host "  |  " -ForegroundColor DarkGray -NoNewline
    Write-Host "$totalAssigned assigned" -ForegroundColor Green -NoNewline
    Write-Host "  |  " -ForegroundColor DarkGray -NoNewline
    Write-Host "$totalUnassigned unassigned" -ForegroundColor $(if ($totalUnassigned -eq 0) { 'Green' } else { 'Yellow' })
    Write-Host ''

    $filteredData = if ($Unassigned) {
        @($policyData | Where-Object { $_.Assignments.Count -eq 0 })
    } else {
        $policyData
    }

    # Group policies by type for better visual separation
    $grouped = $filteredData | Group-Object { $_.DisplayType }

    foreach ($typeGroup in $grouped) {
        Write-Host "  $($typeGroup.Name)" -ForegroundColor Cyan
        $thinLine = [string]([char]0x2500) * 78
        Write-Host "  $thinLine" -ForegroundColor DarkGray

        foreach ($pol in $typeGroup.Group) {
            Write-Host "    $($pol.Name)" -ForegroundColor White

            if ($pol.Assignments.Count -eq 0) {
                Write-Host "      (no assignments)" -ForegroundColor DarkGray
            } else {
                foreach ($a in $pol.Assignments) {
                    $color = switch ($a.Type) {
                        'Exclude'          { 'Magenta' }
                        'AllDevices'       { 'DarkYellow' }
                        'AllUsers'         { 'DarkYellow' }
                        'AllLicensedUsers' { 'DarkYellow' }
                        'Include'          { 'Green' }
                        default            { 'DarkGray' }
                    }

                    $typeTag = switch ($a.Type) {
                        'Include'          { '+' }
                        'Exclude'          { '-' }
                        'AllDevices'       { '*' }
                        'AllUsers'         { '*' }
                        'AllLicensedUsers' { '*' }
                        default            { '?' }
                    }

                    $label = if ($a.GroupName) { $a.GroupName } else { $a.Type }
                    $broadLabel = switch ($a.Type) {
                        'AllDevices'       { 'All Devices' }
                        'AllUsers'         { 'All Users' }
                        'AllLicensedUsers' { 'All Licensed Users' }
                        default            { $null }
                    }
                    if ($broadLabel) { $label = $broadLabel }

                    Write-Host "      $typeTag " -ForegroundColor $color -NoNewline
                    Write-Host "$label" -ForegroundColor $color -NoNewline

                    # Append intent label for app assignments
                    if ($a.Intent) {
                        $intentLabel = switch ($a.Intent) {
                            'required'  { 'Required' }
                            'available' { 'Available' }
                            'uninstall' { 'Uninstall' }
                            default     { $a.Intent }
                        }
                        Write-Host " ($intentLabel)" -ForegroundColor DarkGray -NoNewline
                    }

                    # Append filter label
                    if ($a.FilterName) {
                        $filterModeLabel = if ($a.FilterType -eq 'include') { 'Include' } else { 'Exclude' }
                        Write-Host " [Filter: $($a.FilterName) ($filterModeLabel)]" -ForegroundColor DarkCyan -NoNewline
                    }
                    Write-Host ''
                }
            }
            Write-Host ''
        }
    }

    Write-Host $separator -ForegroundColor DarkGray
    Write-Host ''
}
