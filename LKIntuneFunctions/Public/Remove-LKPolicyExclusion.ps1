function Remove-LKPolicyExclusion {
    <#
    .SYNOPSIS
        Removes a group exclusion from one or more Intune policies.
    .EXAMPLE
        Remove-LKPolicyExclusion -GroupName 'SG-Intune-TestDevices' -All
    .EXAMPLE
        Get-LKPolicy -Name "XW365" | Remove-LKPolicyExclusion -GroupName 'TestGroup'
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'ByPipeline')]
    param(
        [Parameter(Mandatory)]
        [string]$GroupName,

        [Parameter(ValueFromPipeline, ParameterSetName = 'ByPipeline')]
        [PSCustomObject]$InputObject,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'All')]
        [ValidateSet(
            'DeviceConfiguration', 'SettingsCatalog', 'CompliancePolicy', 'EndpointSecurity',
            'AppProtectionIOS', 'AppProtectionAndroid', 'AppProtectionWindows',
            'AppConfiguration', 'EnrollmentConfiguration', 'PolicySet',
            'GroupPolicyConfiguration', 'PowerShellScript', 'ProactiveRemediation',
            'DriverUpdate', 'MobileApp'
        )]
        [string[]]$PolicyType
    )

    begin {
        Assert-LKSession
        $groupId = Resolve-LKGroupId -GroupName $GroupName
        $bulkConfirmed = $false
    }

    process {
        if ($All) {
            $policies = @(Get-LKPolicy -PolicyType:$PolicyType)

            $typeList = ($policies | Select-Object -ExpandProperty DisplayType -Unique) -join ', '
            Write-LKActionSummary -Action 'REMOVE EXCLUSION FROM ALL POLICIES' -Details ([ordered]@{
                Group    = "$GroupName (Exclude)"
                Policies = "$($policies.Count) policies found"
                Types    = $typeList
            })

            if (-not $PSCmdlet.ShouldProcess("$($policies.Count) policies", "Remove exclusion for '$GroupName' from ALL")) {
                return
            }
            $bulkConfirmed = $true
        } elseif ($InputObject) {
            $policies = @($InputObject)
        } else {
            return
        }

        foreach ($policy in $policies) {
            $typeEntry = $script:LKPolicyTypes | Where-Object { $_.TypeName -eq $policy.PolicyType }
            if (-not $typeEntry) { continue }

            if ($typeEntry.AssignmentMethod -eq 'GroupAssignments') {
                Write-Verbose "Skipping '$($policy.Name)' - policy type does not support exclusions."
                continue
            }

            $assignments = Get-LKRawAssignment -PolicyId $policy.Id -PolicyType $typeEntry

            $hasExclusion = $assignments | Where-Object {
                $_.target.'@odata.type' -like '*exclusionGroupAssignmentTarget' -and
                $_.target.groupId -eq $groupId
            }
            if (-not $hasExclusion) {
                Write-Verbose "Skipping '$($policy.Name)' - group is not excluded."
                continue
            }

            $shouldProceed = $bulkConfirmed
            if (-not $shouldProceed) {
                Write-LKActionSummary -Action 'REMOVE EXCLUSION' -Details ([ordered]@{
                    Policy = "$($policy.Name) ($($typeEntry.DisplayName))"
                    Group  = "$GroupName (Exclude)"
                })
                $shouldProceed = $PSCmdlet.ShouldProcess("$($policy.Name) ($($typeEntry.DisplayName))", "Remove exclusion for '$GroupName'")
            }

            if ($shouldProceed) {
                $updatedAssignments = @($assignments | Where-Object {
                    -not ($_.target.'@odata.type' -like '*exclusionGroupAssignmentTarget' -and $_.target.groupId -eq $groupId)
                })

                try {
                    Set-LKRawAssignment -PolicyId $policy.Id -PolicyType $typeEntry -Assignments $updatedAssignments
                    [PSCustomObject]@{
                        PolicyName = $policy.Name
                        PolicyType = $typeEntry.TypeName
                        Action     = 'ExclusionRemoved'
                        GroupName  = $GroupName
                        GroupId    = $groupId
                    }
                } catch {
                    $err = $_.Exception.Message
                    Write-Warning "Failed to remove exclusion from '$($policy.Name)': $err"
                }
            }
        }
    }
}
