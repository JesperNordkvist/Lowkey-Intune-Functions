# Add-LKPolicyAssignment

## Synopsis
Adds a group as an include assignment to one or more Intune policies.

## Syntax
```powershell
# Pipeline (default)
Add-LKPolicyAssignment
    -GroupName <String>
    [-InputObject <PSCustomObject>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By ID
Add-LKPolicyAssignment
    -GroupName <String>
    -PolicyId <String>
    -PolicyType <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description
For each target policy, fetches the current assignments, appends a group include entry, and writes back the complete assignment set using a replace-all pattern. Policies that already include the group are silently skipped. Supports `-WhatIf` and `-Confirm` for safe previewing.

The target policy can come from pipeline input (e.g. from `Get-LKPolicy`) or be specified directly by ID and type.

## Parameters

### -GroupName
The exact display name of the Entra ID group to assign to the policy.

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
- **Action** -- `AssignmentAdded`
- **GroupName** -- the assigned group's display name
- **GroupId** -- the assigned group's object ID

## Examples

### Example 1
```powershell
Get-LKPolicy -Name "XW365 - TestConfig" | Add-LKPolicyAssignment -GroupName 'SG-Intune-TestDevices'
```
Assigns the group "SG-Intune-TestDevices" to all policies whose name contains "XW365 - TestConfig".

### Example 2
```powershell
Add-LKPolicyAssignment -GroupName 'TestDevices' -PolicyId 'abc-123' -PolicyType SettingsCatalog
```
Assigns the group to a specific Settings Catalog policy by its ID.

## Notes
- Requires an active session (`New-LKSession`).
- Policies where the group is already included are skipped with a verbose message.
- This adds a group include (not an exclusion). To add an exclusion, use `Add-LKPolicyExclusion`.
- See also: `Remove-LKPolicyAssignment`, `Add-LKPolicyExclusion`.
