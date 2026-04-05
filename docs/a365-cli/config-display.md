# `a365 config display`

> View current Agent 365 CLI configuration settings.

## Purpose

Displays the current configuration from `a365.config.json` and optionally the generated configuration from `a365.generated.config.json`. Use this to verify your setup before running other commands.

---

## Syntax

```shell
a365 config display [options]
```

| Option | Description |
|---|---|
| `-g`, `--generated` | Show generated config (`a365.generated.config.json`) |
| `-a`, `--all` | Show both static and generated config |
| `-f`, `--field <field>` | Output a single field value (for scripting) |
| `-h`, `--help` | Show help |

---

## Examples

```shell
# Show static config
a365 config display

# Show generated config (after setup)
a365 config display -g

# Get a single value for scripting
a365 config display -g --field messagingEndpoint
```

---

## Output

The full JSON contents of `a365.config.json` (or `a365.generated.config.json` with `-g`).

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/developer/reference/cli/config#config-display" target="_blank">a365 config display reference</a>
