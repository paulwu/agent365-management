# Pillar 1: Registry

The Agent Registry is the foundation of agent governance in Microsoft Agent 365. It provides a single inventory of every agent in your tenant — Microsoft-built, partner-built, custom, and shadow agents — and is the starting point for discovering what's running, onboarding it properly, and preventing ungoverned agents from proliferating.

---

## Phase 1: Identify Rogue and Shadow Agents

Before you can govern agents, you need to know what exists. Agent 365 surfaces agents from multiple sources — but not all agents are visible by default.

### Step 1: Review the Agent Registry Inventory

1. Go to **Microsoft 365 admin center → Agents → All Agents → Registry** tab.
2. Review the full list. The registry shows agents integrated with M365 Copilot, including their publisher, type, platform, version, and connectivity status.
3. Use **Agents by Publishers** (on the Overview page) to see the split between agents created by your organization vs. external partners.
4. Use **Agents by Platforms** to understand which tools are producing agents (Copilot Studio lite/full, Azure AI Foundry, external).

**Required role:** AI Administrator (manage) or Global Reader (view-only).

### Step 2: Find Ownerless Agents

1. On the **Agents → Overview** page, check the **Ownerless Agents** card — these are agents with no assigned owner.
2. Click **Assign Owner** to navigate to the **Agent Registry → Ownerless Agents** filter.
3. For each ownerless agent, assign an owner from your organization. Ownerless agents are governance gaps — they have no one responsible for their lifecycle or security.

### Step 3: Check Entra for Shadow Agents

1. Go to **Entra admin center → Entra ID → Agent ID → All agent identities**.
2. Also check **Entra ID → Agent identities → Agent Registry** for registry-only agents (those without full Entra identities).
3. Cross-reference what's in Entra with what's in the M365 Agent Registry. Agents that exist in one but not the other represent a gap.

### Step 4: Check for Copilot Studio Agents Missing from Inventory

Legacy Copilot Studio agents won't appear if:
- The **Entra Agent Identity** setting is off for their Power Platform environment.
- They were never published to the **Teams & Microsoft 365 Copilot** channel.
- They were never submitted for **admin approval**.

See [enabling-legacy-agents.md](enabling-legacy-agents.md) for the full remediation process.

### Step 5: Trace Agent Identities via Service Principal Tags

Steps 1–4 rely on agents being visible in the Agent Registry or Entra Agent ID portal. However, **agents that were never registered or integrated with Agent 365 won't appear in either view**. These truly hidden agents still leave identity traces as service principals in Entra ID.

Agent-related service principals carry specific **tags** that identify them even when they aren't in the Agent Registry:

| Tag Pattern | Agent Type |
|---|---|
| `AgenticInstance` | Agent 365 managed agent instance |
| `AgenticApp` | Agent application registered via Agent 365 |
| `power-virtual-agents-*` | Copilot Studio (formerly Power Virtual Agents) bot |

**Query via Microsoft Graph PowerShell:**

```powershell
Import-Module Microsoft.Graph.Authentication
Connect-MgGraph -Scopes "Application.Read.All"

# Find service principals with agent-related tags
$url = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=" +
    "(tags/Any(p: startswith(p, 'power-virtual-agents-'))" +
    " or tags/Any(p: p eq 'AgenticInstance')" +
    " or tags/Any(p: p eq 'AgenticApp'))"
$results = Invoke-MgGraphRequest -Method Get -Uri $url
$results.value | Select-Object displayName, appId, tags, createdDateTime
```

Cross-reference the results against your Agent Registry inventory. Any service principal found here but **not** in the Registry is a shadow agent that needs onboarding or removal.

### Step 6: Analyze Agent Sign-In Logs

Entra ID now includes an `agentSignIn` resource type in sign-in logs, enabling you to filter for agent-specific authentication activity — even for agents not in the formal registry.

1. Go to **Entra admin center → Monitoring → Sign-in logs**.
2. Filter by **Sign-in type: Service principal** and look for entries with agent-specific attributes.
3. Review key log fields:
   - `AppOwnerTenantId` — identifies the tenant that owns the agent.
   - `ResourceOwnerTenantId` — identifies which resources the agent accessed.
   - `SourceAppClientID` — the client ID performing the sign-in.
   - `SessionID` — for correlating multi-step agent workflows.
4. Flag sign-ins from **unknown app IDs**, **external tenants**, or with **abnormal frequency**.

**Via Graph API:**

```powershell
Connect-MgGraph -Scopes "AuditLog.Read.All"

# Get recent service principal sign-ins (last 7 days)
$date = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ")
$url = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=" +
    "signInEventTypes/any(t: t eq 'servicePrincipal') and createdDateTime ge $date" +
    "&`$top=100&`$orderby=createdDateTime desc"
$signIns = Invoke-MgGraphRequest -Method Get -Uri $url
$signIns.value | Select-Object appDisplayName, appId, resourceDisplayName,
    ipAddress, createdDateTime, status
```

### Step 7: Discover Shadow AI Agents via Microsoft Defender

Microsoft Defender for Cloud Apps provides an **AI agent inventory** that discovers agents across your environment — including shadow agents that bypass the Agent Registry entirely.

1. Go to **Microsoft Defender portal → Investigation & response → Cloud apps → AI agent inventory**.
2. Review discovered agents, including those from:
   - Copilot Studio (low-code/no-code)
   - Azure AI Foundry (pro-code)
   - Third-party AI platforms detected via endpoint traffic analysis
3. For each agent, Defender surfaces:
   - Agent instructions/prompts
   - Connected tools and data sources
   - User identity context
   - Risk indicators

**Advanced Hunting with AIAgentsInfo:**

Use the `AIAgentsInfo` table in Defender Advanced Hunting to query for shadow agents:

```kusto
AIAgentsInfo
| where Timestamp > ago(30d)
| summarize AgentCount = dcount(AgentName) by AgentPlatform, IsManaged
| order by AgentCount desc
```

Filter for `IsManaged == false` to surface unmanaged/shadow agents.

**Cloud Discovery for Generative AI apps:**

1. Go to **Defender for Cloud Apps → Cloud Discovery**.
2. Filter the app catalog by category: **Generative AI**.
3. Review usage data, risk scores, and which users are accessing unsanctioned AI tools from corporate devices.

### Step 8: Audit App Registrations for Over-Privileged or Orphaned Agents

Hidden agents often exist as standard **app registrations** with high-privilege API permissions but no formal agent identity.

1. Go to **Entra admin center → Applications → App registrations → All applications**.
2. Audit for red flags:
   - **No owner assigned** — orphaned apps with no human accountability.
   - **Excessive permissions** — apps with `Directory.ReadWrite.All`, `Application.ReadWrite.All`, `Mail.ReadWrite`, or other high-privilege Graph permissions.
   - **Expired or unused credentials** — stale secrets/certificates that could be exploited.
   - **External ownership** — apps registered by guest or external users.
   - **Generic or suspicious names** — apps with names like "test-bot", "agent-1", or no description.

Use the **Discover-ShadowAgents.ps1** script in the [scripts/](../scripts/) folder to automate this audit.

### Step 9: Use Third-Party Tools for Comprehensive Enumeration

| Tool | What It Does | Link |
|---|---|---|
| **EntraFalcon** | Enumerates all Entra objects (users, apps, service principals) and scores them for risk, privilege, and anomalous configuration | <a href="https://blog.compass-security.com/2025/04/introducing-entrafalcon-a-tool-to-enumerate-entra-id-objects-and-assignments/" target="_blank">EntraFalcon</a> |
| **Defender for Cloud Apps** | Endpoint-based discovery of shadow AI tools accessed from corporate devices | Built into Microsoft Defender |
| **Security Dashboard for AI** | Single-pane view aggregating posture, inventory, and risk signals from Defender, Entra, and Purview | Built into Microsoft Defender (Preview) |

---

## Phase 2: Onboard Discovered Agents

Once you've identified agents, bring them into the governed ecosystem.

### For Copilot Studio / Foundry Agents

1. **Enable Entra Agent Identity** in Power Platform admin center for each environment (see [enabling-legacy-agents.md](enabling-legacy-agents.md)).
2. Have the agent maker **republish** to the Teams & M365 Copilot channel with required metadata.
3. **Approve** the agent in M365 admin center → Agents → Registry → Requests tab.
4. The default template auto-assigns the **Agent 365 license** during activation.

### For Code-Built / Third-Party Agents

1. **Register the agent** via Microsoft Graph API: `POST /beta/agentRegistry/agentInstances` (see [enabling-code-built-agents.md](enabling-code-built-agents.md) and the [scripts/](../scripts/) folder).
2. Include the **agent card manifest** for discoverability metadata.
3. Optionally create an **agent identity blueprint** and full **Entra Agent ID** for agents that need Entra-issued tokens.

### For All Agents — Assign to Collections

Collections control agent discoverability and are the governance boundary:

| Collection | Purpose |
|---|---|
| **Global** | Visible to everyone in the tenant |
| **Custom** | Scoped to specific groups or departments |
| **Quarantined** | Blocked pending review — use for unknown or suspicious agents |

1. Go to **Entra admin center → Agent ID → Agent Registry → Collections**.
2. Assign each onboarded agent to the appropriate collection.
3. Default to **Quarantined** for any agent you're still evaluating.

---

## Phase 3: Prevent Rogue Agents Going Forward

### Control Who Can Create and Publish Agents

1. In **M365 admin center → Agents → Agent Settings**, configure:
   - **Allowed agent types** — restrict which types of agents can be created.
   - **Sharing** — control who can share agents within the org.
   - **User access** — define which users/groups can interact with agents.
   - **Templates** — apply predefined security policy templates to new agents.

2. In **Power Platform admin center**, restrict which environments allow agent creation:
   - Only enable **Entra Agent Identity for Copilot Studio** in approved environments.
   - Use environment-level security roles to limit who can build agents.

### Require Admin Approval for All New Agents

All agents published to the M365 Copilot catalog must go through the **Integrated Apps** approval process:
1. Agent makers submit via **Channels → Teams and Microsoft 365 Copilot → Submit for admin approval**.
2. IT reviews in **M365 admin center → Agents → Registry → Requests tab**.
3. No agent appears in the org catalog without explicit admin approval.

### Quarantine-First Policy for Unknown Agents

1. Set a governance policy: all newly registered agents (especially third-party) default to the **Quarantined** collection.
2. Require a security review before moving to Custom or Global.
3. Review the agent's data sources, tools, permissions, and owner before promoting.

### Monitor Continuously

1. Review the **Agent 365 Overview** dashboard weekly:
   - Check **Pending Requests** (approval backlog).
   - Check **Ownerless Agents** (governance gaps).
   - Track **Active Users Over Time** for adoption anomalies.
2. Use **Entra → Agent ID → All agent identities** for identity-level audit logs.
3. Use **Microsoft Defender → Advanced Hunting** for tool-call trace logs and anomaly detection.

---

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-registry?view=o365-worldwide" target="_blank">Agent Registry in the Microsoft 365 admin center</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-365-overview?view=o365-worldwide" target="_blank">Agent 365 Overview page</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-lists" target="_blank">View and manage agent identities</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-registry-collections" target="_blank">Agent Registry collections</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-settings?view=o365-worldwide" target="_blank">Agent Settings in Microsoft 365 admin center</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/manage-agents-without-identity" target="_blank">Manage Agents with No Agent Identities</a>
