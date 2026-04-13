# Diagram 04: Full Azure AI Target State

**Purpose:** Shows the SpaceGenius architecture after full Azure AI platform adoption. No constraints. Every constrained solution upgraded to its enterprise target. This is the vision story and the business case for Phase 5 investment.

---

```mermaid
graph TB
    subgraph MicrosoftTenant["Microsoft Tenant (SpaceGenius - Full Azure AI)"]

        subgraph DevExperience["Developer Experience Layer"]
            CopilotE["GitHub Copilot Enterprise\nWhole-repo context for 10+ developers\nNo CLAUDE.md maintenance\nCopilot Workspace: PBI to PR"]
        end

        subgraph Orchestration["AI Orchestration Layer"]
            Foundry["Azure AI Foundry\nOrg-wide versioned prompt flows\nDocumentation pipeline\nIntegration pattern library\nEvaluation metrics"]
            LogicApps["Logic Apps\nNative ADO connector\nNative HelpScout connector\nVisual workflow designer\nRun history audit trail"]
        end

        subgraph AIServices["AI Services Layer"]
            AOAI["Azure OpenAI (GPT-4o)\nTwo deployments:\nbatch-operations\nquality-operations\nManaged Identity auth\nData stays in tenant"]
            AISearch["Azure AI Search\nVector index: full backlog\nVector index: living docs\nVector index: support tickets\nNo scope limits"]
            ContentSafety["Azure AI Content Safety\nCustomer-facing output filter\nPre-display evaluation"]
        end

        subgraph Platform["Platform Layer (Existing + Enhanced)"]
            KV["Azure Key Vault\nThird-party API keys only\n(Azure services use Managed Identity)"]
            MI["Managed Identity\nAll Azure service-to-service auth"]
            Functions["Azure Functions\nExtended with new routes\nAll existing functionality preserved"]
            AppSvc["App Services\nExisting .NET API\nNew AI-powered routes"]
            SQLMI["SQL Managed Instance\nUnchanged"]
            SB["Service Bus\nExtended with ticket topics"]
            ADO["Azure DevOps\nNative connectors via Logic Apps"]
        end

        subgraph Analytics["Analytics Layer"]
            Fabric["Microsoft Fabric\nLakehouse: full transaction history\nML model: dynamic pricing\nContinuous improvement loop"]
            PBI["Power BI Copilot\nSelf-service: Rick asks in plain English\nPricing impact queries\nVelocity and quality metrics"]
        end

        subgraph ConversationalAI["Conversational AI Layer"]
            CopilotStudio["Copilot Studio\nCustomer reservation bot\nConsultant onboarding bot\nInternal support bot\nAll backed by AI Search RAG"]
            BotService["Azure Bot Service\nMulti-channel delivery:\nWeb, mobile, Teams, SMS"]
        end

    end

    subgraph NoThirdParty["Third-Party Dependencies (Eliminated)"]
        NoEgress["No Anthropic API egress\nNo third-party LLM data\nAll AI processing in Microsoft tenant"]
    end

    CopilotE -->|"Repo context"| AOAI
    Foundry -->|"GPT-4o backed"| AOAI
    LogicApps -->|"AI steps via"| AOAI
    AISearch -->|"Semantic search"| Foundry
    ContentSafety -->|"Output validation"| AppSvc
    Fabric -->|"ML model feeds"| PBI
    CopilotStudio -->|"RAG queries"| AISearch
    CopilotStudio --> BotService
    MI -->|"Auth to all Azure services"| AOAI
    MI -->|"Auth to all Azure services"| AISearch
    MI -->|"Auth to all Azure services"| Foundry
```

---

## Constrained Solution vs Enterprise Target: Summary

| Pain Point | Constrained Solution | Enterprise Target |
|---|---|---|
| Documentation pipeline | Azure Function + Claude API | AI Foundry prompt flow + Logic Apps + native ADO connector |
| Estimates | ADO Analytics OData + Claude API | Azure OpenAI fine-tuned on velocity + Power BI Copilot |
| Backlog dedup | Service Bus + Function + Claude API 90-day scope | Azure AI Search vector index, full backlog, no LLM token cost |
| Support triage | Chained Functions + Claude API | Logic Apps workflow + native connectors + Azure OpenAI |
| QA automation | Claude Code + CLAUDE.md + ADO Pipelines | Copilot Enterprise + Copilot Workspace |
| Living docs | CLAUDE.md + Claude Code CLI | AI Foundry RAG + AI Search vector index + Copilot Studio bot |
| Developer productivity | Claude Code slash commands + Key Vault MCP | Copilot Enterprise + Copilot Workspace (Key Vault MCP remains) |
| Payment integrations | Claude Code + CLAUDE.md pattern library | AI Foundry prompt flow, org-wide, with eval metrics |
| Rate page NLP | App Service route + Claude API JSON output | Azure OpenAI + Semantic Kernel function calling (strongly typed) |
| NL reservations | Azure Function + Claude API slot-filling | Copilot Studio + Azure OpenAI + Bot Service multi-channel |
| Dynamic pricing | SQL MI + Claude API + Teams webhook | Microsoft Fabric + Azure OpenAI fine-tuned + Power BI Copilot |
| Legacy modernization | Claude Code + ARM parameterization | Copilot Enterprise + .NET Upgrade Assistant + Bicep + Deployment Environments |

---

## Investment Summary for Phase 5 Approval Request

| Resource | Estimated Monthly Cost | Primary Value |
|---|---|---|
| Azure OpenAI (GPT-4o, 2 deployments) | $200 to $500 (usage-based) | Data residency, Managed Identity, AI Foundry eval |
| GitHub Copilot Enterprise (10+ seats) | $390/month at $39/seat | Whole-repo context, Copilot Workspace, no CLAUDE.md maintenance |
| Azure AI Foundry | Included with Azure OpenAI | Org-wide versioned prompts, evaluation metrics |
| Azure AI Search (Standard S1) | $250/month | Full-backlog vector index, living docs RAG |
| Logic Apps Standard | $15 to $50/month | Native connectors, visual designer, audit trail |
| Copilot Studio | $200/month (2,000 sessions included) | Customer reservation bot, consultant onboarding bot |
| Microsoft Fabric (F2) | $730/month | Dynamic pricing ML, self-service analytics for Rick |

**Total Phase 5 infrastructure:** approximately $1,800 to $2,100/month

The first two items (Azure OpenAI + Copilot Enterprise) provide disproportionate value and should be the initial request. Combined cost: approximately $600 to $900/month. This is the minimum viable Phase 5 investment.
