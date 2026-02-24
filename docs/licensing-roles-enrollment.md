# Licensing, Entra Roles, Preview Enrollment & General Availability

## Licensing Requirements

| Requirement | Details |
|---|---|
| **Minimum to enable Agent 365** | At least one **Microsoft 365 Copilot** license in the tenant |
| **Program access (current)** | **Frontier Preview** enrollment required |
| **Per-agent licensing** | Agent 365 uses a per-agent licensing model — each active agent instance receives an **A365 license**, auto-assigned via the default template during activation in the Agent Registry |
| **Conditional Access for agents** | Requires **Microsoft Entra ID P1** |
| **Identity Governance for agents** | Requires **Entra ID Governance** or **Entra Suite** licensing |

**Key clarifications:**

- Agent 365 is **not** included in Microsoft 365 E3/E5 licenses — it is a separate offering.
- For agentic users (humans interacting with agents), additional licenses may be required (M365 E5, Teams Enterprise, Copilot) depending on the scenario.
- Managing Copilot agents in the M365 admin center is enabled by default in **Microsoft 365 Copilot licensed tenants** — no extra enablement needed for the base admin experience.

## Entra Roles

| Role | Purpose | Where Used |
|---|---|---|
| **AI Administrator** | Manage agents in M365 admin center | admin.microsoft.com → Agents |
| **Global Reader** | View-only access to agents in M365 admin center | admin.microsoft.com → Agents |
| **Agent ID Administrator** | Create and manage agent identity blueprints and identities | Entra admin center → Agent ID |
| **Agent ID Developer** | Create and configure agent identity blueprints | Graph API / CLI / Entra |
| **Cloud Application Administrator** | Manage Entra agent identities (or be the identity owner) | Entra admin center → Agent ID |
| **Agent Registry Administrator** | Register non-Microsoft agents into Agent Registry | Entra Agent Registry / Graph API |
| **Privileged Role Administrator** | Grant Graph application permissions for agent automation | Entra admin center |
| **Power Platform tenant admin / Environment Admin** | Turn on Copilot Studio → Entra Agent Identity integration | Power Platform admin center |

## Frontier Preview Enrollment Steps

1. Sign into the **Microsoft 365 admin center**.
2. Navigate to **Copilot → Settings**.
3. Under **User access**, select **Copilot Frontier**.
4. Grant access to the appropriate users or groups.
5. Go to **Agents** in the left pane.
6. Accept terms of service if prompted.

## General Availability Status

As of the latest available information, **Agent 365 is in preview** via the Frontier program. Microsoft has not announced a firm general availability (GA) date. Key indicators:

- The feature is accessible only through the Frontier preview program.
- Per-agent production licensing is described as a future requirement ("will eventually require separate per-agent licenses for production use — not yet GA").
- The Agent Registry, Agent ID, and collections features are all documented as **(preview)** in Microsoft Learn.
- Frontier previews are subject to the existing preview terms of your customer agreements; availability and capabilities may change.

Monitor the <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/overview" target="_blank">Microsoft Agent 365 overview</a> page and the Microsoft 365 roadmap for GA announcements.

## Agent 365 Overview Dashboard

Once enrolled, the **Agents → Overview** page in the Microsoft 365 admin center provides a centralized control plane with:

### Hero Metrics (Last 30 Days)

| Metric | Description |
|---|---|
| **Agent Registry** | Total count of all agents in the catalog (Microsoft-built, partner-built, custom/LOB) |
| **Active Users** | Unique users who interacted with at least one agent |
| **Time Saved with Agents** | Estimated cumulative hours saved through agent-assisted tasks (ROI metric) |

### Agent Analytics

- **Agents by Publishers** — Created by your organization vs. created by external partners.
- **Agents by Platforms** — Copilot Studio (Full/Lite), Azure AI Foundry, external partner platforms.
- **Active Users Over Time** — Daily active user trend chart over 30 days.

### Top Actions for Admins

- **Pending Requests for Agents** — Approval queue prioritized oldest-first. Navigate via **Manage requests → Agent Registry → Requests tab**.
- **Ownerless Agents** — Agents without an assigned owner. Navigate via **Assign Owner → Agent Registry → Ownerless Agents filter**.

### Agent Map

The **Agent Map** tab (under **Agents → All Agents**) provides an interactive spatial visualization of agents, clustered by platform (Copilot Studio lite/full, M365 Agents Toolkit, Microsoft Corporation, Others). Supports filtering by platform, publisher, and blocked status. Currently supports up to **800 agents**. Available exclusively to Frontier customers.

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-registry?view=o365-worldwide" target="_blank">Agent Registry in the Microsoft 365 admin center</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/manage-copilot-agents-integrated-apps?view=o365-worldwide" target="_blank">Manage Microsoft 365 Copilot Agents</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/overview" target="_blank">Microsoft Agent 365 overview</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-365-overview?view=o365-worldwide" target="_blank">Agent 365 Overview page in the admin center</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-map?view=o365-worldwide" target="_blank">Agent Map</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/capabilities-entra" target="_blank">Protect agent identities with Microsoft Entra</a>
- <a href="https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview" target="_blank">Microsoft Entra Conditional Access</a>
- <a href="https://learn.microsoft.com/en-us/entra/id-governance/identity-governance-overview" target="_blank">Microsoft Entra ID Governance</a>
