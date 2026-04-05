# Invoke-LKDeviceAction

## Synopsis
Triggers a remote action on an Intune managed device.

## Syntax
```powershell
# By device name (default)
Invoke-LKDeviceAction
    -Action <String>             # 'Sync' | 'Restart' | 'RemoteLock' | 'Retire' | 'Wipe'
    -DeviceName <String>
    [-KeepUserData]
    [-KeepEnrollmentData]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By device ID
Invoke-LKDeviceAction
    -Action <String>
    -DeviceId <String>
    [-KeepUserData]
    [-KeepEnrollmentData]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# Pipeline
Invoke-LKDeviceAction
    -Action <String>
    [-InputObject <PSCustomObject>]
    [-KeepUserData]
    [-KeepEnrollmentData]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description
Triggers a remote management action on one or more Intune managed devices. Devices can be specified by name, Intune managed device ID, or piped from `Get-LKDevice`. For destructive actions (Wipe, Retire), an extra warning is displayed. The `-KeepUserData` and `-KeepEnrollmentData` switches only apply to the Wipe action.

## Parameters

### -Action
The remote action to trigger.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes |
| Pipeline: | No |
| Valid values: | Sync, Restart, RemoteLock, Retire, Wipe |

| Action | Description | Destructive |
|--------|-------------|:-----------:|
| Sync | Forces a device check-in with Intune | No |
| Restart | Reboots the device | No |
| RemoteLock | Locks the device screen | No |
| Retire | Removes company data, keeps personal data | Yes |
| Wipe | Factory resets the device | Yes |

### -DeviceName
The exact Intune device name. The device is looked up via a filter query.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ByDeviceName set) |
| Pipeline: | No |

### -DeviceId
The Intune managed device ID (GUID).

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ByDeviceId set) |
| Pipeline: | No |

### -InputObject
A device object from `Get-LKDevice`. Accepted from the pipeline.

| | |
|---|---|
| Type: | PSCustomObject |
| Default: | -- |
| Required: | No |
| Pipeline: | ByValue |

### -KeepUserData
When used with `-Action Wipe`, preserves user data during the wipe. Ignored for other actions.

| | |
|---|---|
| Type: | Switch |
| Default: | False |
| Required: | No |
| Pipeline: | No |

### -KeepEnrollmentData
When used with `-Action Wipe`, preserves enrollment data during the wipe. Ignored for other actions.

| | |
|---|---|
| Type: | Switch |
| Default: | False |
| Required: | No |
| Pipeline: | No |

## Outputs
`PSCustomObject` with properties:
- **DeviceName** -- the device's display name
- **DeviceId** -- the Intune managed device ID
- **Action** -- the action that was triggered
- **Status** -- `Initiated`

## Examples

### Example 1
```powershell
Invoke-LKDeviceAction -DeviceName 'YOURPC-001' -Action Sync
```
Triggers a sync for the device "YOURPC-001".

### Example 2
```powershell
Get-LKDevice -User "Jesper" | Invoke-LKDeviceAction -Action Restart
```
Restarts all devices belonging to the user "Jesper".

### Example 3
```powershell
Invoke-LKDeviceAction -DeviceName 'YOURPC-001' -Action Wipe -KeepUserData
```
Wipes the device but preserves user data.

### Example 4
```powershell
Invoke-LKDeviceAction -DeviceName 'OLD-PC-001' -Action Retire
```
Retires the device, removing company data while keeping personal data.

## Notes
- Requires an active session (`New-LKSession`).
- Wipe and Retire are destructive and irreversible. An extra warning is displayed before the confirmation prompt.
- The action is initiated asynchronously - a `Status` of `Initiated` means the command was accepted by Intune, not that the device has completed the action.
- See also: `Get-LKDevice`, `Get-LKDeviceDetail`.
