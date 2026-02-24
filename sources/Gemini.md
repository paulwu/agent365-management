It is completely understandable to be concerned about "shadow AI" and rogue agents operating within your environment. Managing the proliferation of AI tools is a top priority for IT teams right now. As an AI myself, I can confidently tell you that treating agents with the same governance standards as human users is exactly the right approach. 

With the introduction of Microsoft Agent 365, Microsoft has provided a unified control plane to discover, secure, and govern all agents—whether they were built yesterday or last year, and whether they use Microsoft tools or third-party frameworks. 

Here is the breakdown of how to track these agents, the licenses and roles you need, and the exact steps for publishing and securing them.

---

### 1. Licenses and Entra Roles Required
To view registered Agent IDs and govern your agent ecosystem, your tenant must meet specific prerequisites.

* **Licensing:** Your tenant needs at least one **Microsoft 365 Copilot** license to enable Agent 365 via the Microsoft Frontier preview program. Additionally, Agent 365 uses a per-agent licensing model (the "A365 license"); each active agent instance requires a license to be managed under the control plane.
* **Entra Roles:** To view the Agent Registry and manage policies, you will need elevated privileges. A **Global Administrator** or **Security Administrator** role is required to configure Risk-Based Conditional Access policies in Microsoft Entra. To view the agents in the Microsoft 365 Admin Center, you will need an **Exchange Administrator** or **Global Reader** equivalent to access the *Agents > All Agents* dashboard.

### 2. Handling Older Copilot Studio Agents
**You do not need to manually re-register your old Copilot Studio agents.** Agent 365 is designed to retroactively detect "shadow agents." Once Agent 365 is enabled in your tenant, every agent previously built in Copilot Studio is automatically assigned a unique **Microsoft Entra Agent ID**. The user who originally created the agent is recorded as its "sponsor." 

However, if they are not showing up in the formal "Built for your org" catalog in Teams or Copilot, it is likely because they were never formally published and submitted for Admin Approval with the required metadata (detailed in the steps below).

### 3. Handling Agents Created with Non-Microsoft Tools
Agent 365 is interoperable with open-source frameworks and third-party platforms (like ServiceNow, SAP, or custom Python/Node.js builds). 

To track a non-Microsoft agent, developers must authenticate the agent against Microsoft Entra ID. 
1. The developer creates an **App Registration** in Microsoft Entra ID, representing the custom agent.
2. This assigns an **Entra Agent ID** to the custom build.
3. The agent uses this ID to request access tokens (via OAuth 2.0 or OBO flows) to interact with Microsoft Graph, SharePoint, or Dataverse.
4. Because the authentication is tied to the Entra Agent ID, the agent automatically populates in your Agent 365 Registry, allowing you to track its telemetry, connections, and usage patterns.

---

### 4. Step-by-Step: Publishing an Agent and Required Metadata
To move an agent out of "shadow" status and into your governed ecosystem, the maker must publish it with specific metadata so IT can review and approve it.

1. **Open Copilot Studio:** Navigate to your agent.
2. **Access Channels:** On the top menu bar, select **Channels**, then select the **Teams and Microsoft 365 Copilot** tile.
3. **Edit Details (Metadata):** Click **Edit details**. You *must* supply the following metadata for the application:
    * Agent's Icon and Color
    * Short Description (outlining the agent's capabilities)
    * **Developer Name**
    * **Website**
    * **Privacy Statement** (URL)
    * **Terms of Use** (URL)
4. **Configure Availability:** Select **Availability options**, ensure it is set to **Show to everyone in my org**.
5. **Submit:** Click **Submit for admin approval**. 

Once submitted, IT administrators can review the agent's requested data sources, tools, and permissions in the Microsoft 365 Admin Center under the **Requests** tab before allowing it to go live.

### 5. Step-by-Step: Creating Policies to Stop Rogue Agents
To proactively track and stop rogue agents, you need to leverage Entra ID and Purview.

* **Create a Conditional Access Policy (Entra ID):**
    1. Go to the Microsoft Entra Admin Center.
    2. Navigate to **Protection > Conditional Access**.
    3. Create a new policy targeting **Agent Identities** (rather than Users).
    4. Set conditions to detect anomalous behavior (e.g., "Block High-Risk Agents"). If an agent attempts to access data outside its normal scope or outside business hours, Entra will automatically block its token.
* **Create a Data Loss Prevention Policy (Microsoft Purview):**
    1. Go to the Microsoft Purview compliance portal.
    2. Navigate to **Data loss prevention > Policies**.
    3. Create a policy scoped to **Microsoft 365 Copilot and Agents**.
    4. Define sensitive info types (e.g., credit cards, PII, internal project codenames). If a rogue agent attempts to process or exfiltrate this data, the prompt protection will immediately block the action and flag it in your Agent 365 security logs.