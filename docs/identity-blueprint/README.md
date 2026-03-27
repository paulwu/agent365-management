# Identity Blueprint Guide

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

An **agent identity blueprint** is the Entra Agent ID template and control plane for one or more agent identities. This guide breaks the topic into smaller pages so you can quickly find the part you need.

## Start Here

| If you want to know... | Read |
|---|---|
| What an identity blueprint is and why it exists | [What is an identity blueprint?](./what-is-an-identity-blueprint.md) |
| Which settings live on the blueprint and how credentials work | [Blueprint contents explainer](./blueprint-contents-explainer.md) |
| How a blueprint is used in the creation and runtime flow | [How blueprints are used](./how-blueprints-are-used.md) |
| Which scenarios call for a blueprint versus registry-only onboarding | [When to use identity blueprints](./when-to-use-identity-blueprints.md) |
| How to move older or registry-only agents toward the blueprint model | [Migrating legacy agents](./migrating-legacy-agents.md) |

## At a Glance

Microsoft Learn describes four core jobs for a blueprint:

1. It is the **template** for shared agent settings.
2. It is the **parent identity** that can create agent identities.
3. It is the **credential container** used to request tokens.
4. It is the **governance container** administrators can target with policy.

That combination is what makes a blueprint different from a normal app registration or a registry-only metadata record.

## Related Documents

- [Developer Guide: Agent Identity Platform](../developer-identity-platform.md) — manual Graph and PowerShell flow
- [Agent Blueprint vs. Registration](../agent-blueprint-vs-registration.md) — Pattern A vs. Pattern B diagram
- [Enabling Agents Created in Code](../enabling-code-built-agents.md) — registry-only versus full Entra Agent ID
- [Enabling Legacy Agents](../enabling-legacy-agents.md) — Copilot Studio and Foundry modernization path
- [Scripts README](../../scripts/README.md) — `blueprint-input.json` and `agent-metadata.json` field guides
- [GitHub Copilot Primer](../github-copilot-primer/README.md) — how the custom agents, instructions, and MCP servers in this repository work together

## References

- [Agent identity blueprints](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-blueprint)
- [Create an agent identity blueprint](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint)
- [Create and delete agent identities](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-delete-agent-identities)
- [Agent ID creation channels](https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/agent-id-creation-channels)
- [Manage Agent Registry-only agents](https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/manage-agents-without-identity)
