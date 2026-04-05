# Remove-LKGroup

## Synopsis
Deletes an Entra ID group.

## Syntax
```powershell
# By name (default)
Remove-LKGroup
    -Name <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]

# By ID
Remove-LKGroup
    -GroupId <String>
    [-WhatIf] [-Confirm]
    [<CommonParameters>]
```

## Description
Permanently deletes an Entra ID group. The group can be identified by its display name or object ID. This action is irreversible. A confirmation prompt with a readback of the group name and ID is shown before deletion.

## Parameters

### -Name
The display name of the group to delete. Used to resolve the group's object ID internally.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ByName set) |
| Pipeline: | No |

### -GroupId
The Entra ID object ID of the group to delete.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ById set) |
| Pipeline: | No |

## Outputs
`PSCustomObject` with properties:
- **GroupId** -- the deleted group's object ID
- **Name** -- the deleted group's display name
- **Action** -- `Deleted`

## Examples

### Example 1
```powershell
Remove-LKGroup -Name 'SG-Intune-TestDevices'
```
Deletes the group "SG-Intune-TestDevices" after confirmation.

### Example 2
```powershell
Remove-LKGroup -Name 'SG-Intune-TestDevices' -WhatIf
```
Shows what would happen without actually deleting the group.

### Example 3
```powershell
Remove-LKGroup -GroupId 'abc-123'
```
Deletes the group by its object ID. The display name is fetched for the confirmation prompt.

## Notes
- Requires an active session (`New-LKSession`).
- This action is irreversible. The group and its membership data are permanently deleted.
- The group name is resolved via `Resolve-LKGroupId` which requires an exact match.
- See also: `New-LKGroup`, `Rename-LKGroup`, `Get-LKGroup`.
