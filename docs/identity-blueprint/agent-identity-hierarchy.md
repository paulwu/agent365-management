# Agent Identity Hierarchy

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

This page explains the relationship between the four core identity objects in Microsoft Entra Agent ID and how they work together.

<details>
<summary><strong>📑 Table of Contents</strong></summary>

- [Terminology Guide](#terminology-guide)
- [The Identity Hierarchy](#the-identity-hierarchy)
- [How Objects Relate](#how-objects-relate)
  - [Blueprint → Agent Identity](#blueprint--agent-identity)
  - [Agent Identity → Agent's User Account](#agent-identity--agents-user-account)
  - [Blueprint Principal → Tenant](#blueprint-principal--tenant)
- [Token Flow Summary](#token-flow-summary)
- [Comparison with Traditional App Identities](#comparison-with-traditional-app-identities)
- [When Each Object Is Needed](#when-each-object-is-needed)
- [Related Pages](#related-pages)

</details>

## Terminology Guide

Before diving in, here is the official terminology mapping. Some informal shorthand is common, but the official Microsoft Learn terms should be used in formal documentation:

| Official Term | Common Shorthand | What It Is |
|---|---|---|
| **Agent identity blueprint** | "blueprint", "identity blueprint" | Template and credential holder for agent identities |
| **Agent identity blueprint principal** | "blueprint principal" | Tenant-local representation of a blueprint |
| **Agent identity** | "agent ID" | The runtime identity (a specialized service principal) |
| **Agent's user account** | "agent user" | Optional user-object identity paired 1:1 with an agent identity |

> **Note:** Terms like "agent blueprint", "agentic app instance", and "agentic user" are NOT official Microsoft Learn terminology.

> Throughout this document, "blueprint" is used as shorthand for "agent identity blueprint."

---

## The Identity Hierarchy

```text
┌─────────────────────────────────────────────────────────────────────┐
│                    AGENT IDENTITY BLUEPRINT                         │
│                                                                     │
│  • Template for creating agent identities                           │
│  • Holds ALL credentials (managed identity, certs, secrets)         │
│  • Stores shared config (description, appRoles, publisher, claims)  │
│  • OAuth client ID for token acquisition                            │
│  • Has AgentIdentity.CreateAsManager permission                     │
│  • Governance boundary: CA policies, OAuth grants, disable/enable   │
│                                                                     │
│  Cardinality: 1 blueprint → many agent identities (up to 250)       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌───────────────────────────────────────┐                          │
│  │  AGENT IDENTITY BLUEPRINT PRINCIPAL   │                          │
│  │                                       │                          │
│  │  • Created when blueprint is added    │                          │
│  │    to a tenant                        │                          │
│  │  • Token oid claim references this    │                          │
│  │  • Audit logs attribute actions here  │                          │
│  │  • 1:1 with blueprint per tenant      │                          │
│  └───────────────────────────────────────┘                          │
│                                                                     │
│  ┌───────────────────────────────────────┐  ┌────────────────────┐  │
│  │         AGENT IDENTITY (1)            │  │  AGENT IDENTITY    │  │
│  │                                       │  │      (2)           │  │
│  │  • Specialized service principal      │  │                    │  │
│  │  • No credentials of its own          │  │  • Same structure  │  │
│  │  • Object ID = App ID (unique)        │  │  • Different ID    │  │
│  │  • Has sponsor, owner, display name   │  │  • Own lifecycle   │  │
│  │  • Can request/receive tokens         │  │                    │  │
│  │  • Tenant-scoped (cannot cross tenant)│  │                    │  │
│  │                                       │  │                    │  │
│  │  ┌─────────────────────────────────┐  │  │                    │  │
│  │  │  AGENT'S USER ACCOUNT           │  │  │                    │  │
│  │  │  (optional, 1:1)                │  │  │                    │  │
│  │  │                                 │  │  │                    │  │
│  │  │  • Microsoft Entra user object  │  │  │                    │  │
│  │  │  • idtyp=user in tokens         │  │  │                    │  │
│  │  │  • Can have mailbox, Teams      │  │  │                    │  │
│  │  │  • Can join groups (not role-   │  │  │                    │  │
│  │  │    assignable)                  │  │  │                    │  │
│  │  │  • Can be assigned licenses     │  │  │                    │  │
│  │  │  • No passwords/passkeys        │  │  │                    │  │
│  │  │  • Immutable link to parent     │  │  │                    │  │
│  │  │    agent identity               │  │  │                    │  │
│  │  └─────────────────────────────────┘  │  │                    │  │
│  └───────────────────────────────────────┘  └────────────────────┘  │
│                                    ...more agent identities...      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## How Objects Relate

### Blueprint → Agent Identity

| Aspect | Detail |
|---|---|
| **Relationship** | Parent → child (1:many, up to 250 per blueprint principal) |
| **Creation** | Blueprint uses `AgentIdentity.CreateAsManager` permission via Microsoft Graph |
| **Credentials** | Agent identity has NO credentials — uses blueprint's credentials via token exchange |
| **Policy inheritance** | Conditional Access policies on the blueprint cascade to all child identities |
| **Permission inheritance** | When `InheritDelegatedPermissions` is enabled, delegated permissions flow from blueprint to children |
| **Lifecycle** | Disabling the blueprint stops ALL child identities from authenticating |

### Agent Identity → Agent's User Account

| Aspect | Detail |
|---|---|
| **Relationship** | 1:1 (each agent identity can have at most one agent's user account) |
| **Creation** | Blueprint must be granted `AgentIdUser.ReadWrite.IdentityParentedBy` permission; then creates the user account linked to a specific agent identity |
| **Authentication** | Agent's user account authenticates via its parent agent identity's token (impersonation chain: blueprint → agent identity → agent's user account) |
| **Purpose** | Access systems requiring user objects (Exchange mailbox, Teams, calendar, groups) |
| **Token type** | Receives tokens with `idtyp=user` claim |
| **Immutability** | The parent link is set at creation and cannot be changed |

### Blueprint Principal → Tenant

| Aspect | Detail |
|---|---|
| **Relationship** | 1:1 per tenant (one principal per blueprint per tenant) |
| **Single-tenant** | Blueprint and principal in the same tenant |
| **Multitenant** | Blueprint in publisher's tenant; principal added to customer tenants via consent or catalog |
| **Removal** | Deleting the principal removes the blueprint's ability to create identities in that tenant |

---

## Token Flow Summary

```text
  Interactive (on-behalf-of user)         Autonomous (app-only)           Agent's User Account
  ─────────────────────────────           ─────────────────────           ────────────────────

  User signs in                           No user involved                No user involved
       │                                       │                              │
  Blueprint gets user token               Blueprint gets app token        Blueprint gets app token
       │                                       │                              │
  Token exchange:                         Token exchange:                 Token exchange (2 hops):
  blueprint → agent identity              blueprint → agent identity     blueprint → agent identity
       │                                       │                         → agent's user account
       │                                       │                              │
  Token subject = user                    Token subject = agent identity  Token subject = agent's
  Token actor = agent identity            Token actor = agent identity    user account
  idtyp = user                            idtyp = app                    idtyp = user
  scp = delegated permissions             scp = (empty)                  scp = delegated permissions
```

---

## Comparison with Traditional App Identities

| Aspect | Traditional App Registration | Agent Identity Blueprint Model |
|---|---|---|
| **Credentials** | Each app has its own secrets/certs | Blueprint holds all credentials; children have none |
| **Cardinality** | 1 app registration : 1 service principal | 1 blueprint : many agent identities |
| **Lifecycle** | Long-lived, manually managed | Designed for dynamic creation/destruction |
| **Governance** | No enforced sponsorship | Sponsor required; lifecycle workflows enforced |
| **Audit** | Standard app sign-in logs | Agent-specific sign-in logs with `agentSignIn` resource type |
| **Policy scope** | Per-app Conditional Access | Blueprint-level policies cascade to all children |

---

## When Each Object Is Needed

| Object | Always needed? | Create when... |
|---|---|---|
| **Agent identity blueprint** | Yes (for Entra Agent ID) | You want Entra-issued tokens, Conditional Access, or governance |
| **Blueprint principal** | Yes (auto-created) | Automatically created when blueprint is added to a tenant |
| **Agent identity** | Yes | Each deployed agent instance needs its own identity |
| **Agent's user account** | Optional | Agent needs mailbox, Teams chat, calendar, or group membership |

---

## Related Pages

- [What is an identity blueprint?](./what-is-an-identity-blueprint.md) — Conceptual overview
- [Blueprint contents explainer](./blueprint-contents-explainer.md) — What lives on the blueprint
- [How blueprints are used](./how-blueprints-are-used.md) — Provisioning and runtime flow
- [Agent's user account guide](./agent-user-account-guide.md) — How to create and use agent's user accounts

## References

- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/key-concepts" target="_blank">Key concepts in Microsoft Entra Agent ID</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-blueprint" target="_blank">Agent identity blueprints</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-identities" target="_blank">Agent identities</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-users" target="_blank">Agent's user accounts</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-service-principals" target="_blank">Agent service principals</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-tokens" target="_blank">Tokens in Microsoft agent identity platform</a>
