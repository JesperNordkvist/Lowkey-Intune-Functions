---
title: Search-LKSetting
nav_order: 26
---

# Search-LKSetting

Searches Intune policies for settings matching a query.

## Syntax

```text
Search-LKSetting
    -Setting <String[]>
    [-SettingMatch <String>]
    [-PolicyType <String[]>]
    [-PolicyName <String[]>]
    [-PolicyNameMatch <String>]
    [-SearchValues]
    [-DisplayAs <String>]
    [<CommonParameters>]
```

## Description

Scans policies across all or specific policy types, retrieves their configured settings, and returns matches where the setting name (or optionally value) matches the search term. Useful for answering "which policies configure this setting?" across your entire tenant.

Supports all 16 policy types including Settings Catalog (with full definition name resolution), Endpoint Security (category-level settings), Group Policy / ADMX (definition values), and flat property extraction for everything else.

## Parameters

### -Setting

One or more search terms to match against setting names.

| Attribute | Value |
|---|---|
| Type | `String[]` |
| Required | Yes |

### -SettingMatch

How `-Setting` is matched against setting names. Default: `Contains`.

| Attribute | Value |
|---|---|
| Type | `String` |
| Default | Contains |
| Valid values | Contains, Exact, Wildcard, Regex |

### -PolicyType

Restrict the search to specific policy types. When omitted, all types are searched.

| Attribute | Value |
|---|---|
| Type | `String[]` |
| Required | No |
| Valid values | DeviceConfiguration, SettingsCatalog, CompliancePolicy, EndpointSecurity, AppProtectionIOS, AppProtectionAndroid, AppProtectionWindows, AppConfiguration, EnrollmentConfiguration, PolicySet, GroupPolicyConfiguration, PlatformScript, Remediation, DriverUpdate, App, AutopilotDeploymentProfile |

### -PolicyName

Pre-filters policies by name before fetching their settings. Reduces API calls when you know which policies to search within.

| Attribute | Value |
|---|---|
| Type | `String[]` |
| Required | No |

### -PolicyNameMatch

How `-PolicyName` is matched. Default: `Contains`.

| Attribute | Value |
|---|---|
| Type | `String` |
| Default | Contains |
| Valid values | Contains, Exact, Wildcard, Regex |

### -SearchValues

When specified, the search also matches against setting values, not just setting names.

| Attribute | Value |
|---|---|
| Type | `SwitchParameter` |

### -DisplayAs

Controls output format. Table (default) renders a colored table to the host. List emits objects to the pipeline.

| Attribute | Value |
|---|---|
| Type | `String` |
| Default | Table |
| Valid values | List, Table |

## Outputs

| Property | Type | Description |
|---|---|---|
| PolicyName | String | Display name of the policy containing the match |
| PolicyId | String | Graph object ID of the policy |
| PolicyType | String | Normalised type key (e.g. SettingsCatalog) |
| DisplayType | String | Human-readable type label (e.g. Settings Catalog Policy) |
| SettingName | String | Name of the matching setting |
| Value | Object | Configured value of the setting |
| Category | String | Setting category (e.g. Settings Catalog, Disk Encryption, ADMX) |

## Examples

### Example 1 - Search for a setting across all policies

```powershell
Search-LKSetting -Setting "BitLocker"
```

Scans all 16 policy types and returns every setting with "BitLocker" in its name.

### Example 2 - Narrow to specific policy types

```powershell
Search-LKSetting -Setting "Password" -PolicyType CompliancePolicy, DeviceConfiguration
```

Only searches compliance and device configuration policies, reducing the number of API calls.

### Example 3 - Wildcard matching

```powershell
Search-LKSetting -Setting "Firewall*" -SettingMatch Wildcard
```

### Example 4 - Search within values

```powershell
Search-LKSetting -Setting "block" -SearchValues
```

Finds settings where either the name or the configured value contains "block".

### Example 5 - Pre-filter by policy name

```powershell
Search-LKSetting -Setting "Encryption" -PolicyName "Baseline*" -PolicyNameMatch Wildcard
```

Only fetches settings for policies whose names match "Baseline*", then searches within those.

### Example 6 - Pipeline output for scripting

```powershell
Search-LKSetting -Setting "BitLocker" -DisplayAs List |
    Select-Object PolicyName, SettingName, Value |
    Export-Csv -Path .\BitLockerSettings.csv -NoTypeInformation
```

### Example 7 - Regex search

```powershell
Search-LKSetting -Setting "password.*(length|age)" -SettingMatch Regex
```

Uses regex to find settings related to password length or password age.

### Example 8 - Multiple search terms

```powershell
Search-LKSetting -Setting "BitLocker", "Encryption", "Recovery"
```

Matches settings containing any of the specified terms.

## Notes

- This function makes additional API calls per policy to retrieve settings. Searching all policy types across a large tenant may take some time. Use `-PolicyType` and `-PolicyName` to narrow the scope when possible.
- Settings Catalog policies use expanded definition lookups for human-readable setting names.
- Endpoint Security policies retrieve settings per category.
- ADMX policies show definition display names with Enabled/Disabled state.
- Other policy types extract settings from the raw policy object properties.

## Related

- [Get-LKPolicy](Get-LKPolicy.md) - query policies with optional `-IncludeSettings`
- [Show-LKPolicyDetail](Show-LKPolicyDetail.md) - detailed formatted view of a single policy
- [Get-LKPolicyOverview](Get-LKPolicyOverview.md) - at-a-glance assignment summary
