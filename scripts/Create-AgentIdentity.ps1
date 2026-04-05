<#
.SYNOPSIS
    Creates an agent identity from an agent identity blueprint via Microsoft Graph API.

.DESCRIPTION
    Creates one or more agent identities under an existing agent identity blueprint.
    Each agent identity is a specialized service principal with no independent credentials —
    it authenticates via its parent blueprint.

    Prerequisites:
      - An agent identity blueprint must already exist (run Create-Blueprint.ps1 first)
      - A blueprint token is needed (the script acquires this using the blueprint's credentials)

.PARAMETER BlueprintAppId
    The appId of the agent identity blueprint (from Create-Blueprint.ps1 output).

.PARAMETER DisplayName
    Display name for the new agent identity (e.g., "Sales Assistant NA").

.PARAMETER SponsorUserId
    GUID of the user to assign as sponsor for the agent identity.

.PARAMETER TenantId
    Your Microsoft Entra tenant ID (GUID or domain name).

.PARAMETER ClientSecret
    Client secret of the blueprint (for dev/test). For production, use managed identity.

.PARAMETER Count
    Number of agent identities to create (default: 1).

.EXAMPLE
    # Create a single agent identity
    .\Create-AgentIdentity.ps1 -BlueprintAppId "aaaa-bbbb-..." -DisplayName "Sales Agent NA" `
        -SponsorUserId "cccc-dddd-..." -TenantId "contoso.onmicrosoft.com" -ClientSecret "secret"

    # Create multiple identities
    .\Create-AgentIdentity.ps1 -BlueprintAppId "aaaa-bbbb-..." -DisplayName "Sales Agent" `
        -SponsorUserId "cccc-dddd-..." -TenantId "contoso.onmicrosoft.com" -ClientSecret "secret" -Count 3

.NOTES
    Requires the beta Microsoft Graph endpoint (preview).
    Output: agentIdentityId for each created identity — use in agent-metadata.json or Create-AgentUser.ps1.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$BlueprintAppId,

    [Parameter(Mandatory)]
    [string]$DisplayName,

    [Parameter(Mandatory)]
    [string]$SponsorUserId,

    [Parameter(Mandatory)]
    [string]$TenantId,

    [Parameter(Mandatory)]
    [string]$ClientSecret,

    [Parameter()]
    [int]$Count = 1
)

$ErrorActionPreference = "Stop"
$graphBase = "https://graph.microsoft.com/beta"

# --- Acquire blueprint token ---
Write-Host "`n=== Step 1: Acquire blueprint token ===" -ForegroundColor Cyan
$tokenBody = @{
    client_id     = $BlueprintAppId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $ClientSecret
    grant_type    = "client_credentials"
}
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
    -Method POST -ContentType "application/x-www-form-urlencoded" -Body $tokenBody
$token = $tokenResponse.access_token
Write-Host "Blueprint token acquired." -ForegroundColor Green

$headers = @{
    "Authorization"  = "Bearer $token"
    "Content-Type"   = "application/json"
    "OData-Version"  = "4.0"
}

# --- Create agent identities ---
$createdIds = @()
for ($i = 1; $i -le $Count; $i++) {
    $name = if ($Count -eq 1) { $DisplayName } else { "$DisplayName $i" }
    Write-Host "`n=== Step 2.$i: Create agent identity '$name' ===" -ForegroundColor Cyan

    $body = @{
        displayName = $name
        agentIdentityBlueprintId = $BlueprintAppId
        "sponsors@odata.bind" = @(
            "https://graph.microsoft.com/v1.0/users/$SponsorUserId"
        )
    } | ConvertTo-Json -Depth 5

    $response = Invoke-RestMethod -Uri "$graphBase/serviceprincipals/Microsoft.Graph.AgentIdentity" `
        -Method POST -Headers $headers -Body $body

    $agentId = $response.id
    $createdIds += $agentId
    Write-Host "Created agent identity: $name" -ForegroundColor Green
    Write-Host "  Agent Identity ID: $agentId" -ForegroundColor Yellow
    Write-Host "  App ID:            $($response.appId)" -ForegroundColor Yellow
}

# --- Summary ---
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Blueprint:           $BlueprintAppId" -ForegroundColor White
Write-Host "Identities created:  $Count" -ForegroundColor White
foreach ($id in $createdIds) {
    Write-Host "  Agent Identity ID: $id" -ForegroundColor Yellow
}
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. (Optional) Create an agent's user account: .\Create-AgentUser.ps1 -AgentIdentityId '$($createdIds[0])' ..." -ForegroundColor White
Write-Host "  2. Register in Agent Registry: add agentIdentityId to agent-metadata.json, then run .\Register-Agent.ps1" -ForegroundColor White
Write-Host "  3. See docs/identity-blueprint/agent-identity-hierarchy.md for the full object hierarchy." -ForegroundColor White
