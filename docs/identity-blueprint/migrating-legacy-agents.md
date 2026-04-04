# Migrating Legacy Agents to Identity Blueprints

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

There is no single in-place "convert" button described in Microsoft Learn for every older agent type. In practice, migration means choosing the right modernization path for the kind of legacy agent you have and then moving it onto the blueprint + agent identity model where appropriate.

<details>
<summary><strong>📑 Table of Contents</strong></summary>

- [First Classify the Legacy Agent](#first-classify-the-legacy-agent)
  - [Legacy type 1: Registry-only or external-identity agent](#legacy-type-1-registry-only-or-external-identity-agent)
  - [Legacy type 2: Older Copilot Studio agent](#legacy-type-2-older-copilot-studio-agent)
  - [Legacy type 3: Existing code-built agent using app registration or another identity provider](#legacy-type-3-existing-code-built-agent-using-app-registration-or-another-identity-provider)
- [Migration Path for Registry-Only or External-Identity Agents](#migration-path-for-registry-only-or-external-identity-agents)
  - [1. Create a new blueprint](#1-create-a-new-blueprint)
  - [2. Create an agent identity](#2-create-an-agent-identity)
  - [3. Update the application authentication path](#3-update-the-application-authentication-path)
  - [4. Update registry metadata](#4-update-registry-metadata)
  - [5. Retire the old identity path](#5-retire-the-old-identity-path)
- [Migration Path for Older Copilot Studio Agents](#migration-path-for-older-copilot-studio-agents)
- [Migration Path for Existing Code-Built Agents](#migration-path-for-existing-code-built-agents)
- [Validate the Migration](#validate-the-migration)
- [When Not to Migrate](#when-not-to-migrate)
- [Related Documents](#related-documents)

</details>

## First Classify the Legacy Agent

### Legacy type 1: Registry-only or external-identity agent

The agent is visible in the Agent Registry, or can be registered there, but it does not yet have an Entra agent identity.

### Legacy type 2: Older Copilot Studio agent

The agent was created before Entra Agent Identity integration was enabled for the environment, so it might not yet appear in Entra Agent ID or the governed registry path.

### Legacy type 3: Existing code-built agent using app registration or another identity provider

The application already runs, but it does not yet use an Entra Agent ID blueprint as its parent identity model.

## Migration Path for Registry-Only or External-Identity Agents

### 1. Create a new blueprint

Create a tenant-owned blueprint for the legacy agent family. Assign sponsor and owner relationships and choose a production-grade credential model.

### 2. Create an agent identity

Provision a new agent identity from that blueprint using Microsoft Graph or supported tooling.

### 3. Update the application authentication path

Change the legacy service so that token acquisition starts from the blueprint credential model instead of the old standalone secret or non-Agent-ID pattern.

### 4. Update registry metadata

Add the new `agentIdentityBlueprintId` and `agentIdentityId` values to the registry metadata so the deployed agent is represented in both layers.

### 5. Retire the old identity path

After validation, remove or phase out the former credential path so the blueprint becomes the supported identity boundary.

## Migration Path for Older Copilot Studio Agents

For Copilot Studio, the usual action is not to hand-build a replacement blueprint. Instead, follow the product integration path:

1. Enable **Entra Agent Identity for Copilot Studio** for the correct Power Platform environment.
2. Republish the agent to the Teams and Microsoft 365 Copilot channel if needed.
3. Verify the agent now has an **Entra Agent ID**.
4. Confirm the agent is visible in the governed registry flow.

That path is documented in [Enabling Legacy Agents](../enabling-legacy-agents.md) and aligns with Microsoft Learn's creation-channel model, where Microsoft products can add the necessary blueprint artifacts to the tenant.

## Migration Path for Existing Code-Built Agents

For custom applications, migration usually looks like this:

1. Decide whether the agent really needs full Entra Agent ID or only registry visibility.
2. If full Entra Agent ID is required, create a blueprint and credential setup.
3. Create one or more agent identities for the deployed agents.
4. Update the code to authenticate using the blueprint credential path.
5. Register or update the agent instance in the Agent Registry with the Entra identity IDs attached.
6. Apply governance controls such as Conditional Access, collections, and lifecycle review.

## Validate the Migration

After migration, verify all of the following:

- the blueprint exists in Entra
- the blueprint principal exists in the tenant
- the target agent identity exists
- the application can request tokens through the new blueprint path
- the Agent Registry entry includes the new identity metadata
- governance controls now target the intended Entra objects

## When Not to Migrate

If the agent only needs inventory in the Agent Registry and does not need Entra-issued tokens or Entra identity controls, Microsoft Learn allows you to keep it as a registry-only agent.

## Related Documents

- [What is an identity blueprint?](./what-is-an-identity-blueprint.md)
- [How blueprints are used](./how-blueprints-are-used.md)
- [Enabling Legacy Agents](../enabling-legacy-agents.md)
- [Enabling Agents Created in Code](../enabling-code-built-agents.md)

## References

- [Agent identity blueprints](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-blueprint)
- [Create an agent identity blueprint](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint)
- [Create and delete agent identities](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-delete-agent-identities)
- [Agent ID creation channels](https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/agent-id-creation-channels)
- [Manage Agent Registry-only agents](https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/manage-agents-without-identity)
