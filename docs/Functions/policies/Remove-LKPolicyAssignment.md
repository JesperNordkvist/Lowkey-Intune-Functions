---
title: Remove-LKPolicyAssignment
parent: Policy Operations
nav_order: 6
---

# Remove-LKPolicyAssignment

Removes a group include assignment from one or more Intune policies.

## Syntax

```powershell
# By name (default)
Remove-LKPolicyAssignment
    -GroupName <String>
    -PolicyName <String[]>
    [-NameMatch <String>]
    [-SearchPolicyType <String[]>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# Pipeline
Remove-LKPolicyAssignment
    -GroupName <String>
    [-InputObject <PSCustomObject>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By ID
Remove-LKPolicyAssignment
    -GroupName <String>
    -PolicyId <String>
    [-PolicyType <String>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description

Fetches the current assignments, removes the matching group include, and writes back the updated set. Policies that don't include the group are silently skipped.

## Parameters

### -GroupName

| | |
|---|---|
| Type | String |
| Required | Yes |

### -PolicyName

| | |
|---|---|
| Type | String[] |
| Required | Yes (ByName) |

### -NameMatch

| | |
|---|---|
| Type | String |
| Default | Contains |
| Valid values | Contains, Exact, Wildcard, Regex |

### -SearchPolicyType

| | |
|---|---|
| Type | String[] |
| Required | No |

### -InputObject

| | |
|---|---|
| Type | PSCustomObject |
| Pipeline | ByValue |

### -PolicyId

| | |
|---|---|
| Type | String |
| Required | Yes (ById) |

### -PolicyType

Optional --- auto-resolved if omitted.

| | |
|---|---|
| Type | String |

## Outputs

| Property | Type | Description |
|---|---|---|
| PolicyName | String | Modified policy name |
| PolicyType | String | Normalised type key |
| Action | String | `AssignmentRemoved` |
| GroupName | String | Removed group name |
| GroupId | String | Removed group GUID |

## Examples

### Example 1 --- Pipeline

```powershell
Get-LKPolicy -Name "XW365 - TestConfig" | Remove-LKPolicyAssignment -GroupName 'SG-Intune-TestDevices'
```

### Example 2 --- By ID

```powershell
Remove-LKPolicyAssignment -GroupName 'TestDevices' -PolicyId 'abc-123' -PolicyType SettingsCatalog
```

## Related

- [Add-LKPolicyAssignment](Add-LKPolicyAssignment.md)
- [Remove-LKPolicyExclusion](Remove-LKPolicyExclusion.md)
