# Pillar 2: Access Control

Access Control ensures that agents operate under the same Zero Trust principles as human identities — verifying explicitly, enforcing least-privilege access, and assuming breach. Microsoft Agent 365 extends Entra Conditional Access, ID Protection, and ID Governance to agent identities.

<details>
<summary><strong>📑 Table of Contents</strong></summary>

- [Agent Identity Architecture](#agent-identity-architecture)
- [Phase 1: Assess Current Agent Access](#phase-1-assess-current-agent-access)
  - [Step 1: Audit Agent Identities and Their Permissions](#step-1-audit-agent-identities-and-their-permissions)
  - [Step 2: Review Administrative Relationships](#step-2-review-administrative-relationships)
  - [Step 3: Identify Over-Privileged Agents](#step-3-identify-over-privileged-agents)
- [Phase 2: Enforce Least-Privilege Access](#phase-2-enforce-least-privilege-access)
  - [Step 1: Apply Conditional Access Policies for Agents](#step-1-apply-conditional-access-policies-for-agents)
  - [Step 2: Enable Entra ID Protection for Agents](#step-2-enable-entra-id-protection-for-agents)
  - [Step 3: Apply Network-Level Controls (Global Secure Access)](#step-3-apply-network-level-controls-global-secure-access)
- [Phase 3: Implement Lifecycle Governance](#phase-3-implement-lifecycle-governance)
  - [Step 1: Set Up Agent Lifecycle Workflows](#step-1-set-up-agent-lifecycle-workflows)
  - [Step 2: Use Access Packages for Time-Bound Agent Access](#step-2-use-access-packages-for-time-bound-agent-access)
  - [Step 3: Define Guardrails for Agent Creation](#step-3-define-guardrails-for-agent-creation)
- [Phase 4: Prevent Access Control Gaps Going Forward](#phase-4-prevent-access-control-gaps-going-forward)
  - [Continuous Monitoring Checklist](#continuous-monitoring-checklist)
  - [Key Principles](#key-principles)

</details>

## Agent Identity Architecture

Understanding the identity constructs is essential for configuring access control:

| Term | Description |
|---|---|
| **Agent identity blueprint** | A logical definition of an agent type; template for creating agent identities with preconfigured permissions, policies, and settings |
| **Agent identity blueprint principal** | A service principal that represents the blueprint in the tenant; executes only creation of agent identities and agent users |
| **Agent identity** | Instantiated agent identity; performs token acquisitions to access resources |
| **Agent user** | Nonhuman user identity used for agent experiences that require a user account |
| **Agent resource** | Agent blueprint or agent identity acting as the resource app (e.g., in A2A flows) |

> Throughout this document, "blueprint" refers to **agent identity blueprint** — the official Microsoft Learn term.

Credentials used to authenticate an agent identity are configured on the blueprint.OAuth permissions granted to a blueprint are granted to all agent identities created from that blueprint. Disabling a blueprint prevents all its agent identities from authenticating.

---

## Phase 1: Assess Current Agent Access

Before creating policies, understand what agents can access today.

### Step 1: Audit Agent Identities and Their Permissions

1. Go to **Entra admin center → Entra ID → Agent ID → All agent identities**.
2. For each agent identity, review:
   - **Owner/Sponsor** — who is responsible for this agent?
   - **Resource access** — what apps and resources does this agent have access to?
   - **Sign-in logs** — when was the last activity? What resources were accessed?
3. Flag agents with **no sponsor**, **broad permissions**, or **access to sensitive resources**.

### Step 2: Review Administrative Relationships

Agent 365 uses three administrative relationships for agent governance:

| Relationship | Purpose |
|---|---|
| **Owner** | Can manage the agent's properties and configuration |
| **Sponsor** | Responsible for the agent's lifecycle; ensures ongoing oversight |
| **Manager** | Organizational hierarchy for the agent (optional) |

1. Ensure every agent has at least an **owner** and a **sponsor**.
2. Agents without sponsors are governance gaps — lifecycle workflows can't enforce time-bound access.

### Step 3: Identify Over-Privileged Agents

1. Use **Microsoft Defender → Security Exposure Management** to identify agents with excessive permissions or access paths to critical assets.
2. Review agents that access high-value resources (SharePoint sites with sensitive data, Dataverse production, email/calendar).
3. Prioritize agents accessing resources beyond what their stated purpose requires.

---

## Phase 2: Enforce Least-Privilege Access

### Step 1: Apply Conditional Access Policies for Agents

Conditional Access for Agent ID extends Zero Trust controls to agents as first-class identities. Policies evaluate agent access requests the same way they evaluate requests for users or workload identities, but with agent-specific logic.

1. Go to **Entra admin center → Entra ID → Conditional Access → Policies**.
2. Select **New policy** and configure the four key components:

**Assignments:**

- Under **What does this policy apply to?**, select **Agents (Preview)**.
- **Include** options: All agent identities, specific agent identities by object ID, agent identities by custom security attributes, or agent identities grouped by blueprint.
- For agent users: select **All agent users**.

**Target resources:**

- All resources, all agent resources(blueprints and identities), specific resources by custom security attributes, or specific resources by appId.
- Targeting a blueprint covers all agent identities created from that blueprint.

**Conditions:**

- **Agent risk (Preview)** — high, medium, or low.

**Access controls:**

- Block access.

**Example policies to create:**

| Policy | Configuration | Effect |
|---|---|---|
| **Block high-risk agents** | Condition: agent risk = high → Grant: block | Prevents compromised agents from accessing resources |
| **Allow only approved agents** | Use custom security attributes (e.g., `AgentApprovalStatus` = `IT_Approved`) to exclude approved agents; block all others | Only reviewed/approved agents can access resources |
| **Restrict access by resource** | Target: specific apps tagged with custom security attributes → Grant: allow only for tagged agents | Enforces per-agent, per-resource access |
| **Block agents outside business hours** | Condition: network location ≠ approved → Grant: block | Restricts agent traffic to known networks |

> **Conditional Access applies** when an agent identity or agent user requests a token for any resource. It does **not** apply when a blueprint acquires a token to create agent identities, or during intermediate token exchanges at the AAD Token Exchange Endpoint.

**Required licensing:** Microsoft Entra ID P1 or higher. Microsoft 365 Copilot with Frontier program enabled.

### Step 2: Enable Entra ID Protection for Agents

Microsoft Entra ID Protection automatically detects and responds to identity-based risks on agent identities. The system establishes a baseline for each agent's normal activity and continuously monitors for anomalies.

**Risk detections for agents:**

| Detection | Type | Description |
|---|---|---|
| **Unfamiliar resource access** | Offline | Agent targeted resources it doesn't usually access — may indicate unauthorized access attempt |
| **Sign-in spike** | Offline | Abnormally high number of sign-ins compared to usual frequency — may indicate automation attack |
| **Failed access attempt** | Offline | Agent attempted to access unauthorized resources — may indicate token replay |
| **Sign-in by risky user** | Offline | Agent signed in on behalf of a risky user during delegated authentication |
| **Confirmed compromised** | Offline | Admin confirmed agent compromised |
| **Microsoft Entra threat intelligence** | Offline | Activity consistent with known attack patterns based on Microsoft's threat intelligence sources |

**Using the Risky Agents report:**

1. Go to **Entra admin center → Protection → Identity Protection → Risky Agents**.
2. Review flagged agents and their risk level (high, medium, low).
3. Take action directly from the report:
   - **Confirm compromise** — sets risk to High, triggers risk-based Conditional Access policies that block on High Agent Risk.
   - **Confirm safe** — clears active risk state (use for false positives).
   - **Dismiss risk** — marks risk as no longer relevant after investigation.
   - **Disable** — prevents all sign-ins for that agent across Microsoft Entra ID and connected apps.

**Via Microsoft Graph API:**

Use the `riskyAgents` and `agentRiskDetections` collections in the ID Protection APIs for programmatic access.

**Required licensing:** Microsoft Entra ID P2 (included during preview).

### Step 3: Apply Network-Level Controls (Global Secure Access)

For agents created in Copilot Studio, apply network controls via Global Secure Access:

- **Web content filtering** — block agents from accessing unapproved web endpoints.
- **Threat intelligence filtering** — block traffic to known malicious destinations.
- **Network file filtering** — scan files agents transmit across the network.

---

## Phase 3: Implement Lifecycle Governance

### Step 1: Set Up Agent Lifecycle Workflows

Agent lifecycle workflows prevent agents from retaining resource access longer than needed.

1. Go to **Entra admin center → Identity Governance → Lifecycle workflows**.
2. Create workflows for agent identities:
   - **On creation** — apply a security policy template and assign a sponsor.
   - **On access expiry** — revoke resource access and notify the sponsor.
   - **On decommission** — disable the agent identity and remove from collections.

**Required licensing:** Entra ID Governance or Entra Suite. Microsoft 365 Copilot with Frontier program enabled for Agent ID features.

### Step 2: Use Access Packages for Time-Bound Agent Access

Access packages let you grant agents temporary access to resources with approval workflows. Agent identities can receive access to security group memberships, application OAuth API permissions (including Graph application permissions), and Microsoft Entra roles.

1. Go to **Entra admin center → Identity Governance → Entitlement management → Access packages**.
2. Create an access package for a set of resources (e.g., "HR Data Access").
3. In the assignment policy, under **Who can get access**, select **For users, service principals, and agent identities in your directory**, then select **All agents (preview)**.
4. Configure:
   - **Approval required** — sponsor or resource owner must approve.
   - **Time-limited** — access expires after a set duration (e.g., 90 days).
   - **Renewal required** — sponsor must re-approve before access extends.

**Three access request pathways:**

| Pathway | Description |
|---|---|
| **Agent self-request** | The agent identity itself programmatically requests an access package when needed for its operations via Microsoft Graph API |
| **Sponsor request** | The agent's sponsor requests access on behalf of the agent, providing human oversight |
| **Admin direct assign** | An administrator directly assigns the agent identity to the access package |

**Sponsor lifecycle management:**

Sponsors are human users accountable for making decisions about an agent's lifecycle and access. Microsoft Entra provides automatic safeguards:

- If the sponsor is leaving the organization, **sponsorship automatically transfers to their manager**.
- This ensures there is always a human user accountable for managing the agent's access and lifecycle.
- Lifecycle workflows include tasks for notifying cosponsors and managers of sponsors about impending sponsorship changes.

**Agent management portals:**

| Portal | Capabilities |
|---|---|
| **My Account portal** (myaccount.microsoft.com) | Sponsors and owners can manage agent lifecycle (enable/disable), view access, activity, and lifecycle information |
| **My Access portal** (myaccess.microsoft.com) | Sponsors and owners can request access packages on behalf of their agent identities |

### Step 3: Define Guardrails for Agent Creation

Control who can create, onboard, and manage agents:

1. In **M365 admin center → Agents → Agent Settings**, define policies for:
   - Who can create agents (restrict to approved maker groups).
   - What security templates are applied by default.
2. In **Power Platform admin center**, restrict agent creation to approved environments.
3. Require all new agents to have a **sponsor assigned at creation time**.

---

## Phase 4: Prevent Access Control Gaps Going Forward

### Continuous Monitoring Checklist

| What to Monitor | Where | Frequency |
|---|---|---|
| Risky agents | Entra ID Protection → Risky agents report | Daily |
| Conditional Access sign-in failures | Entra → Sign-in logs (filter: agent identities) | Weekly |
| Over-privileged agents | Defender → Security Exposure Management | Monthly |
| Agents without sponsors | Entra → Agent ID → All agent identities | Weekly |
| Access package renewals due | Entra → Identity Governance → Access packages | Weekly |

### Key Principles

1. **No agent should have standing access** to sensitive resources — use time-bound access packages.
2. **Every agent must have a sponsor** — sponsors are accountable for lifecycle decisions.
3. **Start with block-all Conditional Access** — then explicitly allow access per agent/resource pair.
4. **Review risky agent reports proactively** — don't wait for an incident.

---

## References

| Source | Author | Priority |
|---|---|---|
| <a href="https://learn.microsoft.com/en-us/entra/identity/conditional-access/agent-id" target="_blank">Conditional Access for Agent ID (Preview)</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/id-protection/concept-risky-agents" target="_blank">Entra ID Protection for agents</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview" target="_blank">Governing Agent Identities (Preview)</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id" target="_blank">What is Microsoft Entra Agent ID?</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/what-are-agent-identities" target="_blank">What are agent identities?</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/id-governance/agent-sponsor-tasks" target="_blank">Agent lifecycle workflows</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-owners-sponsors-managers" target="_blank">Administrative relationships (owners, sponsors, managers)</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/global-secure-access/concept-secure-web-ai-gateway-agents" target="_blank">Global Secure Access for agents</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/capabilities-entra" target="_blank">Protect agent identities with Microsoft Entra</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/agent-access-packages" target="_blank">Access packages for agent identities</a> | Microsoft Learn | 1 |
| [grounding/Microsoft-Learn-Entra-AgentID.md](../grounding/Microsoft-Learn-Entra-AgentID.md) | Microsoft Learn | 2 |
| [grounding/ChatGPT.md](../grounding/ChatGPT.md) | ChatGPT | 4 |
