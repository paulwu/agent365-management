# Agent 365 Management — Repository Guide

## Purpose

This repository is a knowledge base for managing and governing AI agents in Microsoft 365 using **Microsoft Agent 365**, **Microsoft Entra Agent ID**, and the **Agent Registry**. It is designed to answer questions about Agent 365 governance, identity, and security — grounded on the [official Microsoft Learn Entra Agent ID documentation](https://learn.microsoft.com/en-us/entra/agent-id/) as well as curated knowledge compiled from multiple research sources. Each knowledge note carries a **Priority** attribute (1 = highest, higher = less authoritative) so that when sources conflict, the system knows which to prefer. The repository also caches key Microsoft Learn pages locally in `notes/` for faster lookups and offline access when the internet is not reachable.

The repository includes three custom Copilot agents:

| Agent | Invoke with | Purpose |
|---|---|---|
| **Entra Researcher** | `@entra-researcher` | Provides authoritative, source-cited answers about agent identities, blueprints, registry, governance, and security. Cross-references live Microsoft Learn content with local notes, flags contradictions, and saves every response to `copilot-playground/`. |
| **Notes Author** | `@notes-author` | Creates and maintains research notes in `notes/`, enforcing the required YAML frontmatter format (`Author` and `Priority` fields) and the canonical priority scale. The Entra Researcher defers to this agent for note format rules. |

## Folder Structure

```
Agent365-Management/
├── notes/            ← Raw research documents (primary knowledge notes)
│   ├── ChatGPT.md            Source-cited reference with Microsoft Learn links
│   ├── Gemini.md             Prescriptive FAQ-style operational guide
│   ├── Researcher.md         Implementation guide with summary tables
│   ├── Microsoft-Learn.md    Official Microsoft Learn pages (5 articles on Agent 365 admin)
│   └── Microsoft-Learn-Entra-AgentID.md  Cached Entra Agent ID docs (73 pages indexed)
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
│   ├── identity-blueprint/
│   │   ├── README.md                         Landing page for identity blueprint guidance
│   │   ├── what-is-an-identity-blueprint.md Definition, roles, and object relationships
│   │   ├── blueprint-contents-explainer.md  Shared settings, credentials, and governance boundary
│   │   ├── how-blueprints-are-used.md       Provisioning, runtime auth, and operational flow
│   │   ├── when-to-use-identity-blueprints.md Scenario-based decision guide
│   │   └── migrating-legacy-agents.md       Modernization paths for older agents
│   └── README.md                          This file
├── scripts/          ← Automation scripts and tooling
│   ├── Create-Blueprint.ps1           Create an agent identity blueprint (Entra Agent ID)
│   ├── blueprint-input.json.example   Sample blueprint input (copy to blueprint-input.json)
│   ├── Register-Agent.ps1             Register an agent in the Agent Registry via Graph API
│   ├── agent-metadata.json.example    Sample agent metadata (copy to agent-metadata.json)
│   ├── Discover-ShadowAgents.ps1      Scan tenant for ungoverned/shadow agents; outputs CSV report
│   └── README.md                      Field-by-field guides, roles, and app registration setup
├── copilot-playground/   ← Saved @Entra-Researcher responses (auto-generated)
│   └── response-*.md               Timestamped response files (Pacific Time)
└── .github/
    ├── copilot-instructions.md        Instructions for GitHub Copilot sessions
    └── agents/
        ├── Entra-Researcher.agent.md  @entra-researcher custom Copilot agent for Microsoft Learn grounding
        └── Notes-Author.agent.md      @notes-author agent for creating/maintaining notes with headers
```

## How to Use This Repository

### Looking for guidance on a specific topic?

Start with the **docs/** folder. The **five pillar documents** provide comprehensive operational guidance:

| Document | Covers |
|---|---|
| [pillar-registry.md](pillar-registry.md) | **Registry** — How to identify rogue agents, onboard them, and prevent future rogue agents |
| [pillar-access-control.md](pillar-access-control.md) | **Access Control** — Conditional Access, ID Protection, lifecycle governance, least-privilege |
| [pillar-visualization.md](pillar-visualization.md) | **Visualization** — Overview dashboard, Agent Map, metrics, and monitoring routines |
| [pillar-interoperability.md](pillar-interoperability.md) | **Interoperability** — MCP tooling servers, custom servers, governed tool access |
| [pillar-security.md](pillar-security.md) | **Security** — Posture, detection, runtime defense, data protection, Purview/Defender |

Additional topic guides:

| Document | Covers |
|---|---|
| [licensing-roles-enrollment.md](licensing-roles-enrollment.md) | What licenses you need, which Entra roles to assign, how to enroll in the Frontier preview, and the current GA status |
| [enabling-legacy-agents.md](enabling-legacy-agents.md) | Step-by-step process to make existing Copilot Studio and Foundry agents visible in Agent 365 |
| [enabling-code-built-agents.md](enabling-code-built-agents.md) | Two patterns for registering agents built with non-Microsoft tools (registry-only vs. full Entra Agent ID) |
| [developer-identity-platform.md](developer-identity-platform.md) | Developer guide: blueprint creation (Graph API + PowerShell), OAuth flows, owners/sponsors/managers |
| [entra-sdk-agent-id.md](entra-sdk-agent-id.md) | Entra SDK for Agent ID: companion container architecture, token flows, scenarios, security requirements |
| [agent-blueprint-vs-registration.md](agent-blueprint-vs-registration.md) | Relationship diagram: blueprint creation vs. agent registration; Pattern A vs. Pattern B end-to-end flow |
| [identity-blueprint/README.md](identity-blueprint/README.md) | Landing page for the identity blueprint doc set: definition, contents, usage, scenarios, and migration |
| [identity-blueprint/what-is-an-identity-blueprint.md](identity-blueprint/what-is-an-identity-blueprint.md) | Defines the blueprint object, its four roles, and its relationship to blueprint principals and agent identities |
| [identity-blueprint/blueprint-contents-explainer.md](identity-blueprint/blueprint-contents-explainer.md) | Explains which settings live on the blueprint, how credentials work, and when to separate blueprints |
| [identity-blueprint/how-blueprints-are-used.md](identity-blueprint/how-blueprints-are-used.md) | Shows the provisioning, runtime authentication, and governance lifecycle for blueprint-backed agents |
| [identity-blueprint/when-to-use-identity-blueprints.md](identity-blueprint/when-to-use-identity-blueprints.md) | Scenario guide for choosing full Entra Agent ID versus registry-only or product-managed paths |
| [identity-blueprint/migrating-legacy-agents.md](identity-blueprint/migrating-legacy-agents.md) | Modernization paths for registry-only, older Copilot Studio, and custom legacy agents |

### Need the original source material?

The **notes/** folder contains the unedited research from different AI assistants. These documents cover overlapping topics from different angles and are the basis for everything in **docs/**.

### Updating documentation

When new information becomes available, add or update files in **notes/** first, then regenerate or update the corresponding **docs/** files to reflect the changes.

### Using the Copilot agents

Two custom Copilot agents are available in VS Code Copilot Chat when this repository is open:

**`@entra-researcher`** — Ask questions about Microsoft Entra Agent ID. The agent:

1. **Fetches live content** from Microsoft Learn Entra Agent ID documentation
2. **Cross-references** with the cached baseline in `notes/Microsoft-Learn-Entra-AgentID.md`
3. **Checks curated notes** in `notes/` (ChatGPT.md, Gemini.md, Researcher.md, Microsoft-Learn.md)
4. **Flags contradictions** between sources with ⚠️ warnings, listing Author and Priority so you can correct stale notes
5. **Saves every response** to `copilot-playground/response-YY-MM-DD-HH-MM-SS.md` (Pacific Time)

**`@notes-author`** — Create or modify notes in `notes/`. The agent enforces the required YAML frontmatter (`Author`, `Priority`) and the priority scale (1 = reserved for verified-in-session, 2 = cached Microsoft Learn, 3 = other official docs, 4 = AI research, 5+ = community).
