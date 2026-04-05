# Rename-LKGroup

## Synopsis
Renames an existing Entra ID group.

## Syntax
```powershell
# By name (default)
Rename-LKGroup
    -Name <String>
    -NewName <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By ID
Rename-LKGroup
    -GroupId <String>
    -NewName <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description
Updates the `displayName` property of an existing Entra ID group via a PATCH request to Microsoft Graph. The group can be identified by its current display name or by its object ID. Supports `-WhatIf` and `-Confirm`.

## Parameters

### -Name
The current display name of the group. Used to resolve the group's object ID internally.

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

### -NewName
The new display name for the group.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes |
| Pipeline: | No |

## Outputs
`PSCustomObject` with properties:
- **GroupId** -- the group's object ID
- **OldName** -- the previous display name
- **NewName** -- the updated display name
- **Action** -- `Renamed`

## Examples

### Example 1
```powershell
Rename-LKGroup -Name 'SG-Old-Name' -NewName 'SG-New-Name'
```
Renames the group "SG-Old-Name" to "SG-New-Name".

### Example 2
```powershell
Rename-LKGroup -GroupId 'abc-123' -NewName 'SG-New-Name'
```
Renames the group identified by the given object ID.

## Notes
- Requires an active session (`New-LKSession`).
- The group name is resolved via `Resolve-LKGroupId` which requires an exact match.
- See also: `Get-LKGroup`, `New-LKGroup`.
