# Copilot Instructions

## Canonical sources and grounding

This repository is a documentation knowledge base for Microsoft Agent 365 management, Entra Agent ID, and the Agent Registry.

- Treat live Microsoft Learn content under `https://learn.microsoft.com/en-us/entra/agent-id/` as the highest-authority source.
- Use `notes/Microsoft-Learn-Entra-AgentID.md` as the cached baseline when live fetches are unavailable or to find the right page URL first.
- Use the other files in `notes/` (`ChatGPT.md`, `Gemini.md`, `Researcher.md`, `Microsoft-Learn.md`) as secondary research only.
- Treat `docs/` as generated output, not as the factual source of truth, except when you are explicitly updating documentation in `docs/`.
- If a source file disagrees with Microsoft Learn, call out the contradiction explicitly, prefer Microsoft Learn, and include the Learn URL for manual verification.
- The custom agent in `.github/agents/Entra-Researcher.agent.md` follows the same grounding policy; use `@Entra-Researcher` for Entra Agent ID questions that need source-cited synthesis.

## Repository architecture

The repository has three working layers that matter together:

1. `notes/` stores raw research and cached documentation.
2. `docs/` stores synthesized topic guides generated from those sources.
3. `scripts/` stores PowerShell automation that operationalizes the documentation against Microsoft Graph beta endpoints.

The main cross-file workflow is:

1. `scripts/Create-Blueprint.ps1` creates an Entra Agent ID blueprint from `blueprint-input.json`.
2. An agent identity is then created outside this repo (Graph API / CLI), using the blueprint output.
3. The resulting `agentIdentityBlueprintId` and `agentIdentityId` are added to `agent-metadata.json`.
4. `scripts/Register-Agent.ps1` registers the agent in the Agent Registry.
5. `scripts/Discover-ShadowAgents.ps1` is the separate discovery/audit path and outputs a CSV report to `discovery/` rather than registry metadata.

Pattern A is registry-only registration with `Register-Agent.ps1`. Pattern B is full Entra Agent ID integration and spans blueprint creation, identity creation, metadata wiring, and registry registration. That relationship is documented across `docs/agent-blueprint-vs-registration.md`, `docs/developer-identity-platform.md`, and `scripts/README.md`.

## Build, test, lint, and validation commands

There is currently no repo-wide build system, linter, unit test suite, `package.json`, Python project file, or CI workflow in this repository.

For PowerShell script changes, use PowerShell parse validation:

```powershell
# Validate all scripts
pwsh -NoLogo -NoProfile -Command '$errors=@(); Get-ChildItem ./scripts/*.ps1 | ForEach-Object { [void][System.Management.Automation.Language.Parser]::ParseFile($_.FullName,[ref]$null,[ref]$errors) }; if ($errors.Count) { $errors | Format-List; exit 1 }'
```

```powershell
# Validate one script only
pwsh -NoLogo -NoProfile -Command '$errors=@(); [void][System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path ./scripts/Register-Agent.ps1),[ref]$null,[ref]$errors); if ($errors.Count) { $errors | Format-List; exit 1 }'
```

Operational script entry points from the repository docs are:

```powershell
pwsh -File ./scripts/Create-Blueprint.ps1 -TenantId "<tenant>" -ClientId "<client-id>"
pwsh -File ./scripts/Register-Agent.ps1 -TenantId "<tenant>" -ClientId "<client-id>"
pwsh -File ./scripts/Discover-ShadowAgents.ps1 -IncludeSignIns
```

There is no single-test command because there is no automated test harness. When validating a targeted change, validate the edited script directly with the single-file parse command above, or run that one script with real tenant inputs if you are intentionally doing live validation.

## Codebase conventions

- Keep factual answers grounded in Microsoft Learn first, then `notes/`; do not answer from `docs/` alone.
- Add new research to `notes/`; add or update end-user guides in `docs/`.
- If you add or remove any file in `docs/`, update `README.md` (root) in both the structure listing and the topic-guide table.
- Documentation in `docs/` consistently uses `###` step-oriented headings, Markdown tables for role/license mappings, and `References` sections with Microsoft Learn links. Mermaid diagrams are already used for multi-step relationships.
- `notes/ChatGPT.md` uses numbered reference-style citations like `[1]`, `[2]`; preserve that citation style when editing it.
- The scripts are independent entry points, each with `[CmdletBinding()]`, `$ErrorActionPreference = "Stop"`, and default input paths rooted at `$PSScriptRoot`. Preserve those patterns when extending scripts.
- `Create-Blueprint.ps1` and `Register-Agent.ps1` both switch auth mode based on `-ClientSecret`: omit it for interactive device-code flow, provide it for app-only client-credentials flow.
- The scripts expect companion working JSON files named `blueprint-input.json` and `agent-metadata.json`, created by copying the committed `.json.example` templates. Keep those filenames and field names stable.
- The repository does not currently contain a `.gitignore`, so be extra careful not to commit tenant-specific JSON files, client secrets, or generated CSV outputs.
- All automation targets Microsoft Graph `/beta` endpoints today. Do not silently convert calls to `v1.0` unless the repository docs and Microsoft Learn both support that change.
- Preserve the metadata field names that connect the identity and registry workflow: `agentIdentityBlueprintId`, `agentIdentityId`, and `agentUserId`.

## Key files to consult before editing

- `scripts/README.md`: authoritative usage, permissions, roles, and field-by-field input docs for all scripts.
- `README.md` (root): index of generated guides and the repo's synthesized information architecture.
- `docs/agent-blueprint-vs-registration.md`: the clearest big-picture map of Pattern A vs. Pattern B.
- `docs/developer-identity-platform.md`: identity hierarchy, required permissions, and the manual Graph flow that the scripts automate.
- `.github/agents/Entra-Researcher.agent.md`: source-grounding behavior for the custom Copilot agent.
- `.github/agents/BluePrint-Creator.agent.md`: interactive wizard that creates blueprints via `Create-Blueprint.ps1`.
- `.github/agents/Shadow-Agent-Discovery.agent.md`: interactive wizard that discovers shadow agents via `Discover-ShadowAgents.ps1`; outputs to `discovery/`.
- `.github/agents/AgentId-Registration-Helper.agent.md`: interactive wizard that registers agents via `Register-Agent.ps1`.
