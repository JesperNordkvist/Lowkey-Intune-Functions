---
title: Remove-LKPolicyExclusion
parent: Policy Operations
nav_order: 8
---

# Remove-LKPolicyExclusion

Removes a group exclusion from one or more Intune policies.

## Syntax

```powershell
# By name
Remove-LKPolicyExclusion
    -GroupName <String>
    -PolicyName <String[]>
    [-NameMatch <String>]
    [-SearchPolicyType <String[]>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# All policies
Remove-LKPolicyExclusion
    -GroupName <String>
    -All
    [-PolicyType <String[]>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# Pipeline
Remove-LKPolicyExclusion
    -GroupName <String>
    [-InputObject <PSCustomObject>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description

Fetches current assignments, removes the matching exclusion, and writes back the updated set.

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

### -All

Remove the exclusion from all policies.

| | |
|---|---|
| Type | SwitchParameter |

### -PolicyType

Restrict to specific types when using `-All`.

| | |
|---|---|
| Type | String[] |

### -InputObject

| | |
|---|---|
| Type | PSCustomObject |
| Pipeline | ByValue |

## Outputs

| Property | Type | Description |
|---|---|---|
| PolicyName | String | Modified policy name |
| PolicyType | String | Normalised type key |
| Action | String | `ExclusionRemoved` |
| GroupName | String | Group name |
| GroupId | String | Group GUID |

## Examples

### Example 1 --- Remove from all policies

```powershell
Remove-LKPolicyExclusion -GroupName 'SG-Intune-TestDevices' -All
```

### Example 2 --- Pipeline

```powershell
Get-LKPolicy -Name "XW365" | Remove-LKPolicyExclusion -GroupName 'TestGroup'
```

## Related

- [Add-LKPolicyExclusion](Add-LKPolicyExclusion.md)
