# `a365 setup blueprint`

> Create the agent identity blueprint in Microsoft Entra ID.

## Purpose

Registers the agent identity blueprint (Entra ID application), creates the blueprint principal (service principal), configures credentials using the managed identity from the Azure Web App, and registers the messaging endpoint.

---

## Prerequisites

| What | Why |
|---|---|
| `a365.config.json` | Must have blueprint display name and Azure settings |
| **Agent ID Developer** or **Agent ID Administrator** role | Required to create blueprints |
| Azure infrastructure | Must exist (run `a365 setup infrastructure` first, or use `--no-endpoint`) |

---

## Syntax

```shell
a365 setup blueprint [options]
```

| Option | Description |
|---|---|
| `-c`, `--config <path>` | Config file path |
| `-v`, `--verbose` | Detailed output |
| `--dry-run` | Show what would be created |
| `--no-endpoint` | Create blueprint without registering messaging endpoint |
| `--endpoint-only` | Register endpoint on existing blueprint |
| `-h`, `--help` | Show help |

---

## What It Creates

| Object | Details |
|---|---|
| **Agent identity blueprint** | Entra application with `@odata.type: Microsoft.Graph.AgentIdentityBlueprint` |
| **Blueprint principal** | Service principal in the tenant |
| **Credentials** | Managed identity FIC from the Azure Web App |
| **Messaging endpoint** | URL registered for bot messaging (unless `--no-endpoint`) |

---

## Output

Updates `a365.generated.config.json` with:

```json
{
  "agentBlueprintId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "agentBlueprintObjectId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "agentBlueprintServicePrincipalObjectId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "agentBlueprintClientSecret": "xxx~xxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "managedIdentityPrincipalId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "messagingEndpoint": "https://your-app.azurewebsites.net/api/messages"
}
```

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/setup#setup-blueprint" target="_blank">a365 setup blueprint reference</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/registration" target="_blank">Setup agent blueprint guide</a>
