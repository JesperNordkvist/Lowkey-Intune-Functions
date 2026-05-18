---
title: Remove-LKPolicyAssignment
nav_order: 22
---

# Remove-LKPolicyAssignment

Removes an include assignment from one or more Intune policies. The assignment target can be an Entra ID group, **all devices**, or **all licensed users**.

## Syntax

```text
# By name (default)
Remove-LKPolicyAssignment
    (-GroupName <String> | -AllDevices | -AllLicensedUsers)
    -PolicyName <String[]>
    [-NameMatch <String>]
    [-SearchPolicyType <String[]>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# Pipeline
Remove-LKPolicyAssignment
    (-GroupName <String> | -AllDevices | -AllLicensedUsers)
    [-InputObject <PSCustomObject>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By ID
Remove-LKPolicyAssignment
    (-GroupName <String> | -AllDevices | -AllLicensedUsers)
    -PolicyId <String>
    [-PolicyType <String>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description

Fetches the current assignments, removes the matching include, and writes back the updated set. Policies that don't include the target are silently skipped.

Exactly one assignment target must be specified - `-GroupName`, `-AllDevices`, or `-AllLicensedUsers`. The three are mutually exclusive; specifying none, or more than one, throws.

## Parameters

### -GroupName

The exact display name of the Entra ID group whose assignment is removed. One of `-GroupName`, `-AllDevices`, or `-AllLicensedUsers` is required.

| Attribute | Value |
|---|---|
| Type | `String` |
| Required | One of three assignment targets |

### -AllDevices

Removes the built-in **All Devices** assignment (`#microsoft.graph.allDevicesAssignmentTarget`). Mutually exclusive with `-GroupName` and `-AllLicensedUsers`.

| Attribute | Value |
|---|---|
| Type | `SwitchParameter` |
| Required | One of three assignment targets |

### -AllLicensedUsers

Removes the built-in **All Licensed Users** assignment (`#microsoft.graph.allLicensedUsersAssignmentTarget`). Mutually exclusive with `-GroupName` and `-AllDevices`.

| Attribute | Value |
|---|---|
| Type | `SwitchParameter` |
| Required | One of three assignment targets |

### -PolicyName

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

| Attribute | Value |
|---|---|
| Type | `String[]` |
| Required | No |

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
| Action | String | `AssignmentRemoved` |
| GroupName | String | Removed target name (`All Devices` / `All Licensed Users` for broad targets) |
| GroupId | String | Removed group GUID (empty for broad targets) |

## Examples

### Example 1 - Pipeline

```powershell
Get-LKPolicy -Name "Contoso - TestConfig" | Remove-LKPolicyAssignment -GroupName 'SG-Intune-TestDevices'
```

### Example 2 - By ID

```powershell
Remove-LKPolicyAssignment -GroupName 'TestDevices' -PolicyId 'abc-123' -PolicyType SettingsCatalog
```

### Example 3 - Remove a broad target

```powershell
Remove-LKPolicyAssignment -PolicyName "Contoso - Win - Compliance" -NameMatch Exact -AllLicensedUsers
```

## Notes

- Exactly one of `-GroupName`, `-AllDevices`, `-AllLicensedUsers` is required.
- Broad targets are **not** supported for Platform Script policies (legacy group-assignment API); such policies are skipped with a warning.

## Related

- [Add-LKPolicyAssignment](Add-LKPolicyAssignment.md)
- [Remove-LKPolicyExclusion](Remove-LKPolicyExclusion.md)
