BeforeAll {
    $ModulePath = "$PSScriptRoot\..\IntuneLogicKit\IntuneLogicKit.psd1"
    Import-Module $ModulePath -Force
}

Describe 'Module: IntuneLogicKit' {
    It 'Should import without errors' {
        Get-Module -Name IntuneLogicKit | Should -Not -BeNullOrEmpty
    }

    It 'Should export all expected public functions' {
        $expectedFunctions = @(
            'New-LKSession'
            'Get-LKSession'
            'Close-LKSession'
            'Get-LKPolicy'
            'Get-LKPolicyAssignment'
            'Add-LKPolicyAssignment'
            'Remove-LKPolicyAssignment'
            'Add-LKPolicyExclusion'
            'Remove-LKPolicyExclusion'
            'Copy-LKPolicyAssignment'
            'Rename-LKPolicy'
            'Get-LKGroup'
            'New-LKGroup'
            'Remove-LKGroup'
            'Rename-LKGroup'
            'Get-LKGroupAssignment'
            'Get-LKGroupMember'
            'Add-LKGroupMember'
            'Remove-LKGroupMember'
            'Get-LKUser'
            'Get-LKDevice'
            'Get-LKDeviceDetail'
            'Invoke-LKDeviceAction'
            'Show-LKPolicyDetail'
        )

        $exportedFunctions = (Get-Module -Name IntuneLogicKit).ExportedFunctions.Keys
        foreach ($fn in $expectedFunctions) {
            $exportedFunctions | Should -Contain $fn
        }
    }

    It 'Should not export private functions' {
        $exportedFunctions = (Get-Module -Name IntuneLogicKit).ExportedFunctions.Keys
        $exportedFunctions | Should -Not -Contain 'Assert-LKSession'
        $exportedFunctions | Should -Not -Contain 'Invoke-LKGraphRequest'
        $exportedFunctions | Should -Not -Contain 'Resolve-LKGroupId'
        $exportedFunctions | Should -Not -Contain 'Resolve-LKMemberId'
        $exportedFunctions | Should -Not -Contain 'Get-LKPolicySettings'
        $exportedFunctions | Should -Not -Contain 'Invoke-LKGraphWithRetry'
    }
}

Describe 'Session state' {
    It 'Should initialize with Connected = false' {
        Get-LKSession 3>&1 | Should -BeLike '*No active session*'
    }
}

Describe 'Test-LKNameMatch (via module internals)' {
    BeforeAll {
        # Access the private function via the module scope
        $module = Get-Module IntuneLogicKit
        $testMatch = & $module { Get-Command Test-LKNameMatch }
    }

    It 'Contains match should find substring' {
        $result = & $module { Test-LKNameMatch -Value 'XW365 - Baseline Policy' -Name 'Baseline' -NameMatch Contains }
        $result | Should -BeTrue
    }

    It 'Contains match should be case-insensitive' {
        $result = & $module { Test-LKNameMatch -Value 'XW365 - Baseline Policy' -Name 'baseline' -NameMatch Contains }
        $result | Should -BeTrue
    }

    It 'Exact match should require full string' {
        $result = & $module { Test-LKNameMatch -Value 'Baseline Policy' -Name 'Baseline' -NameMatch Exact }
        $result | Should -BeFalse
    }

    It 'Exact match should succeed on full match' {
        $result = & $module { Test-LKNameMatch -Value 'Baseline Policy' -Name 'Baseline Policy' -NameMatch Exact }
        $result | Should -BeTrue
    }

    It 'Wildcard match should work with asterisks' {
        $result = & $module { Test-LKNameMatch -Value 'XW365 - Firewall' -Name 'XW365*' -NameMatch Wildcard }
        $result | Should -BeTrue
    }

    It 'Regex match should work with patterns' {
        $result = & $module { Test-LKNameMatch -Value 'Policy-V2-Final' -Name 'V\d+' -NameMatch Regex }
        $result | Should -BeTrue
    }

    It 'Should return false when no match found' {
        $result = & $module { Test-LKNameMatch -Value 'Production Policy' -Name 'Staging' -NameMatch Contains }
        $result | Should -BeFalse
    }

    It 'Should match any of multiple name patterns' {
        $result = & $module { Test-LKNameMatch -Value 'Firewall Policy' -Name @('Baseline', 'Firewall') -NameMatch Contains }
        $result | Should -BeTrue
    }
}

Describe 'Policy type registry' {
    BeforeAll {
        $module = Get-Module IntuneLogicKit
        $types = & $module { $script:LKPolicyTypes }
    }

    It 'Should have 16 policy types registered' {
        $types.Count | Should -Be 16
    }

    It 'Each type should have required keys' {
        foreach ($type in $types) {
            $type.TypeName       | Should -Not -BeNullOrEmpty
            $type.DisplayName    | Should -Not -BeNullOrEmpty
            $type.Endpoint       | Should -Not -BeNullOrEmpty
            $type.ApiVersion     | Should -BeIn @('v1.0', 'beta')
            $type.NameProperty   | Should -Not -BeNullOrEmpty
            $type.TargetScope    | Should -BeIn @('User', 'Device', 'Both')
            $type.AssignmentMethod | Should -BeIn @('Standard', 'GroupAssignments')
        }
    }

    It 'Should have unique TypeName values' {
        $typeNames = $types | ForEach-Object { $_.TypeName }
        ($typeNames | Select-Object -Unique).Count | Should -Be $typeNames.Count
    }
}

Describe 'Required scopes' {
    BeforeAll {
        $module = Get-Module IntuneLogicKit
        $scopes = & $module { $script:LKRequiredScopes }
    }

    It 'Should define required scopes' {
        $scopes | Should -Not -BeNullOrEmpty
        $scopes.Count | Should -BeGreaterThan 0
    }

    It 'Should include core Intune scopes' {
        $scopes | Should -Contain 'DeviceManagementConfiguration.ReadWrite.All'
        $scopes | Should -Contain 'DeviceManagementManagedDevices.ReadWrite.All'
    }
}

Describe 'Functions requiring session should throw without one' {
    It 'Get-LKPolicy should throw without session' {
        { Get-LKPolicy } | Should -Throw '*No active session*'
    }

    It 'Get-LKDevice should throw without session' {
        { Get-LKDevice } | Should -Throw '*No active session*'
    }

    It 'Get-LKGroup should throw without session' {
        { Get-LKGroup } | Should -Throw '*No active session*'
    }

    It 'Get-LKUser should throw without session' {
        { Get-LKUser } | Should -Throw '*No active session*'
    }
}

Describe 'Resolve-LKGroupScope: empty assigned group fallback (issue #5)' {
    # Regression coverage for issue #5. An assigned (non-dynamic) group with no
    # members must still resolve its scope from the U/D/C tokens in its display
    # name instead of returning 'Unknown'. The name heuristic must stay reachable
    # for empty groups - it must not be gated behind an early 'Unknown' return.

    It 'Empty group with a -U- name token resolves to User' {
        InModuleScope IntuneLogicKit {
            Mock Invoke-LKGraphRequest {
                if ($Uri -like '*/members/*') { return [pscustomobject]@{ value = @() } }
                return [pscustomobject]@{
                    displayName                   = 'SG-Intune-U-Empty Test'
                    membershipRule                = $null
                    membershipRuleProcessingState = 'Off'
                    groupTypes                    = @()
                }
            }
            Resolve-LKGroupScope -GroupId '00000000-0000-0000-0000-0000000000a1' |
                Should -Be 'User'
        }
    }

    It 'Empty group with a -D- name token resolves to Device' {
        InModuleScope IntuneLogicKit {
            Mock Invoke-LKGraphRequest {
                if ($Uri -like '*/members/*') { return [pscustomobject]@{ value = @() } }
                return [pscustomobject]@{
                    displayName                   = 'SG-Intune-D-Empty Test'
                    membershipRule                = $null
                    membershipRuleProcessingState = 'Off'
                    groupTypes                    = @()
                }
            }
            Resolve-LKGroupScope -GroupId '00000000-0000-0000-0000-0000000000a2' |
                Should -Be 'Device'
        }
    }

    It 'Empty group with a -C- name token resolves to Device' {
        InModuleScope IntuneLogicKit {
            Mock Invoke-LKGraphRequest {
                if ($Uri -like '*/members/*') { return [pscustomobject]@{ value = @() } }
                return [pscustomobject]@{
                    displayName                   = 'SG-Intune-C-Empty Test'
                    membershipRule                = $null
                    membershipRuleProcessingState = 'Off'
                    groupTypes                    = @()
                }
            }
            Resolve-LKGroupScope -GroupId '00000000-0000-0000-0000-0000000000a3' |
                Should -Be 'Device'
        }
    }

    It 'Empty group whose name carries no scope token resolves to Unknown' {
        InModuleScope IntuneLogicKit {
            Mock Invoke-LKGraphRequest {
                if ($Uri -like '*/members/*') { return [pscustomobject]@{ value = @() } }
                return [pscustomobject]@{
                    displayName                   = 'Marketing Team'
                    membershipRule                = $null
                    membershipRuleProcessingState = 'Off'
                    groupTypes                    = @()
                }
            }
            Resolve-LKGroupScope -GroupId '00000000-0000-0000-0000-0000000000a4' |
                Should -Be 'Unknown'
        }
    }

    It 'Actual members take precedence over a misleading name token' {
        InModuleScope IntuneLogicKit {
            Mock Invoke-LKGraphRequest {
                if ($Uri -like '*/members/microsoft.graph.user*') {
                    return [pscustomobject]@{ value = @([pscustomobject]@{ id = 'u1' }) }
                }
                if ($Uri -like '*/members/*') { return [pscustomobject]@{ value = @() } }
                return [pscustomobject]@{
                    displayName                   = 'SG-Intune-D-Mislabeled'
                    membershipRule                = $null
                    membershipRuleProcessingState = 'Off'
                    groupTypes                    = @()
                }
            }
            Resolve-LKGroupScope -GroupId '00000000-0000-0000-0000-0000000000a5' |
                Should -Be 'User'
        }
    }
}

AfterAll {
    Remove-Module -Name IntuneLogicKit -ErrorAction SilentlyContinue
}
