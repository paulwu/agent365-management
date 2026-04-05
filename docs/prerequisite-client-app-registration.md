# Prerequisite: Client App Registration

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

Before using the **Agent 365 CLI** (`a365`), the **repository scripts** (`Create-Blueprint.ps1`), or the **`@blueprint-creator`** Copilot agent, you need a custom client app registration in Microsoft Entra ID. This app registration provides the Client ID used for interactive authentication.

> This is a one-time setup per tenant. Once created, reuse the same Client ID for all agent identity operations.

<details>
<summary><strong>📑 Table of Contents</strong></summary>

- [Who Needs This](#who-needs-this)
- [Step 1: Register the Application](#step-1-register-the-application)
- [Step 2: Set Redirect URIs](#step-2-set-redirect-uris)
- [Step 3: Copy the Application (Client) ID](#step-3-copy-the-application-client-id)
- [Step 4: Configure API Permissions](#step-4-configure-api-permissions)
  - [Option A: Via Microsoft Entra Admin Center](#option-a-via-microsoft-entra-admin-center)
  - [Option B: Via Microsoft Graph API (for beta permissions)](#option-b-via-microsoft-graph-api-for-beta-permissions)
- [Step 5: Grant Admin Consent](#step-5-grant-admin-consent)
- [Using Your Client ID](#using-your-client-id)

</details>

---

## Who Needs This

| Tool | Requires Client App Registration? |
|---|---|
| **Agent 365 CLI** (`a365 config init`) | ✅ Yes — prompted for Client App ID during init |
| **Repository script** (`Create-Blueprint.ps1 -ClientId`) | ✅ Yes — passed as `-ClientId` parameter |
| **`@blueprint-creator`** Copilot agent | ✅ Yes — collects Client ID at Step 5 |
| **Microsoft Graph API** (direct HTTP calls) | ❌ No — you authenticate with your own token method |

---

## Step 1: Register the Application

1. Go to the **[Microsoft Entra admin center](https://entra.microsoft.com/)**.
2. Navigate to **Identity → Applications → App registrations**.
3. Select **New registration**.
4. Fill in:
   - **Name**: A meaningful name, e.g., `Agent365-CLI-Client` or `Blueprint-Creator-Client`.
   - **Supported account types**: **Accounts in this organizational directory only** (single tenant).
   - **Redirect URI**: Select **Public client/native (mobile & desktop)** and enter `http://localhost:8400/`.
5. Select **Register**.

---

## Step 2: Set Redirect URIs

The CLI and scripts require additional redirect URIs. Add them now:

1. In your app registration, go to **Authentication**.
2. Under **Mobile and desktop applications**, add these URIs:

| URI | Purpose |
|---|---|
| `http://localhost:8400/` | MSAL interactive browser authentication (added in Step 1) |
| `http://localhost` | Microsoft Graph PowerShell SDK `Connect-MgGraph` |
| `ms-appx-web://Microsoft.AAD.BrokerPlugin/{client-id}` | Web Account Manager (WAM) — replace `{client-id}` with your Application (client) ID |

3. Under **Advanced settings**, enable **Allow public client flows** (set to **Yes**).
4. Select **Save**.

> **Note:** The Agent 365 CLI can auto-add missing redirect URIs during `a365 config init` if you approve the prompt.

---

## Step 3: Copy the Application (Client) ID

1. Go to your app registration's **Overview** page.
2. Copy the **Application (client) ID** (a GUID like `12345678-abcd-efgh-ijkl-1234567890ab`).
3. Save this value — you will use it in the next steps.

> **Important:** This is the **Application (client) ID**, not the Object ID.

---

## Step 4: Configure API Permissions

Add these **delegated** permissions (NOT application permissions):

| Permission | Purpose |
|---|---|
| `Application.ReadWrite.All` | Create and manage applications and blueprints |
| `AgentIdentityBlueprint.ReadWrite.All` | Manage blueprint configurations (beta) |
| `AgentIdentityBlueprint.UpdateAuthProperties.All` | Update blueprint inheritable permissions (beta) |
| `AgentIdentityBlueprint.AddRemoveCreds.All` | Add credentials to blueprints |
| `DelegatedPermissionGrant.ReadWrite.All` | Grant permissions for blueprints |
| `Directory.Read.All` | Read directory data for validation |

> **Why Delegated?** You sign in interactively and the CLI/script acts on your behalf. Application permissions are for background services only.

### Option A: Via Microsoft Entra Admin Center

1. In your app registration, go to **API permissions**.
2. Select **Add a permission → Microsoft Graph → Delegated permissions**.
3. Search for and add each permission listed above.
4. Select **Grant admin consent for [Your Tenant]**.
5. Verify all permissions show green checkmarks.

> **Note:** The `AgentIdentityBlueprint.*` permissions are beta APIs and may not appear in the admin center. If they don't appear, use Option B.

### Option B: Via Microsoft Graph API (for beta permissions)

Use this if the beta permissions aren't visible in the admin center.

1. Open **[Graph Explorer](https://developer.microsoft.com/graph/graph-explorer)** and sign in with an admin account.

2. Get your service principal ID:

   ```http
   GET https://graph.microsoft.com/v1.0/servicePrincipals?$filter=appId eq '{your-client-app-id}'&$select=id
   ```

   Copy the `id` value — this is your `{sp-object-id}`.

3. Get the Microsoft Graph resource ID:

   ```http
   GET https://graph.microsoft.com/v1.0/servicePrincipals?$filter=appId eq '00000003-0000-0000-c000-000000000000'&$select=id
   ```

   Copy the `id` value — this is your `{graph-resource-id}`.

4. Grant all permissions with admin consent:

   ```http
   POST https://graph.microsoft.com/v1.0/oauth2PermissionGrants

   {
     "clientId": "{sp-object-id}",
     "consentType": "AllPrincipals",
     "principalId": null,
     "resourceId": "{graph-resource-id}",
     "scope": "Application.ReadWrite.All Directory.Read.All DelegatedPermissionGrant.ReadWrite.All AgentIdentityBlueprint.ReadWrite.All AgentIdentityBlueprint.UpdateAuthProperties.All"
   }
   ```

> ⚠️ **Warning:** After using the API method, do NOT click "Grant admin consent" in the Entra admin center — it overwrites API-granted beta permissions with only the visible ones.

---

## Step 5: Grant Admin Consent

If you used Option A, admin consent is granted via the button in the admin center.

If you used Option B, admin consent is already included in the `POST` call (`consentType: "AllPrincipals"`).

**Required role:** Application Administrator, Cloud Application Administrator, or Global Administrator.

> **Don't have admin access?** Complete Steps 1–3 yourself, then send your Application (client) ID to your tenant admin and ask them to complete Step 4.

---

## Using Your Client ID

Once created, use the Client ID with your preferred tool:

**Agent 365 CLI:**

```shell
a365 config init
# When prompted for "Client App ID", enter your Application (client) ID
```

**Repository script:**

```powershell
pwsh -File ./scripts/Create-Blueprint.ps1 -TenantId "contoso.onmicrosoft.com" -ClientId "{your-client-id}"
```

**`@blueprint-creator` Copilot agent:**

```text
@blueprint-creator I want to create a new agent identity blueprint
# The wizard will ask for your Client ID at Step 5
```

---

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/custom-client-app-registration" target="_blank">Custom client app registration for Agent 365 CLI</a>
- <a href="https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app" target="_blank">Register an application with the Microsoft identity platform</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/agent-365-cli" target="_blank">Agent 365 CLI</a>
