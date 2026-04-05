# `a365 setup permissions`

> Configure OAuth2 permission grants and inheritable permissions for the blueprint.

## Purpose

Grants the blueprint access to MCP servers, Messaging Bot API, Copilot Studio, and custom APIs. Also configures inheritable permissions so agent instances inherit access from the blueprint.

> **Requires Global Administrator.** If you're not a Global Admin, use `a365 setup all` first, then hand off to a Global Admin via `a365 setup admin`.

---

## Subcommands

### `mcp`

```shell
a365 setup permissions mcp [options]
```

**Purpose:** Reads `ToolingManifest.json` from the deployment project and grants OAuth2 delegated permissions for each MCP server scope to the blueprint.

**Prerequisites:** Blueprint must exist. Run `a365 develop add-mcp-servers` first to populate the manifest.

---

### `bot`

```shell
a365 setup permissions bot [options]
```

**Purpose:** Configures Messaging Bot API OAuth2 grants and inheritable permissions so the agent can send/receive messages via Teams and Outlook.

**Prerequisites:** Blueprint + MCP permissions must be configured first.

---

### `custom`

```shell
a365 setup permissions custom [options]
```

**Purpose:** Adds custom API permissions (e.g., `Presence.ReadWrite`, `Files.Read.All`, `Chat.Read`) beyond the standard agent permissions.

**Configure first:**

```shell
a365 config permissions \
  --resource-app-id 00000003-0000-0000-c000-000000000000 \
  --scopes Presence.ReadWrite,Files.Read.All,Chat.Read
```

**Remove:**

```shell
a365 config permissions --reset
a365 setup permissions custom   # Reconciles Entra with updated config
```

---

### `copilotstudio`

```shell
a365 setup permissions copilotstudio [options]
```

**Purpose:** Grants the blueprint permission to invoke Copilot Studio copilots via the Power Platform API (`CopilotStudio.Copilots.Invoke` scope).

---

## Common Options (all subcommands)

| Option | Description |
|---|---|
| `-c`, `--config <path>` | Config file path |
| `-v`, `--verbose` | Detailed output |
| `--dry-run` | Preview without executing |
| `-h`, `--help` | Show help |

---

## What It Creates

- OAuth2 delegated permission grants (blueprint → resource API)
- Inheritable permissions (blueprint → agent instances)
- Admin consent records

All operations are **idempotent** — safe to run multiple times.

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/setup#setup-permissions" target="_blank">a365 setup permissions reference</a>
