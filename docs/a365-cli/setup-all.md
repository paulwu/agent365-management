# `a365 setup all`

> Run the complete Agent 365 setup in one command.

## Purpose

Executes all setup steps in sequence: prerequisites validation, Azure infrastructure, blueprint creation, and permission grants. This is the recommended way to set up a new agent.

---

## Syntax

```shell
a365 setup all [options]
```

| Option | Description |
|---|---|
| `-c`, `--config <path>` | Config file path |
| `-v`, `--verbose` | Detailed output |
| `--dry-run` | Preview without executing |
| `--skip-infrastructure` | Skip Azure resource creation (if infrastructure exists) |
| `--skip-requirements` | Skip prerequisite checks (use with caution) |
| `-h`, `--help` | Show help |

---

## What It Does (In Order)

| Step | What | Requires |
|---|---|---|
| 1 | Prerequisites check | — |
| 2 | Azure infrastructure (Resource Group, App Service, Web App) | Azure Contributor |
| 3 | Blueprint creation (Entra application + service principal) | Agent ID Developer |
| 4 | Inheritable permissions | Agent ID Developer |
| 5 | OAuth2 permission grants (admin consent) | **Global Administrator** |

---

## Role-Based Behavior

| Step | Global Admin | Agent ID Admin/Dev |
|---|---|---|
| Prerequisites | ✅ | ✅ |
| Infrastructure | ✅ | ✅ |
| Blueprint | ✅ | ✅ |
| Inheritable permissions | ✅ | ✅ |
| OAuth2 grants | ✅ | ❌ → requires `a365 setup admin` |

**Non-admin workflow:**

```shell
# Step 1: Developer runs setup
a365 setup all
# CLI completes what it can, shows next steps

# Step 2: Share config folder with Global Admin

# Step 3: Global Admin completes grants
a365 setup admin --config-dir "<path>"
```

---

## Output

- Creates all Azure resources
- Creates blueprint + principal in Entra
- Grants all permissions
- Saves everything to `a365.generated.config.json`

Setup typically takes **3–5 minutes**.

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/setup#setup-all" target="_blank">a365 setup all reference</a>
