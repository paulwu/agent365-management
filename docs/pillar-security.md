# Pillar 5: Security

Security in Agent 365 extends Microsoft's full security infrastructure to AI agents — covering identity, access, posture, detection, runtime defense, and data protection. The goal: treat agents with the same security rigor as human identities while addressing agent-specific threats like prompt injection and autonomous data exfiltration.

## Why AI Agents Need Identity-Based Security

Unlike applications that execute predetermined logic, AI agents make dynamic decisions and adapt behavior based on training data, input, and environment conditions. This creates specific security challenges:

| Challenge | Description |
|---|---|
| **External accessibility** | Many agents interact with external users, third-party systems, or the public internet, creating pathways for adversaries |
| **Permission escalation risk** | Agents often provisioned with broad permissions to ensure capability — broader than necessary for specific tasks |
| **Autonomous decision-making** | Compromised agents making autonomous decisions can take harmful actions (unauthorized purchases, system deletions) |
| **Prompt injection attacks** | AI agents are vulnerable to attacks that manipulate behavior by inserting malicious instructions into processed data |
| **Agent-to-agent propagation** | Compromised orchestration agents can potentially target other agents to perform malicious actions |

### Agent Security Scenarios

| Scenario | Description | Risk |
|---|---|---|
| **User-initiated agent** | Agent acts on behalf of user, inheriting capabilities and access | Compromised agent performs unauthorized actions as the user |
| **Autonomous agent** | Agent operates with its own identity and permissions | Compromised agent operates without constraint beyond its authorized scope |
| **Agent's user account** | Agent functions as a human user with persistent identity, mailbox, team access | Compromised agent accesses documents, participates in meetings, sends communications as trusted member |
| **Agent-to-agent** | Orchestration agent delegates tasks to specialized agents | Unsecured communication allows injection of malicious agents or interception of interactions |

### Agent Sprawl

Agent sprawl is the uncontrolled expansion of agents across an organization without adequate visibility, management, or lifecycle controls. It emerges when:

- Business units create agentswithout formal IT oversight (**shadow AI**).
- Agents created for temporary purposes remain in production indefinitely.
- Agent permissions exceed actual requirements and are never reviewed.

Uncontrolled sprawl leads to increased security risk from over-privileged agents with unclear ownership, compliance challenges when auditors expect governance, and incident response difficulties when organizations can't quickly identify compromised agents.

---

## Phase 1: Assess Your Agent Security Posture

### Step 1: Inventory All Agents (Including Shadow Agents)

The security stack starts with knowing what exists.

1. **M365 admin center → Agents → All Agents → Registry** — full inventory of agents integrated with M365 Copilot.
2. **Entra admin center → Entra ID → Agent ID → All agent identities** — agents with Entra identities, self-registered agents, and shadow agents.
3. **Entra → Agent identities → Agent Registry** — registry-only agents (no full Entra identity).

Cross-reference all three views. Agents appearing in only one view represent security blind spots.

### Step 2: Review Security Posture in Microsoft Defender

1. Go to **Microsoft Defender portal → Agent page → Overview tab**.
2. Review:
   - Agent and data security posture score.
   - Attack paths that adversaries could exploit from agents to critical assets.
   - Misconfigurations, exposures, and vulnerabilities.
3. Use **Security Exposure Management** to identify agents with excessive permissions or connections to high-value targets.

### Step 3: Identify High-Risk Agents

Prioritize agents that:

- Have **no owner or sponsor**(no human accountability).
- Access **sensitive data** (PII, financial data, internal project codenames).
- Have **broad permissions** (access to many resources beyond stated purpose).
- Were built by **external parties** or exist in **unknown origins**.
- Show **risky behavior** in Entra ID Protection reports.

**Understanding agent identity types:**

| Identity Type | Built For | Key Difference |
|---|---|---|
| **Agent identity** | AI agents with dynamic, autonomous behavior | Designed for scale and ephemerality; supports bulk creation/retirement |
| **Application identity** | Long-lived services with known ownership | Designed for permanence and stability |
| **Human user identity** | Human beings using passwords, MFA, passkeys | Tied to human authentication mechanisms |

Agent identities can optionally be paired with **agent user accounts** — special Entra user accounts that maintain a 1:1 relationship with their paired agent identity for scenarios requiring user-like context (mailbox, team membership).

---

## Phase 2: Secure Agent Identities

### Conditional Access for Agents

Conditional Access for Agent ID extends Zero Trust evaluation and enforcement to agents as first-class identities. Creating a policy involves four key components:

1. Go to **Entra admin center → Protection → Conditional Access**.
2. Create policies targeting **agent identities**:

**Policy configuration:**

- **Assignments** — Scope to: all agent identities, specific identities by object ID, identities by custom security attributes, or identities grouped by blueprint. Also supports all agent users.
- **Target resources** — All resources, all agent resources (blueprints and identities), specific resources by custom security attributes or appId. Targeting a blueprint covers all its child agent identities.
- **Conditions** — Agent risk level (high, medium, low).
- **Access controls** — Block access.

| Policy | Configuration | Effect |
|---|---|---|
| **Block high-risk agents** | Condition: agent risk = high → Grant: block | Prevents compromised agents from accessing resources |
| **Allow only approved agents** | Exclude agents with custom attribute `AgentApprovalStatus` = `IT_Approved`; block all others | Only reviewed agents can access resources |
| **Restrict by resource** | Target: specific apps → Grant: allow only for named agents | Enforces per-agent, per-resource access |
| **Block unfamiliar resource access** | Condition: unfamiliar resource → Grant: block + alert sponsor | Stops agents from accessing resources outside normal scope |
| **Require approved network** | Condition: network location ≠ approved → Grant: block | Restricts agent traffic to known networks |

> **Conditional Access applies** when an agent identity or agent user requests a token for any resource. It does **not** apply when a blueprint acquires a token to create identities, or during intermediate token exchanges.

**Required licensing:** Microsoft Entra ID P1 or higher. Microsoft 365 Copilot with Frontier program enabled.

### Entra ID Protection for Agents

Microsoft Entra ID Protection establishes a baseline for each agent's normal activity and continuously monitors for anomalies.

**Risk detections:**

| Detection | Type | Description |
|---|---|---|
| **Unfamiliar resource access** | Offline | Agent targeted resources it doesn't usually access |
| **Sign-in spike** | Offline | Abnormally high number of sign-ins compared to usual frequency |
| **Failed access attempt** | Offline | Agent attempted to access unauthorized resources |
| **Sign-in by risky user** | Offline | Agent signed in on behalf of a risky user during delegated auth |
| **Confirmed compromised** | Offline | Admin confirmed agent compromised |
| **Microsoft Entra threat intelligence** | Offline | Activity consistent with known attack patterns |

1. Go to **Entra admin center → Protection → Identity Protection → Risky Agents**.
2. Review flagged agents, risk levels, and risk reasons.
3. Take action:
   - **Confirm compromise** — sets risk to High, triggers risk-based Conditional Access that blocks the agent.
   - **Confirm safe** — clears risk state for false positives.
   - **Dismiss risk** — marks risk as no longer relevant.
   - **Disable** — prevents all sign-ins for the agent across Entra ID and connected apps.
4. Use Microsoft Graph `riskyAgents` and `agentRiskDetections` collections for programmatic monitoring.

### Network-Level Controls (Global Secure Access)

Global Secure Access for agents provides network security controls for Copilot Studio agents, enabling the same security policies used for users.

1. Enable **traffic forwarding** in Power Platform Admin Center on a per-environment or per-environment-group basis.
2. Agent traffic forwarding applies to: **HTTP Node traffic**, **Custom connectors**, and **MCP Server Connector**.
3. Once forwarded, apply security policies via the **baseline profile** in Global Secure Access:
   - **Web content filtering** — control access to APIs and MCP servers using web categorization.
   - **Threat intelligence filtering** — block traffic to known malicious destinations.
   - **File-type policies** — restrict file uploads and downloads to minimize risk.
   - **Prompt injection detection** — detect and block prompt injection attacks that attempt to manipulate agent behavior.

---

## Phase 3: Detect and Respond to Threats

### Microsoft Defender for Agent Threats

Defender extends threat detection to agent-specific attack vectors.

1. Go to **Microsoft Defender portal → Incidents**.
2. Review incidents involving agent identities:
   - Complete view of the **cyberattack chain** involving agents.
   - **Prioritized investigation** at the incident level.
   - Response actions: disable agent identity, revoke tokens, isolate.

### Advanced Hunting for Agent Activity

Use Advanced Hunting queries to proactively find threats:

1. Go to **Microsoft Defender → Advanced Hunting**.
2. Query for:
   - **Tool call trace logs** — which tools were invoked, parameters passed, outcomes.
   - **Anomalous patterns** — unusual volumes, unexpected resources, off-hours activity.
   - **Failed actions** — repeated failures may indicate misconfiguration or probing.

### Security Posture Remediation

1. Use **Defender → Security Exposure Management** to:
   - Map attack paths from agents to critical assets.
   - Identify misconfigurations (e.g., over-permissioned agents, missing Conditional Access).
   - Remediate with guided recommendations.
2. Use **Defender for Cloud Apps** to:
   - Discover and protect AI agents across your cloud environment.
   - Monitor agent interactions with cloud services.

---

## Phase 4: Protect Data from Agents

### Microsoft Purview Data Loss Prevention (DLP)

Prevent agents from accessing or exfiltrating sensitive data.

1. Go to **Microsoft Purview compliance portal → Data loss prevention → Policies**.
2. Create a policy scoped to **Microsoft 365 Copilot and Agents**.
3. Define sensitive info types to protect:
   - PII (Social Security numbers, addresses, phone numbers).
   - Financial data (credit card numbers, bank accounts).
   - Internal classifications (project codenames, trade secrets).
4. If an agent attempts to process or transmit protected data, the policy **blocks the action** and logs the event.

### Microsoft Purview Information Protection

Apply sensitivity labels to data and enforce label-based agent access:

1. Ensure sensitivity labels are applied to documents, emails, and data stores.
2. Configure policies: agents **cannot interact with data** above a certain sensitivity level unless explicitly authorized.
3. Dynamically block agent interactions based on data labels.

### Data Security Posture Management

1. Go to **Microsoft Purview → Data Security Posture Management**.
2. Review AI-related data exposure risks:
   - Which agents are interacting with sensitive data?
   - Are there data flows from agents to external systems?
   - Are sensitivity labels being respected?

---

## Phase 5: Runtime Defense

### Real-Time Agent Protection

Agent 365 provides runtime defense that blocks threats as they happen:

| Defense | Product | What It Blocks |
|---|---|---|
| **Prompt injection attacks** | Defender + AI Prompt Shield | Malicious inputs designed to hijack agent behavior |
| **Malicious traffic** | Entra Global Secure Access (SASE) | Agent traffic to/from known bad destinations |
| **Data exfiltration** | Purview Insider Risk Management | Agents moving sensitive data outside approved boundaries |
| **Risky runtime behavior** | Defender for Cloud Apps | Agents performing unexpected actions during execution |

### Configure Runtime Protection

1. **AI Prompt Shield** — Enable via Entra Global Secure Access to filter prompts before they reach the agent.
2. **Defender for Cloud Apps → Real-time agent protection** — monitor and block risky agent actions during execution.
3. **Purview Insider Risk Management** — create policies detecting agents exhibiting data exfiltration patterns.

---

## Phase 6: Prevent Security Gaps Going Forward

### Security Review Checklist for New Agents

Before approving any agent in the Registry:

| Check | How |
|---|---|
| ✅ Agent has an owner and sponsor | Entra → Agent ID → agent identity details |
| ✅ Conditional Access policy covers the agent | Entra → Conditional Access → verify agent is in scope |
| ✅ Permissions follow least privilege | Review requested MCP server permissions and resource access |
| ✅ Data access is appropriate | Check what data sources the agent connects to |
| ✅ Sensitivity labels are enforced | Purview → verify label-based policies cover agent scenarios |
| ✅ Agent is in the correct collection | Quarantined by default; promote only after review |

### Ongoing Security Operations

| Frequency | Activity | Tool |
|---|---|---|
| **Daily** | Review risky agents report | Entra ID Protection |
| **Daily** | Check Defender incidents involving agents | Microsoft Defender |
| **Weekly** | Run Advanced Hunting queries for anomalies | Defender → Advanced Hunting |
| **Weekly** | Review ownerless/sponsorless agents | M365 admin center + Entra |
| **Monthly** | Full posture review + attack path analysis | Defender → Exposure Management |
| **Monthly** | Review Purview DLP policy hits for agents | Purview → DLP activity explorer |

---

## Security Stack Summary

| Layer | Products | What It Protects |
|---|---|---|
| **Identity** | Entra Agent Registry, M365 Admin Center | Complete inventory including shadow agents |
| **Access Control** | Entra Conditional Access, ID Protection, ID Governance | Least-privilege, risk-based access decisions |
| **Security Posture** | Microsoft Defender, Security Exposure Management | Attack paths, misconfigurations, vulnerabilities |
| **Detection & Response** | Microsoft Defender | Threat detection, incident investigation, response |
| **Runtime Defense** | Defender, Entra SASE, AI Prompt Shield, Purview Insider Risk | Prompt injection, malicious traffic, data exfiltration |
| **Data Security** | Purview DLP, Information Protection, DSPM | Sensitive data protection by label and policy |

**Required licensing:** Microsoft 365 Copilot with Frontier program enabled. Entra ID P1 for Conditional Access. Entra ID P2 for ID Protection (included during preview).

---

## References

| Source | Author | Priority |
|---|---|---|
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/security-for-ai-overview" target="_blank">Microsoft Entra security for AI overview</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id" target="_blank">What is Microsoft Entra Agent ID?</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/identity/conditional-access/agent-id" target="_blank">Conditional Access for Agent ID (Preview)</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/id-protection/concept-risky-agents" target="_blank">Entra ID Protection for agents</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/global-secure-access/concept-secure-web-ai-gateway-agents" target="_blank">Global Secure Access for agents</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/what-are-agent-identities" target="_blank">What are agent identities?</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-tokens" target="_blank">Tokens in Microsoft agent identity platform</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/security/security-for-ai/agent-365-security" target="_blank">Secure AI agents at scale using Microsoft Agent 365</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/defender-cloud-apps/ai-agent-inventory" target="_blank">Discover and protect your AI agents (Preview)</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/defender-cloud-apps/real-time-agent-protection-during-runtime" target="_blank">Real-time agent protection during runtime</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-ai-prompt-shield" target="_blank">AI Prompt Shield</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/purview/ai-agents" target="_blank">Microsoft Purview for AI agents</a> | Microsoft Learn | 1 |
| <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/threat-protection" target="_blank">Threat protection in Microsoft Agent 365</a> | Microsoft Learn | 1 |
| [grounding/Microsoft-Learn-Entra-AgentID.md](../grounding/Microsoft-Learn-Entra-AgentID.md) | Microsoft Learn | 2 |
| [grounding/Microsoft-Learn.md](../grounding/Microsoft-Learn.md) | Microsoft Learn | 3 |
