# Agent Registration Script Documentation

## Overview

The `Register-Agent.ps1` script reads an `agent-metadata.json` file and registers the agent in the Microsoft Entra Agent Registry via the Graph API (`POST /beta/agentRegistry/agentInstances`).

---

## Quick Start

```powershell
# 1. Copy the example and fill in your values
Copy-Item agent-metadata.json.example agent-metadata.json

# 2. Edit agent-metadata.json with your agent details

# 3. Run with interactive login
.\Register-Agent.ps1 -TenantId "contoso.onmicrosoft.com" -ClientId "your-app-client-id"

# 4. Or run with client credentials (app-only)
.\Register-Agent.ps1 -TenantId "contoso.onmicrosoft.com" -ClientId "your-app-client-id" -ClientSecret "your-secret"
```

---

## Entra App Registration Setup

Before using the script, you must create an App Registration in Microsoft Entra ID.

### Steps

1. Go to **Entra admin center** → **Applications** → **App registrations** → **New registration**.
2. Set a name (e.g., `Agent Registry Automation`).
3. Set **Supported account types** to **Accounts in this organizational directory only**.
4. Click **Register**.
5. Note the **Application (client) ID** — this is your `-ClientId` parameter.
6. Note the **Directory (tenant) ID** — this is your `-TenantId` parameter.

### API Permissions

Add the following Microsoft Graph API permission:

| Permission | Type | Description |
|---|---|---|
| `AgentRegistry.ReadWrite.All` | **Application** (for client credentials flow) | Read and write agent registry instances |

> For interactive/delegated flow, add `AgentRegistry.ReadWrite.All` as a **Delegated** permission instead.

After adding the permission, click **Grant admin consent for [your tenant]**.

### Client Secret (for app-only flow)

1. In the App Registration, go to **Certificates & secrets** → **New client secret**.
2. Set a description and expiry.
3. Copy the secret **Value** (not the Secret ID) — this is your `-ClientSecret` parameter.

---

## Least-Privilege Entra Roles

The **user or service principal** running the script needs the following role:

| Role | Purpose | Why It's Needed |
|---|---|---|
| **Agent Registry Administrator** | Register and manage agent instances and manifests | Required to call `POST /beta/agentRegistry/agentInstances` |

No other Entra directory roles are required for registry-only registration (Pattern A).

> **For Pattern B** (full Entra Agent ID): if your metadata includes `agentIdentityBlueprintId` and `agentIdentityId`, the person who created those resources needs the **Agent ID Developer** or **Agent ID Administrator** role. The script itself only performs the registry POST and only needs **Agent Registry Administrator**.

### How to Assign the Role

1. Go to **Entra admin center** → **Roles and administrators**.
2. Search for **Agent Registry Administrator**.
3. Click **Add assignments** → select the user or service principal that will run the script.

---

## agent-metadata.json — Field-by-Field Guide

### Top-Level Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `displayName` | string | ✅ | Human-readable name for the agent. Appears in the Agent Registry inventory. |
| `description` | string | Recommended | Short summary of what the agent does. Shown in the agent card. |
| `ownerIds` | array of strings | ✅ | One or more Microsoft Entra **object IDs** (GUIDs) of the users or groups responsible for this agent. To find a user's object ID: Entra admin center → Users → select user → Overview → Object ID. |
| `url` | string | ✅ | The agent's operational endpoint URL — where the agent receives requests. Must be HTTPS. |
| `originatingStore` | string | ✅ | Identifies where the agent was built. Use `"custom"` for code-built agents. Other values include `"copilotStudio"`, `"foundry"`, etc. |
| `preferredTransport` | string | ✅ | The communication protocol the agent uses. Common values: `"restApi"`, `"graphConnector"`, `"botFramework"`. |

### agentCardManifest (Nested Object)

The `agentCardManifest` contains discovery metadata — what users and admins see when browsing the Agent Registry.

| Field | Type | Required | Description |
|---|---|---|---|
| `displayName` | string | ✅ | Display name shown in the agent catalog. Typically matches the top-level `displayName`. |
| `description` | string | ✅ | Description shown in the agent card. Can be more detailed than the top-level description. |
| `iconUrl` | string | Recommended | HTTPS URL to the agent's icon image. Recommended size: 192×192 px. |
| `documentationUrl` | string | Recommended | URL to the agent's documentation (e.g., a SharePoint page or wiki). |
| `provider.name` | string | ✅ | Name of the team or organization that built the agent. |
| `provider.url` | string | Recommended | URL to the provider's website or intranet page. |
| `skills` | array of objects | Recommended | List of skills the agent provides. Each skill has a `name` (string) and `description` (string). |
| `capabilities` | array of strings | Recommended | High-level capability tags. Examples: `"chat"`, `"searchAnswers"`, `"automation"`, `"dataRetrieval"`. |
| `security.type` | string | ✅ | Authentication scheme. Common values: `"oauth2"`, `"apiKey"`, `"none"`. |
| `security.authorizationUrl` | string | If oauth2 | OAuth 2.0 authorization endpoint. |
| `security.tokenUrl` | string | If oauth2 | OAuth 2.0 token endpoint. |
| `security.scopes` | string | If oauth2 | Space-delimited OAuth 2.0 scopes the agent requires. |
| `protocolVersion` | string | ✅ | Version of the agent protocol. Use `"1.0"`. |
| `version` | string | ✅ | Version of your agent (semantic versioning recommended, e.g., `"1.0.0"`). |

### Optional Fields for Pattern B (Full Entra Agent ID)

If you are using Pattern B (full identity integration), add these top-level fields alongside the others:

| Field | Type | Required | Description |
|---|---|---|---|
| `agentIdentityBlueprintId` | string | Pattern B only | The GUID of the agent identity blueprint created in Entra. |
| `agentIdentityId` | string | Pattern B only | The GUID of the agent identity created from the blueprint. |
| `agentUserId` | string | Optional | The GUID of the agent user, if the agent operates as a specific user identity. |

---

## Script Parameters

| Parameter | Required | Description |
|---|---|---|
| `-MetadataPath` | No | Path to the JSON file. Defaults to `agent-metadata.json` in the script directory. |
| `-TenantId` | Yes | Your Entra tenant ID (GUID or domain name, e.g., `contoso.onmicrosoft.com`). |
| `-ClientId` | Yes | Application (client) ID of the Entra app registration. |
| `-ClientSecret` | No | Client secret for app-only flow. If omitted, uses interactive device code flow. |

---

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `403 Forbidden` | Missing role or API permission | Verify the user/SP has **Agent Registry Administrator** and the app has **AgentRegistry.ReadWrite.All** with admin consent |
| `400 Bad Request` | Invalid metadata JSON | Check required fields; validate JSON syntax |
| `401 Unauthorized` | Token expired or invalid credentials | Re-run the script; check ClientId/TenantId; regenerate client secret if expired |
| `Authentication timed out` | Device code flow not completed in time | Re-run and complete the browser login within 15 minutes |

---

## References

- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/publish-agents-to-registry" target="_blank">Register Agents to the Agent Registry</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint" target="_blank">Create an agent identity blueprint</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-registry-collections" target="_blank">Agent Registry collections</a>
