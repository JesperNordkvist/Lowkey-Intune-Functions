# Get-LKGroupMember

## Synopsis
Lists the members of an Entra ID group.

## Syntax
```powershell
# By group name (default)
Get-LKGroupMember
    -GroupName <String>
    [-MemberType <String>]       # 'All' (default) | 'Device' | 'User'
    [<CommonParameters>]

# By group ID
Get-LKGroupMember
    -GroupId <String>
    [-MemberType <String>]
    [<CommonParameters>]

# Pipeline
Get-LKGroupMember
    [-InputObject <PSCustomObject>]
    [-MemberType <String>]
    [<CommonParameters>]
```

## Description
Lists all members (devices and/or users) of an Entra ID group. The group can be specified by name, object ID, or piped from `Get-LKGroup`. Results can be filtered by member type. Supports pipeline input of multiple groups.

## Parameters

### -GroupName
The exact display name of the group.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ByName set) |
| Pipeline: | No |

### -GroupId
The Entra ID object ID of the group.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ById set) |
| Pipeline: | No |

### -InputObject
A group object from `Get-LKGroup`. Accepted from the pipeline.

| | |
|---|---|
| Type: | PSCustomObject |
| Default: | -- |
| Required: | No |
| Pipeline: | ByValue |

### -MemberType
Filters the results by member type.

| | |
|---|---|
| Type: | String |
| Default: | All |
| Required: | No |
| Pipeline: | No |
| Valid values: | All, Device, User |

## Outputs
`PSCustomObject` (type name `LKGroupMember`) with properties:
- **GroupName** -- the group's display name
- **GroupId** -- the group's object ID
- **MemberId** -- the member's directory object ID
- **DisplayName** -- the member's display name
- **MemberType** -- `Device` or `User`
- **UserPrincipalName** -- the user's UPN (users only, `$null` for devices)
- **DeviceId** -- the Azure AD device ID (devices only, `$null` for users)
- **OS** -- the device's operating system (devices only, `$null` for users)

## Examples

### Example 1
```powershell
Get-LKGroupMember -GroupName 'SG-Intune-TestDevices'
```
Lists all members of the group.

### Example 2
```powershell
Get-LKGroup -Name 'SG-Test*' -NameMatch Wildcard | Get-LKGroupMember
```
Lists members of all groups matching the wildcard pattern.

### Example 3
```powershell
Get-LKGroupMember -GroupName 'SG-Mixed-Group' -MemberType Device
```
Lists only device members of the group.

## Notes
- Requires an active session (`New-LKSession`).
- Fetches all members with pagination.
- See also: `Get-LKGroup`, `Add-LKGroupMember`, `Remove-LKGroupMember`.
