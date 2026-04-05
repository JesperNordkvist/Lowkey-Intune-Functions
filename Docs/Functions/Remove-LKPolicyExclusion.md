# Remove-LKPolicyExclusion

## Synopsis
Removes a group exclusion from one or more Intune policies.

## Syntax
```powershell
# Pipeline (default)
Remove-LKPolicyExclusion
    -GroupName <String>
    [-InputObject <PSCustomObject>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# All policies
Remove-LKPolicyExclusion
    -GroupName <String>
    -All
    [-PolicyType <String[]>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description
For each target policy, fetches the current assignments, removes the exclusion entry for the specified group, and writes back the updated assignment set. Policies where the group is not currently excluded are silently skipped. Supports `-WhatIf` and `-Confirm` for safe previewing.

The target policies can come from pipeline input or the `-All` switch, optionally filtered by `-PolicyType`.

## Parameters

### -GroupName
The exact display name of the Entra ID group whose exclusion should be removed.

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
- **Action** -- `ExclusionRemoved`
- **GroupName** -- the group's display name
- **GroupId** -- the group's object ID

## Examples

### Example 1
```powershell
Remove-LKPolicyExclusion -GroupName 'SG-Intune-TestDevices' -All
```
Removes the exclusion for "SG-Intune-TestDevices" from every policy that currently excludes it.

### Example 2
```powershell
Get-LKPolicy -Name "XW365" | Remove-LKPolicyExclusion -GroupName 'TestGroup'
```
Removes the exclusion from policies whose name contains "XW365".

## Notes
- Requires an active session (`New-LKSession`).
- Policies where the group is not excluded are skipped with a verbose message.
- See also: `Add-LKPolicyExclusion`, `Remove-LKPolicyAssignment`.
