# Remove-LKGroupMember

## Synopsis
Removes a device or user from an Entra ID group.

## Syntax
```powershell
# By device name (default)
Remove-LKGroupMember
    -GroupName <String>
    -DeviceName <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By device ID
Remove-LKGroupMember
    -GroupName <String>
    -DeviceId <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By user name
Remove-LKGroupMember
    -GroupName <String>
    -UserName <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By user ID
Remove-LKGroupMember
    -GroupName <String>
    -UserId <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# Pipeline
Remove-LKGroupMember
    -GroupName <String>
    [-InputObject <PSCustomObject>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description
Removes a device or user from an Entra ID group. Devices can be specified by name, Azure AD device ID, or piped from `Get-LKDevice`. Users can be specified by name, directory object ID, or piped from `Get-LKUser`. The function auto-detects whether a pipeline object is a user or device. Supports `-WhatIf` and `-Confirm`.

## Parameters

### -GroupName
The exact display name of the Entra ID group to remove the member from.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes |
| Pipeline: | No |

### -DeviceName
The exact Intune device name. The device is looked up via a filter query.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ByDeviceName set) |
| Pipeline: | No |

### -DeviceId
The Azure AD device ID (GUID).

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ByDeviceId set) |
| Pipeline: | No |

### -UserName
The exact display name of the user. The user is looked up via a filter query.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ByUserName set) |
| Pipeline: | No |

### -UserId
The Entra ID directory object ID of the user.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ByUserId set) |
| Pipeline: | No |

### -InputObject
A device object from `Get-LKDevice` or a user object from `Get-LKUser`. Accepted from the pipeline. The function detects the object type automatically.

| | |
|---|---|
| Type: | PSCustomObject |
| Default: | -- |
| Required: | No |
| Pipeline: | ByValue |

## Outputs
`PSCustomObject` with properties:
- **GroupName** -- the group's display name
- **GroupId** -- the group's object ID
- **MemberName** -- the removed member's display name
- **MemberId** -- the member's directory object ID
- **MemberType** -- `Device` or `User`
- **Action** -- `MemberRemoved`

## Examples

### Example 1
```powershell
Remove-LKGroupMember -GroupName 'SG-Intune-TestDevices' -DeviceName 'YOURPC-001'
```
Removes the device "YOURPC-001" from the group.

### Example 2
```powershell
Get-LKDevice -User "Jesper" | Remove-LKGroupMember -GroupName 'SG-Intune-TestDevices'
```
Removes all devices belonging to the user "Jesper" from the group.

### Example 3
```powershell
Get-LKUser -Name "Jesper" | Remove-LKGroupMember -GroupName 'SG-Intune-TestUsers'
```
Removes the user "Jesper" from the group via pipeline.

### Example 4
```powershell
Remove-LKGroupMember -GroupName 'SG-Intune-TestUsers' -UserName 'Jesper Nordkvist'
```
Removes a user by their display name.

## Notes
- Requires an active session (`New-LKSession`).
- The function resolves devices to Entra directory object IDs. For users, the directory object ID is used directly.
- See also: `Add-LKGroupMember`, `Get-LKDevice`, `Get-LKUser`, `Get-LKGroupMember`.
