<#
.SYNOPSIS
    Registers an agent instance in the Microsoft Entra Agent Registry via Microsoft Graph API.

.DESCRIPTION
    Reads agent metadata from a JSON file (agent-metadata.json) and registers the agent
    in the Agent Registry by calling POST /beta/agentRegistry/agentInstances.

    Supports both interactive (delegated) and app-only (client credentials) authentication.

.PARAMETER MetadataPath
    Path to the agent-metadata.json file. Defaults to agent-metadata.json in the same directory.

.PARAMETER TenantId
    Your Microsoft Entra tenant ID (GUID or domain).

.PARAMETER ClientId
    The Application (client) ID of the Entra app registration used for authentication.

.PARAMETER ClientSecret
    (Optional) Client secret for app-only (client credentials) flow. If omitted, uses interactive login.

.EXAMPLE
    # Interactive login
    .\Register-Agent.ps1 -TenantId "contoso.onmicrosoft.com" -ClientId "12345678-..."

    # App-only (client credentials)
    .\Register-Agent.ps1 -TenantId "contoso.onmicrosoft.com" -ClientId "12345678-..." -ClientSecret "your-secret"
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$MetadataPath = (Join-Path $PSScriptRoot "agent-metadata.json"),

    [Parameter(Mandatory)]
    [string]$TenantId,

    [Parameter(Mandatory)]
    [string]$ClientId,

    [Parameter()]
    [string]$ClientSecret
)

$ErrorActionPreference = "Stop"

# --- Validate metadata file ---
if (-not (Test-Path $MetadataPath)) {
    Write-Error "Metadata file not found: $MetadataPath. Copy agent-metadata.json.example and fill in your values."
    exit 1
}

$metadata = Get-Content $MetadataPath -Raw | ConvertFrom-Json
Write-Host "Loaded metadata for agent: $($metadata.displayName)" -ForegroundColor Cyan

# --- Validate required fields ---
$requiredFields = @("displayName", "ownerIds", "url", "originatingStore", "preferredTransport")
foreach ($field in $requiredFields) {
    if (-not $metadata.$field) {
        Write-Error "Required field '$field' is missing or empty in $MetadataPath"
        exit 1
    }
}

if ($metadata.ownerIds.Count -eq 0) {
    Write-Error "ownerIds must contain at least one Entra user or group object ID."
    exit 1
}

# --- Acquire access token ---
$tokenEndpoint = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
$graphScope = "https://graph.microsoft.com/.default"

if ($ClientSecret) {
    # Client credentials flow (app-only)
    Write-Host "Authenticating with client credentials flow..." -ForegroundColor Yellow
    $tokenBody = @{
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = $graphScope
        grant_type    = "client_credentials"
    }
    $tokenResponse = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $tokenBody -ContentType "application/x-www-form-urlencoded"
    $accessToken = $tokenResponse.access_token
}
else {
    # Device code flow (interactive / delegated)
    Write-Host "Authenticating with device code flow (interactive)..." -ForegroundColor Yellow
    $deviceCodeBody = @{
        client_id = $ClientId
        scope     = "https://graph.microsoft.com/AgentRegistry.ReadWrite.All"
    }
    $deviceCodeResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/devicecode" `
        -Method Post -Body $deviceCodeBody -ContentType "application/x-www-form-urlencoded"

    Write-Host "`n$($deviceCodeResponse.message)" -ForegroundColor Green
    Write-Host "Waiting for authentication..." -ForegroundColor Yellow

    $pollBody = @{
        client_id   = $ClientId
        grant_type  = "urn:ietf:params:oauth:grant-type:device_code"
        device_code = $deviceCodeResponse.device_code
    }

    $timeout = (Get-Date).AddSeconds($deviceCodeResponse.expires_in)
    $accessToken = $null
    while ((Get-Date) -lt $timeout) {
        Start-Sleep -Seconds $deviceCodeResponse.interval
        try {
            $tokenResponse = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $pollBody -ContentType "application/x-www-form-urlencoded"
            $accessToken = $tokenResponse.access_token
            break
        }
        catch {
            $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($errorDetail.error -eq "authorization_pending") {
                continue
            }
            throw
        }
    }

    if (-not $accessToken) {
        Write-Error "Authentication timed out."
        exit 1
    }
}

Write-Host "Authentication successful." -ForegroundColor Green

# --- POST to Agent Registry ---
$graphUrl = "https://graph.microsoft.com/beta/agentRegistry/agentInstances"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type"  = "application/json"
}

$body = $metadata | ConvertTo-Json -Depth 10

Write-Host "`nRegistering agent '$($metadata.displayName)' in Agent Registry..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $graphUrl -Method Post -Headers $headers -Body $body
    Write-Host "`nAgent registered successfully!" -ForegroundColor Green
    Write-Host "  Agent Instance ID: $($response.id)" -ForegroundColor White
    Write-Host "  Display Name:      $($response.displayName)" -ForegroundColor White
    if ($response.agentCardManifest) {
        Write-Host "  Card Manifest:     Included" -ForegroundColor White
    }
    Write-Host "`nVerify in Entra admin center: Entra ID > Agent identities > Agent Registry" -ForegroundColor Yellow
}
catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    Write-Error "Registration failed (HTTP $statusCode):`n$errorBody"
    exit 1
}
