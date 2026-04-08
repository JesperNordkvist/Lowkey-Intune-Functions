function Resolve-LKMemberId {
    <#
    .SYNOPSIS
        Resolves a user or device input (pipeline object, name, or ID) to a directory object ID.
        Returns a hashtable with DirectoryObjectId, DisplayName, and MemberType, or $null on failure.
    #>
    [CmdletBinding()]
    param(
        [PSCustomObject]$InputObject,
        [string]$DeviceName,
        [string]$DeviceId,
        [string]$UserName,
        [string]$UserId
    )

    $memberDisplayName = $null
    $directoryObjectId = $null
    $memberType        = $null
    $azureADDeviceId   = $null

    if ($InputObject) {
        # Use PSTypeName for reliable type detection
        $typeNames = @($InputObject.PSObject.TypeNames)
        if ($typeNames -contains 'LKUser') {
            $directoryObjectId = $InputObject.Id
            $memberDisplayName = $InputObject.DisplayName
            $memberType        = 'User'
        } elseif ($typeNames -contains 'LKDevice' -or $typeNames -contains 'LKDeviceDetail') {
            $memberType        = 'Device'
            $azureADDeviceId   = $InputObject.AzureADDeviceId
            $memberDisplayName = $InputObject.DeviceName
            if (-not $azureADDeviceId) {
                try {
                    $dev = Invoke-LKGraphRequest -Method GET -Uri "/deviceManagement/managedDevices/$($InputObject.Id)?`$select=azureADDeviceId,deviceName" -ApiVersion 'v1.0'
                    $azureADDeviceId   = $dev.azureADDeviceId
                    $memberDisplayName = $dev.deviceName
                } catch {
                    Write-Warning "Failed to resolve device: $($_.Exception.Message)"
                    return $null
                }
            }
        } else {
            Write-Warning "Unsupported pipeline object type. Expected LKUser or LKDevice."
            return $null
        }
    } elseif ($UserId) {
        $directoryObjectId = $UserId
        $memberDisplayName = $UserId
        $memberType        = 'User'
    } elseif ($UserName) {
        $memberType = 'User'
        $escaped = $UserName.Replace("'", "''")
        $found = Invoke-LKGraphRequest -Method GET -Uri "/users?`$filter=displayName eq '$escaped'&`$select=id,displayName" -ApiVersion 'v1.0' -All
        if (-not $found -or $found.Count -eq 0) {
            Write-Warning "User '$UserName' not found."
            return $null
        }
        if ($found.Count -gt 1) {
            Write-Warning "Multiple users found matching '$UserName'. Use -UserId for the correct user."
            return $null
        }
        $directoryObjectId = $found[0].id
        $memberDisplayName = $found[0].displayName
    } elseif ($DeviceId) {
        $azureADDeviceId   = $DeviceId
        $memberDisplayName = $DeviceId
        $memberType        = 'Device'
    } elseif ($DeviceName) {
        $memberType = 'Device'
        $escaped = $DeviceName.Replace("'", "''")
        $found = Invoke-LKGraphRequest -Method GET -Uri "/deviceManagement/managedDevices?`$filter=deviceName eq '$escaped'&`$select=azureADDeviceId,deviceName" -ApiVersion 'v1.0' -All
        if (-not $found -or $found.Count -eq 0) {
            Write-Warning "Device '$DeviceName' not found."
            return $null
        }
        $azureADDeviceId   = $found[0].azureADDeviceId
        $memberDisplayName = $found[0].deviceName
    }

    # Resolve device Azure AD ID to directory object ID
    if ($memberType -eq 'Device' -and -not $directoryObjectId) {
        if (-not $azureADDeviceId) {
            Write-Warning 'Could not determine Azure AD device ID.'
            return $null
        }

        $directoryDevice = Invoke-LKGraphRequest -Method GET -Uri "/devices?`$filter=deviceId eq '$azureADDeviceId'&`$select=id" -ApiVersion 'v1.0' -All
        if (-not $directoryDevice -or $directoryDevice.Count -eq 0) {
            Write-Warning "Device with Azure AD ID '$azureADDeviceId' not found in directory."
            return $null
        }
        $directoryObjectId = $directoryDevice[0].id
    }

    if (-not $directoryObjectId) {
        Write-Warning 'Could not determine directory object ID.'
        return $null
    }

    return @{
        DirectoryObjectId = $directoryObjectId
        DisplayName       = $memberDisplayName
        MemberType        = $memberType
    }
}
