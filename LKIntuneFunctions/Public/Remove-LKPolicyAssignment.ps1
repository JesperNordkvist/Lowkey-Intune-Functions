function Remove-LKPolicyAssignment {
    <#
    .SYNOPSIS
        Removes a group include assignment from one or more Intune policies.
    .EXAMPLE
        Get-LKPolicy -Name "XW365 - TestConfig" | Remove-LKPolicyAssignment -GroupName 'SG-Intune-TestDevices'
    .EXAMPLE
        Remove-LKPolicyAssignment -GroupName 'TestDevices' -PolicyId 'abc-123' -PolicyType SettingsCatalog
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

        $hasInclusion = $assignments | Where-Object {
            $_.target.'@odata.type' -like '*groupAssignmentTarget' -and
            $_.target.'@odata.type' -notlike '*exclusion*' -and
            $_.target.groupId -eq $groupId
        }
        if (-not $hasInclusion) {
            Write-Verbose "Skipping '$name' - group is not assigned."
            return
        }

        Write-LKActionSummary -Action 'REMOVE ASSIGNMENT' -Details ([ordered]@{
            Policy = "$name ($($typeEntry.DisplayName))"
            Group  = "$GroupName (Include)"
        })

        if ($PSCmdlet.ShouldProcess("$name ($($typeEntry.DisplayName))", "Remove include assignment for '$GroupName'")) {
            $updatedAssignments = @($assignments | Where-Object {
                -not (
                    $_.target.'@odata.type' -like '*groupAssignmentTarget' -and
                    $_.target.'@odata.type' -notlike '*exclusion*' -and
                    $_.target.groupId -eq $groupId
                )
            })

            try {
                Set-LKRawAssignment -PolicyId $id -PolicyType $typeEntry -Assignments $updatedAssignments
                [PSCustomObject]@{
                    PolicyName = $name
                    PolicyType = $typeEntry.TypeName
                    Action     = 'AssignmentRemoved'
                    GroupName  = $GroupName
                    GroupId    = $groupId
                }
            } catch {
                $err = $_.Exception.Message
                Write-Warning "Failed to remove assignment from '$name': $err"
            }
        }
    }
}
