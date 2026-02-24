# Enabling Agents Created in Code (Non-Microsoft Tools)

## Overview

Agents built with non-Microsoft tools — open-source frameworks, third-party platforms (ServiceNow, SAP), or custom code (Python, Node.js, .NET) — can be registered into the Agent 365 ecosystem. There are two patterns depending on the level of integration you need.

## Pattern A: Registry-Only (Inventory + Metadata)

Use this when the agent uses its own identity provider or you want **visibility and governance without issuing Entra tokens** to the agent.

### Prerequisites

- **Entra role:** Agent Registry Administrator
- **Licensing:** Microsoft 365 Copilot license in tenant + Frontier enrollment

### Steps

1. **Register an agent instance** via Microsoft Graph:

   ```
   POST /beta/agentRegistry/agentInstances
   ```

   Include the following metadata:
   - `displayName`
   - `ownerIds` (the humans responsible)
   - `url` (operational endpoint)
   - `originatingStore`
   - `preferredTransport` (protocol)

2. **Register the agent card manifest** (discovery metadata):
   - `displayName`, `description`, `iconUrl`
   - `skills` and `capabilities`
   - `security` (authentication schemes)
   - `documentationUrl`
   - `provider` information
   - `protocolVersion`, `version`

3. **Verify in Entra admin center:**
   Navigate to **Entra ID → Agent identities → Agent Registry** to confirm the agent appears.

4. **Assign to a collection** to control discoverability:
   - **Global** — visible to everyone
   - **Custom** — scoped to specific groups
   - **Quarantined** — blocked pending review

   In preview, collection assignment is manual and serves as the governance boundary for agent discovery.

## Pattern B: Full Entra Agent ID (Identity + Registry)

Use this when you want **Entra-issued tokens, Conditional Access enforcement, and full lifecycle controls** — treating the code-built agent with the same identity governance as Microsoft-native agents.

### Prerequisites

- **Entra roles:** Agent ID Developer or Agent ID Administrator (for blueprints); Agent Registry Administrator (for registration)
- **Licensing:** Microsoft 365 Copilot license + Entra ID P1 (for Conditional Access) + optionally Entra ID Governance (for access packages)

### Steps

1. **Create an agent identity blueprint** (the template for agent identities):
   - Use Microsoft Graph API, CLI, or the Entra admin center.
   - Define the sponsor, owner, and required permissions.
   - Requires Agent ID Developer or Agent ID Administrator role plus the Graph permissions described in the <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint" target="_blank">blueprint creation guide</a>.

2. **Create agent identities from the blueprint:**
   - Agent ID Administrator for user-driven creation in Entra/CLI.
   - Graph permissions for automated/programmatic creation.

3. **Register the agent instance in the Agent Registry:**

   ```
   POST /beta/agentRegistry/agentInstances
   ```

   Include, alongside the standard metadata:
   - `agentIdentityBlueprintId`
   - `agentIdentityId`
   - `agentUserId` (optional)
   - Operational endpoint URL

4. **Apply governance controls:**
   - **Conditional Access** — target agent identities with risk-based policies (Entra ID P1).
   - **Collections** — assign to Global, Custom, or Quarantined.
   - **Identity Governance** — access packages for time-bound approvals and renewals.

## Choosing Between Pattern A and Pattern B

| Consideration | Pattern A (Registry-Only) | Pattern B (Full Entra Agent ID) |
|---|---|---|
| **Agent uses own identity provider** | ✅ Good fit | Unnecessary overhead |
| **Need Entra-issued tokens** | ❌ Not available | ✅ Required |
| **Conditional Access enforcement** | ❌ Limited | ✅ Full support |
| **Visibility in Agent Registry** | ✅ Yes | ✅ Yes |
| **Lifecycle governance** | Basic (manual) | Full (blueprints, access packages) |
| **Setup complexity** | Lower (~15 min) | Higher (~30 min) |

## Rogue Agent Triage

For code-built agents discovered outside formal channels:

1. Check **M365 admin center → Agents → All Agents** for inventory and missing-owner views.
2. Check **Entra → Agent ID → All agent identities** to find identities and inspect access logs.
3. Assign unknown agents to the **Quarantined** collection.
4. Apply **Conditional Access** policies to block high-risk agent behavior.

## References

- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/publish-agents-to-registry" target="_blank">Register Agents to the Agent Registry</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint" target="_blank">Create an agent identity blueprint</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/agent-id-creation-channels" target="_blank">How are agent identities created?</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/manage-agents-without-identity" target="_blank">Manage Agents with No Agent Identities</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-registry-collections" target="_blank">Agent Registry collections</a>
