# Pillar 3: Visualization

Visualization gives IT administrators an intuitive way to understand the agent landscape across the tenant — tracking adoption, spotting governance gaps, and monitoring agent health at a glance. Agent 365 provides two primary visualization surfaces: the **Overview dashboard** and the **Agent Map**.

<details>
<summary><strong>📑 Table of Contents</strong></summary>

- [Phase 1: Set Up Visibility](#phase-1-set-up-visibility)
  - [Step 1: Access the Agent 365 Overview Dashboard](#step-1-access-the-agent-365-overview-dashboard)
  - [Step 2: Access the Agent Map](#step-2-access-the-agent-map)
- [Phase 2: Understand What the Dashboard Tells You](#phase-2-understand-what-the-dashboard-tells-you)
  - [Hero Metrics](#hero-metrics)
  - [Agent Analytics](#agent-analytics)
  - [Top Admin Actions](#top-admin-actions)
- [Phase 3: Use the Agent Map for Spatial Analysis](#phase-3-use-the-agent-map-for-spatial-analysis)
  - [What the Agent Map Shows](#what-the-agent-map-shows)
  - [Default Clusters](#default-clusters)
  - [Filtering](#filtering)
  - [Agent Details (Click-Through)](#agent-details-click-through)
  - [Known Issues](#known-issues)
- [Phase 4: Monitor Agent Activity via Sign-In and Audit Logs](#phase-4-monitor-agent-activity-via-sign-in-and-audit-logs)
  - [Agent Sign-In Logs](#agent-sign-in-logs)
  - [Agent Audit Logs](#agent-audit-logs)
  - [Risky Agents Report](#risky-agents-report)
  - [Programmatic Monitoring via Graph API](#programmatic-monitoring-via-graph-api)
- [Phase 5: Build a Monitoring Routine](#phase-5-build-a-monitoring-routine)
  - [Weekly Review Checklist](#weekly-review-checklist)
  - [Monthly Review Checklist](#monthly-review-checklist)
  - [Establish Alerting](#establish-alerting)

</details>

---

## Phase 1: Set Up Visibility

### Step 1: Access the Agent 365 Overview Dashboard

1. Go to **Microsoft 365 admin center → Agents → Overview**.
2. Alternatively: **AI home page → View in Agent 365 overview**.

**Required role:** AI Administrator (manage) or Global Reader (view-only).

The Overview page provides a 30-day snapshot of agent health and actionable insights.

### Step 2: Access the Agent Map

1. Go to **Microsoft 365 admin center → Agents → All Agents → Agent Map** tab.
2. The Agent Map tab appears before the Registry tab for eligible users.

**Access requirements:**

- Available exclusively to **Frontier customers**.
- No special license beyond Frontier group membership.
- If the tab doesn't appear, confirm the user has been added to the Frontier group.
- Currently supports a maximum of **800 agents**.

---

## Phase 2: Understand What the Dashboard Tells You

### Hero Metrics

| Metric | What It Measures | Why It Matters |
|---|---|---|
| **Agent Registry** | Total agents in the catalog (Microsoft, partner, custom/LOB) | Shows the breadth of automation deployed |
| **Active Users** | Unique users who interacted with ≥1 agent in 30 days | Measures adoption and engagement |
| **Time Saved with Agents** | Estimated cumulative hours saved via agent-assisted tasks | Demonstrates ROI and business impact |

### Agent Analytics

| Chart | What It Shows | How to Use It |
|---|---|---|
| **Agents by Publishers** | Agents created by your org vs. external partners | Identify the ratio of internal vs. third-party agents; prioritize governance for third-party |
| **Agents by Platforms** | Breakdown by creation platform (Copilot Studio lite/full, Foundry, external) | Understand which tools are producing the most agents; target governance efforts accordingly |
| **Active Users Over Time** | Daily active user trend over 30 days | Spot adoption spikes, declines, or anomalies (sudden drops may indicate issues) |

### Top Admin Actions

| Card | What It Surfaces | Action |
|---|---|---|
| **Pending Requests** | Agent requests awaiting admin approval (oldest-first) | Click **Manage requests** → Agent Registry → Requests tab to approve/reject |
| **Ownerless Agents** | Agents with no assigned owner | Click **Assign Owner** → Agent Registry → Ownerless Agents filter |

---

## Phase 3: Use the Agent Map for Spatial Analysis

### What the Agent Map Shows

The Agent Map is an interactive spatial visualization that clusters agents by platform. It shows the same data as the Registry tab but in a visual layout suited for large environments.

### Default Clusters

| Cluster | What It Contains |
|---|---|
| **Copilot Studio (lite)** | Lightweight agents built with the simplified Copilot Studio experience |
| **Copilot Studio (full)** | Full-featured Copilot Studio agents |
| **Microsoft 365 Agents Toolkit** | Agents built with the M365 Agents Toolkit |
| **Microsoft Corporation** | Microsoft-built first-party agents |
| **Others** | External partner or custom-coded agents |

### Filtering

Apply filters to narrow the view:

- **By platform** — focus on a specific creation tool(e.g., only Copilot Studio lite).
- **By publisher** — isolate agents from a specific team or partner.
- **By status** — show only blocked agents to triage restricted agents.

### Agent Details (Click-Through)

Select any agent icon to see:

- **Details** — description, publisher, agent type, platform, last updated, version.
- **Users** — who is using this agent.
- **Data and tools** — what data sources and tools the agent accesses.
- **Security and compliance** — governance status and policy compliance.
- **Agent activity** — usage patterns and interaction history.

### Known Issues

| Issue | Status |
|---|---|
| Filters applied in Registry may not synchronize with the map | Fix coming soon |
| Agent count may differ between Registry and Map | Fix coming soon |

---

## Phase 4: Monitor Agent Activity via Sign-In and Audit Logs

### Agent Sign-In Logs

Entra ID includes a dedicated `agentSignIn` resource type in sign-in logs, enabling fine-grained monitoring of agent authentication activity.

1. Go to **Entra admin center → Entra ID → Monitoring & health → Sign-in logs**.
2. Use the dedicated agent filters:
   - **Agent type** — choose from: **Agent ID user**, **Agent Identity**, **Agent Identity Blueprint**, or **Not Agentic**.
   - **Is Agent** — choose **Yes** or **No**.
3. Because agents can sign in with either user-delegated or app-only permissions, their sign-ins may appear across each of the four sign-in log types:
   - Agent identities (actor) accessing resources → **Service principal sign-in logs** → agentType: agent ID user
   - Agent users accessing resources → **Non-interactive user sign-ins** → agentType: agent user
   - Users accessing agents → **User sign-ins**

**Via Microsoft Graph API (beta):**

```powershell
# Retrieve agent identity sign-in events
GET https://graph.microsoft.com/beta/auditLogs/signIns?$filter=signInEventTypes/any(t: t eq 'servicePrincipal') and agent/agentType eq 'AgentIdentity'
```

### Agent Audit Logs

Agent activity is logged under the base identity type from which it originates:

| Agent Identity Type | Example Audit Events |
|---|---|
| Agent identity user (agent's user account) | "Create user" audit activity |
| Agent identity (service principal) | "Create service principal" audit event |
| Agent identity blueprint (application) | "Create application" / "Delete application" audit event |

### Risky Agents Report

Microsoft Entra ID Protection provides a dedicated **Risky Agents** report for monitoring agent risk:

1. Go to **Entra admin center → Protection → Identity Protection → Risky Agents**.
2. Review agents flagged for risky behavior, including:
   - **Unfamiliar resource access** — agent targeted resources it doesn't usually access.
   - **Sign-in spike** — abnormally high number of sign-ins compared to usual frequency.
   - **Failed access attempt** — agent attempted to access unauthorized resources.
   - **Sign-in by risky user** — agent signed in on behalf of a risky user.
   - **Confirmed compromised** — admin confirmed agent compromised.
   - **Microsoft Entra threat intelligence** — activity consistent with known attack patterns.
3. Take action directly from the report:
   - **Confirm compromise** — sets risk to High and triggers risk-based Conditional Access.
   - **Confirm safe** — clears risk state for false positives.
   - **Dismiss risk** — marks risk as no longer relevant.
   - **Disable** — prevents all sign-ins for that agent.

### Programmatic Monitoring via Graph API

Use Microsoft Graph for automated monitoring:

| API Collection | Purpose |
|---|---|
| `riskyAgents` | List all agents flagged for risky behavior |
| `agentRiskDetections` | List individual risk detection events for agents (up to 90 days) |
| `auditLogs/signIns` with agent filters | Query agent-specific sign-in events |

---

## Phase 5: Build a Monitoring Routine

### Weekly Review Checklist

| What to Check | Where | What to Look For |
|---|---|---|
| **Pending approvals** | Overview → Pending Requests card | Growing backlog = approval process bottleneck |
| **Ownerless agents** | Overview → Ownerless Agents card | Any ownerless agent is a governance gap |
| **Active Users trend** | Overview → Active Users Over Time chart | Sudden drops (agent outage?) or spikes (unauthorized agent?) |
| **Platform distribution** | Overview → Agents by Platforms | Unexpected growth in "Others" = possible shadow agents |
| **Blocked agents** | Agent Map → Filter: blocked | Agents that were blocked but may need re-evaluation |
| **Risky agents** | Entra → ID Protection → Risky Agents | New risk detections requiring investigation or remediation |
| **Agent sign-in anomalies** | Entra → Sign-in logs → filter Is Agent = Yes | Unusual sign-in patterns, unfamiliar resources, or sign-in spikes |

### Monthly Review Checklist

| What to Check | Where | What to Look For |
|---|---|---|
| **Total agent count growth** | Overview → Agent Registry metric | Rapid growth may outpace governance capacity |
| **Publisher ratio** | Overview → Agents by Publishers | Increasing external-partner ratio may need additional review |
| **Cluster distribution** | Agent Map → visual clusters | New clusters or unexpected cluster sizes |
| **Time Saved metric** | Overview → Time Saved with Agents | Trending down could indicate agent quality/adoption issues |

### Establish Alerting

Complement the dashboard with programmatic alerting:

1. **Entra sign-in logs** — set up alerts for agent identity sign-in failures, risky sign-ins, or unfamiliar resource access.
2. **Entra ID Protection → Risky Agents** — configure automated responses (block, alert sponsor) for high-risk agent detections.
3. **Microsoft Defender → Advanced Hunting** — create detection rules for anomalous agent tool calls.
4. **Purview alerts** — trigger on agents interacting with sensitive data classifications.
5. **Microsoft Graph** — use `riskyAgents` and `agentRiskDetections` API collections to build custom alerting workflows.

---

## References

| Source | Author | Priority |
|---|---|---|
| <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-365-overview?view=o365-worldwide" target="_blank">Agent 365 Overview page in the admin center</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-map?view=o365-worldwide" target="_blank">Agent Map</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/sign-in-audit-logs-agents" target="_blank">Sign-in and audit logs for agents</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/id-protection/concept-risky-agents" target="_blank">Entra ID Protection for agents (Risky Agents report)</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-registry?view=o365-worldwide" target="_blank">Agent Registry in the Microsoft 365 admin center</a> | Microsoft Learn | 1 |
| [grounding/Microsoft-Learn.md](../grounding/Microsoft-Learn.md) | Microsoft Learn | 3 |
