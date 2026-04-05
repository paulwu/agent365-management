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
- [Multi-Agent Deployment Scenarios](#multi-agent-deployment-scenarios)
  - [How Commands Relate](#how-commands-relate)
  - [Example: 3 Agents, 2 Blueprints](#example-3-agents-2-blueprints)
  - [When to Create a Separate Blueprint](#when-to-create-a-separate-blueprint)
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

## Multi-Agent Deployment Scenarios

### How Commands Relate

Each `a365 config init` + `a365 setup all` cycle creates **one blueprint with one set of Azure infrastructure**. Agent identities are created from blueprints, and multiple agents can share the same blueprint if they need the same permissions, credentials, and governance boundary.

**Key relationships:**

| Object | Created By | How Many Per Blueprint |
|---|---|---|
| `a365.config.json` | `a365 config init` | 1 per project/agent |
| Azure infrastructure | `a365 setup infrastructure` | 1 per project |
| Agent identity blueprint | `a365 setup blueprint` | 1 per blueprint |
| Agent identity | Graph API (`POST /beta/serviceprincipals/Microsoft.Graph.AgentIdentity`) | Many (up to 250) |
| Agent's user account | Graph API (`POST /beta/users` with `agentIdUser` type) | 1 per agent identity (optional) |

### Example: 3 Agents, 2 Blueprints

Imagine you need to deploy:
- **Agent A** — Sales Assistant (North America)
- **Agent B** — Sales Assistant (Europe) — same type as Agent A, shares its blueprint
- **Agent C** — HR Benefits Bot — different purpose, needs its own blueprint

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                         YOUR TENANT                                     │
│                                                                         │
│  ┌─── Project 1: Sales Assistant ──────────────────────────────────┐    │
│  │                                                                  │    │
│  │  a365 config init  ←── run ONCE for this project                 │    │
│  │  a365 setup all    ←── creates 1 Azure infra + 1 blueprint       │    │
│  │  a365 deploy       ←── deploys code once                         │    │
│  │  a365 publish      ←── creates manifest.zip once                 │    │
│  │                                                                  │    │
│  │  Blueprint: "Sales Assistant Blueprint"                          │    │
│  │  Azure: rg-sales-assistant / webapp-sales-assistant              │    │
│  │                                                                  │    │
│  │  ┌──────────────────┐    ┌──────────────────┐                    │    │
│  │  │  Agent Identity A │    │  Agent Identity B │                   │    │
│  │  │  "Sales NA"       │    │  "Sales EU"       │                   │    │
│  │  │                   │    │                   │                    │    │
│  │  │  ┌─────────────┐  │    │  ┌─────────────┐  │                   │    │
│  │  │  │ Agent User A │  │    │  │ Agent User B │  │  ← optional     │    │
│  │  │  └─────────────┘  │    │  └─────────────┘  │                   │    │
│  │  └──────────────────┘    └──────────────────┘                    │    │
│  │       ▲                        ▲                                  │    │
│  │       └── Graph API call ──────┘  (not CLI — manual or script)   │    │
│  └──────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─── Project 2: HR Benefits Bot ──────────────────────────────────┐    │
│  │                                                                  │    │
│  │  a365 config init  ←── run ONCE for this project                 │    │
│  │  a365 setup all    ←── creates 1 Azure infra + 1 blueprint       │    │
│  │  a365 deploy       ←── deploys code once                         │    │
│  │  a365 publish      ←── creates manifest.zip once                 │    │
│  │                                                                  │    │
│  │  Blueprint: "HR Benefits Bot Blueprint"                          │    │
│  │  Azure: rg-hr-benefits / webapp-hr-benefits                      │    │
│  │                                                                  │    │
│  │  ┌──────────────────┐                                            │    │
│  │  │  Agent Identity C │                                           │    │
│  │  │  "HR Benefits"    │                                           │    │
│  │  │                   │                                            │    │
│  │  │  ┌─────────────┐  │                                           │    │
│  │  │  │ Agent User C │  │  ← optional                              │    │
│  │  │  └─────────────┘  │                                           │    │
│  │  └──────────────────┘                                            │    │
│  │       ▲                                                           │    │
│  │       └── Graph API call (not CLI)                                │    │
│  └──────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

### Command Count for This Scenario

| Command | Project 1 (Sales) | Project 2 (HR) | Total |
|---|---|---|---|
| `a365 config init` | 1 | 1 | **2** |
| `a365 setup all` | 1 | 1 | **2** |
| `a365 deploy` | 1 | 1 | **2** |
| `a365 publish` | 1 | 1 | **2** |
| Graph API: create agent identity | 2 (Agent A + B) | 1 (Agent C) | **3** |
| Graph API: create agent's user account | 0–2 (if needed) | 0–1 (if needed) | **0–3** |

### Key Insight

- **`config init` + `setup all`** = **once per blueprint** (i.e., once per distinct agent type/project)
- **Agent identities** = created from the blueprint via **Graph API** (not CLI) — one per deployed instance
- Agents that share the same permissions, credentials, and governance boundary → **share one blueprint**
- Agents with different permission needs → **separate blueprints, separate `config init` + `setup all` runs**

### When to Create a Separate Blueprint

| Scenario | Same Blueprint? |
|---|---|
| Same agent type, different regions/teams | ✅ Yes — share one blueprint |
| Same agent type, different permission needs | ❌ No — separate blueprints |
| Different agent types entirely | ❌ No — separate blueprints |
| Same agent, dev vs. prod environment | ❌ No — separate blueprints (different credentials) |

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
