# Enabling Agents Created in Code (Non-Microsoft Tools)

## Overview

Agents built with non-Microsoft tools — open-source frameworks, third-party platforms (ServiceNow, SAP), or custom code (Python, Node.js, .NET) — can be registered into the Agent 365 ecosystem. There are two patterns depending on the level of integration you need.

## Pattern A: Registry-Only (Inventory + Metadata)

Use this when the agent uses its own identity provider or you want **visibility and governance without issuing Entra tokens** to the agent.

### Prerequisites

- **Entra role:** Agent Registry Administrator
- **Licensing:** Microsoft 365 Copilot license in tenant + Frontier enrollment

### Steps

1. **Register an agent instance** via Microsoft Graph using [`Register-Agent.ps1`](../scripts/Register-Agent.ps1):

   ```
   POST /beta/agentRegistry/agentInstances
   ```

   Copy `scripts/agent-metadata.json.example` → `agent-metadata.json`, fill in your values, then run:
   ```powershell
   .\Register-Agent.ps1 -TenantId "contoso.onmicrosoft.com" -ClientId "your-app-client-id"
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

1. **Create an agent identity blueprint** using [`Create-Blueprint.ps1`](../scripts/Create-Blueprint.ps1):
   - Copy `scripts/blueprint-input.json.example` → `blueprint-input.json`, fill in sponsor/owner IDs and credentials, then run:
     ```powershell
     .\Create-Blueprint.ps1 -TenantId "contoso.onmicrosoft.com" -ClientId "your-app-client-id"
     ```
   - Or use Microsoft Graph API directly — see [Developer Guide: Agent Identity Platform](./developer-identity-platform.md).
   - Requires Agent ID Developer or Agent ID Administrator role plus the Graph permissions described in the <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint" target="_blank">blueprint creation guide</a>.
   - For a visual overview of how blueprint creation relates to agent registration, see [Agent Blueprint vs. Registration](./agent-blueprint-vs-registration.md).

2. **Create agent identities from the blueprint:**
   - Agent ID Administrator for user-driven creation in Entra/CLI.
   - Graph permissions for automated/programmatic creation.

3. **Register the agent instance in the Agent Registry** using [`Register-Agent.ps1`](../scripts/Register-Agent.ps1):

   Add the identity IDs to `agent-metadata.json`, then run:
   ```powershell
   .\Register-Agent.ps1 -TenantId "contoso.onmicrosoft.com" -ClientId "your-app-client-id"
   ```

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
5. Use **Microsoft Defender → Advanced Hunting** to inspect trace logs and detect anomalous tool usage.
6. Use **Microsoft Purview DLP** to block agent interactions with sensitive data based on security labels.

## Extending Agents with MCP Tooling Servers

Once registered, code-built agents can access **Agent 365 tooling servers** — enterprise-grade Model Context Protocol (MCP) servers that provide governed access to Microsoft 365 services.

### Available Default MCP Servers

| Server | Capabilities |
|---|---|
| **Outlook Mail** | Create, update, delete messages; reply/reply-all; semantic search |
| **Outlook Calendar** | Create, list, update, delete events; accept/decline; resolve conflicts |
| **Teams** | Create/update/delete chats; add members; post messages; channel operations |
| **SharePoint & OneDrive** | Upload files; get metadata; search; manage lists |
| **Copilot Search** | Chat with M365 Copilot; multi-turn threads; ground responses with files |
| **Dataverse & Dynamics 365** | CRUD operations and domain-specific actions |
| **User Profile** | Manager, direct reports, profile info; user search |
| **Word** | Create/read documents; add and reply to comments |

### Governance

- Each MCP server is represented as a **permission on the Agent 365 application**.
- Admin must **grant required permissions** during agent onboarding — only then does the agent gain access.
- If an MCP server is **blocked**, it is blocked for every user and every agent.
- Manage in **M365 admin center → Agents and Tools**.

### Custom MCP Servers

Use the **Microsoft MCP Management Server** to build custom servers via API:

- `CreateMCPServer` — Spin up a new server instance
- `CreateToolWithConnector` — Add connectors, Graph APIs, REST endpoints, or Dataverse custom APIs
- `PublishMCPServer` — Publish a server (currently tenant admin only)

Supports **1,500+ connectors** (ServiceNow, JIRA, etc.), Microsoft Graph APIs, Dataverse custom APIs, and any REST endpoint.

### Authentication for Tooling

Agents authenticate to MCP servers using **agentic user identity** or **On-Behalf-Of (OBO) delegated user permissions**.

## Security Stack for Code-Built Agents

Agent 365 extends Microsoft's full security suite to registered agents:

| Layer | Product | What It Does |
|---|---|---|
| **Identity** | Entra Agent Registry | Complete inventory including shadow agents |
| **Access Control** | Entra Conditional Access + ID Protection | Risk-based policies; detect risky agent behavior |
| **Security Posture** | Microsoft Defender + Exposure Management | Attack path analysis; remediate misconfigurations |
| **Detection & Response** | Microsoft Defender | Threat detection; incident-level investigation |
| **Runtime Defense** | Defender + Entra SASE + Purview Insider Risk | Block prompt injection, malicious traffic, data exfiltration |
| **Data Security** | Purview DLP + Information Protection | Block agent access to sensitive data by label/policy |

## References

- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/publish-agents-to-registry" target="_blank">Register Agents to the Agent Registry</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint" target="_blank">Create an agent identity blueprint</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/agent-id-creation-channels" target="_blank">How are agent identities created?</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/manage-agents-without-identity" target="_blank">Manage Agents with No Agent Identities</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-registry-collections" target="_blank">Agent Registry collections</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview" target="_blank">Agent 365 Tooling Servers (MCP)</a>
- <a href="https://learn.microsoft.com/en-us/security/security-for-ai/agent-365-security" target="_blank">Secure AI agents at scale using Microsoft Agent 365</a>
