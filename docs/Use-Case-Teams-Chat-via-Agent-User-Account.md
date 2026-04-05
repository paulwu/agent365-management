# Use Case: Teams Chat via Agent's User Account

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

This guide walks you through the complete workflow for creating an AI agent that communicates via Microsoft Teams chat — just like a human team member. Users can find the agent in Teams, send task assignments, and receive responses in the same chat thread.

The guide covers: creating an agent identity blueprint, provisioning an agent identity, creating an agent's user account, assigning a license, registering in the Agent Registry, and building a backend that communicates via Teams.

> Throughout this document, "blueprint" refers to **agent identity blueprint** — the official Microsoft Learn term.

<details>
<summary><strong>📑 Table of Contents</strong></summary>

- [Prerequisites](#prerequisites)
  - [Tool Options](#tool-options)
- [Step 0: Create the Client App Registration](#step-0-create-the-client-app-registration-one-time-setup)
- [Step 1: Create the Agent Identity Blueprint](#step-1-create-the-agent-identity-blueprint)
- [Step 2: Create the Agent Identity](#step-2-create-the-agent-identity)
- [Step 3: Grant Permission to Create Agent's User Account](#step-3-grant-permission-to-create-agents-user-account)
- [Step 4: Create the Agent's User Account](#step-4-create-the-agents-user-account)
- [Step 5: Assign a Microsoft 365 License](#step-5-assign-a-microsoft-365-license)
- [Step 6: Add the Agent to a Team](#step-6-add-the-agent-to-a-team)
- [Step 7: Build the Agent Backend Service](#step-7-build-the-agent-backend-service)
  - [7a. Subscribe to Teams chat messages](#7a-subscribe-to-teams-chat-messages-change-notifications)
  - [7b. Process incoming messages and respond](#7b-process-incoming-messages-and-respond)
  - [7c. Token acquisition (authentication chain)](#7c-token-acquisition-authentication-chain)
- [Step 8: Register the Agent in the Agent Registry](#step-8-register-the-agent-in-the-agent-registry)
- [Step 9: How It Works for the Human User](#step-9-how-it-works-for-the-human-user)
- [Security Constraints](#security-constraints)
- [Complete Architecture](#complete-architecture)
- [Tool Reference Summary](#tool-reference-summary)
- [Related Pages](#related-pages)
- [References](#references)

</details>

⬅️ [Back to docs index](../README.md#looking-for-guidance-on-a-specific-topic)

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Licensing** | Microsoft 365 Copilot license + Frontier program enabled |
| **Roles** | Agent ID Developer or Agent ID Administrator (blueprint), Agent ID Administrator or User Administrator (agent user), Privileged Role Administrator (granting Graph permissions), Agent Registry Administrator (registry) |
| **Tools** | PowerShell 7, Microsoft Graph PowerShell SDK or HTTP client. Optionally: .NET 8.0 for Agent 365 CLI |
| **Azure** | (For production) Azure App Service, Functions, or VM with managed identity |

### Tool Options

This guide shows three approaches for each step where applicable:

| Tool | Best For |
|---|---|
| **Microsoft Graph API** | Fine-grained control, automation pipelines, any language |
| **Agent 365 CLI** (`a365`) | End-to-end setup with Azure infrastructure in one step |
| **Repository scripts** | Pre-built PowerShell wrappers around Graph API calls |

**Install Agent 365 CLI (optional):**

```shell
dotnet tool install --global Microsoft.Agents.A365.DevTools.Cli --prerelease
a365 -h
```

> See [Agent 365 CLI docs](https://learn.microsoft.com/en-us/microsoft-agent-365/developer/agent-365-cli) for full reference.

---

## Step 0: Create the Client App Registration (One-Time Setup)

Before creating a blueprint with the CLI or repository scripts, you need a **client app registration** in Microsoft Entra ID. This provides the Client ID used for interactive authentication.

👉 **Follow the step-by-step guide:** [Prerequisite: Client App Registration](./prerequisite-client-app-registration.md)

Once you have your **Application (client) ID**, proceed to Step 1.

> **Option C (Graph API) users:** You can skip this step if you already have a method for obtaining Graph API tokens (e.g., via `az account get-access-token` or an existing app registration).

---

## Step 1: Create the Agent Identity Blueprint

The blueprint is the template and credential holder for your agent.

### Option A — Agent 365 CLI (recommended for new agents)

The CLI creates the blueprint, configures credentials, sets up Azure infrastructure, and configures permissions in one step.

**Prerequisite:** You need a Client App ID from [Step 0](#step-0-create-the-client-app-registration-one-time-setup).

```shell
# 1. Initialize configuration (enter your Client App ID when prompted)
a365 config init

# 2. Run the complete setup (Azure infra + blueprint + permissions)
a365 setup all
```

Or for granular control:

```shell
a365 setup requirements      # Validate prerequisites
a365 setup infrastructure    # Create Azure resource group, App Service, Web App
a365 setup blueprint         # Register the blueprint in Entra
a365 setup permissions mcp   # Configure MCP tooling server permissions
a365 setup permissions bot   # Configure bot messaging permissions
```

If you're not a Global Administrator, a Global Admin must complete OAuth2 permission grants:

```shell
a365 setup admin --config-dir "<path-to-config-folder>"
```

The CLI saves all generated IDs to `a365.generated.config.json`.

### Option B — Repository script

```powershell
Copy-Item scripts/blueprint-input.json.example scripts/blueprint-input.json
# Edit blueprint-input.json: set sponsorUserIds, ownerUserIds, displayName, credentials

pwsh -File ./scripts/Create-Blueprint.ps1 -TenantId "contoso.onmicrosoft.com" -ClientId "your-app-client-id"
```

See `scripts/README.md` for full documentation and required permissions.

**Prerequisite:** You need a Client App ID from [Step 0](#step-0-create-the-client-app-registration-one-time-setup) — passed as the `-ClientId` parameter.

### Option C — Microsoft Graph API

```http
POST https://graph.microsoft.com/v1.0/applications/
OData-Version: 4.0
Content-Type: application/json
Authorization: Bearer {admin-token}

{
  "@odata.type": "Microsoft.Graph.AgentIdentityBlueprint",
  "displayName": "Task Assistant Agent Blueprint",
  "sponsors@odata.bind": [
    "https://graph.microsoft.com/v1.0/users/{your-user-id}"
  ],
  "owners@odata.bind": [
    "https://graph.microsoft.com/v1.0/users/{your-user-id}"
  ]
}
```

Record the returned `appId` — this is your `{blueprint-app-id}`.

#### Configure credentials (client secret for dev/test)

```http
POST https://graph.microsoft.com/v1.0/applications/{blueprint-app-id}/addPassword
Content-Type: application/json
Authorization: Bearer {admin-token}

{
  "passwordCredential": {
    "displayName": "Dev Secret",
    "endDateTime": "2027-01-01T00:00:00Z"
  }
}
```

> **Production:** Use managed identity as federated identity credential instead. See [Microsoft Learn: Create blueprint](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint).

#### Configure identifier URI and scope (required for Teams interaction)

```http
PATCH https://graph.microsoft.com/v1.0/applications/{blueprint-app-id}
OData-Version: 4.0
Content-Type: application/json
Authorization: Bearer {admin-token}

{
  "identifierUris": ["api://{blueprint-app-id}"],
  "api": {
    "oauth2PermissionScopes": [
      {
        "adminConsentDescription": "Allow the application to access the agent on behalf of the signed-in user.",
        "adminConsentDisplayName": "Access agent",
        "id": "{generate-a-guid}",
        "isEnabled": true,
        "type": "User",
        "value": "access_agent"
      }
    ]
  }
}
```

#### Create the blueprint principal

```http
POST https://graph.microsoft.com/v1.0/serviceprincipals/graph.agentIdentityBlueprintPrincipal
OData-Version: 4.0
Content-Type: application/json
Authorization: Bearer {admin-token}

{
  "appId": "{blueprint-app-id}"
}
```

### Option D — `@blueprint-creator` Copilot agent (interactive wizard)

If you have this repository open in VS Code with GitHub Copilot, use the interactive wizard:

```text
@blueprint-creator I want to create a new agent identity blueprint
```

The wizard walks you through a 10-step process:
1. Checks PowerShell and Microsoft Graph module
2. Verifies tenant login and Entra roles
3. Validates app registration and Graph permissions (needs Client App ID from [Step 0](#step-0-create-the-client-app-registration-one-time-setup))
4. Collects all blueprint fields (display name, sponsor, owner, credentials)
5. Generates `blueprint-input.json`
6. Executes `scripts/Create-Blueprint.ps1`
7. Provides post-creation guidance

> **Requires interactive mode** — press **Shift+Tab** to exit autopilot mode before invoking.

---

## Step 2: Create the Agent Identity

> **Note:** This step requires the Graph API regardless of which tool you used in Step 1. The Agent 365 CLI does not directly create agent identities — it creates the blueprint, and you create identities from it.

Using the blueprint's credentials, create the agent identity:

```http
POST https://graph.microsoft.com/beta/serviceprincipals/Microsoft.Graph.AgentIdentity
OData-Version: 4.0
Content-Type: application/json
Authorization: Bearer {blueprint-token}

{
  "displayName": "Task Assistant Agent",
  "agentIdentityBlueprintId": "{blueprint-app-id}",
  "sponsors@odata.bind": [
    "https://graph.microsoft.com/v1.0/users/{your-user-id}"
  ]
}
```

Record the returned `id` — this is your `{agent-identity-id}`.

**How to get the blueprint token:**

```http
POST https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token
Content-Type: application/x-www-form-urlencoded

client_id={blueprint-app-id}
&scope=https://graph.microsoft.com/.default
&client_secret={blueprint-secret}
&grant_type=client_credentials
```

---

## Step 3: Grant Permission to Create Agent's User Account

By default, blueprints cannot create agent user accounts. You must explicitly grant the `AgentIdUser.ReadWrite.IdentityParentedBy` permission:

```http
POST https://graph.microsoft.com/v1.0/servicePrincipals/{blueprint-principal-id}/appRoleAssignments
Content-Type: application/json
Authorization: Bearer {admin-token}

{
  "principalId": "{blueprint-principal-id}",
  "resourceId": "{microsoft-graph-sp-id}",
  "appRoleId": "{AgentIdUser.ReadWrite.IdentityParentedBy-role-id}"
}
```

**Required role:** Privileged Role Administrator.

---

## Step 4: Create the Agent's User Account

Now create the user account linked to the agent identity:

```http
POST https://graph.microsoft.com/beta/users
OData-Version: 4.0
Content-Type: application/json
Authorization: Bearer {blueprint-token}

{
  "@odata.type": "#microsoft.graph.agentIdUser",
  "displayName": "Task Assistant Agent",
  "mailNickname": "task-assistant-agent",
  "userPrincipalName": "task-assistant-agent@contoso.onmicrosoft.com",
  "agentIdentityId": "{agent-identity-id}"
}
```

Record the returned `id` — this is your `{agent-user-id}`.

**Key facts about the agent's user account:**

- Immutable 1:1 link to the agent identity — cannot be changed after creation.
- No passwords or passkeys — authenticates only via the parent agent identity.
- Tokens issued with `idtyp=user` — can access user-only APIs (Teams, Exchange, etc.).
- Cannot sign in interactively to web portals.

---

## Step 5: Assign a Microsoft 365 License

The agent's user account needs a license to access Teams, Exchange, etc.

```http
POST https://graph.microsoft.com/v1.0/users/{agent-user-id}/assignLicense
Content-Type: application/json
Authorization: Bearer {admin-token}

{
  "addLicenses": [
    {
      "skuId": "{microsoft-365-e3-or-e5-sku-id}"
    }
  ],
  "removeLicenses": []
}
```

You can also do this in **M365 admin center → Users → Active users** → find the agent → **Licenses and apps**.

> Wait a few minutes for the mailbox and Teams access to be provisioned.

---

## Step 6: Add the Agent to a Team

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

The agent now appears as a team member. Human users can find it by searching its display name ("Task Assistant Agent") in Teams.

---

## Step 7: Build the Agent Backend Service

This is the application that receives messages from Teams, processes tasks, and responds. Here's a Python example using the Microsoft Graph SDK.

### 7a. Subscribe to Teams chat messages (Change Notifications)

```python
import requests

GRAPH_URL = "https://graph.microsoft.com/v1.0"

def create_subscription(agent_user_token, webhook_url):
    """Subscribe to new messages sent to the agent's chats."""
    response = requests.post(
        f"{GRAPH_URL}/subscriptions",
        headers={
            "Authorization": f"Bearer {agent_user_token}",
            "Content-Type": "application/json"
        },
        json={
            "changeType": "created",
            "notificationUrl": webhook_url,
            "resource": "/me/chats/getAllMessages",
            "expirationDateTime": "2026-04-05T00:00:00Z",
            "clientState": "task-assistant-secret"
        }
    )
    return response.json()
```

### 7b. Process incoming messages and respond

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/webhook", methods=["POST"])
def handle_notification():
    data = request.json

    # Validate client state
    if data.get("value", [{}])[0].get("clientState") != "task-assistant-secret":
        return "Unauthorized", 403

    for notification in data.get("value", []):
        chat_id = notification["resource"].split("/")[2]
        message_id = notification["resourceData"]["id"]

        # Get the message content
        msg = get_message(chat_id, message_id)
        sender = msg["from"]["user"]["displayName"]
        content = msg["body"]["content"]

        # Process the task assignment
        response_text = process_task(content)

        # Reply in the same chat
        send_reply(chat_id, response_text)

    return jsonify({"status": "ok"}), 200


def get_message(chat_id, message_id):
    """Fetch the message details."""
    token = get_agent_user_token()
    resp = requests.get(
        f"{GRAPH_URL}/chats/{chat_id}/messages/{message_id}",
        headers={"Authorization": f"Bearer {token}"}
    )
    return resp.json()


def send_reply(chat_id, text):
    """Send a reply as the agent in the same chat thread."""
    token = get_agent_user_token()
    requests.post(
        f"{GRAPH_URL}/chats/{chat_id}/messages",
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        },
        json={
            "body": {
                "contentType": "html",
                "content": text
            }
        }
    )


def process_task(content):
    """Your task processing logic — call an LLM, run a workflow, etc."""
    return f"✅ <b>Task received!</b><br>I'm working on: <i>{content}</i><br>I'll update you when it's done."


def get_agent_user_token():
    """
    Get a token for the agent's user account via the impersonation chain:
    1. Authenticate with blueprint credentials
    2. Blueprint impersonates agent identity
    3. Agent identity impersonates agent's user account

    Use Microsoft Entra SDK for Agent ID or Microsoft.Identity.Web
    to handle this flow. Manual implementation is NOT recommended.
    """
    # Simplified — use the SDK in production:
    # See https://aka.ms/entra/sdk/agentid
    pass
```

### 7c. Token acquisition (authentication chain)

The agent's user account cannot authenticate independently. The flow is:

```text
1. Your service authenticates with blueprint credential
   POST /oauth2/v2.0/token (client_credentials, blueprint client_id + secret/cert)

2. Blueprint token exchanges to impersonate agent identity
   POST /oauth2/v2.0/token (jwt-bearer, subject_token = blueprint token)

3. Agent identity token exchanges to impersonate agent's user account
   POST /oauth2/v2.0/token (jwt-bearer, subject_token = agent identity token)

4. Result: token with subject = agent's user account, idtyp = user
   → Use this token to call Teams, Exchange, and other user-scoped APIs
```

> **Microsoft strongly recommends** using the [Microsoft Entra SDK for Agent ID](https://aka.ms/entra/sdk/agentid) or [Microsoft.Identity.Web](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-oauth-protocols) to handle this chain. Manual implementation is complex and error-prone.

---

## Step 8: Register the Agent in the Agent Registry

### Option A — Agent 365 CLI

If you used the CLI in Step 1, publish and create the agent instance via Teams:

```shell
# Publish the agent
a365 publish

# Deploy to Azure (if hosting on Azure Web App)
a365 deploy
```

Then create the agent instance in Teams:

1. Open Microsoft Teams → **Apps** → search for your agent → **Add**.

### Option B — Repository script

```powershell
Copy-Item scripts/agent-metadata.json.example scripts/agent-metadata.json
# Edit agent-metadata.json with your blueprint ID, agent identity ID, agent user ID, and endpoint URL

pwsh -File ./scripts/Register-Agent.ps1 -TenantId "contoso.onmicrosoft.com"
```

### Option C — Microsoft Graph API

```http
POST https://graph.microsoft.com/beta/agentRegistry/agentInstances
Authorization: Bearer {admin-token}
Content-Type: application/json

{
  "displayName": "Task Assistant Agent",
  "ownerIds": ["{your-user-id}"],
  "sourceAgentId": "{your-internal-agent-id}",
  "originatingStore": "Custom",
  "agentIdentityBlueprintId": "{blueprint-app-id}",
  "agentIdentityId": "{agent-identity-id}",
  "agentUserId": "{agent-user-id}",
  "url": "https://your-agent-backend.azurewebsites.net/a2a/v1",
  "preferredTransport": "JSONRPC",
  "agentCardManifest": {
    "displayName": "Task Assistant Agent",
    "description": "An agent that receives task assignments via Teams chat and executes them autonomously.",
    "iconUrl": "https://your-domain.com/icon.png",
    "provider": {
      "organization": "Contoso"
    },
    "protocolVersion": "1.0",
    "version": "1.0.0",
    "skills": [
      {
        "id": "task-execution",
        "name": "Task Execution",
        "description": "Receives task assignments and executes them, reporting status back via Teams chat."
      }
    ],
    "defaultInputModes": ["application/json"],
    "defaultOutputModes": ["application/json", "text/html"]
  }
}
```

---

## Step 9: How It Works for the Human User

Once everything is set up, the experience for you (the human) is:

| Action | How |
|---|---|
| **Find the agent** | Search "Task Assistant Agent" in the Teams search bar |
| **Start a chat** | Click **New chat** → type the agent's display name → send a message |
| **Assign a task** | Type your task in the chat, e.g., "Generate the Q1 sales report and send it to the team" |
| **Track progress** | The agent responds in the same chat thread with status updates |
| **View history** | Scroll up in the chat to see all past assignments and responses — just like any Teams conversation |
| **Add to group chat** | Create a group chat and add the agent as a participant alongside other team members |
| **@mention in channel** | If the agent is a team member, @mention it in any channel |

The agent's user account appears in Teams like a real user — with a display name, profile, and chat presence.

---

## Security Constraints

| Constraint | Detail |
|---|---|
| No passwords | Agent's user account has no passwords or passkeys |
| No interactive sign-in | Cannot sign in to web apps or portals |
| No admin roles | Cannot be assigned privileged administrator roles |
| No role-assignable groups | Can join regular and dynamic groups only |
| Tenant-scoped | Agent identity can only operate within the tenant where it was created |
| Sponsor required | A human user or group must be designated as sponsor |
| Impersonation only | Agent's user account tokens can only be obtained through the blueprint → agent identity → agent user impersonation chain |

---

## Complete Architecture

```text
┌──────────────┐      ┌─────────────────────────────┐
│  Human User  │      │  Microsoft Teams             │
│  (you)       │◄────►│  Chat with "Task Assistant"  │
└──────────────┘      └─────────────┬───────────────┘
                                    │ Graph API
                                    │ Change Notifications
                      ┌─────────────▼───────────────┐
                      │  Agent Backend Service       │
                      │  (Azure App Service / VM)    │
                      │                              │
                      │  • Receives chat messages    │
                      │  • Processes tasks (LLM/API) │
                      │  • Sends replies as agent    │
                      └─────────────┬───────────────┘
                                    │ Token chain
                      ┌─────────────▼───────────────┐
                      │  Microsoft Entra ID          │
                      │                              │
                      │  Blueprint ──► Agent Identity │
                      │                 ──► Agent's  │
                      │                     User     │
                      │                     Account  │
                      └─────────────────────────────┘
```

---

## Tool Reference Summary

| Step | Graph API | Agent 365 CLI | Repo Script | @blueprint-creator |
|---|---|---|---|---|
| 1. Create blueprint | `POST /v1.0/applications/` | `a365 setup all` or `a365 setup blueprint` | `Create-Blueprint.ps1` | Interactive wizard |
| 2. Create agent identity | `POST /beta/serviceprincipals/Microsoft.Graph.AgentIdentity` | *(use Graph API)* | *(use Graph API)* | — |
| 3. Grant user account permission | `POST /v1.0/servicePrincipals/{id}/appRoleAssignments` | *(use Graph API)* | *(use Graph API)* | — |
| 4. Create agent's user account | `POST /beta/users` | *(use Graph API)* | *(use Graph API)* | — |
| 5. Assign license | `POST /v1.0/users/{id}/assignLicense` | *(use Graph API or M365 admin)* | *(use Graph API or M365 admin)* | — |
| 6. Add to Team | `POST /v1.0/teams/{id}/members` | *(use Graph API)* | *(use Graph API)* | — |
| 7. Build backend | Python/C#/.NET code | *(your code)* | *(your code)* | — |
| 8. Register in registry | `POST /beta/agentRegistry/agentInstances` | `a365 publish` + `a365 deploy` | `Register-Agent.ps1` | — |

---

## Related Pages

- [Agent identity hierarchy](./identity-blueprint/agent-identity-hierarchy.md) — Visual diagram of blueprint → identity → user account
- [Agent's user account guide](./identity-blueprint/agent-user-account-guide.md) — Detailed reference for agent's user accounts
- [Developer guide](./developer-identity-platform.md) — Blueprint creation, OAuth flows, admin relationships
- [Agent blueprint vs. registration](./agent-blueprint-vs-registration.md) — Pattern A vs. Pattern B

⬅️ [Back to docs index](../README.md#looking-for-guidance-on-a-specific-topic) · [↑ Back to top](#use-case-teams-chat-via-agents-user-account)

## References

- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-users" target="_blank">Agent's user accounts</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint" target="_blank">Create an agent identity blueprint</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-delete-agent-identities" target="_blank">Create and delete agent identities</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-oauth-protocols" target="_blank">Agent OAuth protocols</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/publish-agents-to-registry" target="_blank">Register agents with Agent Registry</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-identities" target="_blank">Agent identities</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/manage-agent" target="_blank">Manage agents in Microsoft Entra</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/agent-365-cli" target="_blank">Agent 365 CLI</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/registration" target="_blank">Agent 365 CLI: Setup agent blueprint</a>
