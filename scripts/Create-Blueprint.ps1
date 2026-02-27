<#
.SYNOPSIS
    Creates an agent identity blueprint in Microsoft Entra ID via Microsoft Graph API.

.DESCRIPTION
    Reads blueprint configuration from a JSON file and performs the full blueprint
    creation sequence:
      1. Create the agent identity blueprint (with sponsor and owner)
      2. Configure credentials (managed identity FIC or client secret)
      3. Optionally configure identifier URI and OAuth scope (required for interactive/OBO agents)
      4. Create the blueprint principal (per-tenant service principal)

    Outputs the blueprint appId and object ID — supply these to Create-Agent-Identity and
    Register-Agent.ps1 for the next steps.

.PARAMETER InputPath
    Path to the blueprint input JSON file. Defaults to blueprint-input.json in the same directory.

.PARAMETER TenantId
    Your Microsoft Entra tenant ID (GUID or domain name).

.PARAMETER ClientId
    Application (client) ID of the Entra app registration used to authenticate this script.
    Requires delegated permissions:
      AgentIdentityBlueprint.Create, AgentIdentityBlueprint.AddRemoveCreds.All,
      AgentIdentityBlueprint.ReadWrite.All, AgentIdentityBlueprintPrincipal.Create

.PARAMETER ClientSecret
    (Optional) Client secret for app-only flow. If omitted, uses interactive device code flow.

.EXAMPLE
    # Interactive login
    .\Create-Blueprint.ps1 -TenantId "contoso.onmicrosoft.com" -ClientId "12345678-..."

    # App-only
    .\Create-Blueprint.ps1 -TenantId "contoso.onmicrosoft.com" -ClientId "12345678-..." -ClientSecret "your-secret"

.NOTES
    Requires the beta Microsoft Graph endpoint (preview).
    See docs/developer-identity-platform.md for the full step-by-step guide.
    Use the output appId as agentIdentityBlueprintId in agent-metadata.json for Register-Agent.ps1.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$InputPath = (Join-Path $PSScriptRoot "blueprint-input.json"),

    [Parameter(Mandatory)]
    [string]$TenantId,

    [Parameter(Mandatory)]
    [string]$ClientId,

    [Parameter()]
    [string]$ClientSecret
)

$ErrorActionPreference = "Stop"
$graphBase = "https://graph.microsoft.com/beta"

# --- Load and validate input ---
if (-not (Test-Path $InputPath)) {
    Write-Error "Blueprint input file not found: $InputPath`nCopy blueprint-input.json.example and fill in your values."
    exit 1
}

$config = Get-Content $InputPath -Raw | ConvertFrom-Json
Write-Host "Loaded blueprint config: $($config.displayName)" -ForegroundColor Cyan

foreach ($field in @("displayName", "sponsorUserIds")) {
    if (-not $config.$field) {
        Write-Error "Required field '$field' is missing in $InputPath"
        exit 1
    }
}
if ($config.sponsorUserIds.Count -eq 0) {
    Write-Error "sponsorUserIds must contain at least one Entra user object ID."
    exit 1
}

# --- Acquire access token ---
$tokenEndpoint = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

if ($ClientSecret) {
    Write-Host "Authenticating with client credentials flow..." -ForegroundColor Yellow
    $tokenBody = @{
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = "https://graph.microsoft.com/.default"
        grant_type    = "client_credentials"
    }
    $tokenResponse = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $tokenBody -ContentType "application/x-www-form-urlencoded"
    $accessToken = $tokenResponse.access_token
}
else {
    Write-Host "Authenticating with device code flow (interactive)..." -ForegroundColor Yellow
    $deviceCodeBody = @{
        client_id = $ClientId
        scope     = "AgentIdentityBlueprint.Create AgentIdentityBlueprint.AddRemoveCreds.All AgentIdentityBlueprint.ReadWrite.All AgentIdentityBlueprintPrincipal.Create User.Read"
    }
    $dcResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/devicecode" `
        -Method Post -Body $deviceCodeBody -ContentType "application/x-www-form-urlencoded"
    Write-Host "`n$($dcResponse.message)" -ForegroundColor Green

    $pollBody = @{
        client_id   = $ClientId
        grant_type  = "urn:ietf:params:oauth:grant-type:device_code"
        device_code = $dcResponse.device_code
    }
    $timeout = (Get-Date).AddSeconds($dcResponse.expires_in)
    $accessToken = $null
    while ((Get-Date) -lt $timeout) {
        Start-Sleep -Seconds $dcResponse.interval
        try {
            $tokenResponse = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $pollBody -ContentType "application/x-www-form-urlencoded"
            $accessToken = $tokenResponse.access_token
            break
        }
        catch {
            $err = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($err.error -eq "authorization_pending") { continue }
            throw
        }
    }
    if (-not $accessToken) { Write-Error "Authentication timed out."; exit 1 }
}

Write-Host "Authentication successful." -ForegroundColor Green

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type"  = "application/json"
    "OData-Version" = "4.0"
}

# --- Step 1: Create the blueprint ---
Write-Host "`n[1/4] Creating agent identity blueprint..." -ForegroundColor Cyan

$blueprintBody = [ordered]@{
    "@odata.type" = "Microsoft.Graph.AgentIdentityBlueprint"
    "displayName" = $config.displayName
    "sponsors@odata.bind" = @($config.sponsorUserIds | ForEach-Object { "https://graph.microsoft.com/v1.0/users/$_" })
}

if ($config.ownerUserIds -and $config.ownerUserIds.Count -gt 0) {
    $blueprintBody["owners@odata.bind"] = @($config.ownerUserIds | ForEach-Object { "https://graph.microsoft.com/v1.0/users/$_" })
}

$blueprint = Invoke-RestMethod -Uri "$graphBase/applications/" -Method Post -Headers $headers -Body ($blueprintBody | ConvertTo-Json -Depth 5)
$blueprintAppId = $blueprint.appId
$blueprintObjectId = $blueprint.id

Write-Host "  Blueprint created: $blueprintAppId" -ForegroundColor Green

# --- Step 2: Configure credentials ---
Write-Host "[2/4] Configuring credentials..." -ForegroundColor Cyan

if ($config.credentials.type -eq "managedIdentity") {
    $credBody = @{
        name      = $config.credentials.name ?? "managed-identity"
        issuer    = "https://login.microsoftonline.com/$TenantId/v2.0"
        subject   = $config.credentials.managedIdentityPrincipalId
        audiences = @("api://AzureADTokenExchange")
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$graphBase/applications/$blueprintAppId/federatedIdentityCredentials" `
        -Method Post -Headers $headers -Body $credBody | Out-Null
    Write-Host "  Managed identity FIC configured." -ForegroundColor Green
}
else {
    # Client secret (dev/test)
    $endDate = $config.credentials.secretExpiryDate ?? (Get-Date).AddMonths(6).ToString("yyyy-MM-ddTHH:mm:ssZ")
    $secretBody = @{
        passwordCredential = @{
            displayName = $config.credentials.name ?? "Dev Secret"
            endDateTime = $endDate
        }
    } | ConvertTo-Json
    $secretResult = Invoke-RestMethod -Uri "$graphBase/applications/$blueprintAppId/addPassword" `
        -Method Post -Headers $headers -Body $secretBody
    Write-Host "  Client secret created. SECRET VALUE (save now — not shown again):" -ForegroundColor Yellow
    Write-Host "  $($secretResult.secretText)" -ForegroundColor White
}

# --- Step 3: Configure identifier URI and scope (optional, required for interactive/OBO agents) ---
if ($config.exposeScope -eq $true) {
    Write-Host "[3/4] Configuring identifier URI and OAuth scope..." -ForegroundColor Cyan
    $scopeId = [guid]::NewGuid().ToString()
    $uriBody = @{
        identifierUris = @("api://$blueprintAppId")
        api            = @{
            oauth2PermissionScopes = @(@{
                adminConsentDescription = "Allow the application to access the agent on behalf of the signed-in user."
                adminConsentDisplayName = "Access agent"
                id                      = $scopeId
                isEnabled               = $true
                type                    = "User"
                value                   = "access_agent"
            })
        }
    } | ConvertTo-Json -Depth 5
    Invoke-RestMethod -Uri "$graphBase/applications/$blueprintAppId" -Method Patch -Headers $headers -Body $uriBody | Out-Null
    Write-Host "  Identifier URI and scope configured (scope ID: $scopeId)." -ForegroundColor Green
}
else {
    Write-Host "[3/4] Skipping scope configuration (exposeScope is false or not set)." -ForegroundColor DarkGray
}

# --- Step 4: Create blueprint principal ---
Write-Host "[4/4] Creating blueprint principal..." -ForegroundColor Cyan

$principalBody = @{ appId = $blueprintAppId } | ConvertTo-Json
Invoke-RestMethod -Uri "$graphBase/serviceprincipals/graph.agentIdentityBlueprintPrincipal" `
    -Method Post -Headers $headers -Body $principalBody | Out-Null

Write-Host "  Blueprint principal created." -ForegroundColor Green

# --- Summary ---
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Blueprint creation complete!" -ForegroundColor Green
Write-Host "  Display Name:  $($config.displayName)"
Write-Host "  App ID:        $blueprintAppId"
Write-Host "  Object ID:     $blueprintObjectId"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nNext steps:"
Write-Host "  1. Create agent identities from this blueprint (see docs/developer-identity-platform.md)"
Write-Host "  2. Add agentIdentityBlueprintId = '$blueprintAppId' to your agent-metadata.json"
Write-Host "  3. Run Register-Agent.ps1 to register the agent in the Agent Registry"
Write-Host "`nVerify in Entra admin center: Entra ID > Agent identities > Blueprints" -ForegroundColor Yellow
