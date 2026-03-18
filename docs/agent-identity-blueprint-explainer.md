# Agent Identity Blueprint: Pro-Code Usage and Credential Model

> Based on Microsoft Learn Entra Agent ID documentation (preview). Content may change as the product evolves.

## Can Pro-Code Agents Use the Copilot Studio Blueprint?

**No.** The Copilot Studio agent identity blueprint (object ID `fb29d786-a550-4428-adf2-af97bc1503b2`) cannot be used by pro-code agents. There are three fundamental reasons why.

### 1. Credentials Live on the Blueprint

Agent identities do not have their own credentials. All authentication uses the blueprint's credentials — whether that is a managed identity, federated identity credential, certificate, or client secret. Because the Copilot Studio blueprint's credentials are managed by Microsoft for Copilot Studio's internal use, you have no access to them. Without those credentials, your code cannot request tokens through the blueprint.

### 2. Blueprints Provision Identities

A blueprint uses its `AgentIdentity.CreateAsManager` permission to provision agent identities underneath it. The Copilot Studio blueprint principal performs this action on behalf of Copilot Studio when an employee creates an agent in the Copilot Studio UI. Your code does not have authorization to call the Copilot Studio blueprint principal to create identities — that workflow is internal to Copilot Studio.

### 3. Blueprints Are Governance Containers

Policies applied to a blueprint — Conditional Access policies, permission grants, disabling — affect **all** child agent identities created from that blueprint. If you were somehow able to mix your pro-code agents into the Copilot Studio blueprint, an administrator disabling the Copilot Studio blueprint would also disable your agents. Conversely, your agents would inherit whatever permissions Copilot Studio agents receive. This creates unacceptable governance and security risks.

### Creation Workflow Examples

The table below shows how agent identity creation works for different scenarios:

| Scenario | Workflow |
|---|---|
| Copilot Studio agent | Customer enables Copilot Studio → Copilot Studio blueprint added to tenant → Employee creates agent → Copilot Studio creates agent identity |
| Pro-code agent | Developer creates own blueprint via Entra admin center/Graph API → Developer writes code using blueprint → Code creates agent identities via Microsoft Graph |
| Third-party agent | Third-party publishes agent → Employee acquires/consents → Blueprint principal added to tenant → Third-party creates agent identity |

### What Pro-Code Developers Should Do Instead

For pro-code solutions, developers should create their own blueprint using the Microsoft Graph API or PowerShell. This gives you full control over:

- The blueprint's credentials (managed identity is preferred)
- Which agent identities are provisioned underneath it
- The governance boundary for your agents

**Required role:** Agent ID Developer or Agent ID Administrator.

See [developer-identity-platform.md](developer-identity-platform.md) for step-by-step blueprint creation guidance using Graph API and PowerShell.

For the blueprint input JSON format used by the automation script, see the [blueprint-input.json field guide](../scripts/README.md#blueprint-inputjson--field-guide) in the scripts documentation.

---

## How Blueprint Credentials Work and the One-to-Many Pattern

### "Agent identities authenticate using the blueprint's credentials" — What Does This Mean?

Agent identities do **not** have their own passwords, secrets, or certificates. The credential material is held entirely on the blueprint. Here is how authentication works mechanically:

1. The blueprint holds credentials — a managed identity (preferred), federated identity credential, certificate, or client secret.
2. When an agent needs to authenticate, the blueprint's credentials are used to request an access token from Microsoft Entra ID.
3. The blueprint then **impersonates** the specific agent identity. From Microsoft Learn: *"All agent auth flows involve multi-stage token exchanges where the agent identity blueprint impersonates the agent identity to perform operations."*
4. The result is that **one** set of credentials (on the blueprint) is used to obtain tokens for **many** different agent identities.

This multi-stage token exchange means your code authenticates once with the blueprint's credentials and then specifies which agent identity to act as. Each agent identity still has its own unique object ID and its own audit trail in Entra ID — but the credential that initiates the flow always belongs to the blueprint.

### Do You Need One Blueprint per Agent?

**No.** The one-to-many relationship between a blueprint and its agent identities is the intended design. You do not need a separate blueprint for every agent.

- The blueprint is a **template** that captures shared characteristics: name, publisher, roles, and permissions.
- Each agent identity created from the blueprint gets its own unique object ID but inherits the blueprint's configuration.
- One set of blueprint credentials services all the agent identities created from it.

Think of the blueprint as a **class** and agent identities as **instances** of that class.

### Practical Example: Sales Assistant Agent

From the Microsoft Learn agent identities documentation, consider an organization that uses a "Sales Assistant Agent":

**One blueprint** called "Sales Assistant Agent" is created with:
- Publisher: "Contoso"
- Roles: "sales manager", "sales rep"
- Permissions: "read the signed-in user's calendar"

**Multiple agent identities** are created from this single blueprint:
- North America sales agent identity
- South America sales agent identity
- Enterprise sales agent identity
- Small/medium business sales agent identity
- Startup sales agent identity

Because all five agent identities share one blueprint, the administrator can:
- Apply a **Conditional Access policy** to all Sales Assistant Agents at once
- **Disable** all Sales Assistant Agents at once
- **Revoke a permission grant** for all Sales Assistant Agents at once

This is the governance benefit of the one-to-many model — a single administrative action affects all agents of the same type.

### Practical Pattern: Multi-Tenant ISV

The one-to-many pattern extends across tenant boundaries for independent software vendors (ISVs):

1. An ISV builds a "Customer Support Agent."
2. The ISV creates one blueprint and publishes it to customers via Microsoft catalogs.
3. Each customer tenant gets a **blueprint principal** (the tenant-local representation of the ISV's blueprint).
4. The ISV's service creates agent identities per customer deployment.
5. The blueprint is effectively **multitenant** — one blueprint definition, many agent identities across tenants.

Each customer tenant's administrator retains governance control over the blueprint principal in their tenant, including the ability to apply Conditional Access policies or disable it entirely.

### When You Should Create a Separate Blueprint

Create a new blueprint when you have a fundamentally different type of agent that requires different governance characteristics:

- A "Sales Assistant Agent" and an "HR Benefits Agent" need separate blueprints because they require different permissions, roles, and governance policies.
- A "Customer Support Agent" and an "Internal IT Help Desk Agent" need separate blueprints if they have different security requirements or Conditional Access needs.
- If two agents share the same permissions, roles, publisher, and governance requirements, they belong under the same blueprint as separate agent identities.

**Rule of thumb:** If you would want to disable or apply a policy to one group of agents without affecting another group, those groups need separate blueprints.

## References

- [Agent identity blueprints](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-blueprint) — Blueprint concepts, lifecycle, and governance role
- [Agent identities](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-identities) — Agent identity objects, the Sales Assistant example, and identity lifecycle
- [Agent OAuth protocols](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-oauth-protocols) — Multi-stage token exchange and impersonation flows
- [Create a blueprint](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-blueprint) — Step-by-step blueprint creation via Graph API and Entra admin center
- [Create and delete agent identities](https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/create-delete-agent-identities) — Provisioning agent identities from a blueprint
- [Agent ID creation channels](https://learn.microsoft.com/en-us/entra/agent-id/identity-professional/agent-id-creation-channels) — Creation workflow comparison: Copilot Studio, pro-code, and third-party
- [Blueprint input JSON field guide](../scripts/README.md#blueprint-inputjson--field-guide) — Field-by-field documentation for the `blueprint-input.json` automation input file
