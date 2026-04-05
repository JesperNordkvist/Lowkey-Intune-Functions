# Get-LKGroup

## Synopsis
Queries Entra ID groups with flexible name filtering.

## Syntax
```powershell
Get-LKGroup
    [-Name <String[]>]
    [-NameMatch <String>]         # 'Contains' (default) | 'Exact' | 'Wildcard' | 'Regex'
    [-FilterScript <ScriptBlock>]
    [<CommonParameters>]
```

## Description
Searches Entra ID groups via Microsoft Graph with smart query routing: single exact-match names use a `$filter` query, single contains-match names use a `$search` query with `ConsistencyLevel: eventual`, and all other patterns fall back to client-side filtering. Each returned group is normalised into a consistent object showing its type and membership model.

## Parameters

### -Name
One or more name strings to match against the group display name. Matching behaviour is controlled by `-NameMatch`.

| | |
|---|---|
| Type: | String[] |
| Default: | -- |
| Required: | No |
| Pipeline: | No |

### -NameMatch
Determines how `-Name` values are matched.

| | |
|---|---|
| Type: | String |
| Default: | Contains |
| Required: | No |
| Pipeline: | No |
| Valid values: | Contains, Exact, Wildcard, Regex |

### -FilterScript
A script block applied to each normalised group object. Only objects where the script block returns `$true` are emitted.

| | |
|---|---|
| Type: | ScriptBlock |
| Default: | -- |
| Required: | No |
| Pipeline: | No |

## Outputs
`PSCustomObject` (type name `LKGroup`) with properties:
- **Id** -- the group's Entra ID object ID
- **Name** -- the group display name
- **Description** -- the group description
- **GroupType** -- `Security` or `Microsoft365`
- **MembershipType** -- `Dynamic` or `Assigned`
- **MembershipRule** -- the dynamic membership rule expression (null for assigned groups)

## Examples

### Example 1
```powershell
Get-LKGroup -Name "SG-Windows-*" -NameMatch Wildcard
```
Returns all groups whose name matches the wildcard pattern "SG-Windows-*".

### Example 2
```powershell
Get-LKGroup -Name "TestGroup" -NameMatch Exact
```
Returns the group with the exact display name "TestGroup".

### Example 3
```powershell
Get-LKGroup -FilterScript { $_.MembershipType -eq 'Dynamic' }
```
Returns all dynamic membership groups.

## Notes
- Requires an active session (`New-LKSession`).
- The `$search` query used for `Contains` matching requires the `ConsistencyLevel: eventual` header, which is handled automatically.
- When no `-Name` is specified, all groups are returned (up to the API page limit with automatic paging).
- See also: `New-LKGroup`, `Rename-LKGroup`, `Get-LKGroupAssignment`.
