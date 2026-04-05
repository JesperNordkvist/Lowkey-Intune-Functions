function Invoke-LKGraphRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')]
        [string]$Method,

        [Parameter(Mandatory)]
        [string]$Uri,

        [ValidateSet('v1.0', 'beta')]
        [string]$ApiVersion = 'v1.0',

        [object]$Body,

        [hashtable]$Headers,

        [switch]$All
    )

    $baseUrl = "https://graph.microsoft.com/$ApiVersion"
    $fullUri = "$baseUrl$Uri"

    $params = @{
        Method      = $Method
        Uri         = $fullUri
        ErrorAction = 'Stop'
    }

    if ($Body) {
        $params['Body']        = $Body | ConvertTo-Json -Depth 20
        $params['ContentType'] = 'application/json'
    }

    if ($Headers) {
        $params['Headers'] = $Headers
    }

    $response = Invoke-LKGraphWithRetry -Params $params

    if (-not $All -or $Method -ne 'GET') {
        return $response
    }

    # Paginate: collect all values
    $results = @()
    if ($response.value) {
        $results += $response.value
    }

    while ($response.'@odata.nextLink') {
        $params['Uri'] = $response.'@odata.nextLink'
        $response = Invoke-LKGraphWithRetry -Params $params
        if ($response.value) {
            $results += $response.value
        }
    }

    return $results
}

function Invoke-LKGraphWithRetry {
    <#
    .SYNOPSIS
        Executes an Invoke-MgGraphRequest with retry logic for 429 (throttled) responses.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Params,

        [int]$MaxRetries = 3
    )

    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            return (Invoke-MgGraphRequest @Params)
        } catch {
            $status = $_.Exception.Response.StatusCode.value__
            if ($status -eq 429 -and $attempt -lt $MaxRetries) {
                $retryAfter = 2 * [math]::Pow(2, $attempt - 1)
                $retryHeader = $_.Exception.Response.Headers['Retry-After']
                if ($retryHeader) { $retryAfter = [int]$retryHeader }
                Write-Warning "Throttled (429). Retrying in ${retryAfter}s... (attempt $attempt of $MaxRetries)"
                Start-Sleep -Seconds $retryAfter
                continue
            }
            throw
        }
    }
}
