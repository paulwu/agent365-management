<#
.SYNOPSIS
    Discovers shadow and rogue AI agents in Microsoft Entra ID.

.DESCRIPTION
    Scans the tenant for AI agents that may not appear in the Agent 365 Registry by:
    1. Querying service principals with agent-related tags (AgenticInstance, AgenticApp, power-virtual-agents-*)
    2. Identifying app registrations with no owner (orphaned agents)
    3. Identifying app registrations with high-privilege API permissions
    4. Checking for stale credentials (expired secrets/certificates)
    5. Reviewing recent service principal sign-in activity for unknown agents

    Outputs a CSV report of all discovered agents with risk indicators.

.PARAMETER OutputPath
    Path for the output CSV report. Defaults to shadow-agents-report.csv in the script directory.

.PARAMETER DaysInactive
    Number of days to consider an agent "stale" if it has no sign-in activity. Default: 90.

.PARAMETER IncludeSignIns
    If specified, also queries sign-in logs for recent agent activity (requires AuditLog.Read.All).

.EXAMPLE
    # Basic discovery
    .\Discover-ShadowAgents.ps1

    # Include sign-in analysis, output to specific path
    .\Discover-ShadowAgents.ps1 -IncludeSignIns -OutputPath "C:\Reports\agents.csv"

.NOTES
    Required Microsoft Graph PowerShell SDK module: Microsoft.Graph.Authentication
    Required permissions: Application.Read.All, Directory.Read.All
    Optional permissions: AuditLog.Read.All (for -IncludeSignIns)
    Minimum Entra role: Global Reader (read-only discovery)
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputPath = (Join-Path $PSScriptRoot "shadow-agents-report.csv"),

    [Parameter()]
    [int]$DaysInactive = 90,

    [Parameter()]
    [switch]$IncludeSignIns
)

$ErrorActionPreference = "Stop"

# --- High-privilege permissions to flag ---
$highRiskPermissions = @(
    "Directory.ReadWrite.All",
    "Application.ReadWrite.All",
    "AppRoleAssignment.ReadWrite.All",
    "RoleManagement.ReadWrite.Directory",
    "Mail.ReadWrite",
    "Mail.Send",
    "Files.ReadWrite.All",
    "Sites.ReadWrite.All",
    "User.ReadWrite.All",
    "Group.ReadWrite.All",
    "Chat.ReadWrite.All"
)

# --- Connect to Microsoft Graph ---
$scopes = @("Application.Read.All", "Directory.Read.All")
if ($IncludeSignIns) { $scopes += "AuditLog.Read.All" }

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes $scopes -NoWelcome
$context = Get-MgContext
Write-Host "Connected to tenant: $($context.TenantId)" -ForegroundColor Green

$report = [System.Collections.Generic.List[PSObject]]::new()

# ============================================================
# CHECK 1: Service principals with agent-related tags
# ============================================================
Write-Host "`n[1/5] Scanning for service principals with agent tags..." -ForegroundColor Yellow

$agentTagFilters = @(
    "tags/Any(p: startswith(p, 'power-virtual-agents-'))",
    "tags/Any(p: p eq 'AgenticInstance')",
    "tags/Any(p: p eq 'AgenticApp')"
)

foreach ($filter in $agentTagFilters) {
    $url = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=$filter&`$select=id,displayName,appId,tags,createdDateTime,appOwnerOrganizationId&`$top=999"
    try {
        $response = Invoke-MgGraphRequest -Method Get -Uri $url
        foreach ($sp in $response.value) {
            $report.Add([PSCustomObject]@{
                DisplayName     = $sp.displayName
                AppId           = $sp.appId
                ObjectId        = $sp.id
                Type            = "Tagged Agent SP"
                Tags            = ($sp.tags -join "; ")
                CreatedDate     = $sp.createdDateTime
                OwnerTenantId   = $sp.appOwnerOrganizationId
                RiskIndicators  = "Agent tag detected"
                Permissions     = ""
                LastSignIn      = ""
                HasOwner        = ""
            })
        }
    }
    catch {
        Write-Warning "Tag filter query failed: $_"
    }
}
Write-Host "  Found $($report.Count) tagged agent service principals." -ForegroundColor White

# ============================================================
# CHECK 2: App registrations with no owner
# ============================================================
Write-Host "`n[2/5] Scanning for ownerless app registrations..." -ForegroundColor Yellow

$ownerlessCount = 0
$apps = Invoke-MgGraphRequest -Method Get -Uri "https://graph.microsoft.com/v1.0/applications?`$select=id,displayName,appId,createdDateTime&`$top=999"

foreach ($app in $apps.value) {
    $owners = Invoke-MgGraphRequest -Method Get -Uri "https://graph.microsoft.com/v1.0/applications/$($app.id)/owners?`$select=id" -ErrorAction SilentlyContinue
    if (-not $owners.value -or $owners.value.Count -eq 0) {
        $ownerlessCount++
        # Check if already in report
        $existing = $report | Where-Object { $_.AppId -eq $app.appId }
        if ($existing) {
            $existing.HasOwner = "NO"
            $existing.RiskIndicators += "; No owner"
        }
        else {
            $report.Add([PSCustomObject]@{
                DisplayName     = $app.displayName
                AppId           = $app.appId
                ObjectId        = $app.id
                Type            = "Ownerless App Registration"
                Tags            = ""
                CreatedDate     = $app.createdDateTime
                OwnerTenantId   = ""
                RiskIndicators  = "No owner"
                Permissions     = ""
                LastSignIn      = ""
                HasOwner        = "NO"
            })
        }
    }
}
Write-Host "  Found $ownerlessCount ownerless app registrations." -ForegroundColor White

# ============================================================
# CHECK 3: Apps with high-privilege permissions
# ============================================================
Write-Host "`n[3/5] Scanning for high-privilege API permissions..." -ForegroundColor Yellow

$highPrivCount = 0
# Get Microsoft Graph service principal to resolve permission names
$graphSp = Invoke-MgGraphRequest -Method Get -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0000-c000-000000000000'&`$select=id,appRoles,oauth2PermissionScopes"
$graphSpId = $graphSp.value[0].id
$appRolesMap = @{}
foreach ($role in $graphSp.value[0].appRoles) {
    $appRolesMap[$role.id] = $role.value
}

$allSps = Invoke-MgGraphRequest -Method Get -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$select=id,displayName,appId&`$top=999"

foreach ($sp in $allSps.value) {
    try {
        $assignments = Invoke-MgGraphRequest -Method Get -Uri "https://graph.microsoft.com/v1.0/servicePrincipals/$($sp.id)/appRoleAssignments?`$select=appRoleId,resourceId" -ErrorAction SilentlyContinue
        $flaggedPerms = @()
        foreach ($assignment in $assignments.value) {
            if ($assignment.resourceId -eq $graphSpId) {
                $permName = $appRolesMap[$assignment.appRoleId]
                if ($permName -and $highRiskPermissions -contains $permName) {
                    $flaggedPerms += $permName
                }
            }
        }
        if ($flaggedPerms.Count -gt 0) {
            $highPrivCount++
            $existing = $report | Where-Object { $_.AppId -eq $sp.appId }
            if ($existing) {
                $existing.Permissions = ($flaggedPerms -join "; ")
                $existing.RiskIndicators += "; High-privilege permissions"
            }
            else {
                $report.Add([PSCustomObject]@{
                    DisplayName     = $sp.displayName
                    AppId           = $sp.appId
                    ObjectId        = $sp.id
                    Type            = "High-Privilege App"
                    Tags            = ""
                    CreatedDate     = ""
                    OwnerTenantId   = ""
                    RiskIndicators  = "High-privilege permissions"
                    Permissions     = ($flaggedPerms -join "; ")
                    LastSignIn      = ""
                    HasOwner        = ""
                })
            }
        }
    }
    catch { }
}
Write-Host "  Found $highPrivCount apps with high-privilege permissions." -ForegroundColor White

# ============================================================
# CHECK 4: Apps with expired or expiring credentials
# ============================================================
Write-Host "`n[4/5] Scanning for stale or expired credentials..." -ForegroundColor Yellow

$staleCount = 0
$now = Get-Date
$allApps = Invoke-MgGraphRequest -Method Get -Uri "https://graph.microsoft.com/v1.0/applications?`$select=id,displayName,appId,passwordCredentials,keyCredentials&`$top=999"

foreach ($app in $allApps.value) {
    $hasExpired = $false
    $allExpired = $true

    $creds = @()
    if ($app.passwordCredentials) { $creds += $app.passwordCredentials }
    if ($app.keyCredentials) { $creds += $app.keyCredentials }

    if ($creds.Count -eq 0) { continue }

    foreach ($cred in $creds) {
        if ($cred.endDateTime -and [DateTime]$cred.endDateTime -lt $now) {
            $hasExpired = $true
        }
        else {
            $allExpired = $false
        }
    }

    if ($hasExpired) {
        $staleCount++
        $riskNote = if ($allExpired) { "All credentials expired" } else { "Some credentials expired" }
        $existing = $report | Where-Object { $_.AppId -eq $app.appId }
        if ($existing) {
            $existing.RiskIndicators += "; $riskNote"
        }
        else {
            $report.Add([PSCustomObject]@{
                DisplayName     = $app.displayName
                AppId           = $app.appId
                ObjectId        = $app.id
                Type            = "Stale Credentials"
                Tags            = ""
                CreatedDate     = ""
                OwnerTenantId   = ""
                RiskIndicators  = $riskNote
                Permissions     = ""
                LastSignIn      = ""
                HasOwner        = ""
            })
        }
    }
}
Write-Host "  Found $staleCount apps with expired credentials." -ForegroundColor White

# ============================================================
# CHECK 5: Recent service principal sign-ins (optional)
# ============================================================
if ($IncludeSignIns) {
    Write-Host "`n[5/5] Querying service principal sign-in logs..." -ForegroundColor Yellow

    $sinceDate = (Get-Date).AddDays(-30).ToString("yyyy-MM-ddTHH:mm:ssZ")
    try {
        $url = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=signInEventTypes/any(t: t eq 'servicePrincipal') and createdDateTime ge $sinceDate&`$top=500&`$orderby=createdDateTime desc&`$select=appDisplayName,appId,resourceDisplayName,ipAddress,createdDateTime,status"
        $signIns = Invoke-MgGraphRequest -Method Get -Uri $url

        $signInsByApp = @{}
        foreach ($si in $signIns.value) {
            if (-not $signInsByApp.ContainsKey($si.appId)) {
                $signInsByApp[$si.appId] = $si.createdDateTime
            }
        }

        # Update report entries with sign-in data
        foreach ($entry in $report) {
            if ($signInsByApp.ContainsKey($entry.AppId)) {
                $entry.LastSignIn = $signInsByApp[$entry.AppId]
            }
        }

        # Find active service principals NOT in our report (potential unknown agents)
        $unknownActive = $signIns.value | Where-Object {
            $_.appId -and -not ($report | Where-Object { $_.AppId -eq $_.appId })
        } | Select-Object -Property appId, appDisplayName -Unique | Select-Object -First 50

        Write-Host "  Processed $($signIns.value.Count) sign-in events." -ForegroundColor White
    }
    catch {
        Write-Warning "Sign-in log query failed (requires AuditLog.Read.All): $_"
    }
}
else {
    Write-Host "`n[5/5] Skipping sign-in log analysis (use -IncludeSignIns to enable)." -ForegroundColor DarkGray
}

# ============================================================
# OUTPUT REPORT
# ============================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Discovery Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total items found: $($report.Count)" -ForegroundColor White

if ($report.Count -gt 0) {
    $report | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "Report saved to: $OutputPath" -ForegroundColor Green

    # Summary by risk type
    Write-Host "`nSummary:" -ForegroundColor Yellow
    $taggedAgents = ($report | Where-Object { $_.RiskIndicators -match "Agent tag" }).Count
    $ownerless = ($report | Where-Object { $_.RiskIndicators -match "No owner" }).Count
    $highPriv = ($report | Where-Object { $_.RiskIndicators -match "High-privilege" }).Count
    $staleCreds = ($report | Where-Object { $_.RiskIndicators -match "expired" }).Count

    Write-Host "  Agent-tagged service principals: $taggedAgents" -ForegroundColor White
    Write-Host "  Ownerless app registrations:     $ownerless" -ForegroundColor $(if ($ownerless -gt 0) { "Red" } else { "White" })
    Write-Host "  High-privilege apps:             $highPriv" -ForegroundColor $(if ($highPriv -gt 0) { "Red" } else { "White" })
    Write-Host "  Stale/expired credentials:       $staleCreds" -ForegroundColor $(if ($staleCreds -gt 0) { "Yellow" } else { "White" })

    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "  1. Cross-reference tagged agents against your Agent Registry inventory" -ForegroundColor White
    Write-Host "  2. Assign owners to ownerless apps or remove if unnecessary" -ForegroundColor White
    Write-Host "  3. Review and reduce high-privilege permissions" -ForegroundColor White
    Write-Host "  4. Rotate or remove expired credentials" -ForegroundColor White
    Write-Host "  5. Onboard legitimate shadow agents into the Agent Registry" -ForegroundColor White
}
else {
    Write-Host "No shadow agents or risk indicators found." -ForegroundColor Green
}

Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
