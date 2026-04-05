---
title: Close-LKSession
parent: Session Management
nav_order: 3
---

# Close-LKSession

Disconnects from Microsoft Graph and ends the current session.

## Syntax

```powershell
Close-LKSession [<CommonParameters>]
```

## Description

Terminates the Graph connection, clears in-memory session state, and removes the persisted session file. Run this when you are finished working to ensure no stale credentials are reused in a later session.

## Parameters

This command has no parameters.

## Examples

### Example 1 --- End the session
```powershell
Close-LKSession
```
