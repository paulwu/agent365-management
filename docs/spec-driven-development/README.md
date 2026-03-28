# Spec-Driven Development

> A framework for extracting, sharing, and synchronizing reusable Copilot agent patterns across repositories.

## Spec Repository

The canonical spec files, format reference, and full documentation live in the **curated-advisor-specs** repo:

👉 **https://github.com/paulwu/curated-advisor-specs**

This project **imports** specs from that repo. The import configuration is in [`.spec-config.yaml`](../../.spec-config.yaml) at the project root.

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│              paulwu/curated-advisor-specs                    │
│              (canonical spec repository)                     │
│                                                             │
│  specs/                                                     │
│  ├── grounding-rules.spec.md      Source hierarchy rules    │
│  ├── notes-conventions.spec.md    Frontmatter, priority     │
│  ├── wizard-agent.spec.md         Prerequisite/wizard flow  │
│  ├── research-agent.spec.md       Fetch/cross-ref/cite      │
│  ├── doc-architecture.spec.md     notes→docs→scripts layers │
│  └── readme-structure.spec.md     TOC, collapsible, agents  │
│                                                             │
│  manifest.yaml                    Version, spec index       │
└──────────────┬──────────────────────────┬───────────────────┘
               │                          │
     ┌─────────▼──────────┐    ┌──────────▼──────────┐
     │ agent365-management│    │azure-resilience-adv. │
     │ (imports specs)    │    │(imports specs)        │
     └────────────────────┘    └──────────────────────┘
```

## Agents in This Project for Spec Management

These agents are included in this project to work with specs:

| Agent | Purpose |
|---|---|
| **`@spec-exporter`** | Reads this project's files and extracts patterns into spec files (writes to local `specs/` folder for review before pushing to the spec repo) |
| **`@spec-importer`** | Reads spec files from the spec repo and applies them to this project using values from `.spec-config.yaml` |
| **`@spec-drift`** | Compares this project's current state against the imported specs and reports divergences |

## Specs Imported by This Project

See [`.spec-config.yaml`](../../.spec-config.yaml) for the full list and variable values. Currently importing:

| Spec | Version | What It Governs |
|---|---|---|
| `grounding-rules` | 1.0.0 | Source hierarchy, contradiction detection, citation format |
| `notes-conventions` | 1.0.0 | YAML frontmatter (`Author`, `Priority`), priority scale |
| `wizard-agent` | 1.0.0 | Prerequisite checks, `az account show` detection, autopilot warning |
| `research-agent` | 1.0.0 | Fetch live docs, cross-reference notes, save responses |
| `doc-architecture` | 1.0.0 | `notes/` → `docs/` → `scripts/` three-layer architecture |
| `readme-structure` | 1.0.0 | TOC, collapsible sections, agent table, prerequisite warnings |

## Quick Reference

```bash
# Check for drift against specs
@spec-drift Compare this project against its imported specs

# Re-import specs after an update
@spec-importer Import specs using .spec-config.yaml

# Export a new pattern to specs
@spec-exporter Extract the grounding rules pattern into specs/
```

## Further Reading

- [Spec repository — full documentation](https://github.com/paulwu/curated-advisor-specs)
- [`.spec-config.yaml`](../../.spec-config.yaml) — this project's import configuration
- [GitHub Copilot Primer](../github-copilot-primer/README.md) — how the agents in this project work
