# Entra SDK for Agent ID

The Microsoft Entra SDK for Agent ID is a **containerized web service** (companion container) that handles token acquisition, validation, and downstream API calls on behalf of your application. Instead of embedding identity logic in each service, you offload authentication to the SDK via a simple HTTP API.

> **Preview:** The SDK is currently in preview. See [GitHub releases](https://github.com/AzureAD/microsoft-identity-web/releases) for the latest container image tags.

---

## Architecture

```
Client Application
       │
       ▼
  Your Web API  ──HTTP──▶  Entra SDK for Agent ID  ──▶  Microsoft Entra ID
                              (companion container)
                                    │
                                    ▼
                            Downstream APIs
                          (Graph, SharePoint, etc.)
```

The SDK runs as a **sidecar container** in the same trust boundary as your application (same Kubernetes pod or virtual network). It must **never** be publicly accessible.

---

## When to use this SDK vs. Microsoft.Identity.Web

| Scenario | Use Entra SDK for Agent ID | Use Microsoft.Identity.Web |
|---|---|---|
| **Language** | Python, Node.js, Go, Java, any language | .NET only |
| **Deployment** | Containers (Kubernetes, Docker, AKS) | Any deployment model |
| **Agent identity support** | ✅ All supported languages | .NET only |
| **Token validation** | ✅ All supported languages | .NET only |
| **Security model** | Secrets isolated from app code | Integrated with application |
| **Performance** | Additional network hop required | Direct in-process calls |
| **Polyglot microservices** | ✅ Consistent patterns across services | ❌ .NET only |

---

## Key capabilities

### Token validation
- Validates access tokens and ID tokens issued by Microsoft Entra ID
- Verifies signatures against Entra's public keys
- Checks expiration and audience claims
- Extracts user claims, roles, and scopes for authorization decisions

### Token acquisition
- On-Behalf-Of (OBO) flow — delegates user context to downstream APIs
- Client Credentials — app-to-app / autonomous agent authentication
- Managed Identity — native Azure service authentication
- Agent Identity — autonomous or delegated agent patterns

### Downstream API calls
- Automatically acquires and attaches tokens to outbound requests
- Supports optional scope, method, and header overrides
- Supports Signed HTTP Requests (Proof-of-Possession / PoP/SHR)

---

## Quick start

### 1. Choose your deployment

| Platform | Guide |
|---|---|
| Kubernetes | [Kubernetes deployment](https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/installation) |
| Docker | [Docker deployment](https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/installation) |
| Azure Kubernetes Service (AKS) | [AKS deployment](https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/installation) |

### 2. Configure via environment variables

Set the following in the SDK container's environment:

| Variable | Description |
|---|---|
| `AzureAd__TenantId` | Your Entra tenant ID |
| `AzureAd__ClientId` | The blueprint's `appId` |
| Credential config | Managed identity (recommended) or client secret |

See the [configuration reference](https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/configuration) for the full list.

### 3. Call the SDK from your application

All SDK operations are standard HTTP calls. Example: validate an inbound bearer token.

```http
GET http://localhost:5000/Validate
Authorization: Bearer <inbound-token>
```

Example: acquire a token for a downstream API.

```http
GET http://localhost:5000/AuthorizationHeader?scope=https://graph.microsoft.com/.default
Authorization: Bearer <user-token>
```

The SDK returns an `Authorization` header value ready to attach to your downstream request.

---

## Supported scenarios

| Scenario | SDK Endpoint | Description |
|---|---|---|
| **Validate inbound token** | `/Validate` | Extract claims for access control middleware |
| **Obtain token for downstream API** | `/AuthorizationHeader` | Acquire token (OBO or client credentials) |
| **Call downstream API directly** | `/DownstreamApi` | SDK makes the outbound call and returns the response |
| **Managed identity auth** | `/AuthorizationHeaderUnauthenticated` | Authenticate as an Azure service (no user context) |
| **Long-running OBO** | `/AuthorizationHeader` with refresh | Maintain user context across extended background operations |
| **Signed HTTP Requests (PoP)** | SDK config flag | Proof-of-possession token binding |
| **Autonomous batch processing** | Client credentials flow | Agent processes batches under its own identity |

### Language-specific integration guides

- [TypeScript / Node.js / Express / NestJS](https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/scenarios/using-from-typescript)
- [Python / Flask / FastAPI / Django](https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/scenarios/using-from-python)

---

## Security requirements

> ⚠️ **The SDK API must not be publicly accessible.** Exposing it externally enables unauthorized token acquisition.

| Requirement | Guidance |
|---|---|
| **Network isolation** | Run in the same Kubernetes pod or virtual network as your application only |
| **Credentials** | Use managed identity (FIC) in production — never plain client secrets |
| **Secrets management** | Keep credentials in Azure Key Vault or environment variables injected at runtime; never hardcode |
| **Least privilege** | Grant only the Microsoft Graph / resource permissions the agent actually needs |
| **Zero Trust** | Integrates with managed identity and PoP tokens — sensitive data never enters app code |

See the [security best practices guide](https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/security) for full production hardening guidance.

---

## Relationship to agent identity blueprints

The SDK authenticates **on behalf of an agent identity blueprint**. Before using the SDK you must:

1. Create a blueprint and configure credentials (managed identity recommended) — use [`Create-Blueprint.ps1`](../scripts/Create-Blueprint.ps1) or see [Developer Guide: Agent Identity Platform](./developer-identity-platform.md)
2. Set the blueprint's `appId` as the SDK's `ClientId`
3. Ensure the blueprint has a sponsor assigned

For a visual overview of the full flow from blueprint to registered agent, see [Agent Blueprint vs. Registration](./agent-blueprint-vs-registration.md).

---

## Source Notes

This document was compiled from the following research notes. Author and Priority are drawn from each note's YAML frontmatter. Priority 1 is the highest importance; higher numbers indicate lower importance.

| Source | Author | Priority |
|---|---|---|
| [research/Microsoft-Learn-Entra-AgentID.md](../research/Microsoft-Learn-Entra-AgentID.md) | Microsoft Learn | 2 |
| [research/Microsoft-Learn.md](../research/Microsoft-Learn.md) | Microsoft Learn | 3 |
| [research/ChatGPT.md](../research/ChatGPT.md) | ChatGPT | 4 |
| [research/Gemini.md](../research/Gemini.md) | Gemini | 4 |
| [research/Researcher.md](../research/Researcher.md) | Researcher | 4 |

---

## References

- <a href="https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/overview" target="_blank">Entra SDK for Agent ID overview</a>
- <a href="https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/installation" target="_blank">SDK installation (Kubernetes, Docker, AKS)</a>
- <a href="https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/configuration" target="_blank">SDK configuration reference</a>
- <a href="https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/security" target="_blank">SDK security best practices</a>
- <a href="https://learn.microsoft.com/en-us/entra/agent-id/identity-platform/agent-oauth-protocols" target="_blank">Agent OAuth protocols</a>
- <a href="https://learn.microsoft.com/en-us/entra/msidweb/agent-id-sdk/comparison" target="_blank">SDK vs. Microsoft.Identity.Web comparison</a>
- <a href="https://github.com/AzureAD/microsoft-identity-web/releases" target="_blank">GitHub releases (container image tags)</a>
