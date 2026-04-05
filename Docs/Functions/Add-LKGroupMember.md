# Add-LKGroupMember

## Synopsis
Adds a device or user to an Entra ID group.

## Syntax
```powershell
# By device name (default)
Add-LKGroupMember
    -GroupName <String>
    -DeviceName <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By device ID
Add-LKGroupMember
    -GroupName <String>
    -DeviceId <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By user name
Add-LKGroupMember
    -GroupName <String>
    -UserName <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By user ID
Add-LKGroupMember
    -GroupName <String>
    -UserId <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# Pipeline
Add-LKGroupMember
    -GroupName <String>
    [-InputObject <PSCustomObject>]
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description
Adds a device or user as a member of an Entra ID group. Devices can be specified by name, Azure AD device ID, or piped from `Get-LKDevice`. Users can be specified by name, directory object ID, or piped from `Get-LKUser`. The function auto-detects whether a pipeline object is a user or device. If the member is already in the group, a warning is displayed.

## Parameters

### -GroupName
The exact display name of the target Entra ID group.

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
A device object from `Get-LKDevice` or a user object from `Get-LKUser`. Accepted from the pipeline. The function detects the object type automatically: objects with `UserPrincipalName` but no `AzureADDeviceId` are treated as users; all others as devices.

| | |
|---|---|
| Type: | PSCustomObject |
| Default: | -- |
| Required: | No |
| Pipeline: | ByValue |

## Outputs
`PSCustomObject` with properties:
- **GroupName** -- the target group's display name
- **GroupId** -- the target group's object ID
- **MemberName** -- the added member's display name
- **MemberId** -- the member's directory object ID
- **MemberType** -- `Device` or `User`
- **Action** -- `MemberAdded`

## Examples

### Example 1
```powershell
Get-LKDevice -User "Jesper" | Add-LKGroupMember -GroupName 'SG-Intune-TestDevices'
```
Adds all devices belonging to the user "Jesper" to the group.

### Example 2
```powershell
Add-LKGroupMember -GroupName 'SG-Intune-TestDevices' -DeviceName 'YOURPC-001'
```
Adds the device "YOURPC-001" to the group by looking up the device name in Intune.

### Example 3
```powershell
Get-LKUser -Name "Jesper" | Add-LKGroupMember -GroupName 'SG-Intune-TestUsers'
```
Adds the user "Jesper" to the group via pipeline.

### Example 4
```powershell
Add-LKGroupMember -GroupName 'SG-Intune-TestUsers' -UserName 'Jesper Nordkvist'
```
Adds a user by their display name.

## Notes
- Requires an active session (`New-LKSession`).
- For devices, the function resolves the Intune managed device ID to an Entra directory object ID, since group membership requires directory object references.
- For users, the directory object ID is used directly.
- If the member is already in the group, a warning is displayed and no duplicate is created.
- See also: `Remove-LKGroupMember`, `Get-LKDevice`, `Get-LKUser`, `Get-LKGroupMember`, `New-LKGroup`.
