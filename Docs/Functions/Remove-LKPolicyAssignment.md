# Remove-LKPolicyAssignment

## Synopsis
Removes a group include assignment from one or more Intune policies.

## Syntax
```powershell
# Pipeline (default)
Remove-LKPolicyAssignment
    -GroupName <String>
    [-InputObject <PSCustomObject>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By ID
Remove-LKPolicyAssignment
    -GroupName <String>
    -PolicyId <String>
    -PolicyType <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description
For each target policy, fetches the current assignments, removes the group include entry for the specified group, and writes back the updated assignment set. Policies where the group is not currently assigned are silently skipped. Supports `-WhatIf` and `-Confirm` for safe previewing.

The target policy can come from pipeline input or be specified directly by ID and type.

## Parameters

### -GroupName
The exact display name of the Entra ID group whose include assignment should be removed.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes |
| Pipeline: | No |

### -InputObject
A policy object from `Get-LKPolicy`. Accepted from the pipeline.

| | |
|---|---|
| Type: | PSCustomObject |
| Default: | -- |
| Required: | No |
| Pipeline: | ByValue |

### -PolicyId
The Graph object ID of the policy. Required when using the `ById` parameter set.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ById set) |
| Pipeline: | No |

### -PolicyType
The normalised policy type key. Required when using the `ById` parameter set.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ById set) |
| Pipeline: | No |
| Valid values: | DeviceConfiguration, SettingsCatalog, CompliancePolicy, EndpointSecurity, AppProtectionIOS, AppProtectionAndroid, AppProtectionWindows, AppConfiguration, EnrollmentConfiguration, PolicySet, GroupPolicyConfiguration, PowerShellScript, ProactiveRemediation, DriverUpdate, MobileApp |

## Outputs
`PSCustomObject` per modified policy with properties:
- **PolicyName** -- name of the modified policy
- **PolicyType** -- normalised type key
- **Action** -- `AssignmentRemoved`
- **GroupName** -- the group's display name
- **GroupId** -- the group's object ID

## Examples

### Example 1
```powershell
Get-LKPolicy -Name "XW365 - TestConfig" | Remove-LKPolicyAssignment -GroupName 'SG-Intune-TestDevices'
```
Removes the group "SG-Intune-TestDevices" from all policies whose name contains "XW365 - TestConfig".

### Example 2
```powershell
Remove-LKPolicyAssignment -GroupName 'TestDevices' -PolicyId 'abc-123' -PolicyType SettingsCatalog
```
Removes the group assignment from a specific Settings Catalog policy by its ID.

## Notes
- Requires an active session (`New-LKSession`).
- Only removes include assignments, not exclusions. To remove an exclusion, use `Remove-LKPolicyExclusion`.
- Policies where the group is not assigned are skipped with a verbose message.
- See also: `Add-LKPolicyAssignment`, `Remove-LKPolicyExclusion`.
