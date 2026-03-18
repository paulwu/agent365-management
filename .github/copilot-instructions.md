# Copilot Instructions

## Grounding Rule

**Official Microsoft Learn documentation is the highest authority.** When answering any question about Agent 365, Entra Agent ID, licensing, roles, or agent governance:

1. **If web tools are available** (`web_fetch`, `web_search`), fetch the relevant page(s) from `https://learn.microsoft.com/en-us/entra/agent-id/` first. The site index in `sources/Microsoft-Learn-Entra-AgentID.md` lists all page URLs — use it to identify which page to fetch.
2. **Then read the cached sources** in `sources/` to supplement. The cached copy in `sources/Microsoft-Learn-Entra-AgentID.md` is the offline baseline when web tools are unavailable.
3. **Then consult other source files** in `sources/` (ChatGPT.md, Gemini.md, Researcher.md, Microsoft-Learn.md) for additional context.
4. **Use external knowledge only as a last resort** when neither live nor cached sources cover the topic.

## Contradiction Handling

When information in `sources/` files contradicts the official Microsoft Learn documentation:

- **Always flag the contradiction explicitly.** State what each source says and where the discrepancy is.
- **Prefer the Microsoft Learn version** as the authoritative answer, but note that the cached copy may be stale.
- **Recommend the user verify manually** by checking the live Microsoft Learn page. Include the URL.
- Example: _"⚠️ Contradiction: `sources/ChatGPT.md` states X, but the official Microsoft Learn page ([link]) states Y. The Microsoft Learn version is more authoritative — please verify at the link above."_

## Knowledge Source Policy

- **Microsoft Learn** (`https://learn.microsoft.com/en-us/entra/agent-id/`) — The **highest-authority** source. Always check live content when web tools are available.
- **`sources/Microsoft-Learn-Entra-AgentID.md`** — Cached baseline of the Entra Agent ID docs. Use when web tools are unavailable or as a starting point before live fetching.
- **`sources/`** (other files) — Research compiled from multiple AI assistants. Valuable context, but subordinate to Microsoft Learn.
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
