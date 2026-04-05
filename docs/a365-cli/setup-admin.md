# `a365 setup admin`

> Complete OAuth2 permission grants as Global Administrator.

## Purpose

Completes the OAuth2 delegated permission grants (admin consent) that require Global Administrator. Run this after an Agent ID Administrator or Developer runs `a365 setup all`.

---

## Syntax

```shell
a365 setup admin [options]
```

| Option | Description |
|---|---|
| `--config-dir <path>` | Directory containing `a365.config.json` and `a365.generated.config.json` |
| `-c`, `--config <path>` | Config file path |
| `-v`, `--verbose` | Detailed output |
| `--dry-run` | Preview without executing |
| `-h`, `--help` | Show help |

---

## Typical Handoff

```shell
# 1. Developer runs setup
a365 setup all

# 2. Developer shares config folder with Global Admin
# (contains a365.config.json + a365.generated.config.json)

# 3. Global Admin runs:
a365 setup admin --config-dir "C:\shared\agent-config"
```

**Alternative:** The Global Admin can open the combined consent URL saved in `a365.generated.config.json` (field: `combinedAdminConsentUrl`) in a browser.

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/setup#setup-admin" target="_blank">a365 setup admin reference</a>
