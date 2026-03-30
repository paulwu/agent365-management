---
Author: Microsoft Learn
Priority: 3
---

# Microsoft Learn — Official Agent 365 Documentation

> Compiled from 5 Microsoft Learn pages, accessed February 2026.

---

## Source 1: Agent 365 Overview Page in the Microsoft 365 Admin Center

**URL:** https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-365-overview

The Agent 365 overview page in the Microsoft 365 admin center serves as the control plane for all agents. It provides IT administrators with a centralized dashboard to:

- Track agent adoption and usage trends.
- Identify alerts and governance gaps.
- Enable visibility and control across all agents in the tenant.

Access via: **Microsoft 365 admin center → Agents → Overview**, or **AI home page → View in Agent 365 overview**.

### Key Features

- Snapshot of agent health and actionable insights for the last 30 days.
- Highlight critical actions (approve pending requests, manage agents with alerts, exceptions).
- Surface governance signals to maintain compliance and reduce risk.
- Quick navigation to All agent pages.

### Hero Metrics

- **Agent Registry** — Total count of all agents in the organization's catalog (Microsoft-built, partner-built, custom/LOB agents). Select **Explore All agents → Registry** for detailed inventory.
- **Active Users** — Unique users who interacted with at least one agent in the last 30 days.
- **Time Saved with Agents** — Estimated cumulative hours saved through agent-assisted tasks, based on modeled productivity gains (ROI metric).

### Agent Analytics

- **Agents by Publishers** — Breakdown by source: created by your organization vs. created by external partners.
- **Agents by Platforms** — Which creation platforms are most used (Copilot Studio Full/Lite, Azure AI Foundry, external partner platforms).
- **Active Users Over Time** — Trend chart showing daily active user engagement over 30 days.

### Top Actions for Admins

- **Pending Requests for Agents** — Total pending approval requests (last 30 days), prioritized oldest-first. Navigate via **Manage requests → Agent Registry → Requests tab**.
- **Ownerless Agents** — Agents without an assigned owner. Navigate via **Assign Owner → Agent Registry → Ownerless Agents filter**.

---

## Source 2: Protect Agent Identities with Microsoft Entra

**URL:** https://learn.microsoft.com/en-us/microsoft-agent-365/admin/capabilities-entra

Microsoft Entra Agent ID provides the identity platform capabilities for Microsoft Agent 365.

### Register and Manage Agents

- Unified agent registry consolidating all agents into a single view.
- Built-in and custom controls with agent collections and policies (Zero Trust principles).
- Role-specific observability with built-in Microsoft Entra roles.
- Detailed logging and reporting capabilities.

### Agent Governance and Lifecycles

- Agent sponsorship and ownership capabilities for effective governance.
- Agent lifecycle workflows — ensure agents don't retain resource access longer than needed.

### Protect Agent Access to Resources

Zero Trust principles extended to agents:

- **Conditional Access for agents** — policies targeting agent identities, agent resources, trigger based on agent risk.
- **Entra ID Protection for agents** — automatically detect and respond to risky agent identity behavior (accessing unfamiliar resources, high sign-in attempts).
- **Global Secure Access** — network-level controls for Copilot Studio agents (web content filtering, threat intelligence filtering, network file filtering).

### Agent Identity Platform

- Configure secure authentication for application-only and delegated access scenarios.
- Integration via SDKs and APIs.

---

## Source 3: Agent Map

**URL:** https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-map

The Agent Map is a feature within the Microsoft 365 admin center providing an intuitive visualization of agents in the tenant.

### Key Capabilities

- Interactive spatial visualization of registered agents.
- Identify clusters, review agent metrics, access detailed info (publisher, type, platform, version, connectivity).
- Complements the Registry tab for environments with large numbers of agents.
- Same data as the Registry tab, different presentation.

### Access Requirements

- Available exclusively to **Frontier customers**.
- No special license beyond Frontier group membership.
- Admins must add users to the Frontier group; if the tab doesn't appear, confirm membership.
- Maximum of **800 agents** currently supported on the map.

### Clustering

Default clusters by platform:
- Copilot Studio (lite)
- Copilot Studio (full)
- Microsoft 365 Agents Toolkit
- Microsoft Corporation
- Others

### Filtering

Filter by platform, publisher, and metrics (e.g., blocked agents).

### Agent Details (on click)

- Description, Publisher, Agent type, Platform, Last updated, Version
- Users
- Data and tools
- Security and compliance
- Agent activity

### Known Issues

- Filter malfunction: registry filters may not synchronize with the map (fix coming soon).
- Agent count mismatch: discrepancies between registry and map counts (fix coming soon).

---

## Source 4: Agent 365 Tooling Servers (MCP Servers)

**URL:** https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview

Agent 365 tooling servers are enterprise-grade **Model Context Protocol (MCP) servers** that give agents safe, governed access to business systems through the tooling gateway.

### Available MCP Servers (Default)

- **Copilot Search** — Chat with M365 Copilot, multi-turn threads, ground responses with files.
- **Dataverse and Dynamics 365** — CRUD operations and domain-specific actions.
- **Outlook Calendar** — Create, list, update, delete events; accept/decline; resolve conflicts.
- **Outlook Mail** — Create, update, delete messages; reply/reply-all; semantic search.
- **SharePoint and OneDrive** — Upload files; get metadata; search; manage lists.
- **Teams** — Create, update, delete chat; add members; post messages; channel operations.
- **User Profile** — Get manager, direct reports, profile info; search users.
- **Word** — Create and read documents; add/reply to comments.

### Key Features

- **Centralized governance** — IT admins manage MCP servers in M365 admin center (allow/block across org).
- **Enterprise-grade security** — Scoped permissions, policy enforcement, runtime observability.
- **Continuous evaluation** — Rigorous testing for accuracy, latency, reliability.
- **Integrated developer experience** — Built into Agent 365 SDK, Foundry SDK, and Copilot Studio.

### Governance

- Each MCP server = a permission on the Agent 365 application.
- Admin grants required permissions during agent onboarding; only then does the agent gain access.
- Manage in M365 admin center under **Agents and Tools**.
- If an MCP server is blocked, it is blocked for every user and every agent.

### Observability via Microsoft Defender

- Advanced Hunting in Defender portal to inspect trace logs, monitor execution details, detect anomalies.

### Custom MCP Servers

The **Microsoft MCP Management Server** allows building custom MCP servers:

- **CreateMCPServer** — Spin up a new server instance.
- **CreateToolWithConnector** — Add connectors, Graph APIs, REST endpoints, or Dataverse custom APIs as tools.
- **UpdateTool** — Modify existing tools.
- **DeleteMCPServer** — Remove a server.
- **PublishMCPServer** — Publish a server.

Supports 1,500+ connectors (ServiceNow, JIRA), Microsoft Graph APIs, Dataverse custom APIs, REST APIs.

> At this time, only tenant administrators can publish custom MCP servers within a tenant.

### Authentication

- Agentic user identity or On-Behalf-Of (OBO) delegated user permissions.

---

## Source 5: Secure AI Agents at Scale Using Microsoft Agent 365

**URL:** https://learn.microsoft.com/en-us/security/security-for-ai/agent-365-security

Agent 365 provides a unified control plane for overseeing the security of all AI agents. It integrates with Microsoft's security suite to secure agents from Copilot Studio, Foundry, and third-party solutions.

### Security Areas

#### Identity Management (M365 Admin Center + Entra Registry)

- Complete view of all agents: agents with agent ID, self-registered agents, and **shadow agents**.
- References: Agent 365 Overview, Agent Registry, Entra Agent Registry, Administrative relationships (owners, sponsors, managers).

#### Access Control (Entra Lifecycle + ID Governance + Conditional Access + ID Protection)

- **Define guardrails** — Policies for who can create/onboard/manage agents; assign sponsors; security policy templates.
- **Governance access** — Enforce least-privilege access.
- **Conditional access** — Real-time intelligent access decisions based on agent context, risk, conditions, and target resource.

#### Security Posture (Microsoft Defender + Security Exposure Management)

- Understand agent and data security posture.
- Identify attack paths from agents to critical assets.
- Remediate misconfigurations, exposures, and vulnerabilities.

#### Detection and Response (Microsoft Defender)

- Detect known and emerging threats targeting agents.
- Complete view of cyberattack chain.
- Prioritized investigation and response at incident level.

#### Runtime Defense (Defender + Entra SASE + Purview Insider Risk)

- AI-powered intelligence to block **prompt injection attacks**, malicious traffic, data exfiltration.
- **AI Prompt Shield** via Entra Global Secure Access.

#### Data Security (Purview DLP + Information Protection + Data Security Posture Management)

- Visibility into AI-related data exposure risks.
- Dynamically block agent interactions with sensitive data based on labels and policies.
