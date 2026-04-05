# GitHub Copilot Primer

> A quick-start guide for understanding how GitHub Copilot's customization system works and how this repository uses it.

If you're new to GitHub Copilot's agent and customization features, start here. This primer explains the three core building blocks — **instructions**, **custom agents**, and **MCP servers / skills** — then shows exactly how this repository wires them together.

<details>
<summary><strong>📑 Table of Contents</strong></summary>

- [The Three Building Blocks](#the-three-building-blocks)
  - [How They Relate](#how-they-relate)
- [How This Repository Uses Each Concept](#how-this-repository-uses-each-concept)
  - [1. Copilot Instructions → `.github/copilot-instructions.md`](#1-copilot-instructions--githubcopilot-instructionsmd)
  - [2. Custom Agents → `.github/agents/`](#2-custom-agents--githubagents)
  - [3. MCP Servers → `.github/copilot/`](#3-mcp-servers--githubcopilot)
- [Quick Reference: File Locations in This Repo](#quick-reference-file-locations-in-this-repo)
- [Further Reading](#further-reading)

</details>

## The Three Building Blocks

| Building Block | What It Does | Where It Lives |
|---|---|---|
| [**Copilot Instructions**](./copilot-instructions.md) | Give Copilot persistent, repository-specific context — conventions, build commands, architecture notes | `.github/copilot-instructions.md` |
| [**Custom Agents**](./custom-agents.md) | Create specialized personas with tailored prompts, tool access, and MCP servers | `.github/agents/<name>.agent.md` |
| [**MCP Servers & Skills**](./mcp-servers-and-skills.md) | Connect Copilot to external tools and data sources (web fetch, APIs, databases, browsers) | `.github/copilot/mcp.json` or inline in agent profiles |

### How They Relate

```text
┌─────────────────────────────────────────────────────────┐
│                    Your Repository│
│                                                          │
│  .github/                                                │
│  ├── copilot-instructions.md  ◄── Copilot Instructions   │
│  │   (applies to ALL Copilot interactions)               │
│  │                                                       │
│  ├── agents/                                             │
│  │   ├── agent-a.agent.md     ◄── Custom Agent A         │
│  │   └── agent-b.agent.md     ◄── Custom Agent B         │
│  │   (each agent has its own prompt + tool config)       │
│  │                                                       │
│  └── copilot/                                            │
│      └── mcp.json             ◄── MCP Server Config      │
│          (shared tools available to all agents)           │
└─────────────────────────────────────────────────────────┘

Flow:
1. Copilot reads copilot-instructions.md → learns repo conventions
2. User invokes @agent-a → Copilot loads agent-a's prompt + tools
3. Agent calls MCP server tools → fetches web pages, runs commands, etc.
4. Agent produces a grounded, context-aware response
```

**Key principle:** Instructions set the baseline for all interactions. Agents build on that baseline with specialized behavior. MCP servers give agents the ability to take external actions.

---

## How This Repository Uses Each Concept

### 1. Copilot Instructions → `.github/copilot-instructions.md`

This file tells Copilot about the repository's architecture and conventions. Any Copilot session (chat, agent, code review) automatically reads it.

**What it contains in this repo:**

| Section | Purpose |
|---|---|
| Canonical sources and grounding | Always prefer Microsoft Learn over local research |
| Repository architecture | Three layers: `grounding/` → `docs/` → `scripts/` |
| Build, test, lint commands | PowerShell parse validation for scripts |
| Codebase conventions | JSON field names, citation styles, Graph API version rules |
| Key files to consult | Which files to read before making changes |

**Why it matters:** Without this file, Copilot would treat `docs/` as a source of truth (it's actually generated output). The instructions ensure Copilot always grounds answers on Microsoft Learn first, then `grounding/`.

### 2. Custom Agents → `.github/agents/`

This repository has six custom agents. Four are interactive wizards that require **interactive mode** (not autopilot) and **Azure CLI login** (`az login`) before use:

> **⚠️ Before using `@blueprint-creator`, `@shadow-agent-discovery-prep`, `@agentid-registration-helper`, or `@agent-user-creator`:**
>
> 1. Press **Shift+Tab** to switch to **interactive mode** (autopilot will skip wizard steps)
> 2. Run `az login` in your terminal (the wizards use `az account show` to auto-detect your tenant)

#### `@entra-researcher` — Research Agent

**File:** `.github/agents/Entra-Researcher.agent.md`

| Aspect | Configuration |
|---|---|
| **Role** | Answer questions about Microsoft Entra Agent ID, grounded on Microsoft Learn |
| **Key behavior** | Fetches live docs, cross-references local research, flags contradictions, references `scripts/` |
| **Response capture** | Saves every response to `answers/response-*.md` |
| **Tools used** | `web_fetch` / `web_search` (to fetch Microsoft Learn pages), file read/edit (to save responses) |

**Example invocation:**

```text
@entra-researcher How do I create an agent identity blueprint for my C# agent?
```

#### `@entra-curator` — Entra Curator

**File:** `.github/agents/Entra-Curator.agent.md`

| Aspect | Configuration |
|---|---|
| **Role** | Create and maintain research notes in `grounding/` |
| **Key behavior** | Enforces YAML frontmatter format (`Author`, `Priority`), validates priority scale |
| **Boundaries** | Only operates on files in `grounding/` |

**Example invocation:**

```text
@entra-curator Create a new note about Conditional Access for agents from this Microsoft Learn page: https://learn.microsoft.com/en-us/entra/identity/conditional-access/agent-id
```

#### `@blueprint-creator` — Blueprint Creation Wizard

**File:** `.github/agents/BluePrint-Creator.agent.md`

| Aspect | Configuration |
|---|---|
| **Role** | Interactive wizard that creates an Entra Agent ID blueprint end-to-end |
| **Key behavior** | 10-step workflow: auto-detects tenant via `az account show` → checks prerequisites → collects inputs → generates JSON → provides run command |
| **Tools used** | `execute` (run PowerShell), `read`/`edit` (generate blueprint-input.json), `search` |

**Example invocation:**

```text
@blueprint-creator I want to create a new agent identity blueprint
```

#### `@shadow-agent-discovery-prep` — Shadow Agent Discovery Prep Wizard

**File:** `.github/agents/Shadow-Agent-Discovery-Prep.agent.md`

| Aspect | Configuration |
|---|---|
| **Role** | Prepares environment for scanning, provides the run command |
| **Key behavior** | 6-step workflow: auto-detects tenant → checks prerequisites → verifies Entra roles via `az rest` → configures options → generates command |
| **Tools used** | `execute` (install PowerShell/modules), `read` (check versions), `search` |

**Example invocation:**

```text
@shadow-agent-discovery-prep I want to scan my tenant for shadow agents
```

#### `@agentid-registration-helper` — Agent Registry Registration Wizard

**File:** `.github/agents/AgentId-Registration-Helper.agent.md`

| Aspect | Configuration |
|---|---|
| **Role** | Registers an agent in the Entra Agent Registry (Pattern A or B) |
| **Key behavior** | 12-step workflow: auto-detects tenant via `az account show` → checks prerequisites → collects metadata + manifest → generates JSON → provides run command |
| **Tools used** | `execute` (run PowerShell), `read`/`edit` (generate agent-metadata.json), `search` |

**Example invocation:**

```text
@agentid-registration-helper Register my Python agent in the Agent Registry
```

#### `@agent-user-creator` — Agent User Creation Wizard

**File:** `.github/agents/Agent-User-Creator.agent.md`

| Aspect | Configuration |
|---|---|
| **Role** | Interactive wizard that creates an agent identity and its user account end-to-end |
| **Key behavior** | Guides the user through creating an agent identity from a blueprint, then creating an agent's user account with optional license assignment |
| **Tools used** | `execute` (run PowerShell), `read`/`edit` (collect parameters), `search` |

**Example invocation:**

```text
@agent-user-creator Create an agent user account for my Teams bot
```

#### How the Six Agents Work Together

```text
          ┌──────────────────────────────────────────────────┐
          │         @entra-researcher                        │
          │   Answers questions, references scripts,         │
          │   flags contradictions in research                │
          └──────────────┬───────────────────────────────────┘
                         │ flags stale note
                         ▼
          ┌──────────────────────────────────────────────────┐
          │         @entra-curator                            │
          │   Corrects / creates notes in grounding/             │
          └──────────────────────────────────────────────────┘

          ┌──────────────────────────────────────────────────┐
          │         @blueprint-creator                       │
          │   Creates blueprint → outputs appId              │
          └──────────────┬───────────────────────────────────┘
                         │ appId (agentIdentityBlueprintId)
                         ▼
          ┌──────────────────────────────────────────────────┐
          │         @agent-user-creator                      │
          │   Creates agent identity + user account          │
          └──────────────┬───────────────────────────────────┘
                         │ agentIdentityId, agentUserId
                         ▼
          ┌──────────────────────────────────────────────────┐
          │         @agentid-registration-helper             │
          │   Registers agent in Agent Registry              │
          └──────────────────────────────────────────────────┘

          ┌──────────────────────────────────────────────────┐
          │         @shadow-agent-discovery-prep                │
          │   Prepares environment, provides run command      │
          │   for discovering unregistered agents              │
          └──────────────────────────────────────────────────┘
```

### 3. MCP Servers → `.github/copilot/`

This repository does not currently define additional MCP servers beyond the defaults. The `@entra-researcher` agent relies on Copilot's built-in web tools (`web_fetch`, `web_search`) to fetch live Microsoft Learn pages.

If the repository needed additional capabilities (e.g., querying Microsoft Graph directly, running PowerShell scripts as tools), MCP servers would be configured in `.github/copilot/mcp.json` or inline in the agent profiles.

---

## Quick Reference: File Locations in This Repo

```text
.github/
├── copilot-instructions.md← Repo-wide instructions (all sessions)
├── agents/
│   ├── Entra-Researcher.agent.md           ← @entra-researcher custom agent
│   ├── Entra-Curator.agent.md              ← @entra-curator custom agent
│   ├── BluePrint-Creator.agent.md         ← @blueprint-creator wizard agent
│   ├── Shadow-Agent-Discovery-Prep.agent.md ← @shadow-agent-discovery-prep env prep wizard
│   ├── AgentId-Registration-Helper.agent.md ← @agentid-registration-helper wizard agent
│   └── Agent-User-Creator.agent.md         ← @agent-user-creator wizard agent
└── copilot/                         ← (MCP servers would go here)
```

## Further Reading

- [Custom Agents](./custom-agents.md) — How agent profiles work, YAML frontmatter, tool aliases
- [Copilot Instructions](./copilot-instructions.md) — Types of instruction files, what to include, load order
- [MCP Servers & Skills](./mcp-servers-and-skills.md) — How MCP works, configuration, security
- [GitHub Docs: About custom agents](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents)
- [GitHub Docs: Custom instructions](https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot)
- [GitHub Docs: Extending Copilot with MCP](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/extend-coding-agent-with-mcp)
