# Pillar 4: Interoperability

Interoperability ensures agents can safely interact with enterprise systems — sending emails, scheduling meetings, querying databases, searching documents — regardless of which platform built the agent. Agent 365 achieves this through **MCP (Model Context Protocol) tooling servers**, a **centralized tooling gateway** that enforces governance on every tool call, and the **Agent Communication protocol** that enables secure agent-to-agent interactions via the Agent Registry.

---

## Phase 1: Understand the MCP Architecture

### What Are MCP Tooling Servers?

MCP tooling servers are enterprise-grade servers that expose granular, auditable tools (e.g., `createMessage`, `getEvents`, `createFolder`) for agent actions. They sit behind a **tooling gateway** that:

- Registers servers and enforces Microsoft Entra scopes.
- Applies policy and observability on every tool call.
- Ensures deterministic, auditable agent actions.

### How Agents Connect to Tools

```text
Agent → Tooling Gateway → MCP Server → Business System (Outlook, Teams, SharePoint, etc.)
          ↕                    ↕
     Policy enforcement    Scoped permissions
     + observability       + authentication
```

Each MCP server is represented as a **permission on the Agent 365 application**. An agent only gains access to a server after the admin **grants the required permission** during onboarding.

### Authentication and Token Flows

Agents use OAuth 2.0 protocols with specialized token exchange patterns. The Microsoft agent identity platform supports three primary authentication flows:

| Flow | Description | Use When |
|---|---|---|
| **Agent on-behalf-of flow** | Agent operates on behalf of a regular user via delegated permissions | User-initiated agent actions needing delegated permissions |
| **Autonomous app flow** | Agent operates with its own identity and permissions (app-only) | Autonomous agent operations without user context |
| **Agent's user account flow** | Agent operates using a dedicated agent user account with user-like context | Agent needs mailbox, calendar, or team membership access |

All agent entities are **confidential clients**. Interactive flows are not supported — all authentication occurs through programmatic token exchanges.

**SDK recommendation:** Microsoft recommends using the **Microsoft Identity Web (.NET)** SDK or the **Microsoft Entra SDK for Agent ID** rather than implementing these protocols manually. The SDKs abstract the complexity of token acquisition and protocol handling.

**Credential best practices:**

- **Managed identities** are the preferredcredential type for agent identity blueprints, providing automatic credential rotation and secure storage.
- **Client secrets should not be used** in production environments. Use federated identity credentials (FIC) with managed identities or client certificates instead.

---

## Phase 2: Discover and Enable Default MCP Servers

Microsoft provides pre-certified MCP servers for core M365 services. These are deeply integrated and available in Copilot Studio (low-code) and Azure AI Foundry (pro-code).

### Available Default MCP Servers

| Server | Key Tools | Example Actions |
|---|---|---|
| **Outlook Mail** | createMessage, updateMessage, deleteMessage, reply, replyAll, semanticSearch | Send email on behalf of user; search for messages matching a query |
| **Outlook Calendar** | createEvent, listEvents, updateEvent, deleteEvent, accept, decline | Schedule meetings; resolve scheduling conflicts |
| **Teams** | createChat, updateChat, deleteChat, addMembers, postMessage | Post a status update to a channel; create a group chat |
| **SharePoint & OneDrive** | uploadFile, getMetadata, search, manageLists | Upload a report; search for documents; update a list item |
| **Copilot Search** | chat, startConversation, continueThread | Ground agent responses with M365 data; multi-turn conversations |
| **Dataverse & Dynamics 365** | CRUD operations, domain-specific actions | Query CRM records; update a support case |
| **User Profile** | getManager, getDirectReports, getProfile, searchUsers | Look up a user's reporting chain; find people by name |
| **Word** | createDocument, readDocument, addComment, replyToComment | Generate a report document; add review comments |

### Enable a Default MCP Server

1. Go to **Microsoft 365 admin center → Agents and Tools**.
2. View all available MCP servers.
3. **Allow** the servers your agents need; **block** any servers that shouldn't be available.
4. When onboarding an agent, grant it permission to the specific servers it requires.

> If an MCP server is blocked, it is blocked for **every user and every agent** — no exceptions.

---

## Phase 3: Build Custom MCP Servers

For specialized or line-of-business workflows, build custom MCP servers using the **Microsoft MCP Management Server**.

### What Is the MCP Management Server?

An API-first build surface that exposes tools for creating and managing custom MCP servers — no UI required. Everything is API-driven for automation and integration.

### Core Tools

| Tool | What It Does |
|---|---|
| `CreateMCPServer` | Spin up a new MCP server instance |
| `CreateToolWithConnector` | Add connectors, Graph APIs, REST endpoints, or Dataverse custom APIs as tools |
| `UpdateTool` | Modify an existing tool's configuration |
| `DeleteMCPServer` | Remove a server when no longer needed |
| `PublishMCPServer` | Publish a server to the tenant (currently tenant admin only) |

### Supported Connector Ecosystem

| Connector Type | Examples |
|---|---|
| **Pre-built connectors** | 1,500+ connectors (ServiceNow, JIRA, Salesforce, SAP, etc.) |
| **Microsoft Graph APIs** | Mail, Calendar, Teams, Users, Files |
| **Dataverse custom APIs** | Organization-specific business logic |
| **REST APIs** | Any HTTP endpoint |

### Step-by-Step: Connect via Visual Studio Code

1. Open **Visual Studio Code**.
2. Press **Ctrl + Shift + P** → search for **"MCP: Add Server"**.
3. Select **http** as the server type.
4. Enter the URL:

   ```text
   https://agent365.svc.cloud.microsoft/mcp/environments/{environment ID}/servers/MCPManagement
   ```

   Replace `{environment ID}`with your <a href="https://learn.microsoft.com/en-us/power-platform/admin/determine-org-id-name" target="_blank">Power Platform environment ID</a>.
5. Name the server **"MCPManagement"**.
6. Choose **Global** to make it available across all projects.
7. Sign in with your Microsoft account when prompted.
8. Use built-in tools (**Create MCP Server**, **Add Tools**) to define your custom server.

> **Current limitation:** Only tenant administrators can publish custom MCP servers.

---

## Phase 3.5: Enable Agent-to-Agent Communication

### What Is Agent Communication?

Agent Communication enables secure interactions between AI agents through the Microsoft Entra Agent Registry API. It provides a common language and standardized approach for agents from different developers, built on different frameworks, and owned by different owners to work together.

### Core Components

| Component | Description |
|---|---|
| **Agent manifest** | A JSON document serving as a "business card" — contains metadata about identity, capabilities, endpoint, skills, and authentication requirements |
| **Client agent** | Initiates communication and orchestrates interactions with other agents |
| **Remote agent** | Autonomous agent or system exposing an HTTP endpoint that receives and processes requests |

### How It Works

1. **Validate client agent identity** — the client agent must have an agent identity (`agentIdentityId`) registered in the Agent Registry.
2. **Discover remote agent** — query the Agent Registry for agents by attributes (skills, capabilities, name, collection):

   ```http
   GET https://graph.microsoft.com/beta/agentRegistry/agentCardManifests?$filter=displayName eq 'Sample Agent'&$select=id,displayName,skills
   ```

3. **Discovery policy enforcement**— the Registry validates that the remote agent is in a permitted collection and communication is allowed based on configured policies.
4. **Send collaboration message** — use [JSON-RPC specification](https://www.jsonrpc.org/specification) from the client to the remote agent, including:
   - `method` — action to invoke
   - `params` — input data
   - `traceId` — for audit
   - `caller` — Registry-issued token

### Discovery Policy Error Codes

| HTTP Status | Error Code | Description |
|---|---|---|
| 400 | ValidationError | Request validation failed |
| 401 | Unauthorized | Authentication required |
| 403 | Forbidden | Insufficient permissions — agent not in permitted collection |
| 404 | AgentNotFound | Agent not found in registry |
| 404 | AgentCardNotFound | Agent card manifest not found |

> **Prerequisite:** Only agents with an agent identity can query the Agent Registry for discovery. Agents without an identity can be discovered by others but cannot initiate discovery themselves.

### Token Claims for A2A Validation

When agents communicate, tokens carry enhanced claims to support agent-specific requirements:

| Claim | Purpose |
|---|---|
| `xms_act_fct` (Actor facet) | Identifies the entity performing actions within the token flow |
| `xms_sub_fct` (Subject facet) | Identifies the ultimate subject for whom operations are performed |
| `idtyp` (Identity type) | Distinguishes between user and application contexts |
| `xms_idrel` (Identity relationship) | Describes the relationship between token subject and resource tenant |

Resource servers receiving agent tokens should validate:

- Standard OAuth claims (`aud`, `exp`, `iss`)
- Agent facet claims for proper entity identification
- Permissions based on token type (delegated vs. app-only)
- Tenant boundary compliance

---

## Phase 4: Govern Tool Access

### Configure MCP Server Policies

1. In **M365 admin center → Agents and Tools**:
   - **Allow** servers needed by your agent fleet.
   - **Block** servers that pose compliance risks or aren't needed.
   - Review the list periodically as new servers become available.

2. For each agent onboarding:
   - Grant only the **specific MCP server permissions** the agent needs (least privilege).
   - Don't grant blanket access to all servers.

### Scoped Permissions per Agent

When onboarding an agent, the admin grants permissions to specific MCP servers. This creates a **per-agent permission scope**:

| Agent | Allowed MCP Servers | Blocked |
|---|---|---|
| HR Benefits Bot | User Profile, SharePoint | Outlook Mail, Teams, Calendar |
| Meeting Scheduler | Outlook Calendar, Teams, User Profile | SharePoint, Dataverse |
| Sales Copilot | Dataverse, Outlook Mail, Teams | Word, SharePoint |

### Monitor Tool Usage

1. **Microsoft Defender → Advanced Hunting** — run queries to:
   - Inspect trace logs of tool calls made by agents.
   - Monitor which tools were invoked, parameters passed, and outcomes.
   - Detect anomalies or unauthorized usage patterns.

2. Review tool call patterns:
   - Is an agent calling tools it shouldn't need?
   - Are there failed tool calls suggesting misconfiguration?
   - Are there unusual volumes of calls (possible automation loop)?

### Network-Level Governance (Global Secure Access)

For Copilot Studio agents, apply additional network-level controls via Global Secure Access:

1. Enable **traffic forwarding** in the Power Platform Admin Center on a per-environment or per-environment-group basis.
2. Agent traffic forwarding applies to: HTTP Node traffic, Custom connectors, and MCP Server Connector.
3. Once forwarded, apply security policies via the **baseline profile** in Global Secure Access:
   - **Web content filtering** — control access to APIs and MCP servers.
   - **Threat intelligence filtering** — block malicious destinations.
   - **File-type policies** — restrict file uploads and downloads.
   - **Prompt injection detection** — block malicious instructions in agent data.

---

## Phase 5: Prevent Interoperability Gaps

### ISV and Custom Server Certification

- ISVs can build, publish, and certify their own MCP servers for the ecosystem.
- Customers can create line-of-business servers for internal use.
- All servers go through the tooling gateway for governance, policy enforcement, and observability.

### Platform Integrations

Multiple Microsoft products integrate with the agent identity platform for interoperability:

| Product | Integration |
|---|---|
| **Microsoft Foundry** | Provisions default blueprint per project; supports MCP and A2A tools for agent identity authentication |
| **Azure App Service / Functions** | Can be configured to use the agent identity platform for secure resource connections |
| **Microsoft Copilot Studio** | Agents automatically assigned agent identities when enabled; full MCP server integration |
| **Microsoft Teams** | Developers create and manage blueprints in the Developer Portal for Teams |

### Key Principles

1. **Default-deny for MCP servers** — only enable the servers agents actually need.
2. **Least-privilege permissions** — each agent gets access only to its required servers.
3. **Audit tool calls regularly** — use Defender Advanced Hunting to review what agents are doing.
4. **Block before investigate** — if a server or tool is behaving unexpectedly, block it first, then investigate.
5. **Continuous evaluation** — Microsoft tests all default MCP servers for accuracy, latency, and reliability. Apply the same rigor to custom servers.

---

## References

| Source | Author | Priority |
|---|---|---|
| <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview" target="_blank">Agent 365 Tooling Servers (MCP)</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/registry-agent-to-agent-protocol" target="_blank">Agent communication (A2A protocol)</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-oauth-protocols" target="_blank">Agent OAuth protocols</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-tokens" target="_blank">Tokens in Microsoft agent identity platform</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/what-is-agent-id-platform" target="_blank">What is the Microsoft agent identity platform?</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/global-secure-access/concept-secure-web-ai-gateway-agents" target="_blank">Global Secure Access for agents</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview" target="_blank">Governing Agent Identities (Preview)</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/capabilities-entra" target="_blank">Protect agent identities with Microsoft Entra</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/threat-protection" target="_blank">Threat protection in Microsoft Agent 365</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/monitor-agents" target="_blank">Monitor agents</a> | Microsoft Learn | 1 |
| [grounding/Microsoft-Learn-Entra-AgentID.md](../grounding/Microsoft-Learn-Entra-AgentID.md) | Microsoft Learn | 2 |
| [grounding/Microsoft-Learn.md](../grounding/Microsoft-Learn.md) | Microsoft Learn | 3 |
