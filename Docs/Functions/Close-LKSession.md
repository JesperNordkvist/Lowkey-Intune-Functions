# Close-LKSession

## Synopsis
Disconnects from Microsoft Graph and ends the current session.

## Syntax
```powershell
Close-LKSession [<CommonParameters>]
```

## Description
Terminates the Graph connection, clears in-memory session state, and removes the persisted session file. Run this when you are finished working to ensure no stale credentials are reused in a later session.

## Parameters

This function has no function-specific parameters. It supports all common parameters (`-Verbose`, `-Debug`, etc.).

## Outputs
None. Writes a confirmation message to the host.

## Examples

### Example 1
```powershell
Close-LKSession
```
Disconnects from Microsoft Graph, clears all session data, and prints "Session ended and Graph connection closed."

## Notes
- Safe to call even if no session is currently active.
- Removes the persisted session JSON file so that `Get-LKSession` will not attempt to restore a stale connection.
- See also: `New-LKSession`, `Get-LKSession`.
