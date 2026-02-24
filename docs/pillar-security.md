# Pillar 5: Security

Security in Agent 365 extends Microsoft's full security infrastructure to AI agents — covering identity, access, posture, detection, runtime defense, and data protection. The goal: treat agents with the same security rigor as human identities while addressing agent-specific threats like prompt injection and autonomous data exfiltration.

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
- Have **no owner or sponsor** (no human accountability).
- Access **sensitive data** (PII, financial data, internal project codenames).
- Have **broad permissions** (access to many resources beyond stated purpose).
- Were built by **external parties** or exist in **unknown origins**.
- Show **risky behavior** in Entra ID Protection reports.

---

## Phase 2: Secure Agent Identities

### Conditional Access for Agents

Create policies that enforce real-time access decisions based on agent context and risk.

1. Go to **Entra admin center → Protection → Conditional Access**.
2. Create policies targeting **agent identities**:

| Policy | Configuration | Effect |
|---|---|---|
| **Block high-risk agents** | Condition: agent risk = high → Grant: block | Prevents compromised agents from accessing resources |
| **Restrict by resource** | Target: specific apps → Grant: allow only for named agents | Enforces per-agent, per-resource access |
| **Block unfamiliar resource access** | Condition: unfamiliar resource → Grant: block + alert sponsor | Stops agents from accessing resources outside their normal scope |
| **Require approved network** | Condition: network location ≠ approved → Grant: block | Restricts agent traffic to known networks |

**Required licensing:** Entra ID P1.

### Entra ID Protection for Agents

Automated detection of risky agent behavior:

- Accessing resources the agent has never used before.
- Abnormally high sign-in attempt rates.
- Sign-ins from unusual locations or networks.

1. Go to **Entra admin center → Protection → Identity Protection → Risky agents**.
2. Review flagged agents and their risk reasons.
3. Configure automated responses (block, alert sponsor, require investigation).

### Network-Level Controls (Global Secure Access)

For Copilot Studio agents, apply Entra Global Secure Access:

- **Web content filtering** — block agents from reaching unapproved web endpoints.
- **Threat intelligence filtering** — block traffic to known malicious destinations.
- **Network file filtering** — scan files transmitted by agents.
- **AI Prompt Shield** — block prompt injection attacks at the network layer.

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

---

## References

- <a href="https://learn.microsoft.com/en-us/security/security-for-ai/agent-365-security" target="_blank">Secure AI agents at scale using Microsoft Agent 365</a>
- <a href="https://learn.microsoft.com/en-us/entra/identity/conditional-access/agent-id" target="_blank">Conditional Access for Agent ID (Preview)</a>
- <a href="https://learn.microsoft.com/en-us/entra/id-protection/concept-risky-agents" target="_blank">Entra ID Protection for agents</a>
- <a href="https://learn.microsoft.com/en-us/entra/global-secure-access/concept-secure-web-ai-gateway-agents" target="_blank">Global Secure Access for agents</a>
- <a href="https://learn.microsoft.com/en-us/defender-cloud-apps/ai-agent-inventory" target="_blank">Discover and protect your AI agents (Preview)</a>
- <a href="https://learn.microsoft.com/en-us/defender-cloud-apps/real-time-agent-protection-during-runtime" target="_blank">Real-time agent protection during runtime</a>
- <a href="https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-ai-prompt-shield" target="_blank">AI Prompt Shield</a>
- <a href="https://learn.microsoft.com/en-us/purview/ai-agents" target="_blank">Microsoft Purview for AI agents</a>
- <a href="https://learn.microsoft.com/en-us/microsoft-agent-365/admin/threat-protection" target="_blank">Threat protection in Microsoft Agent 365</a>
