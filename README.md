# Agent 365 Management — Repository Guide

## Purpose

This repository is a knowledge base for managing and governing AI agents in Microsoft 365 using **Microsoft Agent 365**, **Microsoft Entra Agent ID**, and the **Agent Registry**. It is designed to answer questions about Agent 365 governance, identity, and security — grounded on the [official Microsoft Learn Entra Agent ID documentation](https://learn.microsoft.com/en-us/entra/agent-id/) as well as curated knowledge compiled from multiple research sources. Each knowledge note carries a **Priority** attribute (1 = highest, higher = less authoritative) so that when sources conflict, the system knows which to prefer. The repository also caches key Microsoft Learn pages locally in `notes/` for faster lookups and offline access when the internet is not reachable.

The repository includes five custom [Copilot agents](docs/github-copilot-primer/README.md):

| Agent | Invoke with | Purpose |
|---|---|---|
| **Entra Researcher** | `@entra-researcher` | Provides authoritative, source-cited answers about agent identities, blueprints, registry, governance, and security. Cross-references live Microsoft Learn content with local notes, flags contradictions, and saves every response to `copilot-playground/`. |
| **Notes Author** | `@notes-author` | Creates and maintains research notes in `notes/`, enforcing the required YAML frontmatter format (`Author` and `Priority` fields) and the canonical priority scale. The Entra Researcher defers to this agent for note format rules. |
| **BluePrint Creator** | `@blueprint-creator` | Interactive wizard that creates an Entra Agent ID blueprint — auto-detects tenant via `az account show`, checks prerequisites, collects inputs, generates `blueprint-input.json`, and provides the command to run `Create-Blueprint.ps1`. **Requires interactive mode.** |
| **Shadow Agent Discovery Prep** | `@shadow-agent-discovery-prep` | Prepares your environment for scanning — auto-detects tenant, checks/installs PowerShell and Graph module, verifies Entra roles via `az rest`, configures scan options, and provides the exact command to run `Discover-ShadowAgents.ps1`. **Requires interactive mode.** |
| **AgentId Registration Helper** | `@agentid-registration-helper` | Registers an agent in the Entra Agent Registry — auto-detects tenant via `az account show`, determines Pattern A vs. B, collects all metadata fields, generates `agent-metadata.json`, and provides the command to run `Register-Agent.ps1`. **Requires interactive mode.** |

## Table of Contents

- [How to Use This Repository](#how-to-use-this-repository)
  - [Topic Guides](#looking-for-guidance-on-a-specific-topic)
  - [Source Material](#need-the-original-source-material)
  - [Updating Documentation](#updating-documentation)
- [Using the Copilot Agents](#using-the-copilot-agents)
  - [Prerequisites for Wizard Agents](#️-before-using-the-wizard-agents)
  - [@entra-researcher](#entra-researcher--entra-agent-id-research-agent)
  - [@blueprint-creator](#blueprint-creator--interactive-blueprint-creation-wizard)
  - [@shadow-agent-discovery-prep](#shadow-agent-discovery-prep--shadow-agent-discovery-prep-wizard)
  - [@agentid-registration-helper](#agentid-registration-helper--agent-registry-registration-wizard)
  - [@notes-author](#notes-author--research-notes-author)
  - [Priority Scale Reference](#priority-scale-reference)
- [Folder Structure](#folder-structure)

## How to Use This Repository

### Looking for guidance on a specific topic?

Start with the **docs/** folder. The **five pillar documents** provide comprehensive operational guidance:

| Document | Covers |
|---|---|
| [pillar-registry.md](docs/pillar-registry.md) | **Registry** — How to identify rogue agents, onboard them, and prevent future rogue agents |
| [pillar-access-control.md](docs/pillar-access-control.md) | **Access Control** — Conditional Access, ID Protection, lifecycle governance, least-privilege |
| [pillar-visualization.md](docs/pillar-visualization.md) | **Visualization** — Overview dashboard, Agent Map, metrics, and monitoring routines |
| [pillar-interoperability.md](docs/pillar-interoperability.md) | **Interoperability** — MCP tooling servers, custom servers, governed tool access |
| [pillar-security.md](docs/pillar-security.md) | **Security** — Posture, detection, runtime defense, data protection, Purview/Defender |

Additional topic guides:

| Document | Covers |
|---|---|
| [licensing-roles-enrollment.md](docs/licensing-roles-enrollment.md) | What licenses you need, which Entra roles to assign, how to enroll in the Frontier preview, and the current GA status |
| [enabling-legacy-agents.md](docs/enabling-legacy-agents.md) | Step-by-step process to make existing Copilot Studio and Foundry agents visible in Agent 365 |
| [enabling-code-built-agents.md](docs/enabling-code-built-agents.md) | Two patterns for registering agents built with non-Microsoft tools (registry-only vs. full Entra Agent ID) |
| [developer-identity-platform.md](docs/developer-identity-platform.md) | Developer guide: blueprint creation (Graph API + PowerShell), OAuth flows, owners/sponsors/managers |
| [entra-sdk-agent-id.md](docs/entra-sdk-agent-id.md) | Entra SDK for Agent ID: companion container architecture, token flows, scenarios, security requirements |
| [agent-blueprint-vs-registration.md](docs/agent-blueprint-vs-registration.md) | Relationship diagram: blueprint creation vs. agent registration; Pattern A vs. Pattern B end-to-end flow |
| [identity-blueprint/README.md](docs/identity-blueprint/README.md) | Landing page for the identity blueprint doc set: definition, contents, usage, scenarios, and migration |
| [identity-blueprint/what-is-an-identity-blueprint.md](docs/identity-blueprint/what-is-an-identity-blueprint.md) | Defines the blueprint object, its four roles, and its relationship to blueprint principals and agent identities |
| [identity-blueprint/blueprint-contents-explainer.md](docs/identity-blueprint/blueprint-contents-explainer.md) | Explains which settings live on the blueprint, how credentials work, and when to separate blueprints |
| [identity-blueprint/how-blueprints-are-used.md](docs/identity-blueprint/how-blueprints-are-used.md) | Shows the provisioning, runtime authentication, and governance lifecycle for blueprint-backed agents |
| [identity-blueprint/when-to-use-identity-blueprints.md](docs/identity-blueprint/when-to-use-identity-blueprints.md) | Scenario guide for choosing full Entra Agent ID versus registry-only or product-managed paths |
| [identity-blueprint/migrating-legacy-agents.md](docs/identity-blueprint/migrating-legacy-agents.md) | Modernization paths for registry-only, older Copilot Studio, and custom legacy agents |
| [github-copilot-primer/README.md](docs/github-copilot-primer/README.md) | Overview: how Copilot instructions, custom agents, and MCP servers work together in this project |
| [github-copilot-primer/copilot-instructions.md](docs/github-copilot-primer/copilot-instructions.md) | What Copilot instructions are, types of instruction files, and best practices |
| [github-copilot-primer/custom-agents.md](docs/github-copilot-primer/custom-agents.md) | How to create and configure custom Copilot agents with `.agent.md` profiles |
| [github-copilot-primer/mcp-servers-and-skills.md](docs/github-copilot-primer/mcp-servers-and-skills.md) | MCP servers, skills, tool extensibility, and security considerations |

### Need the original source material?

The **notes/** folder contains the unedited research from different AI assistants. These documents cover overlapping topics from different angles and are the basis for everything in **docs/**.

### Updating documentation

When new information becomes available, add or update files in **notes/** first, then regenerate or update the corresponding **docs/** files to reflect the changes.

### Using the Copilot Agents

Five custom Copilot agents are available in VS Code Copilot Chat (or GitHub.com Copilot Chat) when this repository is open. Invoke them with `@agent-name` followed by your question or instruction.

#### ⚠️ Before Using the Wizard Agents

The three wizard agents (`@blueprint-creator`, `@shadow-agent-discovery-prep`, `@agentid-registration-helper`) require interactive input and Azure access. Before invoking them:

1. **Switch to interactive mode** — Press **Shift+Tab** to exit autopilot mode. The wizards require multi-step user input and will skip ahead or terminate prematurely in autopilot mode.

2. **Log in to Azure CLI** — The wizards use `az account show` to auto-detect your tenant and `az rest` to verify your Entra roles. Run this first:
   ```bash
   az login
   ```

3. **Ensure PowerShell 7 is installed** — The wizards will check and attempt to install it, but having it ready saves time:
   ```bash
   pwsh --version
   ```

---

#### `@entra-researcher` — Entra Agent ID Research Agent

Ask questions about Microsoft Entra Agent ID. The agent:

1. **Fetches live content** from Microsoft Learn Entra Agent ID documentation
2. **Cross-references** with the cached baseline in `notes/Microsoft-Learn-Entra-AgentID.md`
3. **Checks curated notes** in `notes/` (ChatGPT.md, Gemini.md, Researcher.md, Microsoft-Learn.md)
4. **Flags contradictions** between sources with ⚠️ warnings, listing Author and Priority so you can correct stale notes
5. **References repository scripts** in `scripts/` when a workflow can be expedited with existing automation
6. **Saves every response** to `copilot-playground/response-YY-MM-DD-HH-MM-SS.md` (Pacific Time)

##### Example 1 — Ask How to Create a Blueprint

```
@entra-researcher How do I create an agent identity blueprint for my custom Python agent?
```

The agent will provide the full step-by-step Graph API calls **and** reference `scripts/Create-Blueprint.ps1` as a ready-to-use alternative, including the Quick Start commands.

##### Example 2 — Register an Agent in the Agent Registry

```
@entra-researcher How do I register my code-built agent in the Entra Agent Registry?
```

The agent will explain the `POST /beta/agentRegistry/agentInstances` API call, the required `AgentInstance.ReadWrite.All` permission, and point you to `scripts/Register-Agent.ps1` with the `agent-metadata.json.example` template.

##### Example 3 — Ask About a Specific Concept

```
@entra-researcher What is the difference between an agent identity and an agent user?
```

```
@entra-researcher What OAuth flows are supported for agent identities?
```

The agent will fetch the relevant Microsoft Learn pages, synthesize an answer, and cite the specific documentation URLs.

##### Example 4 — C# or Python Integration

```
@entra-researcher I have a C# agent — how do I integrate it with Entra Agent ID to call Microsoft Graph?
```

```
@entra-researcher Show me how to use the Agent ID SDK sidecar container with a FastAPI Python app.
```

The agent will provide language-specific guidance: native NuGet packages (`Microsoft.Identity.Web.AgentIdentities`) for .NET, or the containerized sidecar SDK for Python and other languages.

##### Example 5 — Discover Shadow Agents

```
@entra-researcher How do I find unregistered or shadow agents in my tenant?
```

The agent will explain the discovery approach and reference `scripts/Discover-ShadowAgents.ps1`, which scans for agent-tagged service principals, ownerless apps, high-privilege permissions, and stale credentials.

##### Example 6 — Governance and Security

```
@entra-researcher What Conditional Access policies can I apply to agent identities?
```

```
@entra-researcher How does Identity Protection work for agents?
```

The agent will fetch the relevant Entra governance/security pages and provide grounded recommendations.

---

#### `@blueprint-creator` — Interactive Blueprint Creation Wizard

A step-by-step operational wizard that creates an Entra Agent ID blueprint from scratch. It checks prerequisites, collects inputs, generates the configuration file, and runs the script.

##### Example 1 — Start the Wizard

```
@blueprint-creator I want to create a new agent identity blueprint
```

The agent will walk you through a 10-step process: checking PowerShell, verifying your tenant login, validating Entra roles, collecting blueprint fields, generating `blueprint-input.json`, and executing `scripts/Create-Blueprint.ps1`.

##### Example 2 — Resume After Fixing a Prerequisite

```
@blueprint-creator I've activated the Agent ID Developer role, let's continue
```

The agent remembers where you left off and re-validates before proceeding.

##### Example 3 — Create a Blueprint for Production

```
@blueprint-creator Create a blueprint using managed identity credentials for a production agent
```

The agent will guide you through the managed identity FIC configuration path, collecting the managed identity principal ID and other required fields.

---

#### `@shadow-agent-discovery-prep` — Shadow Agent Discovery Prep Wizard

A preparation wizard that ensures your environment is ready to scan for shadow agents, then gives you the exact command to run.

##### Example 1 — Prepare for a Scan

```
@shadow-agent-discovery-prep I want to scan my tenant for shadow agents
```

The agent will check PowerShell, install the Graph module if needed, configure scan options, and give you a ready-to-paste command to run in your terminal (where you can complete browser-based authentication).

##### Example 2 — Prepare with Sign-In Log Analysis

```
@shadow-agent-discovery-prep Prepare a discovery scan including sign-in log analysis
```

The agent will configure the `-IncludeSignIns` flag and explain the additional `AuditLog.Read.All` permission requirement.

##### Example 3 — Quick Setup Check

```
@shadow-agent-discovery-prep Check if my environment is ready to run the shadow agent scan
```

The agent will verify PowerShell and the Graph module are installed, then provide the command.

---

#### `@agentid-registration-helper` — Agent Registry Registration Wizard

A step-by-step wizard that registers your agent in the Microsoft Entra Agent Registry, supporting both Pattern A (registry-only) and Pattern B (full Entra Agent ID).

##### Example 1 — Register a Custom Agent

```
@agentid-registration-helper I want to register my Python agent in the Agent Registry
```

The agent will walk you through a 12-step process: checking prerequisites, determining your registration pattern, collecting all metadata fields (including the agent card manifest with skills, capabilities, and security config), generating `agent-metadata.json`, and executing `scripts/Register-Agent.ps1`.

##### Example 2 — Register with Entra Agent ID (Pattern B)

```
@agentid-registration-helper Register my agent with full Entra Agent ID integration — I already have a blueprint
```

The agent will follow the Pattern B flow, collecting your `agentIdentityBlueprintId` and `agentIdentityId` in addition to the standard registry metadata.

##### Example 3 — Register a Shadow Agent Found by Discovery

```
@agentid-registration-helper I found an unregistered agent during a shadow scan — help me register it
```

The agent will guide you through creating proper registry metadata for an agent that was discovered but not yet formally registered.

---

#### `@notes-author` — Research Notes Author

Create or modify research notes in `notes/`. The agent enforces the required YAML frontmatter (`Author`, `Priority`) and the canonical priority scale.

##### Example 1 — Create a New Research Note

```
@notes-author Create a new note about Entra Agent ID Conditional Access policies based on this Microsoft Learn page: https://learn.microsoft.com/en-us/entra/identity/conditional-access/agent-id
```

The agent will create a properly formatted note in `notes/` with the correct frontmatter headers and priority level.

##### Example 2 — Update an Existing Note

```
@notes-author Update notes/ChatGPT.md to add a section about agent registry collections
```

The agent will edit the note while preserving its existing frontmatter, citation style, and structure.

##### Example 3 — Fix a Contradiction Flagged by Entra Researcher

When `@entra-researcher` flags a contradiction (e.g., a note says something different from Microsoft Learn), use `@notes-author` to correct it:

```
@notes-author In notes/Gemini.md, the section on agent identity tenancy says agents can access resources across tenants. Microsoft Learn says they can only be issued tokens in the tenant where they're created. Please correct the note.
```

#### Priority Scale Reference

| Priority | Meaning | Example |
|---|---|---|
| 1 | Verified in-session (human-confirmed) | Manual corrections |
| 2 | Cached Microsoft Learn content | `notes/Microsoft-Learn-Entra-AgentID.md` |
| 3 | Other official documentation | Microsoft blog posts, whitepapers |
| 4 | AI-generated research | `notes/ChatGPT.md`, `notes/Gemini.md` |
| 5+ | Community / speculative | Forum posts, early previews |

---

## Folder Structure

<details>
<summary>Click to expand the full directory tree</summary>

```
Agent365-Management/
├── notes/            ← Raw research documents (primary knowledge notes)
│   ├── ChatGPT.md            Source-cited reference with Microsoft Learn links
│   ├── Gemini.md             Prescriptive FAQ-style operational guide
│   ├── Researcher.md         Implementation guide with summary tables
│   ├── Microsoft-Learn.md    Official Microsoft Learn pages (5 articles on Agent 365 admin)
│   └── Microsoft-Learn-Entra-AgentID.md  Cached Entra Agent ID docs (73 pages indexed)
├── README.md             ← This file
├── docs/             ← Synthesized topic guides (generated from notes)
│   ├── pillar-registry.md             Pillar 1: Registry — discover, onboard, prevent rogue agents
│   ├── pillar-access-control.md       Pillar 2: Access Control — Conditional Access, governance, least-privilege
│   ├── pillar-visualization.md        Pillar 3: Visualization — dashboard, Agent Map, monitoring
│   ├── pillar-interoperability.md     Pillar 4: Interoperability — MCP servers, tooling gateway
│   ├── pillar-security.md             Pillar 5: Security — posture, detection, runtime defense, data protection
│   ├── licensing-roles-enrollment.md  Licenses, Entra roles, Frontier enrollment, GA status
│   ├── enabling-legacy-agents.md      Enabling agents from Copilot Studio and Foundry
│   ├── enabling-code-built-agents.md      Registering agents built with non-Microsoft tools
│   ├── developer-identity-platform.md    Developer guide: blueprints, OAuth flows, admin relationships
│   ├── entra-sdk-agent-id.md             Entra SDK for Agent ID: companion container, scenarios, security
│   ├── agent-blueprint-vs-registration.md Relationship diagram: blueprint creation vs. agent registration
│   ├── github-copilot-primer/
│   │   ├── README.md                        Overview: how instructions, agents, and MCP servers work together
│   │   ├── copilot-instructions.md          What Copilot instructions are and how to write them
│   │   ├── custom-agents.md                 How to create and configure custom Copilot agents
│   │   └── mcp-servers-and-skills.md        MCP servers, skills, and tool extensibility
│   └── identity-blueprint/
│       ├── README.md                         Landing page for identity blueprint guidance
│       ├── what-is-an-identity-blueprint.md Definition, roles, and object relationships
│       ├── blueprint-contents-explainer.md  Shared settings, credentials, and governance boundary
│       ├── how-blueprints-are-used.md       Provisioning, runtime auth, and operational flow
│       ├── when-to-use-identity-blueprints.md Scenario-based decision guide
│       └── migrating-legacy-agents.md       Modernization paths for older agents
├── scripts/          ← Automation scripts and tooling
│   ├── Create-Blueprint.ps1           Create an agent identity blueprint (Entra Agent ID)
│   ├── blueprint-input.json.example   Sample blueprint input (copy to blueprint-input.json)
│   ├── Register-Agent.ps1             Register an agent in the Agent Registry via Graph API
│   ├── agent-metadata.json.example    Sample agent metadata (copy to agent-metadata.json)
│   ├── Discover-ShadowAgents.ps1      Scan tenant for ungoverned/shadow agents; outputs CSV report
│   └── README.md                      Field-by-field guides, roles, and app registration setup
├── copilot-playground/   ← Saved @Entra-Researcher responses (auto-generated)
│   └── response-*.md               Timestamped response files (Pacific Time)
├── discovery/            ← Shadow agent scan reports (generated by Discover-ShadowAgents.ps1)
│   └── shadow-agents-report.csv    CSV report with risk indicators (not committed)
└── .github/
    ├── copilot-instructions.md        Instructions for GitHub Copilot sessions
    └── agents/
        ├── Entra-Researcher.agent.md           @entra-researcher for Microsoft Learn grounding
        ├── Notes-Author.agent.md               @notes-author for creating/maintaining notes
        ├── BluePrint-Creator.agent.md          @blueprint-creator wizard for blueprint creation
        ├── Shadow-Agent-Discovery-Prep.agent.md @shadow-agent-discovery-prep env prep wizard
        └── AgentId-Registration-Helper.agent.md @agentid-registration-helper wizard for registry
```

</details>
