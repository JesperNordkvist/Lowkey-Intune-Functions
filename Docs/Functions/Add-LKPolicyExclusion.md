# Add-LKPolicyExclusion

## Synopsis
Adds a group as an exclusion to one or more Intune policies.

## Syntax
```powershell
# Pipeline (default)
Add-LKPolicyExclusion
    -GroupName <String>
    [-InputObject <PSCustomObject>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# All policies
Add-LKPolicyExclusion
    -GroupName <String>
    -All
    [-PolicyType <String[]>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description
For each target policy, fetches the current assignments, appends an exclusion entry for the specified group, and writes back the complete assignment set using a replace-all pattern. Policies that already exclude the group are silently skipped. Supports `-WhatIf` and `-Confirm` for safe previewing.

The target policies can come from pipeline input (e.g. from `Get-LKPolicy`) or the `-All` switch can be used to target every policy, optionally filtered by `-PolicyType`.

## Parameters

### -GroupName
The exact display name of the Entra ID group to add as an exclusion.

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

### -All
Targets all Intune policies. Can be narrowed with `-PolicyType`.

| | |
|---|---|
| Type: | SwitchParameter |
| Default: | False |
| Required: | Yes (All set) |
| Pipeline: | No |

### -PolicyType
When used with `-All`, limits the operation to one or more specific policy types.

| | |
|---|---|
| Type: | String[] |
| Default: | -- (all types) |
| Required: | No |
| Pipeline: | No |
| Valid values: | DeviceConfiguration, SettingsCatalog, CompliancePolicy, EndpointSecurity, AppProtectionIOS, AppProtectionAndroid, AppProtectionWindows, AppConfiguration, EnrollmentConfiguration, PolicySet, GroupPolicyConfiguration, PowerShellScript, ProactiveRemediation, DriverUpdate, MobileApp |

## Outputs
`PSCustomObject` per modified policy with properties:
- **PolicyName** -- name of the modified policy
- **PolicyType** -- normalised type key
- **Action** -- `ExclusionAdded`
- **GroupName** -- the excluded group's display name
- **GroupId** -- the excluded group's object ID

## Examples

### Example 1
```powershell
Add-LKPolicyExclusion -GroupName 'SG-Intune-TestDevices' -All
```
Adds the group "SG-Intune-TestDevices" as an exclusion on every Intune policy.

### Example 2
```powershell
Add-LKPolicyExclusion -GroupName 'SG-Intune-TestDevices' -All -PolicyType CompliancePolicy
```
Adds the exclusion only to Compliance policies.

### Example 3
```powershell
Get-LKPolicy -Name "XW365" | Add-LKPolicyExclusion -GroupName 'TestGroup'
```
Adds the exclusion to all policies whose name contains "XW365".

### Example 4
```powershell
Add-LKPolicyExclusion -GroupName 'TestGroup' -All -WhatIf
```
Previews which policies would be modified without making any changes.

## Notes
- Requires an active session (`New-LKSession`).
- Uses the replace-all assignment pattern: the entire assignment array is read, modified, and written back. This is the standard approach for Intune Graph API assignment management.
- Policies that already exclude the group are skipped with a verbose message.
- See also: `Remove-LKPolicyExclusion`, `Add-LKPolicyAssignment`.
