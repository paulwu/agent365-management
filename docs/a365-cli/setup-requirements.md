# `a365 setup requirements`

> Validate all prerequisites before running setup.

## Purpose

Runs modular checks for Azure authentication, Entra roles, PowerShell modules, client app permissions, and configuration validity. Reports problems with detailed resolution guidance.

---

## Prerequisites

| What | Why |
|---|---|
| `a365.config.json` | Must exist (run `a365 config init` first) |
| Azure CLI login | Checks Azure subscription access |

---

## Syntax

```shell
a365 setup requirements [options]
```

| Option | Description |
|---|---|
| `-c`, `--config <path>` | Config file path (default: `a365.config.json`) |
| `-v`, `--verbose` | Detailed output for all checks |
| `--category <name>` | Run checks for a specific category only (`Azure`, `Authentication`, `Configuration`) |
| `-h`, `--help` | Show help |

---

## What It Checks

- Azure CLI authentication and subscription validity
- Entra role assignments (Agent ID Developer/Administrator)
- Client app registration permissions and admin consent
- PowerShell 7 and Microsoft Graph module availability
- Configuration file completeness

---

## Output

A summary report showing pass/fail status for each check, with resolution guidance for failures.

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/setup#setup-requirements" target="_blank">a365 setup requirements reference</a>
