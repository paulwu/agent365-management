# Agent 365 Management — Repository Guide

## Purpose

This repository is a knowledge base for managing and governing AI agents in Microsoft 365 using **Microsoft Agent 365**, **Microsoft Entra Agent ID**, and the **Agent Registry**. It consolidates research from multiple sources into actionable guidance for IT administrators.

## Folder Structure

```
Agent365-Management/
├── sources/          ← Raw research documents (primary knowledge sources)
│   ├── ChatGPT.md        Source-cited reference with Microsoft Learn links
│   ├── Gemini.md         Prescriptive FAQ-style operational guide
│   └── Researcher.md    Implementation guide with summary tables
├── docs/             ← Synthesized topic guides (generated from sources)
│   ├── licensing-roles-enrollment.md    Licenses, Entra roles, Frontier enrollment, GA status
│   ├── enabling-legacy-agents.md        Enabling agents from Copilot Studio and Foundry
│   ├── enabling-code-built-agents.md    Registering agents built with non-Microsoft tools
│   └── README.md                        This file
├── scripts/          ← Automation scripts and tooling
│   ├── Register-Agent.ps1               PowerShell script to register agents via Graph API
│   ├── agent-metadata.json.example      Sample metadata file (copy to agent-metadata.json)
│   └── README.md                        Field-by-field guide, roles, and app registration setup
└── .github/
    └── copilot-instructions.md          Instructions for GitHub Copilot sessions
```

## How to Use This Repository

### Looking for guidance on a specific topic?

Start with the **docs/** folder. Each document covers one topic end-to-end:

| Document | Covers |
|---|---|
| [licensing-roles-enrollment.md](licensing-roles-enrollment.md) | What licenses you need, which Entra roles to assign, how to enroll in the Frontier preview, and the current GA status |
| [enabling-legacy-agents.md](enabling-legacy-agents.md) | Step-by-step process to make existing Copilot Studio and Foundry agents visible in Agent 365 |
| [enabling-code-built-agents.md](enabling-code-built-agents.md) | Two patterns for registering agents built with non-Microsoft tools (registry-only vs. full Entra Agent ID) |

### Need the original source material?

The **sources/** folder contains the unedited research from different AI assistants. These documents cover overlapping topics from different angles and are the basis for everything in **docs/**.

### Updating documentation

When new information becomes available, add or update files in **sources/** first, then regenerate or update the corresponding **docs/** files to reflect the changes.
