# Enabling Legacy Agents Created in Copilot Studio or Foundry

## Why Legacy Agents Don't Appear in Agent 365

Agents built in Copilot Studio before the Agent 365 integration was enabled are **not automatically visible** in the Microsoft 365 admin center's Agents inventory or in Entra Agent ID. This happens because:

1. **The agent was never integrated with Microsoft 365 Copilot surfaces** — only agents deployed to Teams/M365 Copilot channels and approved via Integrated Apps appear in the Agent Registry.
2. **The Entra Agent Identity setting is off** — Copilot Studio's integration with Entra Agent ID is environment-scoped and must be explicitly enabled.
3. **The agent was never formally published** — agents used only on websites or demos won't appear in the "Built for your org" catalog.

> **Foundry note:** Azure AI Foundry manages agent identities automatically. If a Foundry agent isn't visible, confirm the identity exists in Entra (Step 3 below) and ensure it's registered in the Agent Registry.

## Step 1: Enable Entra Agent Identity for Copilot Studio

This is the key modernization step. It is environment-scoped — you must enable it for each Power Platform environment containing agents.

1. Go to **Power Platform admin center** → **Copilot** tab → **Settings**.
2. Under **Copilot Studio**, select **Entra Agent Identity for Copilot Studio**.
3. Select the target **environment** → **Edit setting** → set to **On** → **Save**.

**Required role:** Power Platform tenant admin or Environment Admin.

## Step 2: Publish the Agent to Teams & Microsoft 365 Copilot

To make the agent visible in the governed catalog:

1. In **Copilot Studio**, open the agent.
2. Select **Channels** on the top menu bar → select the **Teams and Microsoft 365 Copilot** tile.
3. Click **Edit details** and supply the required metadata:
   - Agent icon and accent color
   - Short description
   - **Developer name**
   - **Website URL**
   - **Privacy statement URL**
   - **Terms of use URL**
4. Select **Availability options** → set to **Show to everyone in my org**.
5. Click **Submit for admin approval**.

## Step 3: Validate the Agent Has an Entra Agent ID

1. In **Copilot Studio**, open the agent → **Settings** → **Advanced** → expand **Metadata**.
2. Look for the **Entra Agent ID** GUID.
3. Confirm it exists in the **Entra admin center** → **Entra ID** → **Agent ID** → **All agent identities**.

If the GUID is missing, verify Step 1 was completed for the correct environment and republish the agent.

## Step 4: Approve and Govern in Microsoft 365 Admin Center

1. In the **Microsoft 365 admin center**, go to **Agents → All Agents / Registry**.
2. The submitted agent should appear in the **Requests** tab for IT review.
3. Review the agent's requested data sources, tools, and permissions.
4. Approve or reject the agent.

Once approved:

- The **default template** canapply predefined policies and **auto-assign the Agent 365 license** during activation.
- Use **Agent settings** to control allowed agent types, sharing, user access, and template guardrails.

## Step 5: Apply Governance Controls

After the agent is visible and activated:

- **Conditional Access** — Create policies in Entra targeting agent identities to control access scope and behavior. Policies can trigger based on agent context, risk level, and target resource. Requires Entra ID P1.
- **Entra ID Protection for agents** — Automatically detect and respond to risky agent behavior such as accessing unfamiliar resources or unusual sign-in patterns.
- **Identity Governance** — Use access packages for time-bound approvals and renewals. Assign agent sponsors to ensure ongoing oversight. Agent lifecycle workflows prevent agents from retaining resource access longer than needed. Requires Entra ID Governance or Entra Suite.
- **Collections** — Assign the agent to the appropriate collection (Global, Custom, or Quarantined) to control discoverability.
- **Security Posture** — Use Microsoft Defender and Security Exposure Management to identify misconfigurations, exposures, and attack paths from agents to critical assets.
- **Data Security** — Use Microsoft Purview DLP and Information Protection to block agent interactions with sensitive data based on security labels and policies.

## General Approach for Older Microsoft-Built Agents

1. Enable the product's integration controls (Copilot Studio via Power Platform; Foundry manages identities automatically).
2. Confirm the agent identity exists in Entra → Agent ID → All agent identities.
3. Ensure the agent is present in the M365 admin center Agent Registry.
4. Apply guardrails (Conditional Access, collections, governance workflows).

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-copilot-studio/admin-use-entra-agent-identities" target="_blank">Automatically create Entra agent identities (preview)</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-registry?view=o365-worldwide" target="_blank">Agent Registry in the Microsoft 365 admin center</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-lists" target="_blank">View and manage agent identities</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-settings?view=o365-worldwide" target="_blank">Agent Settings in Microsoft 365 admin center</a>
- <a href="https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview" target="_blank">Governing Agent Identities (Preview)</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/capabilities-entra" target="_blank">Protect agent identities with Microsoft Entra</a>
- <a href="https://learn.microsoft.com/en-us/security/security-for-ai/agent-365-security" target="_blank">Secure AI agents at scale using Microsoft Agent 365</a>
