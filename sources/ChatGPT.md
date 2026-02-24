Here’s how to think about it (and why your older Copilot Studio agents might not show up):

* **Agent 365 / Microsoft 365 admin center “Agents” inventory** is built on the **Agent Registry experience** and is focused on agents **integrated with Microsoft 365 Copilot**. ([Microsoft Learn][1])
* **Microsoft Entra “Agent ID”** is the **identity + lifecycle + access** layer for agents (blueprints, agent identities, agent users, registry-only agents, etc.). ([Microsoft Learn][2])

So an agent can exist but not appear where you’re looking, depending on:

* whether it’s **integrated with M365 Copilot surfaces** (for the M365 admin “Agents” view), ([Microsoft Learn][1])
* whether it has an **Entra agent identity** (for Entra “Agent identities”), ([Microsoft Learn][3])
* and whether you have the right **roles/licenses**.

---

## 1) Roles and licenses you need (quick map)

### Admin roles (humans)

| What you’re trying to do                                  | Where                                         | Required role(s)                                                                                                                      |
| --------------------------------------------------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| View/manage agents in Microsoft 365 admin center          | **admin.microsoft.com → Agents**              | **AI Administrator** (manage) or **Global Reader** (view-only) ([Microsoft Learn][4])                                                 |
| View/manage Entra agent identities                        | **entra.microsoft.com → Entra ID → Agent ID** | **Agent ID Administrator** or **Cloud Application Administrator** (or be the **owner** of that agent identity) ([Microsoft Learn][2]) |
| Register non-Microsoft agents into Agent Registry         | **Entra Agent Registry / Graph API**          | **Agent Registry Administrator** ([Microsoft Learn][5])                                                                               |
| Create agent identity blueprints (pro-code)               | **Graph API / CLI / Entra**                   | **Agent ID Developer** or **Agent ID Administrator** ([Microsoft Learn][6])                                                           |
| Turn on Copilot Studio → Entra Agent Identity integration | **Power Platform admin center**               | **Power Platform tenant admin** or **Environment Admin** ([Microsoft Learn][3])                                                       |

### Licensing (what’s actually required)

* **To enable Agent 365 (Frontier preview):** tenant must be in **Frontier** and have **at least one Microsoft 365 Copilot license**, then you enable Frontier user access in M365 admin center. ([Microsoft Learn][7])
* **To manage Copilot agents in M365 admin center:** the capability is enabled by default in **Microsoft 365 Copilot licensed tenants**. ([Microsoft Learn][4])
* **Agent 365 license assignment (agent instances):** the M365 admin center Agent Registry flow notes the **default template automatically assigns the Agent 365 license during activation**. ([Microsoft Learn][1])
* **If you want Conditional Access guardrails for agents:** Conditional Access requires **Microsoft Entra ID P1**. ([Microsoft Learn][8])
* **If you want Identity Governance / access packages for agents:** those governance features require **Entra ID Governance or Entra Suite** licensing. ([Microsoft Learn][9])

---

## 2) Why older Copilot Studio agents don’t show up in Agent 365 (most common causes)

### A) You don’t have the right admin role for the portal you’re checking

* For **M365 admin center → Agents**, you need **AI Admin** or **Global Reader**. ([Microsoft Learn][4])
* For **Entra → Agent ID**, you need **Agent ID Admin / Cloud App Admin** (or be owner). ([Microsoft Learn][2])

### B) Tenant isn’t enabled for the right experience

* If you’re expecting **Agent 365 Frontier features**, confirm Frontier is enabled and user access is granted. ([Microsoft Learn][7])

### C) The Copilot Studio environment isn’t configured to create Entra agent identities

Copilot Studio’s Entra Agent Identity integration is environment-scoped and must be turned on in Power Platform admin center. ([Microsoft Learn][3])

### D) The agent isn’t “integrated with Microsoft 365 Copilot”

The **Agent Registry page** in Microsoft 365 admin center lists agents **integrated with Microsoft 365 Copilot**. ([Microsoft Learn][1])
If an older Copilot Studio agent was only ever used in non-M365 channels (for example, only a website/demo), it may not appear in the M365 “Agents” inventory even though it exists elsewhere. (This is the most common “it exists but I can’t see it” mismatch.)

---

## 3) Step-by-step: bring older Copilot Studio agents into Entra Agent ID + Agent 365 views

### Step 0 — Make sure Agent 365 / agent management is enabled where you expect it

1. If you’re using **Agent 365 Frontier**, ensure: Frontier enrollment + at least one M365 Copilot license in tenant. ([Microsoft Learn][7])
2. In **Microsoft 365 admin center → Copilot → Settings → User access**, enable **Copilot Frontier** for the right users/groups. ([Microsoft Learn][7])
3. Ensure your admin account has **AI Administrator** (or **Global Reader** for read-only). ([Microsoft Learn][4])

### Step 1 — Turn on Entra Agent Identity for Copilot Studio (environment-level)

> This is the key “modernization” step for older agents.

1. Go to **Power Platform admin center** → **Copilot** tab → **Settings**.
2. Under **Copilot Studio**, select **Entra Agent Identity for Copilot Studio**.
3. Select the **environment** → **Edit setting** → set **On** → **Save**. ([Microsoft Learn][3])
   **Required admin:** Power Platform tenant admin or Environment Admin. ([Microsoft Learn][3])

### Step 2 — Validate whether a specific agent has an Entra Agent ID

1. In **Copilot Studio**, open the agent → **Settings** → **Advanced** → expand **Metadata**.
2. Look for the **Entra Agent ID** GUID. ([Microsoft Learn][3])
3. Use that GUID in **Entra admin center → Entra ID → Agent ID → All agent identities** to confirm it exists. ([Microsoft Learn][2])

### Step 3 — Ensure it’s governed/visible in Microsoft 365 admin center “Agents”

1. Go to **Microsoft 365 admin center → Agents → All Agents / Registry** (inventory of Copilot-integrated agents). ([Microsoft Learn][1])
2. If you’re rolling it out broadly, use **Agent settings** to control:

   * **Allowed agent types**
   * **Sharing**
   * **User access**
   * **Templates** (guardrails) ([Microsoft Learn][10])

> Note: When you activate/deploy agents through the Agent Registry flow, Microsoft’s **default template** can apply predefined policies and **auto-assign the Agent 365 license during activation**. ([Microsoft Learn][1])

---

## 4) Step-by-step: agents created with Microsoft tools before Agent 365 / Agent ID existed

Microsoft’s model is: **new identity constructs (blueprints/agent identities/agent users) + registry metadata + collection-based discoverability**. ([Microsoft Learn][11])

### For older Microsoft-built agents (general approach)

1. **Enable the product’s integration controls** (Copilot Studio via Power Platform setting; Foundry manages identities automatically). ([Microsoft Learn][3])
2. **Confirm the agent identity exists** in Entra (Agent ID → All agent identities). ([Microsoft Learn][2])
3. **Ensure the agent is present in the right registry/inventory** (M365 admin center Agents, if it’s meant to be used with M365 Copilot). ([Microsoft Learn][1])
4. Apply guardrails:

   * **Conditional Access** for agent identities (needs Entra P1) ([Microsoft Learn][8])
   * **Identity Governance / access packages** (if you want time-bound approvals and renewals) ([Microsoft Learn][11])

---

## 5) Step-by-step: agents created with non-Microsoft tools

You have two supported patterns:

### Pattern A — “Registry-only” (inventory + metadata, but no Entra Agent ID)

This is common if the agent uses another identity provider or you just want visibility first.

1. Assign yourself **Agent Registry Administrator**. ([Microsoft Learn][5])
2. Register an **agent instance** via Microsoft Graph:
   `POST /beta/agentRegistry/agentInstances` (include operational endpoint URL, ownerIds, originatingStore, etc.). ([Microsoft Learn][5])
3. Register the **agent card manifest** (discovery metadata) by including `agentCardManifest` (skills, security schemes, docs URL, etc.). ([Microsoft Learn][5])
4. Verify in Entra admin center: **Entra ID → Agent identities → Agent Registry**. ([Microsoft Learn][12])
5. Put the agent in the right **collection(s)** to control discoverability (Global/Custom/Quarantined). In preview, collection assignment is manual, and collections are the governance boundary for “who can discover whom.” ([Microsoft Learn][13])

### Pattern B — Full Entra Agent ID (identity + registry)

Use this when you want **Entra-issued tokens, CA/governance, and consistent lifecycle controls**.

1. Create an **agent identity blueprint** (template for agent identities). Requires **Agent ID Developer or Agent ID Administrator** and Graph permissions described in the blueprint creation guide. ([Microsoft Learn][6])
2. Create **agent identities** from that blueprint (Agent ID Administrator for user-driven creation in Entra/CLI; or Graph permissions for automation). ([Microsoft Learn][14])
3. Register the agent instance in Agent Registry and include:

   * `agentIdentityBlueprintId`
   * `agentIdentityId`
   * optional `agentUserId`
     alongside the operational endpoint URL. ([Microsoft Learn][5])
4. Apply controls:

   * Conditional Access (Entra P1) ([Microsoft Learn][8])
   * Collections-based discoverability policies ([Microsoft Learn][13])
   * Optional access packages / governance workflows ([Microsoft Learn][11])

---

## 6) Minimal “rogue agent” control plane checklist (what I’d do first)

1. **M365 admin center → Agents → All Agents**: inventory + block/remove + missing owner views (good for “rogue” triage). ([Microsoft Learn][1])
2. **Entra → Agent ID → All agent identities**: find identities, disable agents, inspect access and logs. ([Microsoft Learn][2])
3. Require **collections** (don’t use Global for everything; quarantine unknowns). ([Microsoft Learn][13])
4. Add **Conditional Access for agent identities** (requires Entra P1). ([Microsoft Learn][8])

---

If you tell me **which UI you mean by “Agent 365 portal”** (Microsoft 365 admin center → Agents, or Entra → Agent ID), I can give you a tighter, click-by-click path tailored to that exact screen and what “missing” looks like there.

[1]: https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-registry?view=o365-worldwide "Agent Registry in the Microsoft 365 admin center - Microsoft 365 admin | Microsoft Learn"
[2]: https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-lists "View and manage agent identities in your tenant - Microsoft Entra Agent ID | Microsoft Learn"
[3]: https://learn.microsoft.com/en-us/microsoft-copilot-studio/admin-use-entra-agent-identities "Automatically create Entra agent identities (preview) - Microsoft Copilot Studio | Microsoft Learn"
[4]: https://learn.microsoft.com/en-us/microsoft-365/admin/manage/manage-copilot-agents-integrated-apps?view=o365-worldwide "Manage Microsoft 365 Copilot Agents - Microsoft 365 admin | Microsoft Learn"
[5]: https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/publish-agents-to-registry "Register Agents to the Agent Registry | Microsoft Learn"
[6]: https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint?utm_source=chatgpt.com "Create an agent identity blueprint - Microsoft Entra Agent ID"
[7]: https://learn.microsoft.com/en-us/microsoft-agent-365/overview "Microsoft Agent 365 overview | Microsoft Learn"
[8]: https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview?utm_source=chatgpt.com "Microsoft Entra Conditional Access: Zero Trust Policy Engine"
[9]: https://learn.microsoft.com/en-us/entra/id-governance/identity-governance-overview?utm_source=chatgpt.com "Microsoft Entra ID Governance"
[10]: https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-settings?view=o365-worldwide "Agent Settings in Microsoft 365 admin center - Microsoft 365 admin | Microsoft Learn"
[11]: https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview "Governing Agent Identities (Preview) - Microsoft Entra ID Governance | Microsoft Learn"
[12]: https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/manage-agents-without-identity "Manage Agents with No Agent Identities | Microsoft Learn"
[13]: https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-registry-collections?utm_source=chatgpt.com "Agent Registry collections - Microsoft Entra Agent ID"
[14]: https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/agent-id-creation-channels "How are agent identities created? | Microsoft Learn"
