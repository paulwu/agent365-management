# Pillar 1: Registry

The Agent Registry is the foundation of agent governance in Microsoft Agent 365. As part of the Microsoft Entra Agent ID system, the Agent Registry is an extensible metadata repository that delivers a unified view of all deployed agents — Microsoft-built, partner-built, custom, and shadow agents — across Microsoft and non-Microsoft ecosystems. It is the starting point for discovering what's running, onboarding it properly, and preventing ungoverned agents from proliferating.

## Agent Registry Architecture

The Agent Registry is built on several core components that work together:

| Component | Purpose | Key Features |
|---|---|---|
| **Metadata store** | Centralized agent metadata repository | NoSQL-based, agent card manifest support, real-time updates |
| **Collections** | Secure agent categorization and discovery control | Baseline (Global, Custom, Quarantined) discovery controls |
| **Discovery service** | Agent and capability discovery APIs | Multi-dimensional search, collection-aware filtering, skill-based discovery |
| **Integration layer** | Coordinates with Microsoft and non-Microsoft ecosystems | Ecosystem-wide security operations and custom workflows |

The registry connects to the Microsoft Entra Core Directory, which enforces identity and entitlement policies. Each agent instance from an authoritative agent store (such as Copilot Studio) is registered in the Registry and linked to an **agent card manifest**, which can represent multiple agents (1:N relationship).

Security is embedded at every layer:

- **Identity Assurance**— Microsoft platforms integrated with Entra Agent ID automatically receive an agent identity and are enrolled in the registry.
- **Runtime Enforcement** — Discovery policies are enforced dynamically when agents attempt discovery, preventing unauthorized actions. Only agents with an agent identity can discover other agents in the registry.

---

## Phase 1: Identify Rogue and Shadow Agents

Before you can govern agents, you need to know what exists. Agent 365 surfaces agents from multiple sources — but not all agents are visible by default.

### Step 1: Review the Agent Registry Inventory

1. Go to **Microsoft 365 admin center → Agents → All Agents → Registry** tab.
2. Review the full list. The registry shows agents integrated with M365 Copilot, including their publisher, type, platform, version, and connectivity status.
3. Use **Agents by Publishers** (on the Overview page) to see the split between agents created by your organization vs. external partners.
4. Use **Agents by Platforms** to understand which tools are producing agents (Copilot Studio lite/full, Azure AI Foundry, external).

**Required role:** AI Administrator (manage) or Global Reader (view-only).
**Required licensing:** Microsoft 365 Copilot license with Frontier program enabled.

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

- The **Entra Agent Identity** settingis off for their Power Platform environment.
- They were never published to the **Teams & Microsoft 365 Copilot** channel.
- They were never submitted for **admin approval**.

See [enabling-legacy-agents.md](enabling-legacy-agents.md) for the full remediation process.

> **Note:** Agent identity blueprints can enter your directory through multiple channels. Understanding these channels helps you identify where shadow agents may originate:
>
> | Channel | Typical Actors |
> |---|---|
> | Microsoft Entra admin center / Azure portal | Developers, Administrators |
> | Microsoft Graph API | Automation, DevOps pipelines, integration services |
> | CLI, PowerShell, Infrastructure as Code | DevOps, Administrators |
> | Microsoft product integrations (Copilot Studio, Foundry, Teams) | Users of Microsoft agent platforms |
> | Microsoft Entra ID consent experience | Employees accepting third-party agents |

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

1. Go to **Entra admin center → Entra ID → Monitoring & health → Sign-in logs**.
2. Use the dedicated agent filters:
   - **Agent type** — choose from: Agent ID user, Agent Identity, Agent Identity Blueprint, or Not Agentic.
   - **Is Agent** — choose Yes or No.
3. Review key log fields:
   - `AppOwnerTenantId` — identifies the tenant that owns the agent.
   - `ResourceOwnerTenantId` — identifies which resources the agent accessed.
   - `SourceAppClientID` — the client ID performing the sign-in.
   - `SessionID` — for correlating multi-step agent workflows.
4. Flag sign-ins from **unknown app IDs**, **external tenants**, or with **abnormal frequency**.

Agent activity is logged under the base identity type from which it originates. The three agent identity types in audit logs are:

| Agent Identity Type | Corresponding Audit Event |
|---|---|
| Agent identity user | "Create user" audit activity |
| Agent identity | "Create service principal" audit event |
| Agent identity blueprint | "Delete application" / "Create application" audit event |

**Via Graph API (beta):**

```powershell
Connect-MgGraph -Scopes "AuditLog.Read.All"

# Get agent identity sign-in events
$url = "https://graph.microsoft.com/beta/auditLogs/signIns?" +
    "`$filter=signInEventTypes/any(t: t eq 'servicePrincipal') " +
    "and agent/agentType eq 'AgentIdentity'"
$signIns = Invoke-MgGraphRequest -Method Get -Uri $url
$signIns.value | Select-Object appDisplayName, appId, resourceDisplayName,
    ipAddress, createdDateTime, status
```

### Step 7: Discover Shadow AI Agents via Microsoft Defender

Microsoft Defender for Cloud Apps provides an **AI agent inventory** that detects all **Copilot Studio custom AI agents** in your tenant and provides tools to identify misconfigured or potentially risky agents.

> **Scope:** The AI agent inventory currently covers Copilot Studio custom agents. It does not yet discover agents built with Azure AI Foundry, third-party platforms, or custom code. For those agents, use Steps 5, 6, and 8.

**Prerequisites:**

- Opt in to **Microsoft Defender preview features**(Defender for Cloud Apps, Defender for Cloud, Defender XDR).
- Requires collaboration with **Power Platform administrators**.

**Enable the AI agent inventory:**

1. Sign in to the **Microsoft Defender portal** → **System → Settings → Cloud Apps → Copilot Studio AI Agents** → Turn on.
2. Work with your Power Platform admin in the **Power Platform Admin Center**:
   - Go to **Security → Threat Protection → Microsoft Defender - Copilot Studio AI Agents** → Enable.
3. Wait up to 30 minutes for the connection status to update. Full inventory may take longer depending on environment size.

**Advanced Hunting with AIAgentsInfo:**

Use the `AIAgentsInfo` table in Defender Advanced Hunting to query for risky agents. Community queries are available under **Investigation & response → Hunting → Advanced hunting → Queries → Community queries → AI Agents**.

**Sample queries from Microsoft Learn:**

Agents with no authentication (high risk — publicly accessible):

```kusto
AIAgentsInfo
| summarize arg_max(Timestamp, *) by AIAgentId
| where AgentStatus != "Deleted"
| where UserAuthenticationType == "None"
| project-reorder AgentCreationTime, AIAgentId, AIAgentName, AgentStatus,
    CreatorAccountUpn, OwnerAccountUpns
```

Agents with hard-coded credentials in topics or actions:

```kusto
let suspicious_patterns = @"(AKIA[0-9A-Z]{16})|(AIza[0-9A-Za-z_\-]{35})|(ghp_[A-Za-z0-9]{36,59})|(sk_(live|test)_[A-Za-z0-9]{24})|(eyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+)";
AIAgentsInfo
| summarize arg_max(Timestamp, *) by AIAgentId
| where AgentStatus != "Deleted"
| mv-expand tool = AgentToolsDetails
| mv-expand topic = AgentTopicsDetails
| where tool matches regex suspicious_patterns or topic matches regex suspicious_patterns
| project-reorder AgentCreationTime, AIAgentId, AIAgentName, AgentStatus,
    CreatorAccountUpn, OwnerAccountUpns
```

Agents making HTTP requests to non-standard ports:

```kusto
AIAgentsInfo
| summarize arg_max(Timestamp, *) by AIAgentId
| where AgentStatus != "Deleted"
| mvexpand Topic = AgentTopicsDetails
| where Topic has "HttpRequestAction"
| extend TopicActions = Topic.beginDialog.actions
| mvexpand action = TopicActions
| where action['$kind'] == "HttpRequestAction"
| extend Url = tostring(action.url.literalValue)
| extend ParsedUrl = parse_url(Url)
| extend Port = tostring(ParsedUrl["Port"])
| where isnotempty(Port) and Port != 443
| project-reorder AgentCreationTime, AIAgentId, AIAgentName, Url, Port,
    AgentStatus, CreatorAccountUpn
```

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
3. Optionally create a **blueprint** and full **Entra Agent ID** for agents that need Entra-issued tokens.

**Required roles for registration:**

| Scenario | Required Role |
|---|---|
| Create agent identity blueprint | Agent ID Developer or Agent ID Administrator |
| Create agent identity from blueprint | Agent ID Administrator |
| Register agent instance in registry | Agent Registry Administrator |
| Grant Graph delegated permissions | Cloud/Application Administrator |
| Grant Graph application permissions | Privileged Role Administrator |

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

### Product Integrations with Agent Registry

Several Microsoft products automatically register agents in the registry:

| Product | How It Works |
|---|---|
| **Microsoft Copilot Studio** | Agents automatically get an agent identity when Entra Agent ID is enabled; creator is recorded as sponsor |
| **Microsoft Foundry** | Provisions a default blueprint and agent identity per project; publishing creates dedicated identities |
| **Azure App Service / Functions** | Apps can be configured to use the agent identity platform for secure resource connections |
| **Microsoft Teams** | Developers create and manage blueprints in the Developer Portal for Teams |
| **Microsoft Agent 365** | Gives each AI agent its own Entra Agent ID for identity, lifecycle, and access management |

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

1. Agent makers submit via**Channels → Teams and Microsoft 365 Copilot → Submit for admin approval**.
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
4. Use the **Agent Registry → Agent Communication** capabilities to monitor agent-to-agent interactions. The Agent Communication protocol enables secure interactions via JSON-RPC specification, with each interaction logged for audit via `traceId`.

---

## References

| Source | Author | Priority |
|---|---|---|
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/what-is-agent-registry" target="_blank">What is the Agent Registry?</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-registry?view=o365-worldwide" target="_blank">Agent Registry in the Microsoft 365 admin center</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/agent-id-creation-channels" target="_blank">Agent identity creation channels</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/registry-agent-to-agent-protocol" target="_blank">Agent communication (A2A protocol)</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/sign-in-audit-logs-agents" target="_blank">Sign-in and audit logs for agents</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-registry-collections" target="_blank">Agent Registry collections</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-365-overview?view=o365-worldwide" target="_blank">Agent 365 Overview page</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-lists" target="_blank">View and manage agent identities</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-settings?view=o365-worldwide" target="_blank">Agent Settings in Microsoft 365 admin center</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/manage-agents-without-identity" target="_blank">Manage Agents with No Agent Identities</a> | Microsoft Learn | 1 |
| [grounding/Microsoft-Learn-Entra-AgentID.md](../grounding/Microsoft-Learn-Entra-AgentID.md) | Microsoft Learn | 2 |
| <a href="https://learn.microsoft.com/en-us/defender-cloud-apps/ai-agent-inventory" target="_blank">Discover and protect your AI agents (Preview)</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/defender-cloud-apps/ai-agent-protection" target="_blank">AI agent protection features</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-aiagentsinfo-table" target="_blank">AIAgentsInfo table reference</a> | Microsoft Learn | 1 |
| [grounding/ChatGPT.md](../grounding/ChatGPT.md) | ChatGPT | 4 |
