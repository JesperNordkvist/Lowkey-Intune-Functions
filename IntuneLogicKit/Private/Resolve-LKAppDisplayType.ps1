function Resolve-LKAppDisplayType {
    <#
    .SYNOPSIS
        Maps a MobileApp @odata.type to a human-friendly display name.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ODataType
    )

    switch -Wildcard ($ODataType) {
        '*win32LobApp'                    { return 'Win32 App' }
        '*win32CatalogApp'                { return 'Win32 App (Store)' }
        '*windowsMobileMSI'               { return 'MSI App' }
        '*microsoftStoreForBusinessApp'   { return 'Microsoft Store App' }
        '*winGetApp'                      { return 'WinGet App' }
        '*officeSuiteApp'                 { return 'Microsoft 365 Apps' }
        '*windowsMicrosoftEdgeApp'        { return 'Microsoft Edge' }
        '*iosVppApp'                      { return 'iOS VPP App' }
        '*iosStoreApp'                    { return 'iOS Store App' }
        '*iosLobApp'                      { return 'iOS LOB App' }
        '*managedIOSStoreApp'             { return 'Managed iOS App' }
        '*managedIOSLobApp'               { return 'Managed iOS LOB App' }
        '*androidStoreApp'                { return 'Android Store App' }
        '*androidLobApp'                  { return 'Android LOB App' }
        '*androidManagedStoreApp'         { return 'Android Managed Store App' }
        '*managedAndroidStoreApp'         { return 'Managed Android App' }
        '*managedAndroidLobApp'           { return 'Managed Android LOB App' }
        '*androidForWorkApp'              { return 'Android Enterprise App' }
        '*macOSLobApp'                    { return 'macOS LOB App' }
        '*macOSDmgApp'                    { return 'macOS DMG App' }
        '*macOSPkgApp'                    { return 'macOS PKG App' }
        '*macOSMicrosoftEdgeApp'          { return 'macOS Microsoft Edge' }
        '*macOSMicrosoftDefenderApp'      { return 'macOS Microsoft Defender' }
        '*macOSOfficeSuiteApp'            { return 'macOS Microsoft 365 Apps' }
        '*macOSVppApp'                    { return 'macOS VPP App' }
        '*webApp'                         { return 'Web App' }
        '*windowsWebApp'                  { return 'Windows Web App' }
        '*windowsAppX'                    { return 'AppX/MSIX App' }
        '*windowsUniversalAppX'           { return 'Universal AppX App' }
        '*windowsPhone*'                  { return 'Windows Phone App' }
        default {
            # Extract a readable name from the odata type as fallback
            $typeName = ($ODataType -split '\.')[-1]
            return ($typeName -creplace '([a-z])([A-Z])', '$1 $2')
        }
    }
}
