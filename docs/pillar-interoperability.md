# Pillar 4: Interoperability

Interoperability ensures agents can safely interact with enterprise systems — sending emails, scheduling meetings, querying databases, searching documents — regardless of which platform built the agent. Agent 365 achieves this through **MCP (Model Context Protocol) tooling servers** and a **centralized tooling gateway** that enforces governance on every tool call.

---

## Phase 1: Understand the MCP Architecture

### What Are MCP Tooling Servers?

MCP tooling servers are enterprise-grade servers that expose granular, auditable tools (e.g., `createMessage`, `getEvents`, `createFolder`) for agent actions. They sit behind a **tooling gateway** that:

- Registers servers and enforces Microsoft Entra scopes.
- Applies policy and observability on every tool call.
- Ensures deterministic, auditable agent actions.

### How Agents Connect to Tools

```
Agent → Tooling Gateway → MCP Server → Business System (Outlook, Teams, SharePoint, etc.)
          ↕                    ↕
     Policy enforcement    Scoped permissions
     + observability       + authentication
```

Each MCP server is represented as a **permission on the Agent 365 application**. An agent only gains access to a server after the admin **grants the required permission** during onboarding.

### Authentication

Agents authenticate to MCP servers using one of two models:

| Model | Description | Use When |
|---|---|---|
| **Agentic user identity** | Agent acts on its own identity | Autonomous agent operations |
| **On-Behalf-Of (OBO)** | Agent acts on behalf of the signed-in user | User-initiated agent actions needing delegated permissions |

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
   ```
   https://agent365.svc.cloud.microsoft/mcp/environments/{environment ID}/servers/MCPManagement
   ```
   Replace `{environment ID}` with your <a href="https://learn.microsoft.com/en-us/power-platform/admin/determine-org-id-name" target="_blank">Power Platform environment ID</a>.
5. Name the server **"MCPManagement"**.
6. Choose **Global** to make it available across all projects.
7. Sign in with your Microsoft account when prompted.
8. Use built-in tools (**Create MCP Server**, **Add Tools**) to define your custom server.

> **Current limitation:** Only tenant administrators can publish custom MCP servers.

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

---

## Phase 5: Prevent Interoperability Gaps

### ISV and Custom Server Certification

- ISVs can build, publish, and certify their own MCP servers for the ecosystem.
- Customers can create line-of-business servers for internal use.
- All servers go through the tooling gateway for governance, policy enforcement, and observability.

### Key Principles

1. **Default-deny for MCP servers** — only enable the servers agents actually need.
2. **Least-privilege permissions** — each agent gets access only to its required servers.
3. **Audit tool calls regularly** — use Defender Advanced Hunting to review what agents are doing.
4. **Block before investigate** — if a server or tool is behaving unexpectedly, block it first, then investigate.
5. **Continuous evaluation** — Microsoft tests all default MCP servers for accuracy, latency, and reliability. Apply the same rigor to custom servers.

---

## References

- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview" target="_blank">Agent 365 Tooling Servers (MCP)</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/capabilities-entra" target="_blank">Protect agent identities with Microsoft Entra</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/threat-protection" target="_blank">Threat protection in Microsoft Agent 365</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/monitor-agents" target="_blank">Monitor agents</a>
