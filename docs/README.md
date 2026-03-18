# Agent 365 Management — Repository Guide

## Purpose

This repository is a knowledge base for managing and governing AI agents in Microsoft 365 using **Microsoft Agent 365**, **Microsoft Entra Agent ID**, and the **Agent Registry**. It consolidates research from multiple sources into actionable guidance for IT administrators.

## Folder Structure

```
Agent365-Management/
├── sources/          ← Raw research documents (primary knowledge sources)
│   ├── ChatGPT.md            Source-cited reference with Microsoft Learn links
│   ├── Gemini.md             Prescriptive FAQ-style operational guide
│   ├── Researcher.md         Implementation guide with summary tables
│   ├── Microsoft-Learn.md    Official Microsoft Learn pages (5 articles on Agent 365 admin)
│   └── Microsoft-Learn-Entra-AgentID.md  Cached Entra Agent ID docs (73 pages indexed)
├── docs/             ← Synthesized topic guides (generated from sources)
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
│   └── README.md                          This file
├── scripts/          ← Automation scripts and tooling
│   ├── Create-Blueprint.ps1           Create an agent identity blueprint (Entra Agent ID)
│   ├── blueprint-input.json.example   Sample blueprint input (copy to blueprint-input.json)
│   ├── Register-Agent.ps1             Register an agent in the Agent Registry via Graph API
│   ├── agent-metadata.json.example    Sample agent metadata (copy to agent-metadata.json)
│   ├── Discover-ShadowAgents.ps1      Scan tenant for ungoverned/shadow agents; outputs CSV report
│   └── README.md                      Field-by-field guides, roles, and app registration setup
└── .github/
    ├── copilot-instructions.md        Instructions for GitHub Copilot sessions
    └── agents/
        └── entra-researcher.agent.md  @entra-researcher custom agent for Microsoft Learn grounding
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

### Need the original source material?

The **sources/** folder contains the unedited research from different AI assistants. These documents cover overlapping topics from different angles and are the basis for everything in **docs/**.

### Updating documentation

When new information becomes available, add or update files in **sources/** first, then regenerate or update the corresponding **docs/** files to reflect the changes.
