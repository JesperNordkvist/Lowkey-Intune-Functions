---
title: Get-LKAssignmentFilter
nav_order: 9
---

# Get-LKAssignmentFilter

Lists Intune assignment filters in the tenant.

## Syntax

```text
Get-LKAssignmentFilter
    [-Name <String[]>]
    [-NameMatch <String>]
    [-DisplayAs <String>]
    [<CommonParameters>]
```

## Description

Queries `/deviceManagement/assignmentFilters` (beta API) and returns structured objects for each assignment filter. Filters can be searched by name using the standard matching modes.

Assignment filters narrow the scope of a policy assignment based on device properties (e.g., OS version, model, enrollment profile).

## Parameters

### -Name

One or more name patterns to search for.

| Attribute | Value |
|---|---|
| Type | `String[]` |
| Required | No |

### -NameMatch

| Attribute | Value |
|---|---|
| Type | `String` |
| Default | Contains |
| Valid values | Contains, Exact, Wildcard, Regex |

### -DisplayAs

Controls output format.

| Attribute | Value |
|---|---|
| Type | `String` |
| Default | List |
| Valid values | List, Table |

## Outputs

| Property | Type | Description |
|---|---|---|
| Id | String | Filter GUID |
| Name | String | Filter display name |
| Description | String | Filter description |
| Platform | String | Target platform |
| Rule | String | Filter rule expression |
| ManagementType | String | Management type (devices, apps) |

## Examples

### Example 1 - List all filters

```powershell
Get-LKAssignmentFilter
```

### Example 2 - Search by name

```powershell
Get-LKAssignmentFilter -Name '24H2'
```

### Example 3 - Table view

```powershell
Get-LKAssignmentFilter -DisplayAs Table
```

## Related

- [Add-LKPolicyAssignment](Add-LKPolicyAssignment.md)
- [Get-LKPolicyAssignment](Get-LKPolicyAssignment.md)
- [Get-LKGroupAssignment](../groups/Get-LKGroupAssignment.md)
