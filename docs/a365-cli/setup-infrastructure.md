# `a365 setup infrastructure`

> Create Azure resources for your agent.

## Purpose

Creates the Azure infrastructure needed to host your agent: a Resource Group, App Service Plan, and Web App with managed identity enabled.

---

## Prerequisites

| What | Why |
|---|---|
| `a365.config.json` | Must exist with Azure settings |
| **Azure Contributor or Owner** role | Required to create resources |

---

## Syntax

```shell
a365 setup infrastructure [options]
```

| Option | Description |
|---|---|
| `-c`, `--config <path>` | Config file path |
| `-v`, `--verbose` | Detailed output |
| `--dry-run` | Show what would be created without executing |
| `-h`, `--help` | Show help |

---

## What It Creates

| Resource | Details |
|---|---|
| **Resource Group** | Named from config (e.g., `rg-task-assistant`) |
| **App Service Plan** | With configured SKU (e.g., `B1`) |
| **Web App** | With system-assigned managed identity enabled |

---

## Output

Updates `a365.generated.config.json` with the managed identity principal ID and resource details.

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/setup#setup-infrastructure" target="_blank">a365 setup infrastructure reference</a>
