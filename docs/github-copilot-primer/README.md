# GitHub Copilot Primer

> A quick-start guide for understanding how GitHub Copilot's customization system works and how this repository uses it.

If you're new to GitHub Copilot's agent and customization features, start here. This primer explains the three core building blocks — **instructions**, **custom agents**, and **MCP servers / skills** — then shows exactly how this repository wires them together.

## The Three Building Blocks

| Building Block | What It Does | Where It Lives |
|---|---|---|
| [**Copilot Instructions**](./copilot-instructions.md) | Give Copilot persistent, repository-specific context — conventions, build commands, architecture notes | `.github/copilot-instructions.md` |
| [**Custom Agents**](./custom-agents.md) | Create specialized personas with tailored prompts, tool access, and MCP servers | `.github/agents/<name>.agent.md` |
| [**MCP Servers & Skills**](./mcp-servers-and-skills.md) | Connect Copilot to external tools and data sources (web fetch, APIs, databases, browsers) | `.github/copilot/mcp.json` or inline in agent profiles |

### How They Relate

```
┌─────────────────────────────────────────────────────────┐
│                    Your Repository                       │
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
| Canonical sources and grounding | Always prefer Microsoft Learn over local notes |
| Repository architecture | Three layers: `notes/` → `docs/` → `scripts/` |
| Build, test, lint commands | PowerShell parse validation for scripts |
| Codebase conventions | JSON field names, citation styles, Graph API version rules |
| Key files to consult | Which files to read before making changes |

**Why it matters:** Without this file, Copilot would treat `docs/` as a source of truth (it's actually generated output). The instructions ensure Copilot always grounds answers on Microsoft Learn first, then `notes/`.

### 2. Custom Agents → `.github/agents/`

This repository has five custom agents:

#### `@entra-researcher` — Research Agent

**File:** `.github/agents/Entra-Researcher.agent.md`

| Aspect | Configuration |
|---|---|
| **Role** | Answer questions about Microsoft Entra Agent ID, grounded on Microsoft Learn |
| **Key behavior** | Fetches live docs, cross-references local notes, flags contradictions, references `scripts/` |
| **Response capture** | Saves every response to `copilot-playground/response-*.md` |
| **Tools used** | `web_fetch` / `web_search` (to fetch Microsoft Learn pages), file read/edit (to save responses) |

**Example invocation:**
```
@entra-researcher How do I create an agent identity blueprint for my C# agent?
```

#### `@notes-author` — Notes Maintenance Agent

**File:** `.github/agents/Notes-Author.agent.md`

| Aspect | Configuration |
|---|---|
| **Role** | Create and maintain research notes in `notes/` |
| **Key behavior** | Enforces YAML frontmatter format (`Author`, `Priority`), validates priority scale |
| **Boundaries** | Only operates on files in `notes/` |

**Example invocation:**
```
@notes-author Create a new note about Conditional Access for agents from this Microsoft Learn page: https://learn.microsoft.com/en-us/entra/identity/conditional-access/agent-id
```

#### `@blueprint-creator` — Blueprint Creation Wizard

**File:** `.github/agents/BluePrint-Creator.agent.md`

| Aspect | Configuration |
|---|---|
| **Role** | Interactive wizard that creates an Entra Agent ID blueprint end-to-end |
| **Key behavior** | 10-step workflow: checks prerequisites → collects inputs → generates JSON → runs script |
| **Tools used** | `execute` (run PowerShell), `read`/`edit` (generate blueprint-input.json), `search` |

**Example invocation:**
```
@blueprint-creator I want to create a new agent identity blueprint
```

#### `@shadow-agent-discovery-prep` — Shadow Agent Discovery Prep Wizard

**File:** `.github/agents/Shadow-Agent-Discovery-Prep.agent.md`

| Aspect | Configuration |
|---|---|
| **Role** | Prepares environment for scanning, provides the run command |
| **Key behavior** | 6-step workflow: checks prerequisites → installs modules → configures options → generates command |
| **Tools used** | `execute` (install PowerShell/modules), `read` (check versions), `search` |

**Example invocation:**
```
@shadow-agent-discovery-prep I want to scan my tenant for shadow agents
```

#### `@agentid-registration-helper` — Agent Registry Registration Wizard

**File:** `.github/agents/AgentId-Registration-Helper.agent.md`

| Aspect | Configuration |
|---|---|
| **Role** | Registers an agent in the Entra Agent Registry (Pattern A or B) |
| **Key behavior** | 12-step workflow: checks prerequisites → collects metadata + manifest → generates JSON → runs script |
| **Tools used** | `execute` (run PowerShell), `read`/`edit` (generate agent-metadata.json), `search` |

**Example invocation:**
```
@agentid-registration-helper Register my Python agent in the Agent Registry
```

#### How the Five Agents Work Together

```
          ┌──────────────────────────────────────────────────┐
          │         @entra-researcher                        │
          │   Answers questions, references scripts,         │
          │   flags contradictions in notes                  │
          └──────────────┬───────────────────────────────────┘
                         │ flags stale note
                         ▼
          ┌──────────────────────────────────────────────────┐
          │         @notes-author                            │
          │   Corrects / creates notes in notes/             │
          └──────────────────────────────────────────────────┘

          ┌──────────────────────────────────────────────────┐
          │         @blueprint-creator                       │
          │   Creates blueprint → outputs appId              │
          └──────────────┬───────────────────────────────────┘
                         │ appId (agentIdentityBlueprintId)
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

```
.github/
├── copilot-instructions.md          ← Repo-wide instructions (all sessions)
├── agents/
│   ├── Entra-Researcher.agent.md           ← @entra-researcher custom agent
│   ├── Notes-Author.agent.md              ← @notes-author custom agent
│   ├── BluePrint-Creator.agent.md         ← @blueprint-creator wizard agent
│   ├── Shadow-Agent-Discovery-Prep.agent.md ← @shadow-agent-discovery-prep env prep wizard
│   └── AgentId-Registration-Helper.agent.md ← @agentid-registration-helper wizard agent
└── copilot/                         ← (MCP servers would go here)
```

## Further Reading

- [Custom Agents](./custom-agents.md) — How agent profiles work, YAML frontmatter, tool aliases
- [Copilot Instructions](./copilot-instructions.md) — Types of instruction files, what to include, load order
- [MCP Servers & Skills](./mcp-servers-and-skills.md) — How MCP works, configuration, security
- [GitHub Docs: About custom agents](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents)
- [GitHub Docs: Custom instructions](https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot)
- [GitHub Docs: Extending Copilot with MCP](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/extend-coding-agent-with-mcp)
