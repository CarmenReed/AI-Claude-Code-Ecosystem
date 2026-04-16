# SpaceGenius Azure Environment Inventory

**Author:** Carmen Reed  
**Date:** April 12, 2026  
**Purpose:** Authoritative inventory of provisioned Azure resources, analysis of leverage opportunities, and identification of gaps that drive constrained design decisions.

---

## Provisioned Resources (Available Today)

Tiers marked "estimated" reflect the SKU expected from the ARM template configuration. Exact SKUs should be confirmed against the Azure portal or ARM template parameters before including this document in a stakeholder presentation.

| Resource | Tier / SKU | Notes |
|---|---|---|
| Azure Key Vault | Standard | Managed Identity configured, used for production secrets |
| Managed Identity | System-assigned | Assigned to App Services and Functions |
| Azure Functions | Consumption (estimated) | ARM-deployed, HTTP and timer triggers in use |
| App Services | Standard (estimated) | Hosts the SpaceGenius .NET Web API and React frontend |
| SQL Managed Instance | Business Critical (estimated) | Primary production database |
| Azure DevOps Pipelines | Basic + one parallel job | PAT authentication in use, CI/CD for all environments |
| Service Bus | Standard namespace | 1 namespace, existing topics for inter-service events |
| ARM Template | Non-modular, single file | Production-deployed, all resources provisioned via this template |

---

## Not Provisioned (Drives All Constrained Decisions)

| Missing Resource | Impact | Workaround Used |
|---|---|---|
| Azure OpenAI | No Microsoft-native LLM | Anthropic Claude API via Key Vault-secured Functions |
| Azure AI Foundry | No org-wide prompt flows, no eval metrics | Claude Code CLAUDE.md + custom slash commands |
| Azure AI Search | No persistent vector index for semantic search | Claude API in-context comparison, 90-day scope limit |
| Logic Apps | No visual workflow orchestration, no native connectors | Chained Azure Functions in C#/.NET |
| GitHub Copilot Enterprise | No whole-repo AI context for all developers | Claude Code + hand-authored CLAUDE.md per project |
| Microsoft Fabric / Power BI | No self-service analytics or ML pipelines | ADO Analytics OData + Claude API reasoning layer |
| Copilot Studio | No conversational bot authoring | Azure Functions HTTP + Claude API slot-filling |
| Azure Bot Service | No multi-channel bot deployment | Single-channel HTTP Functions (web only) |

---

## Leverage Analysis: What Existing Resources Can Do

### Key Vault + Managed Identity

This is the most valuable security asset in the SpaceGenius environment. Every AI solution that requires a third-party API key (Claude API, HelpScout API, SendGrid API, Adzuna API) uses Key Vault as the credential store with Managed Identity as the authentication mechanism.

**Impact:** No API keys in code, no API keys in ADO pipelines, no API keys on developer machines. This is a production-grade secret management pattern that many companies with Azure OpenAI access still implement incorrectly.

**Principal architect principle applied:** The security architecture is already correct. Every new AI solution inherits the existing Key Vault pattern rather than introducing new credential management approaches.

### Azure Functions

Azure Functions is the execution layer for all SDLC automation solutions. New AI capabilities are implemented as new HTTP routes or timer triggers on existing Functions. No new Azure resources are provisioned.

**Scale available with existing resources:**
- HTTP triggers: documentation pipeline, support triage, NLP rate management, natural language reservations
- Timer triggers: dynamic pricing intelligence, backlog hygiene (scheduled), CLAUDE.md auto-update
- Service Bus triggers: ticket dedup, support triage pipeline chain

### Service Bus

The existing Service Bus namespace supports additional topics and subscriptions at no additional cost tier. Adding a new topic for ticket triage or support ticket routing requires an ARM template block addition, not a new resource provisioning request.

**Topics added under existing namespace:**
- `ticket-triage` / `ticket-triage-subscription`: ADO new PBI webhook consumer
- `support-triage` / `support-triage-subscription`: HelpScout webhook consumer

### ADO Pipelines + PAT

ADO Pipelines is already running CI/CD for all environments. The PAT authentication enables REST API calls to ADO from any service that holds the token (Functions, Claude Code sessions via Key Vault MCP).

**Capabilities unlocked by PAT + ADO REST:**
- PBI creation and update (documentation pipeline, estimation output)
- Work item linking (dedup flagging, ticket relationships)
- Pipeline trigger (QA test run initiation)
- ADO Analytics OData queries (velocity data for estimation)

The ADO Analytics OData endpoint is included at zero additional cost with every Azure DevOps subscription. It provides sprint velocity, cycle time, and work item trend data that grounded estimation requires.

### SQL Managed Instance

The SQL MI holds all transaction, occupancy, and pricing data. Direct SQL queries from Azure Functions (using Managed Identity database authentication) provide the data grounding for dynamic pricing intelligence.

**No additional data pipeline required:** Pre-aggregated SQL views over occupancy and transaction data provide Claude API with structured inputs for pricing recommendation reasoning. This avoids the Microsoft Fabric lakehouse requirement.

---

## Resource Request Priority (When Budget Is Approved)

When executive sponsorship approves new Azure resources, the acquisition priority is:

| Priority | Resource | Justification |
|---|---|---|
| 1 | Azure OpenAI (GPT-4o) | Eliminates third-party data egress, enables Managed Identity auth on all LLM calls, unlocks AI Foundry evaluation |
| 2 | GitHub Copilot Enterprise | Eliminates the CLAUDE.md maintenance burden, gives all 10+ developers whole-repo AI context |
| 3 | Azure AI Search | Enables persistent vector index for backlog dedup (removes 90-day scope limitation) and living docs (removes unstructured markdown search limitation) |
| 4 | Logic Apps | Replaces chained Functions with visual workflow orchestration and native ADO + HelpScout connectors |
| 5 | Copilot Studio | Enables multi-turn conversational bot for customer reservations and internal support queries |
| 6 | Microsoft Fabric | Enables continuous ML model improvement for dynamic pricing (current Claude API reasoning is static per prompt) |

The first two items on this list (Azure OpenAI and Copilot Enterprise) provide disproportionate value and should be pursued together as a package request. The remaining items are incremental improvements to already-functional solutions.
