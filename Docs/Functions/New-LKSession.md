# New-LKSession

## Synopsis
Opens an interactive login and connects to Microsoft Graph for Intune administration.

## Syntax
```powershell
New-LKSession [<CommonParameters>]
```

## Description
Launches a browser-based sign-in prompt using delegated authentication with the built-in Microsoft Graph PowerShell app -- no custom app registration required. The user's Intune Administrator role provides effective permissions. If the `Microsoft.Graph.Authentication` module is not installed, it will be installed automatically.

If a previous session was established against a different tenant or account, a warning is shown so you don't accidentally work in the wrong environment.

## Parameters

This function has no function-specific parameters. It supports all common parameters (`-Verbose`, `-Debug`, etc.).

## Outputs
`PSCustomObject` with properties:
- **TenantName** -- display name of the connected Entra ID tenant
- **TenantId** -- GUID of the connected tenant
- **Account** -- UPN of the signed-in user
- **ConnectedAt** -- timestamp of when the session was established

## Examples

### Example 1
```powershell
New-LKSession
```
Opens a browser sign-in window. After authentication, returns the session object showing the tenant, account, and connection time.

## Notes
- Requires interactive access to a browser for the sign-in prompt.
- Installs `Microsoft.Graph.Authentication` to the CurrentUser scope if it is not already present.
- Session state is persisted to a local JSON file so that `Get-LKSession` can detect tenant/account changes across sessions.
- See also: `Get-LKSession`, `Close-LKSession`.
