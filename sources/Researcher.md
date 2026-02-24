# Agent 365 Registration & Management: Complete Implementation Guide

## Executive Summary

**Your legacy Copilot Studio agents likely aren't visible in Agent 365 because they were created before automatic integration was enabled**. Microsoft recently tightened integration between Copilot Studio and Agent 365, requiring agents to be deployed via the Microsoft 365 Admin Center's Integrated Apps approval process. **Agent 365 is currently in preview** and requires **Frontier program enrollment** plus **at least one Microsoft 365 Copilot license**.

---

## 1. Licenses & Prerequisites

### Required Licensing

| Requirement | Details |
|------------|---------|
| Minimum License | 1 Microsoft 365 Copilot License |
| Program Access | Frontier Preview Enrollment Required |

**Licensing Details:**
- Agent 365 is NOT included in Microsoft 365 E3/E5 licenses – it's a separate offering
- At least one Microsoft 365 Copilot license is required to access Agent 365 features in the Frontier preview program
- Agent 365 will eventually require separate per-agent licenses for production use (not yet GA)
- For agentic users, additional licenses may be required (M365 E5, Teams Enterprise, Copilot)

### Enroll in Frontier Preview Program

1. Sign into Microsoft 365 admin center
2. Navigate to **Copilot > Settings**
3. Under **User access**, select **Copilot Frontier**
4. Grant access to users or groups
5. Go to **Agents** in the left-pane
6. Accept terms of service if prompted

## 2. Required Entra Roles for Agent 365 Management

| Role | Purpose | Key Permissions |
|------|---------|-----------------|
| Agent Registry Administrator | Register/manage agent instances and manifests | Create/read/update agent instances and manifests |
| Agent ID Administrator | Create/manage agent identity blueprints | Full control over agent identity infrastructure |
| Agent ID Developer | Create/configure agent identity blueprints | Development role |
| Cloud/Application Administrator | Grant Graph delegated permissions | Manage app registrations |
| Privileged Role Administrator | Grant Graph application permissions | Assign high-privilege Graph API permissions |

## 3. Legacy Copilot Studio Agents: Visibility & Migration

### Why Legacy Agents Aren't Showing Up

Only agents created as "Copilot for Microsoft 365 agents" and approved via Integrated Apps appear in Agent 365.

### Enable Automatic Agent Identity

1. Go to Power Platform admin center > **Copilot > Settings**
2. Under **Copilot Studio**, enable **Entra Agent Identity**
3. Select environment > **Edit setting > On > Save**

### Validate Agent Identity

1. In Copilot Studio, go to **Settings > Advanced > Metadata**
2. Look for **Entra Agent ID** GUID

### Make Legacy Agents Visible

1. Enable Entra Agent Identity
2. Republish agent to Teams & M365 channel
3. Approve via Integrated Apps in M365 Admin Center
4. Agent appears in Agent 365 portal

## 4. Non-Microsoft Agents: Registration Process

### Step 1: Create Agent Identity Blueprint

- Requires Agent ID Admin/Developer role
- Use Microsoft Graph API or Agent 365 CLI
- Define sponsor, owner, and permissions

### Step 2: Register Agent Instance

- Requires Agent Registry Admin role
- POST to `/beta/agentRegistry/agentInstances`
- Include displayName, ownerIds, url, identity IDs, transport protocol

### Step 3: Register Agent Card Manifest

- Define displayName, description, iconUrl, documentationUrl, skills, capabilities, provider, etc.
- Required for discoverability

## 5. Policies & Governance

- Use Microsoft Entra Conditional Access for agent-specific policies
- Integrate with Microsoft Purview for data protection and auditing
- Use Microsoft Defender for threat detection and response

## 6. Metadata Requirements

### Agent Instance Metadata
- displayName
- ownerIds
- url
- agentIdentityBlueprintId
- agentIdentityId
- preferredTransport

### Agent Card Manifest Metadata
- displayName, description, iconUrl
- skills, capabilities, provider
- security, protocolVersion, version

## 7. Summary Table

| Aspect | Microsoft Tools | Non-Microsoft Tools |
|--------|------------------|----------------------|
| Registration | Automatic | Manual via Graph API |
| Identity | Auto-created | Manual blueprint creation |
| Visibility | Auto after approval | Manual registration required |
| Roles | Power Platform Admin | Agent ID & Registry Admins |
| Setup Time | Minutes | 15–30 minutes |
| Metadata | Auto-generated | Manually defined |

