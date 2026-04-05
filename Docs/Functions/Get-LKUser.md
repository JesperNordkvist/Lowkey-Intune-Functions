# Get-LKUser

## Synopsis
Queries Entra ID users with flexible name and department filtering.

## Syntax
```powershell
Get-LKUser
    [-Name <String[]>]
    [-NameMatch <String>]         # 'Contains' (default) | 'Exact' | 'Wildcard' | 'Regex'
    [-Department <String>]
    [-FilterScript <ScriptBlock>]
    [<CommonParameters>]
```

## Description
Queries Entra ID users via the Microsoft Graph `/users` endpoint. Server-side filtering is used where possible (exact name match, contains search with `$search`), with client-side filtering for wildcard/regex patterns and multi-value names. Name matching checks both `displayName` and `userPrincipalName`.

## Parameters

### -Name
One or more name strings to match against the user's display name and UPN. Matching behaviour is controlled by `-NameMatch`.

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

### -Department
Filters users by department. Applied server-side where possible.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | No |
| Pipeline: | No |

### -FilterScript
A script block applied to each normalised user object. Only objects where the script block returns `$true` are emitted.

| | |
|---|---|
| Type: | ScriptBlock |
| Default: | -- |
| Required: | No |
| Pipeline: | No |

## Outputs
`PSCustomObject` (type name `LKUser`) with properties:
- **Id** -- the Entra ID directory object ID
- **DisplayName** -- the user's display name
- **UserPrincipalName** -- the user's UPN
- **Mail** -- the user's email address
- **JobTitle** -- the user's job title
- **Department** -- the user's department
- **AccountEnabled** -- whether the account is enabled

## Examples

### Example 1
```powershell
Get-LKUser -Name "Jesper" -NameMatch Contains
```
Returns all users whose display name or UPN contains "Jesper".

### Example 2
```powershell
Get-LKUser -Name "jesper@contoso.com" -NameMatch Exact
```
Returns the user with the exact display name or UPN match.

### Example 3
```powershell
Get-LKUser -Department "IT"
```
Returns all users in the IT department.

### Example 4
```powershell
Get-LKUser -Name "J*" -NameMatch Wildcard -FilterScript { $_.AccountEnabled -eq $true }
```
Returns enabled users whose name starts with "J".

## Notes
- Requires an active session (`New-LKSession`).
- Output objects can be piped to `Add-LKGroupMember` and `Remove-LKGroupMember`.
- For `Contains` with a single name, the function uses Graph's `$search` with `ConsistencyLevel: eventual` for efficient server-side filtering.
- See also: `Get-LKDevice`, `Add-LKGroupMember`.
