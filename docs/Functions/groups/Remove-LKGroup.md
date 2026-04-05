---
title: Remove-LKGroup
parent: Group Operations
nav_order: 3
---

# Remove-LKGroup
Deletes an Entra ID group.

## Syntax
```powershell
# By name
Remove-LKGroup -Name <String> [-WhatIf] [-Confirm] [<CommonParameters>]

# By ID
Remove-LKGroup -GroupId <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## Parameters

### -Name
| | |
|---|---|
| Type | String |
| Required | Yes (ByName) |

### -GroupId
| | |
|---|---|
| Type | String |
| Required | Yes (ById) |

## Outputs
| Property | Type | Description |
|---|---|---|
| GroupId | String | Deleted group GUID |
| Name | String | Group name |
| Action | String | `Deleted` |

## Examples
```powershell
Remove-LKGroup -Name 'SG-Intune-TestDevices'
```

## Related
- [New-LKGroup](New-LKGroup.md)
