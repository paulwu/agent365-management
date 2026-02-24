# Pillar 2: Access Control

Access Control ensures that agents operate under the same Zero Trust principles as human identities — verifying explicitly, enforcing least-privilege access, and assuming breach. Microsoft Agent 365 extends Entra Conditional Access, ID Protection, and ID Governance to agent identities.

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

Conditional Access for agent identities works the same way as for users — but targets agent principals.

1. Go to **Entra admin center → Protection → Conditional Access**.
2. Create a new policy:
   - **Assignments → Workload identities** → select **Agent identities**.
   - **Target resources** → select the apps/resources the policy applies to.
   - **Conditions** → configure based on agent risk level, location, or sign-in behavior.
   - **Grant** → Block access, require compliant device, or require specific conditions.

**Example policies to create:**

| Policy | What It Does |
|---|---|
| **Block high-risk agents** | If Entra ID Protection flags an agent as risky, block its access tokens |
| **Restrict access by resource** | Only allow agents to access their designated apps — block everything else |
| **Block agents outside business hours** | Prevent agent activity during non-working hours (anomaly signal) |
| **Require specific network location** | Restrict agent access to traffic originating from approved networks |

**Required licensing:** Microsoft Entra ID P1.

### Step 2: Enable Entra ID Protection for Agents

Entra ID Protection automatically detects risky agent behavior:

- Accessing unfamiliar resources the agent hasn't used before.
- High number of sign-in attempts (brute force or misconfiguration).
- Accessing resources from unusual locations or networks.

1. Go to **Entra admin center → Protection → Identity Protection**.
2. Review the **Risky agents** report.
3. Configure automated responses: block access, require investigation, or alert the agent's sponsor.

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

**Required licensing:** Entra ID Governance or Entra Suite.

### Step 2: Use Access Packages for Time-Bound Agent Access

Access packages let you grant agents temporary access to resources with approval workflows.

1. Go to **Entra admin center → Identity Governance → Entitlement management → Access packages**.
2. Create an access package for a set of resources (e.g., "HR Data Access").
3. Add agent identities as eligible requestors.
4. Configure:
   - **Approval required** — sponsor or resource owner must approve.
   - **Time-limited** — access expires after a set duration (e.g., 90 days).
   - **Renewal required** — sponsor must re-approve before access extends.

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

- <a href="https://learn.microsoft.com/en-us/entra/identity/conditional-access/agent-id" target="_blank">Conditional Access for Agent ID (Preview)</a>
- <a href="https://learn.microsoft.com/en-us/entra/id-protection/concept-risky-agents" target="_blank">Entra ID Protection for agents</a>
- <a href="https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview" target="_blank">Governing Agent Identities (Preview)</a>
- <a href="https://learn.microsoft.com/en-us/entra/id-governance/agent-sponsor-tasks" target="_blank">Agent lifecycle workflows</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-owners-sponsors-managers" target="_blank">Administrative relationships (owners, sponsors, managers)</a>
- <a href="https://learn.microsoft.com/en-us/entra/global-secure-access/concept-secure-web-ai-gateway-agents" target="_blank">Global Secure Access for agents</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/capabilities-entra" target="_blank">Protect agent identities with Microsoft Entra</a>
