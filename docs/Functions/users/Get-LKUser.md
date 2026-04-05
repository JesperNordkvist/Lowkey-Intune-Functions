---
title: Get-LKUser
parent: User Operations
nav_order: 1
---

# Get-LKUser
Queries Entra ID users with flexible name and department filtering.

## Syntax
```powershell
Get-LKUser
    [-Name <String[]>]
    [-NameMatch <String>]
    [-Department <String>]
    [-FilterScript <ScriptBlock>]
    [<CommonParameters>]
```

## Parameters

### -Name
Search by display name or UPN.
| | |
|---|---|
| Type | String[] |
| Required | No |

### -NameMatch
| | |
|---|---|
| Type | String |
| Default | Contains |
| Valid values | Contains, Exact, Wildcard, Regex |

### -Department
Filter by department name.
| | |
|---|---|
| Type | String |
| Required | No |

### -FilterScript
| | |
|---|---|
| Type | ScriptBlock |

## Outputs
| Property | Type | Description |
|---|---|---|
| Id | String | User object ID |
| DisplayName | String | Full name |
| UserPrincipalName | String | UPN |
| Mail | String | Email address |
| JobTitle | String | Job title |
| Department | String | Department |
| AccountEnabled | Boolean | Account status |

## Examples

### Example 1 --- Search by name
```powershell
Get-LKUser -Name "Jesper" -NameMatch Contains
```

### Example 2 --- Search by UPN
```powershell
Get-LKUser -Name "jesper@contoso.com" -NameMatch Exact
```

### Example 3 --- Filter by department
```powershell
Get-LKUser -Department "IT"
```

## Related
- [Get-LKDevice](../devices/Get-LKDevice.md)
- [Add-LKGroupMember](../groups/Add-LKGroupMember.md)
