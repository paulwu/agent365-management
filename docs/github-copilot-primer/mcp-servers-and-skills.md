# MCP Servers and Skills

MCP (Model Context Protocol) servers and skills extend GitHub Copilot's capabilities beyond code editing. They let Copilot connect to external tools, APIs, and data sources — turning it from a code assistant into a programmable agent that can take real actions.

## What Is MCP?

MCP is an open standard that defines how AI assistants communicate with external tool servers. It uses a client-server architecture:

- **Copilot** is the MCP **client** — it decides when to call a tool based on your request
- **MCP servers** are external processes that expose **tools** — functions Copilot can invoke

When you ask Copilot something that requires an external action (e.g., "fetch this web page," "query the database," "run Playwright tests"), it routes the request to the appropriate MCP server.

## What Are Skills?

Skills are higher-level behaviors built on top of tools. A skill might combine multiple tools, instruction prompts, and workflows into a named capability. In practice:

- **Tools** = individual functions an MCP server exposes (e.g., `web_fetch`, `search_code`)
- **Skills** = curated sets of tools + instructions that define a workflow (e.g., "research agent that searches the web and saves findings")

Custom agents (`.agent.md` files) are the primary way to package skills — they combine prompts, tool access, and MCP server configurations into a reusable persona.

## Configuring MCP Servers

### In a Repository (for Copilot Coding Agent)

Create a `.github/copilot/mcp.json` file:

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
    },
    "my-api": {
      "type": "http",
      "url": "https://my-mcp-server.example.com/mcp"
    }
  }
}
```

### In a Custom Agent Profile

MCP servers can also be declared inline in an agent profile:

```markdown
---
name: db-analyst
description: Queries and analyzes database schemas
tools: ["read", "search", "custom-db/*"]
mcp-servers:
  custom-db:
    type: local
    command: npx
    args: ["-y", "@modelcontextprotocol/server-postgres"]
    env:
      DATABASE_URL: ${{ secrets.DATABASE_URL }}
---

You are a database analyst. Query schemas, analyze data models,
and suggest optimizations.
```

### For Copilot CLI (User-Level)

Edit `~/.copilot/mcp-config.json` or use the `/mcp add` command:

```bash
# Interactive setup
copilot
/mcp add
```

## Built-In MCP Servers

Copilot coding agent includes these MCP servers out of the box:

| Server | What It Provides |
|---|---|
| `github` | GitHub API access — issues, PRs, code search, repository contents |
| `playwright` | Browser automation for testing web UIs |

Reference them in agent profiles with namespaced tool names: `github/search_code`, `playwright/navigate`.

## Security Considerations

- MCP servers can execute code on your machine (local servers) or make network requests (remote servers). Only use servers you trust.
- Store secrets in the repository's "copilot" environment (Settings → Environments), not in config files.
- Enterprise administrators can control which MCP servers are allowed organization-wide.
- The `tools` property in agent profiles lets you restrict which tools an agent can access — use this to enforce least-privilege.

## References

- [Extending Copilot with MCP (GitHub Docs)](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/extend-coding-agent-with-mcp)
- [Adding MCP servers for Copilot CLI (GitHub Docs)](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-mcp-servers)
- [MCP Specification](https://modelcontextprotocol.io/)
- [Add and manage MCP servers in VS Code](https://code.visualstudio.com/docs/copilot/customization/mcp-servers)
