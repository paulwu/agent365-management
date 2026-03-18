# How Blueprints Are Used

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

An identity blueprint is used in two distinct phases: **provisioning** and **runtime authentication/governance**.

## Phase 1: Provisioning

### Step 1: Create the blueprint

A developer or administrator creates the blueprint in Microsoft Entra ID, assigns sponsor and owner relationships, and records the resulting `appId`.

### Step 2: Add credentials

The blueprint must be able to request tokens. Microsoft Learn recommends a managed identity configured as a federated identity credential for production. Local development can use a client secret.

### Step 3: Optionally expose an identifier URI and scope

If your agent must accept inbound requests and perform user-delegated flows, configure the blueprint's API surface and scope.

### Step 4: Create the blueprint principal

The blueprint principal is the tenant-local representation that lets the blueprint operate in that tenant.

### Step 5: Create one or more agent identities

After the blueprint exists, your code or automation uses it to create one or more agent identities through Microsoft Graph. Microsoft Learn recommends creating one agent identity per agent, though implementations can choose a different granularity if needed.

## Phase 2: Runtime Authentication

At runtime, the service does not sign in as each child identity using separate secrets. Instead:

1. The service authenticates with the blueprint's credential.
2. The blueprint participates in the token exchange.
3. The resulting operation is carried out as the target agent identity.

Microsoft Learn describes these as **multi-stage token exchanges** and recommends using SDKs rather than hand-rolling the protocol.

## Phase 3: Governance and Operations

The blueprint remains useful after creation because administrators can use it as a control point:

- apply Conditional Access to the blueprint
- grant or review OAuth permissions at the blueprint level
- disable the blueprint to stop child identities from authenticating
- review actions in audit logs through the blueprint principal

## Typical Pro-Code Flow

For code-built agents in this repository, the end-to-end pattern is:

1. Create the blueprint with [`Create-Blueprint.ps1`](../../scripts/Create-Blueprint.ps1) or Microsoft Graph.
2. Create the agent identity through Graph or supported tooling.
3. Add `agentIdentityBlueprintId` and `agentIdentityId` to `agent-metadata.json`.
4. Register the deployed agent in the Agent Registry with [`Register-Agent.ps1`](../../scripts/Register-Agent.ps1).

For a diagram of that flow, see [Agent Blueprint vs. Registration](../agent-blueprint-vs-registration.md).

## Product-Managed Flow

Not every blueprint is created manually. Microsoft Learn also describes product integrations and consent-driven flows where Microsoft products or third-party offerings add a blueprint principal to a tenant and then create agent identities from that channel.

That is why administrators need to watch both:

- who can create blueprints directly
- which blueprint principals already exist in the tenant

## References

- [Create an agent identity blueprint](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint)
- [Create and delete agent identities](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-delete-agent-identities)
- [Agent OAuth protocols](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-oauth-protocols)
- [Agent ID creation channels](https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/agent-id-creation-channels)
