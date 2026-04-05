# Get-LKDevice

## Synopsis
Queries Intune managed devices with flexible filtering.

## Syntax
```powershell
Get-LKDevice
    [-Name <String[]>]
    [-NameMatch <String>]         # 'Contains' (default) | 'Exact' | 'Wildcard' | 'Regex'
    [-User <String[]>]
    [-UserMatch <String>]         # 'Contains' (default) | 'Exact' | 'Wildcard' | 'Regex'
    [-OS <String>]                # 'Windows' | 'iOS' | 'Android' | 'macOS'
    [-FilterScript <ScriptBlock>]
    [<CommonParameters>]
```

## Description
Queries the Intune `managedDevices` endpoint and returns normalised device objects. Server-side filtering is used where possible (single exact device name, OS filter), with client-side filtering for wildcard/regex patterns, multi-value names, and user matching. User matching checks both `userDisplayName` and `userPrincipalName`.

## Parameters

### -Name
One or more device name strings to match. Matching behaviour is controlled by `-NameMatch`.

| | |
|---|---|
| Type: | String[] |
| Default: | -- |
| Required: | No |
| Pipeline: | No |

### -NameMatch
Determines how `-Name` values are matched against the device name.

| | |
|---|---|
| Type: | String |
| Default: | Contains |
| Required: | No |
| Pipeline: | No |
| Valid values: | Contains, Exact, Wildcard, Regex |

### -User
One or more user name strings to match against both `userDisplayName` and `userPrincipalName`.

| | |
|---|---|
| Type: | String[] |
| Default: | -- |
| Required: | No |
| Pipeline: | No |

### -UserMatch
Determines how `-User` values are matched.

| | |
|---|---|
| Type: | String |
| Default: | Contains |
| Required: | No |
| Pipeline: | No |
| Valid values: | Contains, Exact, Wildcard, Regex |

### -OS
Filters devices by operating system. Applied as a server-side filter.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | No |
| Pipeline: | No |
| Valid values: | Windows, iOS, Android, macOS |

### -FilterScript
A script block applied to each normalised device object. Only objects where the script block returns `$true` are emitted.

| | |
|---|---|
| Type: | ScriptBlock |
| Default: | -- |
| Required: | No |
| Pipeline: | No |

## Outputs
`PSCustomObject` (type name `LKDevice`) with properties:
- **Id** -- the Intune managed device ID
- **DeviceName** -- the device name
- **UserDisplayName** -- display name of the primary user
- **UserPrincipalName** -- UPN of the primary user
- **OS** -- operating system (e.g. Windows, iOS)
- **OSVersion** -- operating system version string
- **ComplianceState** -- compliance status (e.g. compliant, noncompliant)
- **ManagementState** -- management state (e.g. managed)
- **EnrolledDateTime** -- enrolment timestamp
- **LastSyncDateTime** -- last successful sync timestamp
- **Model** -- device model
- **Manufacturer** -- device manufacturer
- **SerialNumber** -- hardware serial number
- **AzureADDeviceId** -- the Entra ID device identifier

## Examples

### Example 1
```powershell
Get-LKDevice -Name "YOURPC" -NameMatch Contains
```
Returns all managed devices whose name contains "YOURPC".

### Example 2
```powershell
Get-LKDevice -User "Jesper Nordkvist" -NameMatch Contains
```
Returns all devices where the primary user's display name or UPN contains "Jesper Nordkvist".

### Example 3
```powershell
Get-LKDevice -User "Jesper" -NameMatch Contains -OS Windows
```
Returns Windows devices assigned to a user matching "Jesper".

## Notes
- Requires an active session (`New-LKSession`).
- Output objects can be piped to `Get-LKDeviceDetail`, `Add-LKGroupMember`, and `Remove-LKGroupMember`.
- The `-User` filter is always applied client-side, which means the full device list is fetched first. Combine with `-OS` to reduce the data set.
- See also: `Get-LKDeviceDetail`.
