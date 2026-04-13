# Diagram 01: SpaceGenius Current Azure Topology

**Purpose:** Shows the Azure resources provisioned today. This is the constraint map: every AI solution must work within these boundaries for Phase 1 through Phase 4 of the transformation roadmap.

---

```mermaid
graph TB
    subgraph Azure_Subscription["Azure Subscription (SpaceGenius)"]

        subgraph Security["Security Layer"]
            KV["Azure Key Vault\n(Standard SKU)\nStores: DB credentials,\nAPI keys, PATs"]
            MI["Managed Identity\n(System-assigned)\nAssigned to: Functions, App Services"]
        end

        subgraph Compute["Compute Layer"]
            AppSvc["App Services\nASP.NET Web API\nReact Frontend\n(ARM-deployed)"]
            Functions["Azure Functions\n(Consumption plan)\nHTTP triggers\nTimer triggers\n(ARM-deployed)"]
        end

        subgraph Data["Data Layer"]
            SQLMI["SQL Managed Instance\n(Business Critical)\nPrimary production DB\nTransaction data\nOccupancy data\nRate data"]
        end

        subgraph Messaging["Messaging Layer"]
            SB["Service Bus\n(Standard namespace)\n1 namespace\nExisting topics in use"]
        end

        subgraph DevOps["DevOps Layer"]
            ADO["Azure DevOps\nPipelines (CI/CD)\nBoards (work items)\nWiki (docs)\nAnalytics OData (free)"]
        end

        subgraph IaC["Infrastructure as Code"]
            ARM["ARM Template\n(Single non-modular file)\nProduction-deployed\nAll resources defined here"]
        end

    end

    subgraph External["External Services (No Azure equivalent provisioned)"]
        ClaudeAPI["Anthropic Claude API\n(via Key Vault-secured Functions)\nLLM backbone for all AI solutions"]
        HelpScout["HelpScout\nCustomer support platform"]
        Teams["Microsoft Teams\n(Free incoming webhook)\nApproval notifications"]
        SendGrid["SendGrid\n(Free tier: 100/day)\nEmail notifications"]
    end

    MI -->|"Fetches secrets"| KV
    Functions -->|"Managed Identity auth"| KV
    AppSvc -->|"Managed Identity auth"| KV
    Functions -->|"Queries and writes"| SQLMI
    AppSvc -->|"Queries and writes"| SQLMI
    Functions -->|"Publishes and subscribes"| SB
    AppSvc -->|"REST API"| ADO
    Functions -->|"REST API"| ADO
    ARM -->|"Provisions"| AppSvc
    ARM -->|"Provisions"| Functions
    ARM -->|"Provisions"| SQLMI
    ARM -->|"Provisions"| SB
    Functions -->|"API key from Key Vault"| ClaudeAPI
    HelpScout -->|"Webhooks"| SB
    Functions -->|"Posts recommendations"| Teams
    Functions -->|"Sends notifications"| SendGrid
```

---

## What Is Missing (and Why It Matters)

| Missing | Impact on AI Solutions | Workaround in ADRs |
|---|---|---|
| Azure OpenAI | All LLM calls exit to Anthropic servers | Claude API via Functions with Key Vault security; swap-ready architecture (ADR-007, ADR-009, ADR-012) |
| Azure AI Foundry | No org-wide versioned prompts or eval metrics | Claude Code CLAUDE.md + custom slash commands (ADR-001, ADR-006) |
| Azure AI Search | No persistent vector index; 90-day scope limit on dedup | Claude API in-context comparison (ADR-003, ADR-011) |
| Logic Apps | Custom Function chains instead of visual workflows | Chained Functions in C#/.NET (ADR-004) |
| Copilot Enterprise | CLAUDE.md required for repo context | Hand-authored CLAUDE.md knowledge base (ADR-005, ADR-006) |
| Microsoft Fabric | No continuous ML improvement for pricing | Pre-aggregated SQL views + Claude API static analysis (ADR-009) |
| Copilot Studio | Single-exchange HTTP only; no multi-turn | Stateless Function with slot-filling prompt (ADR-008) |

**The gap between what is provisioned and what Microsoft full-platform provides is the business case for Phase 5 budget approval.**
