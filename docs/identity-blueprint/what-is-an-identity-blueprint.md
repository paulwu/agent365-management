# What Is an Identity Blueprint?

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

An **agent identity blueprint** is a Microsoft Entra ID object that serves as the template for creating agent identities. Microsoft Learn positions it as the foundation for how agents are created, authenticated, and managed in Entra Agent ID.

## Why It Exists

Microsoft Learn assigns four responsibilities to the blueprint.

### 1. It standardizes shared agent settings

Many deployed instances of the same agent can share the same publisher, roles, token settings, and descriptive metadata. The blueprint stores those shared characteristics so that identities created from it stay consistent.

### 2. It can create agent identities

The blueprint is not just metadata. It is also a special identity type with:

- an OAuth client ID
- credentials
- the `AgentIdentity.CreateAsManager` permission

Those elements let services create and later deprovision agent identities through Microsoft Graph.

### 3. It holds the credentials used for agent authentication

Agent identities do not each receive their own secret or certificate. Instead, the credential material is configured on the blueprint and used in the token exchange flow for the child agent identities.

### 4. It is the governance boundary

Policies and settings applied to the blueprint can affect all child identities created from it. Microsoft Learn calls out examples such as Conditional Access, OAuth permission grants, and disabling the blueprint.

## Relationship to Other Agent ID Objects

```text
Agent identity blueprint
  ├─ blueprint principal (tenant-local presence of the blueprint)
  ├─ agent identity (service-principal style runtime identity)
  └─ agent user (user-object identity, optional)
```

## Single-Tenant and Multitenant Use

Microsoft Learn describes two common patterns:

- **Single-tenant blueprint**: created in a tenant and used to create identities in that same tenant.
- **Multitenant blueprint**: published so customer tenants can add the blueprint principal and use it to create identities in their own tenants.

In both cases, adding the blueprint to a tenant creates an **agent identity blueprint principal** in that tenant.

## What a Blueprint Is Not

- It is **not** the same thing as the Agent Registry entry.
- It is **not** a single deployed agent instance.
- It is **not** a per-agent secret store where each child identity has distinct credentials.

For registry-only onboarding, see [When to use identity blueprints](./when-to-use-identity-blueprints.md).

## References

- [Agent identity blueprints](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-blueprint)
- [Agent ID creation channels](https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/agent-id-creation-channels)
- [Create and delete agent identities](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-delete-agent-identities)
