# `a365 cleanup`

> Remove Agent 365 resources.

## Purpose

Removes all resources created during setup: blueprint, agent instance, and Azure infrastructure. Use subcommands for granular cleanup.

---

## Syntax

```shell
a365 cleanup [command] [options]
```

---

## Subcommands

| Subcommand | What It Removes |
|---|---|
| `a365 cleanup azure` | Azure resources (App Service, App Service Plan) |
| `a365 cleanup blueprint` | Entra ID blueprint application and service principal |
| `a365 cleanup instance` | Agent instance identity and user from Entra ID |
| `a365 cleanup` (no subcommand) | All of the above |

---

## ⚠️ Warning

Cleanup is **destructive and irreversible**. All associated identities, permissions, and Azure resources will be permanently deleted.

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/cleanup" target="_blank">a365 cleanup reference</a>
