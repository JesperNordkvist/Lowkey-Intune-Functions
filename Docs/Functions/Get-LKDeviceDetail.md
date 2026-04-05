# Get-LKDeviceDetail

## Synopsis
Returns detailed information for a specific Intune managed device.

## Syntax
```powershell
# By name (default)
Get-LKDeviceDetail
    -Name <String>
    [<CommonParameters>]

# By ID
Get-LKDeviceDetail
    -DeviceId <String>
    [<CommonParameters>]

# Pipeline
Get-LKDeviceDetail
    [-InputObject <PSCustomObject>]
    [<CommonParameters>]
```

## Description
Fetches the full managed-device record from Intune for a single device, including hardware details, storage, encryption state, and ownership. Additionally retrieves the device's compliance policy states and configuration profile states, returning them as nested collections on the output object.

Supports three input methods: by device name (looked up via filter), by Intune managed device ID, or by pipeline from `Get-LKDevice`.

## Parameters

### -Name
The exact device name to look up in Intune.

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ByName set) |
| Pipeline: | No |

### -DeviceId
The Intune managed device ID (GUID).

| | |
|---|---|
| Type: | String |
| Default: | -- |
| Required: | Yes (ById set) |
| Pipeline: | No |

### -InputObject
A device object from `Get-LKDevice`. Accepted from the pipeline.

| | |
|---|---|
| Type: | PSCustomObject |
| Default: | -- |
| Required: | No |
| Pipeline: | ByValue |

## Outputs
`PSCustomObject` (type name `LKDeviceDetail`) with properties:
- **Id** -- the Intune managed device ID
- **DeviceName** -- the device name
- **UserDisplayName** -- display name of the primary user
- **UserPrincipalName** -- UPN of the primary user
- **OS** -- operating system
- **OSVersion** -- OS version string
- **ComplianceState** -- compliance status
- **ManagementState** -- management state
- **EnrolledDateTime** -- enrolment timestamp
- **LastSyncDateTime** -- last sync timestamp
- **Model** -- device model
- **Manufacturer** -- device manufacturer
- **SerialNumber** -- serial number
- **AzureADDeviceId** -- the Entra ID device identifier
- **EnrollmentType** -- device enrollment type
- **JoinType** -- Azure AD join type
- **Ownership** -- device ownership type (corporate, personal)
- **TotalStorageGB** -- total storage in GB (rounded to 2 decimal places)
- **FreeStorageGB** -- free storage in GB (rounded to 2 decimal places)
- **EncryptionState** -- whether the device is encrypted (`$true`/`$false`)
- **ComplianceGracePeriod** -- compliance grace period expiration
- **PrimaryUser** -- UPN of the primary user
- **CompliancePolicyStates** -- array of objects with `PolicyName` and `State`
- **ConfigurationStates** -- array of objects with `ProfileName` and `State`

## Examples

### Example 1
```powershell
Get-LKDeviceDetail -Name "YOURPC-001"
```
Returns the full device detail record for the device named "YOURPC-001".

### Example 2
```powershell
Get-LKDevice -User "Jesper" | Get-LKDeviceDetail
```
Finds all devices for the user "Jesper" and returns detailed information for each one.

## Notes
- Requires an active session (`New-LKSession`).
- If multiple devices match the `-Name` filter, only the first result is returned and a warning is displayed.
- Compliance and configuration state lookups are best-effort; failures are silently ignored.
- See also: `Get-LKDevice`.
