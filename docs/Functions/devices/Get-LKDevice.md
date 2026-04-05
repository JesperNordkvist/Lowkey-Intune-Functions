---
title: Get-LKDevice
parent: Device Operations
nav_order: 1
---

# Get-LKDevice
Queries Intune managed devices with flexible filtering.

## Syntax
```powershell
Get-LKDevice
    [-Name <String[]>]
    [-NameMatch <String>]
    [-User <String[]>]
    [-UserMatch <String>]
    [-OS <String>]
    [-FilterScript <ScriptBlock>]
    [<CommonParameters>]
```

## Parameters

### -Name
Search by device name.
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

### -User
Search by primary user display name.
| | |
|---|---|
| Type | String[] |
| Required | No |

### -UserMatch
How `-User` is matched.
| | |
|---|---|
| Type | String |
| Default | Contains |
| Valid values | Contains, Exact, Wildcard, Regex |

### -OS
Filter by operating system.
| | |
|---|---|
| Type | String |
| Valid values | Windows, iOS, Android, macOS |

### -FilterScript
| | |
|---|---|
| Type | ScriptBlock |

## Outputs
| Property | Type | Description |
|---|---|---|
| Id | String | Intune device ID |
| DeviceName | String | Device name |
| UserDisplayName | String | Primary user |
| UserPrincipalName | String | Primary user UPN |
| OS | String | Operating system |
| OSVersion | String | OS version |
| ComplianceState | String | Compliance status |
| ManagementState | String | Management status |
| EnrolledDateTime | DateTime | Enrollment date |
| LastSyncDateTime | DateTime | Last sync |
| Model | String | Hardware model |
| Manufacturer | String | Hardware manufacturer |
| SerialNumber | String | Serial number |
| AzureADDeviceId | String | Entra device ID |

## Examples

### Example 1 --- Search by name
```powershell
Get-LKDevice -Name "YOURPC" -NameMatch Contains
```

### Example 2 --- By user
```powershell
Get-LKDevice -User "Jesper" -OS Windows
```

### Example 3 --- Pipeline to group membership
```powershell
Get-LKDevice -User "Jesper" | Add-LKGroupMember -GroupName 'SG-Intune-TestDevices'
```

## Related
- [Get-LKDeviceDetail](Get-LKDeviceDetail.md)
- [Invoke-LKDeviceAction](Invoke-LKDeviceAction.md)
