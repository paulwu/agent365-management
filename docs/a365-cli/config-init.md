# `a365 config init`

> Create the Agent 365 CLI configuration file interactively.

## Purpose

Launches an interactive wizard that creates `a365.config.json` — the central configuration file used by all other CLI commands. It collects and validates your tenant, Azure subscription, agent identity, and deployment settings in one guided session.

---

## Prerequisites

| What | Why |
|---|---|
| **Azure CLI login** (`az login`) | The wizard reads your Azure session to auto-populate subscription, tenant, resource groups, and regions |
| **Client App Registration** | You need the Application (client) ID — see [Prerequisite: Client App Registration](../prerequisite-client-app-registration.md) |
| **No Entra role required** | This is a local configuration step only |

---

## Syntax

```shell
a365 config init [options]
```

| Option | Description |
|---|---|
| `-c`, `--configfile <path>` | Import settings from an existing config file |
| `-g`, `--global` | Create config in global directory (AppData) instead of current directory |
| `-h`, `--help` | Show help |

---

## What It Prompts For

| Field | Description | Example |
|---|---|---|
| **Client App ID** | Your custom client app registration GUID | `12345678-abcd-efgh-ijkl-1234567890ab` |
| **Deployment project path** | Path to your agent code directory | `C:\MyAgent\sample-agent` |
| **Manager email** | Human sponsor/manager for the agent | `manager@contoso.com` |
| **Azure subscription** | Interactive selection from available subscriptions | *(list from Azure CLI)* |
| **Resource group** | Select existing or create new | *(list from Azure CLI)* |
| **App Service Plan** | Select existing or create new | *(list from Azure CLI)* |
| **Location** | Azure region for deployment | `eastus`, `westus`, `canadacentral` |

---

## What It Auto-Detects

- **Subscription & tenant** from your `az login` session
- **Resource groups, app service plans, regions** from Azure
- **Project type** (.NET, Node.js, Python) from the deployment path
- **Agent naming** — derives blueprint name, identity name, user principal name, and web app name from a single display name you provide

---

## What It Validates

- Client App ID exists in your Entra tenant
- Required delegated permissions are configured on the client app
- Admin consent is granted for the client app
- You get **up to 3 attempts** before the wizard exits if validation fails

---

## Output

Creates `a365.config.json` in the current directory (or global directory with `--global`):

```json
{
  "$schema": "./a365.config.schema.json",
  "tenantId": "72f988bf-86f1-41af-91ab-2d7cd011db47",
  "subscriptionId": "0832b3b6-22b3-4c47-8d8b-572054b97257",
  "resourceGroup": "rg-task-assistant",
  "location": "westus",
  "appServicePlanName": "asp-task-assistant-04051030",
  "appServicePlanSku": "B1",
  "webAppName": "webapp-task-assistant-04051030",
  "agentBlueprintDisplayName": "Task Assistant Blueprint",
  "agentIdentityDisplayName": "Task Assistant Identity",
  "agentUserPrincipalName": "task-assistant@contoso.onmicrosoft.com",
  "agentUserDisplayName": "Task Assistant Agent User",
  "managerEmail": "manager@contoso.com",
  "agentUserUsageLocation": "US",
  "deploymentProjectPath": "C:\\MyAgent\\sample-agent",
  "botName": "task-assistant-bot",
  "botDescription": "Task Assistant - Agent 365 Agent"
}
```

---

## What It Does NOT Do

- Does **not** create Azure resources (that's `a365 setup infrastructure`)
- Does **not** create the blueprint (that's `a365 setup blueprint`)
- Does **not** deploy code (that's `a365 deploy`)

---

## Re-Running

Re-running `a365 config init` loads your existing `a365.config.json` as defaults. Press **Enter** at each prompt to keep the current value, or type a new value to update it.

---

## Tips

- **Commit** `a365.config.json` to source control (no secrets)
- **Do NOT commit** `a365.generated.config.json` (contains secrets from `a365 setup`)
- Verify with `a365 config display` after init

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/config" target="_blank">a365 config command reference</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/a365-config" target="_blank">Agent 365 CLI configuration guide</a>
