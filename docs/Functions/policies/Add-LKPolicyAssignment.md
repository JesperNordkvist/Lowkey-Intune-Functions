---
title: Add-LKPolicyAssignment
nav_order: 3
---

# Add-LKPolicyAssignment

Adds an include assignment to one or more Intune policies. The assignment target can be an Entra ID group, **all devices**, or **all licensed users**.

## Syntax

```text
# By name (default)
Add-LKPolicyAssignment
    (-GroupName <String> | -AllDevices | -AllLicensedUsers)
    -PolicyName <String[]>
    [-NameMatch <String>]
    [-SearchPolicyType <String[]>]
    [-Intent <String>]
    [-FilterName <String>]
    [-FilterMode <String>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# Pipeline
Add-LKPolicyAssignment
    (-GroupName <String> | -AllDevices | -AllLicensedUsers)
    [-InputObject <PSCustomObject>]
    [-Intent <String>]
    [-FilterName <String>]
    [-FilterMode <String>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By ID
Add-LKPolicyAssignment
    (-GroupName <String> | -AllDevices | -AllLicensedUsers)
    -PolicyId <String>
    [-PolicyType <String>]
    [-Intent <String>]
    [-FilterName <String>]
    [-FilterMode <String>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description

For each target policy, fetches the current assignments, appends an include entry, and writes back the complete assignment set. Policies that already include the target are silently skipped. Performs a scope mismatch check - if the target scope is incompatible with the policy scope, the assignment is skipped with a warning.

Exactly one assignment target must be specified - `-GroupName`, `-AllDevices`, or `-AllLicensedUsers`. The three are mutually exclusive; specifying none, or more than one, throws.

## Parameters

### -GroupName

The exact display name of the Entra ID group to assign. One of `-GroupName`, `-AllDevices`, or `-AllLicensedUsers` is required.

| Attribute | Value |
|---|---|
| Type | `String` |
| Required | One of three assignment targets |

### -AllDevices

Assigns to the built-in **All Devices** target (`#microsoft.graph.allDevicesAssignmentTarget`). Treated as Device-scoped for the mismatch check. Mutually exclusive with `-GroupName` and `-AllLicensedUsers`.

| Attribute | Value |
|---|---|
| Type | `SwitchParameter` |
| Required | One of three assignment targets |

### -AllLicensedUsers

Assigns to the built-in **All Licensed Users** target (`#microsoft.graph.allLicensedUsersAssignmentTarget`). Treated as User-scoped for the mismatch check. Mutually exclusive with `-GroupName` and `-AllDevices`.

| Attribute | Value |
|---|---|
| Type | `SwitchParameter` |
| Required | One of three assignment targets |

### -PolicyName

One or more policy name patterns.

| Attribute | Value |
|---|---|
| Type | `String[]` |
| Required | Yes (ByName) |

### -NameMatch

| Attribute | Value |
|---|---|
| Type | `String` |
| Default | Contains |
| Valid values | Contains, Exact, Wildcard, Regex |

### -SearchPolicyType

Restrict the policy name search to specific types.

| Attribute | Value |
|---|---|
| Type | `String[]` |
| Required | No |
| Valid values | DeviceConfiguration, SettingsCatalog, CompliancePolicy, EndpointSecurity, AppProtectionIOS, AppProtectionAndroid, AppProtectionWindows, AppConfiguration, EnrollmentConfiguration, PolicySet, GroupPolicyConfiguration, PlatformScript, Remediation, DriverUpdate, App, AutopilotDeploymentProfile |

### -InputObject

| Attribute | Value |
|---|---|
| Type | `PSCustomObject` |
| Pipeline | ByValue |

### -PolicyId

| Attribute | Value |
|---|---|
| Type | `String` |
| Required | Yes (ById) |

### -PolicyType

Optional - auto-resolved if omitted.

| Attribute | Value |
|---|---|
| Type | `String` |
| Required | No |

### -Intent

The deployment intent for app assignments. Only applies to the App policy type. Also applies to broad targets.

| Attribute | Value |
|---|---|
| Type | `String` |
| Required | No |
| Valid values | Required, Available, Uninstall |

### -FilterName

Name of an Intune assignment filter to apply to the assignment. Must be used together with `-FilterMode`. Applies to group and broad targets alike.

| Attribute | Value |
|---|---|
| Type | `String` |
| Required | No |

### -FilterMode

Whether to include or exclude devices matching the filter. Must be used together with `-FilterName`.

| Attribute | Value |
|---|---|
| Type | `String` |
| Required | No |
| Valid values | Include, Exclude |

### -WhatIf

Shows what would happen without performing the action.

| Attribute | Value |
|---|---|
| Type | `SwitchParameter` |

### -Confirm

Prompts for confirmation before performing the action.

| Attribute | Value |
|---|---|
| Type | `SwitchParameter` |

## Outputs

| Property | Type | Description |
|---|---|---|
| PolicyName | String | Modified policy name |
| PolicyType | String | Normalised type key |
| Action | String | `AssignmentAdded` |
| GroupName | String | Assigned target name (`All Devices` / `All Licensed Users` for broad targets) |
| GroupId | String | Assigned group GUID (empty for broad targets) |

## Examples

### Example 1 - By policy name

```powershell
Add-LKPolicyAssignment -PolicyName "Contoso - Win - SC - Microsoft Edge" -GroupName 'SG-Intune-U-Pilot Users'
```

### Example 2 - Pipeline from Get-LKPolicy

```powershell
Get-LKPolicy -Name "Contoso - TestConfig" | Add-LKPolicyAssignment -GroupName 'SG-Intune-TestDevices'
```

### Example 3 - App as Required

```powershell
Get-LKPolicy -Name "Google Chrome" -PolicyType App | Add-LKPolicyAssignment -GroupName 'All Users' -Intent Required
```

### Example 4 - Assign with a filter

```powershell
Get-LKPolicy -Name "Windows Update - 24H2" | Add-LKPolicyAssignment -GroupName 'SG-Intune-D-All Devices' -FilterName 'Windows 24H2+ Devices' -FilterMode Include
```

### Example 5 - Assign to the All Devices broad target

```powershell
Add-LKPolicyAssignment -PolicyName "Contoso - Win - Compliance" -NameMatch Exact -AllDevices
```

### Example 6 - Assign to All Licensed Users

```powershell
Get-LKPolicy -Name "Contoso - App Protection" | Add-LKPolicyAssignment -AllLicensedUsers
```

## Notes

- Exactly one of `-GroupName`, `-AllDevices`, `-AllLicensedUsers` is required.
- Performs a scope mismatch check before assigning. `-AllDevices` counts as Device-scoped, `-AllLicensedUsers` as User-scoped.
- Broad targets are **not** supported for Platform Script policies (they use the legacy group-assignment API, which only accepts group IDs); such policies are skipped with a warning.
- To add an exclusion instead, use [Add-LKPolicyExclusion](Add-LKPolicyExclusion.md).
- For an audit-and-remediate workflow, see Example 5 in [Test-LKPolicyAssignment](Test-LKPolicyAssignment.md).

## Related

- [Remove-LKPolicyAssignment](Remove-LKPolicyAssignment.md)
- [Add-LKPolicyExclusion](Add-LKPolicyExclusion.md)
- [Test-LKPolicyAssignment](Test-LKPolicyAssignment.md)
