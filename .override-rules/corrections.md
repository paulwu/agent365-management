# Corrections and Overrides

<!--
  This file contains factual corrections, deprecated command replacements,
  and pinned values that take precedence over knowledge base content.

  Corrections are applied by any agent that implements the grounding-rules spec.
  See: specs/grounding-rules.spec.md (Source Hierarchy, tier 2)

  Priority: Corrections sit between live primary source (tier 1) and
  cached baseline (tier 3) in the grounding-rules hierarchy.
-->

## How to Use This File

Each correction is a heading + body describing what to override.
Agents read this file before answering and apply matching corrections.

**Correction types:**
- **Factual correction** — a value or statement in the knowledge base is outdated or wrong
- **Deprecated replacement** — a command, API, or term has been replaced
- **Pinned value** — a value that must always be used exactly as written, regardless of what other sources say
- **Terminology correction** — a preferred term that replaces a deprecated one

---

## Factual Corrections

### Agent identity blueprint creation limit

The cached baseline states that blueprints are "limited to 250 agent identity creations per principal." This limit applies **per blueprint principal per tenant**, not globally. If the limit is reached, create a new blueprint principal in the same tenant.

- **Applies to:** Any mention of the 250 agent identity creation limit
- **Source:** `grounding/Microsoft-Learn-Entra-AgentID.md` § Agent Identity Blueprints

### Credential recommendation for production

The cached baseline states "Client secrets should NOT be used in production." When answering questions about agent identity credentials, always emphasize this and recommend **managed identities** as the preferred credential type, followed by federated identity credentials (FIC), then certificates. Never recommend client secrets for production use.

- **Applies to:** Any discussion of credential types for agent identities
- **Source:** `grounding/Microsoft-Learn-Entra-AgentID.md` § OAuth Protocol for Agent IDs

## Deprecated Replacements

### Graph API beta endpoint

When referencing Microsoft Graph API calls for agent identity operations, always use the `beta` endpoint:

- **Deprecated:** `https://graph.microsoft.com/v1.0/agentIdentityBlueprints`
- **Use instead:** `https://graph.microsoft.com/beta/agentIdentityBlueprints`

The agent identity APIs are in preview and are only available on the beta endpoint.

- **Applies to:** Any Graph API URL for agent identity, blueprint, or agent user operations

## Pinned Values

### Preview status

Microsoft Entra Agent ID is currently in **PREVIEW**. Always include this warning when describing Entra Agent ID features. Do not describe any feature as generally available (GA) unless the live Microsoft Learn page explicitly says so.

- **Applies to:** All answers about Entra Agent ID capabilities
- **Source:** `grounding/Microsoft-Learn-Entra-AgentID.md` § What is Microsoft Entra Agent ID?

### Required Entra roles for blueprint creation

When answering "what role do I need to create a blueprint?", always use these exact values:

- Via admin center / CLI: **Agent ID Developer** or **Agent ID Administrator** role
- Via Graph (delegated): Same role + `AgentIdentityBlueprint.Create` permission
- Via Graph (application): `AgentIdentityBlueprint.Create` permission

- **Applies to:** Questions about permissions for creating blueprints
- **Source:** `grounding/Microsoft-Learn-Entra-AgentID.md` § Agent ID Creation Channels

## Terminology Corrections

### "Agent identity" vs "agent ID"

The preferred official term is **"agent identity"** (lowercase, two words). Avoid using "agent ID" when referring to the identity object itself — "Agent ID" refers to the **product name** (Microsoft Entra Agent ID), not the individual identity resource.

- **Applies to:** All references to the identity object
- **Source:** Microsoft Learn naming conventions across all Entra Agent ID pages
