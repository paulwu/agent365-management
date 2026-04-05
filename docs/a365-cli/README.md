# Agent 365 CLI Command Reference

> Based on Microsoft Learn Agent 365 CLI documentation (preview). Content may change as the product evolves.

The Agent 365 CLI (`a365`) is a cross-platform .NET command-line tool for building, deploying, and managing AI agents for Microsoft 365. This section documents each command with its purpose, inputs, prerequisites, and expected outputs.

> Throughout this documentation, "blueprint" refers to **agent identity blueprint** — the official Microsoft Learn term.

**Install:**

```shell
dotnet tool install --global Microsoft.Agents.A365.DevTools.Cli --prerelease
```

<details>
<summary><strong>📑 Table of Contents</strong></summary>

- [Prerequisites](#prerequisites)
- [Command Overview](#command-overview)
- [Typical Workflow](#typical-workflow)
- [Command Details](#command-details)
- [Related Pages](#related-pages)

</details>

---

## Prerequisites

| Requirement | Details |
|---|---|
| **.NET 8.0** | Required runtime for the CLI |
| **Azure CLI** | Must be logged in (`az login`) before running most commands |
| **Entra roles** | Agent ID Developer or Agent ID Administrator (varies by command) |
| **Azure subscription** | Contributor or Owner role for infrastructure commands |
| **Client app registration** | Required for authentication — see [Prerequisite: Client App Registration](../prerequisite-client-app-registration.md) |
| **Frontier program** | Must be enrolled in the Microsoft 365 Copilot Frontier preview |

---

## Command Overview

| Command | Purpose | Min Role |
|---|---|---|
| [`config init`](./config-init.md) | Interactive wizard to create `a365.config.json` | None (local) |
| [`config display`](./config-display.md) | Show current configuration settings | None (local) |
| [`setup requirements`](./setup-requirements.md) | Validate prerequisites | Agent ID Developer |
| [`setup infrastructure`](./setup-infrastructure.md) | Create Azure resources (Resource Group, App Service Plan, Web App) | Azure Contributor |
| [`setup blueprint`](./setup-blueprint.md) | Create the agent identity blueprint in Entra ID | Agent ID Developer |
| [`setup permissions mcp`](./setup-permissions.md#mcp) | Configure MCP server OAuth2 grants | Global Administrator |
| [`setup permissions bot`](./setup-permissions.md#bot) | Configure Messaging Bot API permissions | Global Administrator |
| [`setup permissions custom`](./setup-permissions.md#custom) | Add custom API permissions to the blueprint | Global Administrator |
| [`setup permissions copilotstudio`](./setup-permissions.md#copilotstudio) | Configure Copilot Studio invocation permissions | Global Administrator |
| [`setup all`](./setup-all.md) | Run all setup steps in sequence | Agent ID Developer + Azure Contributor |
| [`setup admin`](./setup-admin.md) | Complete OAuth2 grants (Global Admin handoff) | Global Administrator |
| [`deploy`](./deploy.md) | Deploy app binaries + update MCP permissions | Azure Contributor + Global Administrator |
| [`publish`](./publish.md) | Create manifest.zip for M365 admin center upload | None (local) |
| [`cleanup`](./cleanup.md) | Remove all resources (blueprint, instance, Azure) | Varies |

---

## Typical Workflow

```text
1. az login                         # Authenticate to Azure
2. a365 config init                 # Create a365.config.json (interactive wizard)
3. a365 setup all                   # Create Azure infra + blueprint + permissions
   └─ (if not Global Admin)
      a365 setup admin              # Global Admin completes OAuth2 grants
4. a365 deploy                      # Deploy agent code to Azure + update MCP permissions
5. a365 publish                     # Create manifest.zip
6. Upload manifest.zip via M365 admin center
7. Create agent instance in Teams → Apps → Add
```

---

## Command Details

Each command is documented on its own page:

| Page | Covers |
|---|---|
| [config-init.md](./config-init.md) | `a365 config init` — create configuration interactively |
| [config-display.md](./config-display.md) | `a365 config display` — view current settings |
| [setup-requirements.md](./setup-requirements.md) | `a365 setup requirements` — validate prerequisites |
| [setup-infrastructure.md](./setup-infrastructure.md) | `a365 setup infrastructure` — create Azure resources |
| [setup-blueprint.md](./setup-blueprint.md) | `a365 setup blueprint` — create blueprint in Entra |
| [setup-permissions.md](./setup-permissions.md) | `a365 setup permissions` (mcp, bot, custom, copilotstudio) |
| [setup-all.md](./setup-all.md) | `a365 setup all` — complete setup in one command |
| [setup-admin.md](./setup-admin.md) | `a365 setup admin` — Global Admin OAuth2 handoff |
| [deploy.md](./deploy.md) | `a365 deploy` — deploy to Azure + update permissions |
| [publish.md](./publish.md) | `a365 publish` — create manifest package |
| [cleanup.md](./cleanup.md) | `a365 cleanup` — remove resources |

---

## Related Pages

- [Prerequisite: Client App Registration](../prerequisite-client-app-registration.md)
- [Use Case: Teams Chat via Agent's User Account](../Use-Case-Teams-Chat-via-Agent-User-Account.md)
- [Developer Guide: Agent Identity Platform](../developer-identity-platform.md)

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/agent-365-cli" target="_blank">Agent 365 CLI</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/" target="_blank">Agent 365 CLI Reference</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/a365-config" target="_blank">Agent 365 CLI Configuration</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/registration" target="_blank">Setup agent blueprint</a>
- <a href="https://github.com/microsoft/Agent365-devTools" target="_blank">Agent 365 DevTools GitHub</a>
