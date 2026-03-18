# Blueprint Contents Explainer

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

This page focuses on what information and capabilities live on an agent identity blueprint, and why those settings are kept there instead of on each child agent identity.

## Shared Configuration Stored on the Blueprint

Microsoft Learn calls out several blueprint properties that are shared across the agent identities created from it:

- `description` — summary of the agent's purpose
- `appRoles` — roles that can be assigned when using the agent
- `verifiedPublisher` — the organization that built the agent
- authentication settings such as `optionalClaims`

These settings are defined once on the blueprint so that all child identities inherit a consistent identity shape.

## Credentials Live on the Blueprint

One of the most important design points is that **agent identities do not have their own credentials**. The credential used to start authentication belongs to the blueprint.

Microsoft Learn recommends:

- **Production**: managed identity used as a federated identity credential
- **Development or testing**: client secret, when managed identity is not practical

Client certificates and other supported app credentials are possible, but Microsoft Learn does not recommend secrets for production.

## The Credential Model in Practice

The runtime pattern is:

1. Your service authenticates using the blueprint credential.
2. Microsoft Entra performs the multi-stage token exchange.
3. The blueprint impersonates the target agent identity for the requested operation.

That model explains why one blueprint can support many agent identities. It also explains why a pro-code team should create its **own** blueprint instead of depending on a Microsoft-managed product blueprint.

## Owners and Sponsors

Blueprint creation also establishes accountability:

- **Sponsor** is required.
- **Owner** is recommended.

This relationship is part of the blueprint definition and matters for governance, renewal, and operational ownership.

## Optional API Surface for Interactive Agents

If agents created from the blueprint need to receive incoming requests from users or other agents, the blueprint should expose:

- an `identifierUri`
- an OAuth scope such as `access_agent`

That setup enables on-behalf-of style flows described in the Agent ID OAuth documentation.

## What Stays Outside the Blueprint

Some things are separate by design:

- The **agent identity** object is created later and gets its own object ID.
- The **Agent Registry** entry is separate metadata for discovery and governance in the registry experience.
- Environment-specific runtime behavior still lives in the application or service that uses the blueprint.

## Rule of Thumb

Create a new blueprint when you need a different governance boundary, credential boundary, permission set, or externally visible API surface. If two agent families should be disabled, granted permissions, or governed together, they are usually candidates to share one blueprint.

## References

- [Agent identity blueprints](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-blueprint)
- [Create an agent identity blueprint](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint)
- [Agent OAuth protocols](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-oauth-protocols)
- [Administrative relationships in Microsoft Entra Agent ID](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-owners-sponsors-managers)
