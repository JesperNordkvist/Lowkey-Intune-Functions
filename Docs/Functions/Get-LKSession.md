# Get-LKSession

## Synopsis
Returns the current LKIntuneFunctions session info.

## Syntax
```powershell
Get-LKSession [<CommonParameters>]
```

## Description
Shows the tenant, account, and connection details for the active session. If no session is currently active in memory, it attempts to restore a previous session by checking whether the Graph token cache is still valid. If restoration fails, a warning is displayed.

## Parameters

This function has no function-specific parameters. It supports all common parameters (`-Verbose`, `-Debug`, etc.).

## Outputs
`PSCustomObject` with properties:
- **TenantName** -- display name of the connected Entra ID tenant
- **TenantId** -- GUID of the connected tenant
- **Account** -- UPN of the signed-in user
- **Scopes** -- array of Microsoft Graph permission scopes granted in the session
- **ConnectedAt** -- timestamp of when the session was established

## Examples

### Example 1
```powershell
Get-LKSession
```
Returns the current session details, including the tenant name, account, granted scopes, and the time the connection was made.

## Notes
- Returns `$null` with a warning if no active or restorable session exists.
- Call `New-LKSession` first to establish a connection.
- See also: `New-LKSession`, `Close-LKSession`.
