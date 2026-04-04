# Agent's User Account Guide

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

An **agent's user account** is an optional Microsoft Entra user object that pairs 1:1 with an agent identity. It enables an AI agent to access systems and services that require a user identity — such as Exchange Online mailboxes, Microsoft Teams channels, calendars, and group memberships.

> **Important:** The agent's user account does NOT replace the agent identity. Both must exist. The agent identity is the primary identity; the agent's user account is a secondary identity for scenarios requiring user-object access.

---

## When You Need an Agent's User Account

| Scenario | Agent's user account needed? |
|---|---|
| Agent needs to send/receive email via Exchange Online | ✅ Yes |
| Agent needs to participate in Teams chats and channels | ✅ Yes |
| Agent needs its own calendar for scheduling | ✅ Yes |
| Agent needs to join Microsoft Entra groups | ✅ Yes |
| Agent needs APIs that only accept user identities | ✅ Yes |
| Agent only calls Microsoft Graph with app-only permissions | ❌ No — agent identity alone is sufficient |
| Agent only acts on behalf of a user (delegated permissions) | ❌ No — use the on-behalf-of flow with the agent identity |

---

## Prerequisites

Before creating an agent's user account, you need:

1. **An agent identity blueprint** with credentials configured.
2. **An agent identity** created from that blueprint.
3. The blueprint must be granted the **`AgentIdUser.ReadWrite.IdentityParentedBy`** application permission.
   - This permission is NOT automatically granted — an admin must explicitly grant it.
   - Required role: **Agent ID Administrator** or **User Administrator**.
4. **Microsoft 365 Copilot** license with **Frontier** program enabled.

---

## Step 1: Grant the Blueprint Permission to Create User Accounts

The blueprint needs the `AgentIdUser.ReadWrite.IdentityParentedBy` permission to create agent's user accounts.

**Via Microsoft Graph API:**

```http
POST https://graph.microsoft.com/beta/servicePrincipals/{blueprint-principal-id}/appRoleAssignments
Content-Type: application/json
Authorization: Bearer {admin-token}

{
    "principalId": "{blueprint-principal-id}",
    "resourceId": "{microsoft-graph-service-principal-id}",
    "appRoleId": "{AgentIdUser.ReadWrite.IdentityParentedBy-role-id}"
}
```

**Required role:** Privileged Role Administrator or Global Administrator.

---

## Step 2: Create the Agent's User Account

Use the blueprint's credentials to create the agent's user account, linking it to a specific agent identity.

**Via Microsoft Graph API:**

```http
POST https://graph.microsoft.com/beta/users
OData-Version: 4.0
Content-Type: application/json
Authorization: Bearer {blueprint-token}

{
    "@odata.type": "#microsoft.graph.agentIdUser",
    "displayName": "Sales Assistant Agent",
    "mailNickname": "sales-assistant-agent",
    "userPrincipalName": "sales-assistant-agent@contoso.onmicrosoft.com",
    "agentIdentityId": "{agent-identity-object-id}"
}
```

**Key points:**

- The `agentIdentityId` establishesthe immutable 1:1 relationship with the parent agent identity.
- The `@odata.type` must be `#microsoft.graph.agentIdUser` to create an agent user (not a regular user).
- Each agent identity can have at most ONE agent's user account.
- The link is immutable — once set, it cannot be changed.

---

## Step 3: Assign a License

The agent's user account typically needs a license to access Microsoft 365 services (Exchange Online, Teams, etc.).

**Via Microsoft Graph API:**

```http
POST https://graph.microsoft.com/v1.0/users/{agent-user-id}/assignLicense
Content-Type: application/json
Authorization: Bearer {admin-token}

{
    "addLicenses": [
        {
            "skuId": "{microsoft-365-license-sku-id}"
        }
    ],
    "removeLicenses": []
}
```

**Common license SKUs:**

- **Microsoft 365 E3/E5** — includes Exchange Online, Teams, SharePoint
- **Exchange Online Plan 1/2** — for mailbox-only scenarios
- **Microsoft Teams Essentials** — for Teams-only scenarios

**Via Microsoft 365 Admin Center:**

1. Go to **Users → Active users**→ find the agent's user account.
2. Select the user → **Licenses and apps**.
3. Assign the appropriate license.

> **Note:** License assignment may take a few minutes to provision the mailbox and Teams access.

---

## Step 4: Enable Teams Communication

Once the agent's user account has a Teams-enabled license, it can participate in Teams conversations.

### How the Agent Communicates on Teams

The agent's user account appears in Teams like any other user. Human users can:

- **Find the agent** by searchingfor its display name in Teams.
- **Start a 1:1 chat** with the agent's user account.
- **Add the agent to a group chat** or Teams channel.
- **@mention the agent** in channels where it's a member.

### Setting Up the Agent for Teams

1. **Verify license provisioning:**

   ```http
   GET https://graph.microsoft.com/v1.0/users/{agent-user-id}/licenseDetails
   Authorization: Bearer {admin-token}
   ```

   Confirm a Teams-enabled SKU is listed.

2. **Add the agent to a Team:**

   ```http
   POST https://graph.microsoft.com/v1.0/teams/{team-id}/members
   Content-Type: application/json
   Authorization: Bearer {admin-token}

   {
       "@odata.type": "#microsoft.graph.aadUserConversationMember",
       "roles": ["member"],
       "user@odata.bind": "https://graph.microsoft.com/v1.0/users/{agent-user-id}"
   }
   ```

3. **Send a message as the agent:**
   The agent uses the impersonation chain (blueprint → agent identity → agent's user account) to acquire a user token, then calls the Teams Graph API:

   ```http
   POST https://graph.microsoft.com/v1.0/chats/{chat-id}/messages
   Content-Type: application/json
   Authorization: Bearer {agent-user-token}

   {
       "body": {
           "content": "Hello! I'm the Sales Assistant Agent. How can I help you today?"
       }
   }
   ```

### How Human Users Interact with the Agent on Teams

| Action | How |
|---|---|
| **Find the agent** | Search by display name in Teams search bar |
| **Start a chat** | Click **New chat** → type the agent's display name → send a message |
| **Add to group chat** | Create or open a group chat → **Add people** → search for the agent |
| **Add to a channel** | Team owner adds the agent as a member of the Team |
| **@mention in channel** | Type `@` followed by the agent's display name in a channel message |

> **Note:** The agent's user account appears with user-like presence in Teams. It can receive messages, but the agent's backend application must poll for or subscribe to new messages to respond. Microsoft Learn recommends using the [Microsoft Graph Change Notifications API](https://learn.microsoft.com/en-us/graph/api/resources/webhooks) for real-time message handling.

---

## Authentication Flow

The agent's user account cannot authenticate independently. The authentication follows a multi-stage impersonation chain:

```text
1. Service authenticates with blueprint credential (managed identity or cert)
         │
2. Blueprint acquires token, impersonates agent identity
         │
3. Agent identity impersonates its paired agent's user account
         │
4. Resulting token: subject = agent's user account, idtyp = user
         │
5. Token used to call Teams, Exchange, or other user-scoped APIs
```

**SDK recommendation:** Use the **Microsoft Identity Web (.NET)** SDK or the **Microsoft Entra SDK for Agent ID** to handle this token exchange. Manual implementation is complex and error-prone.

---

## Security Constraints

| Constraint | Detail |
|---|---|
| **No passwords** | Agent's user account cannot have passwords or passkeys |
| **No interactive sign-in** | Cannot sign in to web apps or portals |
| **No privileged roles** | Cannot be assigned administrator roles |
| **No role-assignable groups** | Can join regular groups and dynamic groups, but not role-assignable groups |
| **No custom roles** | Custom role assignment is not available |
| **Guest-level permissions** | Permissions similar to guest users, with enhanced enumeration |
| **Credential type** | Only agent identity reference credential (confidential client) |

---

## Lifecycle Management

### Enable/Disable

Sponsors and owners can manage the agent's user account via the **My Account portal** (myaccount.microsoft.com):

- **Disable** — blocks all sign-insand token issuance.
- **Enable** — re-enables the agent.

### Deletion

- An admin can delete the agent's user account when its functionality is no longer needed.
- **Warning:** Orphaned agent's user accounts may remain when the parent blueprint or agent identity is deleted. Delete them manually.

### Sponsorship

- If the agent identity's sponsor leaves the organization, sponsorship automatically transfers to their manager.
- Lifecycle workflows notify cosponsors and managers of impending sponsorship changes.

---

## Validation Checklist

After creating an agent's user account, verify:

| Check | How |
|---|---|
| ✅ Agent's user account exists | `GET https://graph.microsoft.com/beta/users/{agent-user-id}` — confirm `@odata.type` includes agent user |
| ✅ Linked to correct agent identity | Check `agentIdentityId` in the user object |
| ✅ License assigned | Check `licenseDetails` endpoint |
| ✅ Mailbox provisioned (if needed) | `GET https://graph.microsoft.com/v1.0/users/{agent-user-id}/mailboxSettings` |
| ✅ Teams access works | Verify user appears in Teams search; test sending a message |
| ✅ Token flow works | Request a token via the impersonation chain; verify `idtyp=user` claim |

---

## Related Pages

- [Agent identity hierarchy](./agent-identity-hierarchy.md) — How all identity objects relate
- [What is an identity blueprint?](./what-is-an-identity-blueprint.md) — Conceptual overview
- [How blueprints are used](./how-blueprints-are-used.md) — Provisioning and runtime flow

## References

- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-users" target="_blank">Agent's user accounts</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-identities" target="_blank">Agent identities</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-delete-agent-identities" target="_blank">Create and delete agent identities</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/manage-agent" target="_blank">Manage agents in Microsoft Entra</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-tokens" target="_blank">Tokens in Microsoft agent identity platform</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-oauth-protocols" target="_blank">Agent OAuth protocols</a>
- <a href="https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview" target="_blank">Identity governance for agents</a>
