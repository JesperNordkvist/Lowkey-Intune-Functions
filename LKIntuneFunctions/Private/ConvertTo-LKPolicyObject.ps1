function ConvertTo-LKPolicyObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$RawPolicy,

        [Parameter(Mandatory)]
        [hashtable]$PolicyType,

        [string]$ResolvedScope
    )

    $scope = if ($ResolvedScope) { $ResolvedScope } else { $PolicyType.TargetScope }

    [PSCustomObject]@{
        PSTypeName  = 'LKPolicy'
        Id          = $RawPolicy.id
        Name        = $RawPolicy.($PolicyType.NameProperty)
        PolicyType  = $PolicyType.TypeName
        DisplayType = $PolicyType.DisplayName
        Description = $RawPolicy.description
        TargetScope = $scope
        CreatedAt   = $RawPolicy.createdDateTime
        ModifiedAt  = $RawPolicy.lastModifiedDateTime
        RawObject   = $RawPolicy
    }
}
