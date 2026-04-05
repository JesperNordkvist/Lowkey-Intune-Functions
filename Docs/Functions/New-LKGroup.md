# New-LKGroup

## Synopsis
Creates a new Entra ID security group for Intune.

## Syntax
```powershell
New-LKGroup
    -Name <String>
    [-Description <String>]       # Default: ''
    [-GroupType <String>]         # 'Device' (default) | 'User'
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description
Creates a new security group in Entra ID via Microsoft Graph. The group is created with mail disabled and security enabled. If a group with the same name already exists, a warning is displayed and the existing group is returned instead of creating a duplicate. The mail nickname is auto-generated from the group name by stripping non-alphanumeric characters.

## Parameters

### -Name
The display name for the new group.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes |
| Pipeline: | No |

### -Description
An optional description for the group.

| | |
|---|---|
| Type: | String |
| Default: | '' (empty string) |
| Required: | No |
| Pipeline: | No |

### -GroupType
Indicates the intended membership type. Currently used for documentation/intent; both values create an assigned security group.

| | |
|---|---|
| Type: | String |
| Default: | Device |
| Required: | No |
| Pipeline: | No |
| Valid values: | Device, User |

## Outputs
`PSCustomObject` (type name `LKGroup`) with properties:
- **Id** -- the new group's Entra ID object ID
- **Name** -- the group display name
- **Description** -- the group description
- **GroupType** -- always `Security`
- **MembershipType** -- `Dynamic` or `Assigned`
- **MembershipRule** -- the dynamic membership rule (null for assigned groups)

## Examples

### Example 1
```powershell
New-LKGroup -Name 'SG-Intune-TestDevices' -Description 'Test device group'
```
Creates a new security group named "SG-Intune-TestDevices" with the given description.

### Example 2
```powershell
New-LKGroup -Name 'SG-Intune-TestUsers' -Description 'Test users' -GroupType User
```
Creates a new security group intended for user membership.

## Notes
- Requires an active session (`New-LKSession`).
- Duplicate detection is performed by name before creation. If a group with the same name exists, the existing group is returned.
- The mail nickname is derived by removing all non-alphanumeric characters from the name and converting to lowercase.
- See also: `Get-LKGroup`, `Rename-LKGroup`, `Add-LKGroupMember`.
