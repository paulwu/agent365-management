# Custom Agents

Custom agents are specialized versions of GitHub Copilot that you can tailor to specific workflows, coding conventions, and use cases. Instead of giving Copilot the same instructions every time, you define a custom agent once and invoke it by name whenever you need it.

## What Is a Custom Agent?

A custom agent is defined by a Markdown file (called an **agent profile**) that tells Copilot:

- **Who it is** — a name and description
- **How it behaves** — a detailed prompt with instructions, boundaries, and expertise
- **What tools it can use** — which built-in tools and MCP servers it has access to

When you invoke a custom agent (e.g., `@entra-researcher`), Copilot takes on that agent's persona, follows its instructions, and uses only the tools it's been granted.

## Agent Profile Format

Agent profiles are Markdown files with YAML frontmatter. The file must be named `*.agent.md` (or just `*.md` in the agents directory).

### Minimal Example

```markdown
---
name: readme-creator
description: Agent specializing in creating and improving README files
---

You are a documentation specialist focused on README files. Your scope
is limited to README files and related documentation — do not modify code.

# Instructions
- Create and update README.md files with clear project descriptions
- Structure sections logically: overview, installation, usage, contributing
- Use relative links for files within the repository
```

### Full Example with Tools and MCP Servers

```markdown
---
name: test-specialist
description: Focuses on test coverage and testing best practices
tools: ["read", "edit", "search", "execute"]
mcp-servers:
  custom-mcp:
    type: local
    command: some-command
    args: ["--arg1"]
---

You are a testing specialist. Write unit and integration tests following
best practices. Never modify production code unless specifically asked.
```

## YAML Frontmatter Properties

| Property | Required | Description |
|---|---|---|
| `name` | ✅ | Unique identifier for the agent. Used to invoke it with `@name`. |
| `description` | ✅ | Explains the agent's purpose. Shown in the agent picker. |
| `tools` | No | Which tools the agent can access. Omit for all tools, `[]` for none. |
| `mcp-servers` | No | MCP server configurations the agent can use. |
| `model` | No | Override the default AI model for this agent. |

## Where to Store Agent Profiles

| Level | Location | Scope |
|---|---|---|
| **Repository** | `.github/agents/<name>.agent.md` | Available to anyone working in this repository |
| **Organization** | `.github-private/agents/<name>.agent.md` | Available to all repos in the organization |
| **User (CLI)** | `~/.copilot/agents/<name>.agent.md` | Available to you in any repository (CLI only) |

Repository-level agents take precedence over organization-level agents with the same name.

## Where Custom Agents Work

- **GitHub.com** — Copilot coding agent (issues, PRs, agents tab)
- **VS Code** — Copilot Chat sidebar
- **JetBrains IDEs** — Copilot Chat (preview)
- **GitHub Copilot CLI** — Terminal-based Copilot sessions

## Tool Aliases

When configuring the `tools` property, you can use these aliases:

| Alias | What It Does |
|---|---|
| `read` | Read file contents |
| `edit` | Edit/create files |
| `search` | Search for files or text (grep/glob) |
| `execute` | Run shell commands |
| `web` | Fetch URLs, perform web searches |
| `agent` | Invoke other custom agents as sub-agents |

## References

- [About custom agents (GitHub Docs)](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents)
- [Custom agents configuration reference (GitHub Docs)](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [Creating custom agents (GitHub Docs)](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents)
