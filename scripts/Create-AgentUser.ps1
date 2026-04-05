<#
.SYNOPSIS
    Creates an agent's user account linked to an agent identity via Microsoft Graph API.

.DESCRIPTION
    Creates an agent's user account (specialized Entra user object) that is paired 1:1
    with an existing agent identity. The agent's user account enables the agent to access
    systems requiring user identities — mailbox, Teams, calendar, group membership.

    Prerequisites:
      - An agent identity must exist (run Create-AgentIdentity.ps1 first)
      - The blueprint must have the AgentIdUser.ReadWrite.IdentityParentedBy permission granted
      - An admin must have assigned this permission before running this script

.PARAMETER AgentIdentityId
    The object ID of the agent identity (from Create-AgentIdentity.ps1 output).

.PARAMETER DisplayName
    Display name for the agent's user account (e.g., "Task Assistant Agent").

.PARAMETER MailNickname
    Mail nickname (used for email alias). Example: "task-assistant-agent".

.PARAMETER UPN
    User Principal Name for the agent's user account. Example: "task-assistant@contoso.onmicrosoft.com".

.PARAMETER BlueprintAppId
    The appId of the parent agent identity blueprint.

.PARAMETER TenantId
    Your Microsoft Entra tenant ID (GUID or domain name).

.PARAMETER ClientSecret
    Client secret of the blueprint (for dev/test).

.PARAMETER LicenseSkuId
    (Optional) SKU ID of the license to assign (e.g., Microsoft 365 E3/E5). If provided, the
    script assigns the license after creating the user account.

.EXAMPLE
    # Create agent user without license
    .\Create-AgentUser.ps1 -AgentIdentityId "aaaa-..." -DisplayName "Task Assistant" `
        -MailNickname "task-assistant" -UPN "task-assistant@contoso.onmicrosoft.com" `
        -BlueprintAppId "bbbb-..." -TenantId "contoso.onmicrosoft.com" -ClientSecret "secret"

    # Create agent user with license assignment
    .\Create-AgentUser.ps1 -AgentIdentityId "aaaa-..." -DisplayName "Task Assistant" `
        -MailNickname "task-assistant" -UPN "task-assistant@contoso.onmicrosoft.com" `
        -BlueprintAppId "bbbb-..." -TenantId "contoso.onmicrosoft.com" -ClientSecret "secret" `
        -LicenseSkuId "05e9a617-0261-4cee-bb36-b42c3c1bf8b1"

.NOTES
    Requires the beta Microsoft Graph endpoint (preview).
    The blueprint must have AgentIdUser.ReadWrite.IdentityParentedBy permission.
    See docs/identity-blueprint/agent-user-account-guide.md for the full guide.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$AgentIdentityId,

    [Parameter(Mandatory)]
    [string]$DisplayName,

    [Parameter(Mandatory)]
    [string]$MailNickname,

    [Parameter(Mandatory)]
    [string]$UPN,

    [Parameter(Mandatory)]
    [string]$BlueprintAppId,

    [Parameter(Mandatory)]
    [string]$TenantId,

    [Parameter(Mandatory)]
    [string]$ClientSecret,

    [Parameter()]
    [string]$LicenseSkuId
)

$ErrorActionPreference = "Stop"
$graphBase = "https://graph.microsoft.com/beta"
$graphV1 = "https://graph.microsoft.com/v1.0"

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

# --- Create agent's user account ---
Write-Host "`n=== Step 2: Create agent's user account '$DisplayName' ===" -ForegroundColor Cyan

$body = @{
    "@odata.type"     = "#microsoft.graph.agentIdUser"
    displayName       = $DisplayName
    mailNickname      = $MailNickname
    userPrincipalName = $UPN
    agentIdentityId   = $AgentIdentityId
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod -Uri "$graphBase/users" `
    -Method POST -Headers $headers -Body $body

$agentUserId = $response.id
Write-Host "Created agent's user account." -ForegroundColor Green
Write-Host "  Agent User ID: $agentUserId" -ForegroundColor Yellow
Write-Host "  UPN:           $UPN" -ForegroundColor Yellow
Write-Host "  Linked to:     Agent Identity $AgentIdentityId" -ForegroundColor Yellow

# --- Assign license (optional) ---
if ($LicenseSkuId) {
    Write-Host "`n=== Step 3: Assign license ===" -ForegroundColor Cyan
    Write-Host "Waiting 30 seconds for user provisioning..." -ForegroundColor Gray
    Start-Sleep -Seconds 30

    # License assignment uses admin token (v1.0 endpoint)
    # Re-acquire token or use existing — blueprint token may work if it has User.ReadWrite.All
    $licenseBody = @{
        addLicenses = @(
            @{ skuId = $LicenseSkuId }
        )
        removeLicenses = @()
    } | ConvertTo-Json -Depth 5

    try {
        Invoke-RestMethod -Uri "$graphV1/users/$agentUserId/assignLicense" `
            -Method POST -Headers $headers -Body $licenseBody
        Write-Host "License assigned: $LicenseSkuId" -ForegroundColor Green
    }
    catch {
        Write-Warning "License assignment failed: $($_.Exception.Message)"
        Write-Host "You can assign the license manually in M365 admin center → Users → Active users → $DisplayName → Licenses" -ForegroundColor Yellow
    }
}

# --- Summary ---
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Agent User ID:     $agentUserId" -ForegroundColor White
Write-Host "UPN:               $UPN" -ForegroundColor White
Write-Host "Agent Identity ID: $AgentIdentityId" -ForegroundColor White
Write-Host "Blueprint:         $BlueprintAppId" -ForegroundColor White
if ($LicenseSkuId) {
    Write-Host "License:           $LicenseSkuId" -ForegroundColor White
}
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Wait a few minutes for mailbox/Teams provisioning" -ForegroundColor White
Write-Host "  2. Add the agent to a Team: POST /v1.0/teams/{team-id}/members" -ForegroundColor White
Write-Host "  3. Register in Agent Registry: add agentUserId='$agentUserId' to agent-metadata.json" -ForegroundColor White
Write-Host "  4. See docs/Use-Case-Teams-Chat-via-Agent-User-Account.md for the full Teams chat guide" -ForegroundColor White
