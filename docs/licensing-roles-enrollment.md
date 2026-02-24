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

Monitor the [Microsoft Agent 365 overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview) page and the Microsoft 365 roadmap for GA announcements.

## References

- [Agent Registry in the Microsoft 365 admin center](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-registry?view=o365-worldwide)
- [Manage Microsoft 365 Copilot Agents](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/manage-copilot-agents-integrated-apps?view=o365-worldwide)
- [Microsoft Agent 365 overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview)
- [Microsoft Entra Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)
- [Microsoft Entra ID Governance](https://learn.microsoft.com/en-us/entra/id-governance/identity-governance-overview)
