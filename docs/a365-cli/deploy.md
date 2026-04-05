# `a365 deploy`

> Deploy agent code to Azure and update MCP permissions.

## Purpose

Builds and deploys your agent application to the Azure Web App created during setup, then updates MCP server permissions on the blueprint.

---

## Syntax

```shell
a365 deploy [command] [options]
```

| Option | Description |
|---|---|
| `-c`, `--config <path>` | Config file path |
| `-v`, `--verbose` | Detailed output |
| `--dry-run` | Preview without executing |
| `--inspect` | Pause before upload to inspect the publish folder |
| `--restart` | Skip build, reuse existing publish folder |
| `-h`, `--help` | Show help |

---

## Two-Phase Deployment

Running `a365 deploy` without a subcommand runs both phases:

| Phase | What | Subcommand |
|---|---|---|
| **Phase 1** | Build and deploy app binaries to Azure App Service | `a365 deploy app` |
| **Phase 2** | Update MCP server permissions on the blueprint | `a365 deploy mcp` |

---

## Subcommands

### `deploy app`

```shell
a365 deploy app [options]
```

Builds your project, creates a ZIP, and deploys to the Azure Web App.

### `deploy mcp`

```shell
a365 deploy mcp [options]
```

Reads `toolingManifest.json` and updates MCP permissions on the blueprint. Use after adding/changing MCP servers.

---

## Preflight Checks

- Azure CLI authentication and subscription validity
- Azure Web App exists (run `a365 setup` first if not)

---

## Logs

| OS | Path |
|---|---|
| Windows | `%LocalAppData%\Microsoft.Agents.A365.DevTools.Cli\logs\a365.deploy.log` |
| Linux/macOS | `~/.config/a365/logs/a365.deploy.log` |

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/deploy" target="_blank">a365 deploy reference</a>
