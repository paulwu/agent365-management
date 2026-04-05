# `a365 publish`

> Create a manifest package for uploading to the Microsoft 365 admin center.

## Purpose

Updates the ID values in `manifest.json` with IDs from your generated config, then creates a `manifest.zip` package. After running this command, upload the package through the Microsoft 365 admin center to make your agent available in Teams.

---

## Syntax

```shell
a365 publish [options]
```

| Option | Description |
|---|---|
| `--dry-run` | Preview changes without writing files |
| `-v`, `--verbose` | Detailed output |
| `-h`, `--help` | Show help |

---

## Output

- Updated `manifest.json` with correct agent IDs
- `manifest.zip` ready for upload

**Next step:** Upload `manifest.zip` via **M365 admin center → Agents → Upload custom app**, then create an agent instance in Teams → Apps → Add.

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/publish" target="_blank">a365 publish reference</a>
