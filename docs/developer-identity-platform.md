# Developer Guide: Agent Identity Platform

This guide covers the core identity constructs, OAuth flows, and Graph API operations that developers need to build agents that integrate with Microsoft Entra Agent ID.

If you want the conceptual version before diving into the Graph steps, start with the [Identity Blueprint Guide](./identity-blueprint/README.md). The most useful companion pages for this document are [What is an identity blueprint?](./identity-blueprint/what-is-an-identity-blueprint.md), [Blueprint contents explainer](./identity-blueprint/blueprint-contents-explainer.md), and [How blueprints are used](./identity-blueprint/how-blueprints-are-used.md).

<details>
<summary><strong>📑 Table of Contents</strong></summary>

- [Identity hierarchy](#identity-hierarchy)
- [Required roles and permissions](#required-roles-and-permissions)
- [Creating an agent identity blueprint](#creating-an-agent-identity-blueprint)
  - [1. Connect with required scopes (PowerShell)](#1-connect-with-required-scopes-powershell)
  - [2. Create the blueprint (Graph API)](#2-create-the-blueprint-graph-api)
  - [3. Configure credentials](#3-configure-credentials)
  - [Production (recommended): Managed identity as federated identity credential](#production-recommended-managed-identity-as-federated-identity-credential)
  - [Development/testing: Client secret](#developmenttesting-client-secret)
  - [4. Configure identifier URI and scope (required for interactive/OBO agents)](#4-configure-identifier-uri-and-scope-required-for-interactiveobo-agents)
  - [5. Create the blueprint principal](#5-create-the-blueprint-principal)
  - [6. Create agent identities from the blueprint](#6-create-agent-identities-from-the-blueprint)
- [OAuth flows](#oauth-flows)
  - [Interactive / OBO pattern](#interactive--obo-pattern)
  - [Autonomous pattern](#autonomous-pattern)
- [Administrative relationships](#administrative-relationships)
  - [Key constraints](#key-constraints)
- [Deleting an agent identity blueprint](#deleting-an-agent-identity-blueprint)

</details>

---

## Identity hierarchy

The agent identity platform uses a three-level hierarchy:

```text
Agent Identity Blueprint  (template + credential store)
        │
        ├── Agent Identity        (app-like identity, object ID = app ID)
        └── Agent User            (user-like identity, for systems requiring user objects)
```

| Object | Entra Type | Use When |
|---|---|---|
| **Agent Identity Blueprint** | Application (AgentIdentityBlueprint) | Creating and managing one or more agent identities; holds credentials |
| **Agent Identity** | Service principal (AgentIdentity) | Agent authenticates as an application identity (no password, token-only) |
| **Agent User** | User object (AgentUser) | Agent must connect to systems with a hard dependency on user objects (e.g., Exchange mailbox) |
| **Blueprint Principal** | Service principal (AgentIdentityBlueprintPrincipal) | Per-tenant record of a blueprint; enables token issuance in that tenant |

---

## Required roles and permissions

| Task | Entra Role Required | Graph Permission |
|---|---|---|
| Create agent identity blueprints | Agent ID Developer **or** Agent ID Administrator | `AgentIdentityBlueprint.Create` |
| Manage blueprint credentials | Agent ID Developer **or** Agent ID Administrator | `AgentIdentityBlueprint.AddRemoveCreds.All` |
| Update blueprint properties | Agent ID Developer **or** Agent ID Administrator | `AgentIdentityBlueprint.ReadWrite.All` |
| Delete blueprint | Agent ID Developer **or** Agent ID Administrator | `AgentIdentityBlueprint.DeleteRestore.All` |
| Create blueprint principal | Agent ID Developer **or** Agent ID Administrator | `AgentIdentityBlueprintPrincipal.Create` |
| Grant Graph app permissions | Privileged Role Administrator | — |
| Grant Graph delegated permissions | Cloud Application Admin **or** Application Admin | — |

> **Preview note:** All operations currently require the `/beta` Microsoft Graph endpoint and the beta PowerShell module (`Microsoft.Graph.Beta.Applications`).

---

## Creating an agent identity blueprint

> **Script available:** [`Create-Blueprint.ps1`](../scripts/Create-Blueprint.ps1) automates all four steps below. Copy `scripts/blueprint-input.json.example` → `blueprint-input.json`, fill in your values, and run the script. The manual Graph API steps are documented here for reference.
>
> See also: [Agent Blueprint vs. Registration](./agent-blueprint-vs-registration.md) for a diagram of how blueprints relate to agent registration.
>
> Need a scenario guide? See [When to use identity blueprints](./identity-blueprint/when-to-use-identity-blueprints.md). Migrating older implementations? See [Migrating legacy agents](./identity-blueprint/migrating-legacy-agents.md).

### 1. Connect with required scopes (PowerShell)

```powershell
Install-Module Microsoft.Graph.Beta.Applications -Scope CurrentUser -Force

Connect-MgGraph `
  -Scopes "AgentIdentityBlueprint.Create","AgentIdentityBlueprint.AddRemoveCreds.All","AgentIdentityBlueprint.ReadWrite.All","AgentIdentityBlueprintPrincipal.Create","User.Read" `
  -TenantId <your-tenant-id>
```

### 2. Create the blueprint (Graph API)

A sponsor is **required**; an owner is strongly recommended. The calling user becomes sponsor automatically if none is specified.

```http
POST https://graph.microsoft.com/beta/applications/
OData-Version: 4.0
Content-Type: application/json
Authorization: Bearer <token>

{
  "@odata.type": "Microsoft.Graph.AgentIdentityBlueprint",
  "displayName": "My Agent Identity Blueprint",
  "sponsors@odata.bind": [
    "https://graph.microsoft.com/v1.0/users/<sponsor-user-id>"
  ],
  "owners@odata.bind": [
    "https://graph.microsoft.com/v1.0/users/<owner-user-id>"
  ]
}
```

Record the `appId` from the response — you need it for all subsequent steps.

### 3. Configure credentials

### Production (recommended): Managed identity as federated identity credential

```http
POST https://graph.microsoft.com/beta/applications/<agent-blueprint-id>/federatedIdentityCredentials
OData-Version: 4.0
Content-Type: application/json

{
  "name": "my-managed-identity",
  "issuer": "https://login.microsoftonline.com/<tenant-id>/v2.0",
  "subject": "<managed-identity-principal-id>",
  "audiences": ["api://AzureADTokenExchange"]
}
```

### Development/testing: Client secret

```http
POST https://graph.microsoft.com/beta/applications/<agent-blueprint-id>/addPassword
Content-Type: application/json

{
  "passwordCredential": {
    "displayName": "Dev Secret",
    "endDateTime": "2026-08-05T23:59:59Z"
  }
}
```

> ⚠️ Client secrets are **not recommended for production**. Use managed identity (FIC) or client certificates instead. Secrets can't be retrieved after initial creation — store the value immediately.

### 4. Configure identifier URI and scope (required for interactive/OBO agents)

Only needed if agents built from this blueprint will receive incoming requests from users or other agents.

```http
PATCH https://graph.microsoft.com/beta/applications/<agent-blueprint-id>
OData-Version: 4.0
Content-Type: application/json

{
  "identifierUris": ["api://<agent-blueprint-id>"],
  "api": {
    "oauth2PermissionScopes": [
      {
        "adminConsentDescription": "Allow the application to access the agent on behalf of the signed-in user.",
        "adminConsentDisplayName": "Access agent",
        "id": "<new-guid>",
        "isEnabled": true,
        "type": "User",
        "value": "access_agent"
      }
    ]
  }
}
```

### 5. Create the blueprint principal

Creates the per-tenant service principal that enables token issuance.

```http
POST https://graph.microsoft.com/beta/serviceprincipals/graph.agentIdentityBlueprintPrincipal
OData-Version: 4.0
Content-Type: application/json

{
  "appId": "<agent-blueprint-app-id>"
}
```

### 6. Create agent identities from the blueprint

See [Create and delete agent identities](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-delete-agent-identities) for the next step.

---

## OAuth flows

All agent entities are **confidential clients**. Interactive flows (redirect URLs, public client) are not supported — all authentication is programmatic.

| Flow | Use Case | Grant Type |
|---|---|---|
| **Agent On-Behalf-Of (OBO)** | Interactive agent acting on behalf of a signed-in user | `jwt-bearer` (OBO) |
| **Autonomous (Client Credentials)** | Agent acting on its own identity without user context | `client_credentials` |
| **Agent User flow** | Agent using a user-object identity (e.g., for mailbox access) | `client_credentials` + user principal |
| **Refresh token** | Background operations maintaining user context over time | `refresh_token` |

### Interactive / OBO pattern

The agent front-end receives a user token, then exchanges it for an agent token via the OBO flow. The blueprint must have an identifier URI and scope configured (see step 4 above).

```text
User → Front-end → [OBO exchange via blueprint] → Agent backend → Downstream APIs
```

### Autonomous pattern

The agent authenticates using the blueprint's credential (managed identity preferred) and receives an agent token scoped to the target resource — no user context.

```text
Agent → Blueprint credential → client_credentials → Agent token → Resource APIs
```

> **Recommendation:** Use the [Microsoft Entra SDK for Agent ID](./entra-sdk-agent-id.md) or `Microsoft.Identity.Web` rather than implementing these flows manually. Manual implementation is complex and error-prone.

---

## Administrative relationships

Every agent blueprint and agent identity requires defined accountability roles:

| Role | Who | What They Can Do | Required? |
|---|---|---|---|
| **Owner** | Developer, IT admin, or service principal | Edit settings, manage credentials, assign owners/sponsors, re-enable disabled identities | No (recommended) |
| **Sponsor** | Business owner, product manager, team lead | Approve lifecycle decisions (renewal, suspension, removal); enable/disable agents | **Yes** (required at creation) |
| **Manager** | Individual user in org hierarchy | Request access packages for agent users; sees agent in reporting chain | No |

### Key constraints

- A sponsor is **required** when creating a blueprint or agent identity (blueprint principals are exempt).
- If no sponsor is specified in a delegated call, the calling user becomes sponsor automatically.
- For app-only creation, the creating service must explicitly set at least one sponsor.
- Owners can re-enable disabled identities and restore soft-deleted ones; sponsors cannot.
- Admin role holders (Agent ID Administrator) are **not** auto-assigned as sponsor to avoid overburdening them.

---

## Deleting an agent identity blueprint

Before deleting a blueprint, you must first remove all agent identities and agent users created from it.

```http
DELETE https://graph.microsoft.com/beta/applications/<agent-blueprint-id>
OData-Version: 4.0
Authorization: Bearer <token>
```

Requires `AgentIdentityBlueprint.DeleteRestore.All`.

---

## References

- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/key-concepts" target="_blank">Agent identity platform key concepts</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint" target="_blank">Create an agent identity blueprint</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-oauth-protocols" target="_blank">Agent OAuth protocols</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-owners-sponsors-managers" target="_blank">Administrative relationships (owners, sponsors, managers)</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-delete-agent-identities" target="_blank">Create and delete agent identities</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-users" target="_blank">Agent users</a>
- [Agent Blueprint vs. Registration diagram](./agent-blueprint-vs-registration.md)
- [Enabling Code-Built Agents](./enabling-code-built-agents.md) — how to use these identities in Pattern B
- [`Create-Blueprint.ps1`](../scripts/Create-Blueprint.ps1) — script that automates blueprint creation
- [`Register-Agent.ps1`](../scripts/Register-Agent.ps1) — script that registers the agent in the registry
