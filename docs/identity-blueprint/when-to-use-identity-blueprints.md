# When to Use Identity Blueprints

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

Use an identity blueprint when you want Microsoft Entra Agent ID to be the identity and governance layer for your agent family. Do not assume every agent must start there; Microsoft Learn also describes registry-only and product-managed paths.

## Scenario Guide

| Scenario | Use a blueprint? | Why |
|---|---|---|
| Internal pro-code agent that needs Entra-issued tokens | Yes | Blueprint is required to create and authenticate agent identities. |
| Internal pro-code agent that needs Conditional Access or centralized lifecycle controls | Yes | Blueprint provides the policy and credential boundary. |
| Interactive agent acting on behalf of a user | Yes | Blueprint can expose identifier URI and scope for delegated flows. |
| Autonomous background agent using app-only access | Yes | Blueprint credentials support client-credentials style flows. |
| ISV or third-party agent published across customer tenants | Yes | Multitenant blueprint/principal model supports customer-tenant creation. |
| Agent only needs inventory/discoverability in Agent Registry | Not necessarily | Registry-only onboarding may be enough. |
| Copilot Studio, Security Copilot, or Foundry integration that already manages Agent ID objects | Usually product-managed | Microsoft product integrations can create or add the needed blueprint artifacts for you. |

## When Registry-Only Is Enough

Microsoft Learn explicitly supports agents that appear in the Agent Registry without a corresponding Entra agent identity. That is the right fit when:

- the agent uses a different identity provider
- you only need inventory and metadata in the registry
- the agent is still being onboarded toward fuller Entra integration

See [Manage Agent Registry-only agents](https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/manage-agents-without-identity).

## When to Create a Separate Blueprint

Create separate blueprints when the agent families need different:

- permission grants
- credential ownership
- Conditional Access posture
- publisher or API surface
- governance blast radius

Practical rule: if you want to disable or re-govern one family of agents without affecting another, they should not share the same blueprint.

## When Not to Reuse a Product Blueprint

For pro-code work, create your own blueprint instead of assuming you can share a Microsoft-managed product blueprint. The Learn documentation makes clear that blueprints are credential containers and governance containers. If a product manages that blueprint, your code should not depend on it as a reusable credential source or shared governance boundary.

## Questions to Ask Before Choosing

### Do I need Entra-issued tokens for this agent?

If yes, you are in blueprint territory.

### Do I need this agent to inherit enterprise identity controls?

If yes, use a blueprint and create an agent identity rather than stopping at registry-only registration.

### Am I only trying to make the agent visible in inventory?

If yes, registry-only might be the simpler starting point.

## References

- [Agent identity blueprints](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-blueprint)
- [Agent ID creation channels](https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/agent-id-creation-channels)
- [Manage Agent Registry-only agents](https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/manage-agents-without-identity)
- [Enabling Agents Created in Code](../enabling-code-built-agents.md)
