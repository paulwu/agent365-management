# Copilot Instructions

## Grounding Rule

**Always read files in the `sources/` folder first before answering any question about Agent 365, Entra Agent ID, licensing, roles, or agent governance.** The sources contain the primary research and are the authoritative knowledge base for this repository. Ground all answers in these source documents before adding any external knowledge.

## Knowledge Source Policy

- **`sources/`** — These files are the primary knowledge sources. Always consult them to ground your answers.
- **`docs/`** — These files are **generated output** and should **not** be used as knowledge sources, except when evaluating whether a document in `docs/` needs to be updated. When asked to create or update documentation, write output to `docs/`.

## Repository Purpose

This is a **documentation knowledge base** about Microsoft Agent 365 management and governance. The `sources/` folder contains research compiled from multiple AI assistants. The `docs/` folder contains synthesized topic guides generated from those sources.

## Folder Structure

```
sources/          ← Primary knowledge (raw research documents)
docs/             ← Generated output (synthesized topic guides) — do NOT use as knowledge source
scripts/          ← PowerShell automation scripts with JSON input templates
.github/          ← Repository configuration
```

## Key Domain Concepts

- **Agent 365** — Microsoft's unified control plane for agent governance (currently in Frontier preview)
- **Entra Agent ID** — The identity layer for agents in Microsoft Entra ID (blueprints → identities → agent users)
- **Agent Registry** — The Microsoft 365 admin center inventory of agents integrated with M365 Copilot
- **Frontier** — Microsoft's preview program required to enable Agent 365 features
- **Collections** — Governance boundaries in Agent Registry (Global/Custom/Quarantined) controlling agent discoverability

## Conventions

- All content is Markdown with no build system, linting, or tests
- Documents use `###` headers for step-by-step sections and Markdown tables for role/license mappings
- Source files in `sources/` are named after the AI assistant that produced them (e.g., `ChatGPT.md`, `Gemini.md`)
- `sources/ChatGPT.md` uses numbered reference-style links (`[1]`, `[2]`) pointing to Microsoft Learn docs; preserve this citation format when editing
- Topic guides in `docs/` should include a **References** section linking to Microsoft Learn
- When adding new research, place it in `sources/`; when generating documentation, place it in `docs/`
- **When any file is added to or removed from `docs/`, update `docs/README.md`** — both the folder structure listing and the topic guide table — to reflect the change
- **After completing any set of file changes, commit and push to GitHub automatically** without waiting for the user to ask

## Scripts

- Scripts are PowerShell (`.ps1`) and call Microsoft Graph API **beta** endpoints
- Each script reads its configuration from a companion JSON file (e.g., `blueprint-input.json`, `agent-metadata.json`)
- `.json.example` files are committed templates; actual `.json` input files are gitignored — never commit credentials or tenant-specific values
- Scripts support both interactive device-code flow (omit `-ClientSecret`) and app-only client-credentials flow
- `scripts/README.md` contains the authoritative field-by-field guides, required Entra roles, and app registration setup for all scripts
