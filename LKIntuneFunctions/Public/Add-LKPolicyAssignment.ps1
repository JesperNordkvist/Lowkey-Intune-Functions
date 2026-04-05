function Add-LKPolicyAssignment {
    <#
    .SYNOPSIS
        Adds a group as an include assignment to one or more Intune policies.
    .EXAMPLE
        Get-LKPolicy -Name "XW365 - TestConfig" | Add-LKPolicyAssignment -GroupName 'SG-Intune-TestDevices'
    .EXAMPLE
        Add-LKPolicyAssignment -GroupName 'TestDevices' -PolicyId 'abc-123' -PolicyType SettingsCatalog
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'ByPipeline')]
    param(
        [Parameter(Mandatory)]
        [string]$GroupName,

        [Parameter(ValueFromPipeline, ParameterSetName = 'ByPipeline')]
        [PSCustomObject]$InputObject,

        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$PolicyId,

        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [ValidateSet(
            'DeviceConfiguration', 'SettingsCatalog', 'CompliancePolicy', 'EndpointSecurity',
            'AppProtectionIOS', 'AppProtectionAndroid', 'AppProtectionWindows',
            'AppConfiguration', 'EnrollmentConfiguration', 'PolicySet',
            'GroupPolicyConfiguration', 'PowerShellScript', 'ProactiveRemediation',
            'DriverUpdate', 'MobileApp'
        )]
        [string]$PolicyType
    )

    begin {
        Assert-LKSession
        $groupId = Resolve-LKGroupId -GroupName $GroupName
        $groupScope = Resolve-LKGroupScope -GroupId $groupId
    }

    process {
        if ($InputObject) {
            $id   = $InputObject.Id
            $type = $InputObject.PolicyType
            $name = $InputObject.Name
        } else {
            $id   = $PolicyId
            $type = $PolicyType
            $name = $PolicyId
        }

        $typeEntry = $script:LKPolicyTypes | Where-Object { $_.TypeName -eq $type }
        if (-not $typeEntry) {
            Write-Warning "Unknown policy type: $type"
            return
        }

        $assignments = Get-LKRawAssignment -PolicyId $id -PolicyType $typeEntry

        $alreadyIncluded = $assignments | Where-Object {
            $_.target.'@odata.type' -like '*groupAssignmentTarget' -and
            $_.target.'@odata.type' -notlike '*exclusion*' -and
            $_.target.groupId -eq $groupId
        }
        if ($alreadyIncluded) {
            Write-Verbose "Skipping '$name' - group already assigned."
            return
        }

        # Scope mismatch check - skip the assignment if scopes are incompatible
        $policyScope = $typeEntry.TargetScope
        if ($InputObject -and $InputObject.TargetScope) { $policyScope = $InputObject.TargetScope }
        if ($groupScope -ne 'Unknown' -and $policyScope -ne 'Both' -and $groupScope -ne $policyScope) {
            Write-Warning "Skipping '$name': group '$GroupName' is a $groupScope group, but policy is $policyScope-scoped."
            return
        }

        Write-LKActionSummary -Action 'ADD ASSIGNMENT' -Details ([ordered]@{
            Policy = "$name ($($typeEntry.DisplayName))"
            Group  = "$GroupName (Include)"
            Scope  = "Policy=$policyScope, Group=$groupScope"
        })

        if ($PSCmdlet.ShouldProcess("$name ($($typeEntry.DisplayName))", "Add include assignment for '$GroupName'")) {
            $newAssignment = @{
                target = @{
                    '@odata.type' = '#microsoft.graph.groupAssignmentTarget'
                    groupId       = $groupId
                }
            }

            $updatedAssignments = @($assignments) + @($newAssignment)

            try {
                Set-LKRawAssignment -PolicyId $id -PolicyType $typeEntry -Assignments $updatedAssignments
                [PSCustomObject]@{
                    PolicyName = $name
                    PolicyType = $typeEntry.TypeName
                    Action     = 'AssignmentAdded'
                    GroupName  = $GroupName
                    GroupId    = $groupId
                }
            } catch {
                $err = $_.Exception.Message
                Write-Warning "Failed to add assignment to '$name': $err"
            }
        }
    }
}
