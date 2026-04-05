---
title: Invoke-LKDeviceAction
parent: Device Operations
nav_order: 3
---

# Invoke-LKDeviceAction
Triggers a remote action on an Intune managed device.

## Syntax
```powershell
# By device name
Invoke-LKDeviceAction
    -Action <String>
    -DeviceName <String>
    [-KeepUserData] [-KeepEnrollmentData]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By device ID
Invoke-LKDeviceAction
    -Action <String>
    -DeviceId <String>
    [-KeepUserData] [-KeepEnrollmentData]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# Pipeline
Invoke-LKDeviceAction
    -Action <String>
    [-InputObject <PSCustomObject>]
    [-KeepUserData] [-KeepEnrollmentData]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Parameters

### -Action
| | |
|---|---|
| Type | String |
| Required | Yes |
| Valid values | Sync, Restart, RemoteLock, Retire, Wipe |

### -DeviceName
| | |
|---|---|
| Type | String |
| Required | Yes (ByDeviceName) |

### -DeviceId
| | |
|---|---|
| Type | String |
| Required | Yes (ByDeviceId) |

### -InputObject
| | |
|---|---|
| Type | PSCustomObject |
| Pipeline | ByValue |

### -KeepUserData
For Wipe action: preserve user data on the device.
| | |
|---|---|
| Type | SwitchParameter |

### -KeepEnrollmentData
For Wipe action: preserve enrollment data on the device.
| | |
|---|---|
| Type | SwitchParameter |

## Outputs
| Property | Type | Description |
|---|---|---|
| DeviceName | String | Target device |
| DeviceId | String | Device GUID |
| Action | String | Action performed |
| Status | String | `Initiated` |

## Examples

### Example 1 --- Sync a device
```powershell
Invoke-LKDeviceAction -DeviceName 'YOURPC-001' -Action Sync
```

### Example 2 --- Restart via pipeline
```powershell
Get-LKDevice -User "Jesper" | Invoke-LKDeviceAction -Action Restart
```

### Example 3 --- Wipe with data preservation
```powershell
Invoke-LKDeviceAction -DeviceName 'YOURPC-001' -Action Wipe -KeepUserData
```

## Related
- [Get-LKDevice](Get-LKDevice.md)
- [Get-LKDeviceDetail](Get-LKDeviceDetail.md)
