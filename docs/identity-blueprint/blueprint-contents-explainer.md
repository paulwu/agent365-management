# Blueprint Contents Explainer

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

This page focuses on what information and capabilities live on an agent identity blueprint, and why those settings are kept there instead of on each child agent identity.

<details>
<summary><strong>📑 Table of Contents</strong></summary>

- [Shared Configuration Stored on the Blueprint](#shared-configuration-stored-on-the-blueprint)
- [Credentials Live on the Blueprint](#credentials-live-on-the-blueprint)
- [The Credential Model in Practice](#the-credential-model-in-practice)
- [How Conditional Access Applies](#how-conditional-access-applies)
- [Mapping: Blueprint Principal vs Agent Identity vs App Registration](#mapping-blueprint-principal-vs-agent-identity-vs-app-registration)
  - [Object hierarchy](#object-hierarchy)
  - [Concept mapping](#concept-mapping)
  - [Key differences from traditional app registrations](#key-differences-from-traditional-app-registrations)
- [Owners and Sponsors](#owners-and-sponsors)
- [Optional API Surface for Interactive Agents](#optional-api-surface-for-interactive-agents)
- [What Stays Outside the Blueprint](#what-stays-outside-the-blueprint)
- [Rule of Thumb](#rule-of-thumb)

</details>

## Shared Configuration Stored on the Blueprint

Microsoft Learn calls out several blueprint properties that are shared across the agent identities created from it:

- `description` — summary of the agent's purpose
- `appRoles` — roles that can be assigned when using the agent
- `verifiedPublisher` — the organization that built the agent
- authentication settings such as `optionalClaims`

These settings are defined once on the blueprint so that all child identities inherit a consistent identity shape.

## Credentials Live on the Blueprint

One of the most important design points is that **agent identities do not have their own credentials**. The credential used to start authentication belongs to the blueprint, not to individual agent identities.

> "Each agent identity doesn't have its own credentials. Instead, the credentials used to authenticate an agent identity are configured on the blueprint."
> — [Agent identity blueprints](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-blueprint)

What this means in practice:

- You configure credentials (managed identity, certificates, or client secrets) on the **blueprint application object**, never on individual agent identities.
- When an agent needs to act, your service authenticates with the **blueprint's** credentials and then the blueprint **impersonates** the target agent identity through a token exchange.
- The resulting access token identifies the **agent identity** as the client, even though the blueprint performed the actual authentication. Audit logs trace the impersonation clearly.
- All agent identities created from the same blueprint share the same credential mechanism. Rotating a credential on the blueprint rotates it for every child identity at once.

Microsoft Learn recommends:

- **Production**: managed identity used as a federated identity credential (automatic rotation, secure storage)
- **Development or testing**: client secret, when managed identity is not practical

Client certificates and other supported credentials are possible, but Microsoft Learn does not recommend secrets for production.

## The Credential Model in Practice

The runtime authentication flow is a multi-stage token exchange:

1. Your service authenticates using the **blueprint's** credential (managed identity, certificate, or secret).
2. Microsoft Entra performs a token exchange where the blueprint impersonates the target agent identity.
3. The issued token has the **agent identity** as the subject — the blueprint is the credential holder, but the agent identity is the actor.

That model explains why one blueprint can support many agent identities without separate credential management per agent. It also explains why a pro-code team should create its **own** blueprint instead of depending on a Microsoft-managed product blueprint — the blueprint is the credential boundary and the governance boundary for all its children.

## How Conditional Access Applies

Conditional Access treats agent identities as first-class identities. The blueprint acts as a **grouping mechanism** for policies:

- **CA policies scoped to a blueprint** take effect for all agent identities created from that blueprint. Admins can target "agent identities grouped by their blueprint" as an assignment scope.
- **CA policies can also target individual agent identities** by object ID or by custom security attributes assigned to them.
- **CA evaluation happens at the agent identity level** when an agent identity requests a token for a resource — not at the blueprint level when it provisions identities.

Conditional Access does **not** apply to blueprint administrative operations (creating/deleting agent identities) or intermediate token exchange steps. Only the final resource-access flow is governed.

> "Agent blueprints have limited functionality. They can't act independently to access resources and are only involved in creating agent identities and agent users. Agentic tasks are always performed by the agent identity."
> — [Conditional Access for Agent ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/agent-id)

| Authentication flow | CA applies? | Details |
|---|---|---|
| Agent identity → Resource | ✅ Yes | Governed by agent identity policies |
| Agent user → Resource | ✅ Yes | Governed by agent user policies |
| Blueprint → Graph (create agent identity) | ❌ No | Administrative provisioning only |
| Blueprint or agent identity → Token exchange endpoint | ❌ No | Intermediate exchange; no resource access |

## Mapping: Blueprint Principal vs Agent Identity vs App Registration

The Agent ID model introduces new object types that map loosely — but not directly — to traditional Entra ID concepts. The table below clarifies what each object is, what it replaces, and where the boundaries lie.

### Object hierarchy

```text
Agent Identity Blueprint          ← Application object (specialized type)
├── Blueprint Principal           ← Service principal (tenant-local representation)
├── Credentials                   ← Configured here; shared by all children
│
├── Agent Identity 1              ← Service principal (subtype "agent")
│   └── Agent User 1 (optional)   ← User object (1:1 with agent identity)
├── Agent Identity 2
│   └── Agent User 2 (optional)
└── Agent Identity N …
```

### Concept mapping

| Agent ID concept | Closest traditional equivalent | Key differences |
|---|---|---|
| **Agent Identity Blueprint** | App Registration (application object) | Created with a specialized OData type. Primary purpose is templating and creating agent identities — not acting as a standalone app. Holds credentials for all children. Cannot be assigned Azure RBAC roles. |
| **Blueprint Principal** | Service Principal (enterprise app) | Created automatically when a blueprint is added to a tenant. Scoped to one operation: provisioning agent identities. Token `oid` references this principal for audit. |
| **Agent Identity** | Service Principal (with "agent" subtype) | Has **no independent credentials**; relies on parent blueprint impersonation. `appId` equals `objectId` (unique to agent identities). Supports one-to-many relationship with the blueprint (vs. traditional 1:1 app-to-SP). Can inherit delegated permissions from parent. |
| **Agent User** | User object (like a service account) | A full user object with UPN, manager, mailbox, and calendar access. Used only when a target system requires a user identity. Immutable 1:1 relationship with an agent identity. |

### Key differences from traditional app registrations

| Aspect | Traditional App Registration + SP | Agent Identity Blueprint + Agent Identities |
|---|---|---|
| **Credential model** | Each service principal manages its own secrets/certs | Blueprint holds credentials; children have none |
| **Impersonation** | SP uses its own credentials directly | Blueprint impersonates agent identity via token exchange |
| **Cardinality** | 1:1 (one app → one SP per tenant) | 1:many (one blueprint → many agent identities, even within the same tenant) |
| **Permissions** | Direct assignment only | Direct assignment + optional inheritance from parent blueprint |
| **Policy scope** | Policies target individual SPs | Policies can target the blueprint and cascade to all children |
| **Design philosophy** | Long-term stability, known ownership | Dynamic, ephemeral — created in bulk, retired without orphaned credentials |

> "Application identities (service principals) assume long-term stability and known ownership. Agent identities embrace dynamic nature — created in bulk, consistent policies, retired without orphaned credentials. Designed for scale and ephemerality."
> — [What is an Agent Identity?](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/what-is-agent-id)

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
- [Agent service principals](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-service-principals)
- [Agent identities](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-identities)
- [What is an Agent Identity?](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/what-is-agent-id)
- [Conditional Access for Agent ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/agent-id)
- [Create an agent identity blueprint](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint)
- [Agent OAuth protocols](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-oauth-protocols)
- [Administrative relationships in Microsoft Entra Agent ID](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-owners-sponsors-managers)
