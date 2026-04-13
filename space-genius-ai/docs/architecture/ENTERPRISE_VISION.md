# SpaceGenius Enterprise AI Vision

**Author:** Carmen Reed  
**Date:** April 12, 2026  
**Purpose:** Target state architecture when full Azure AI platform access is approved. No constraints. No workarounds. The right answer for every problem.

This document is the vision half of the constraint-vision pair. [SOLUTION_ARCHITECTURE.md](./SOLUTION_ARCHITECTURE.md) is the constraint half.

---

## Azure AI Platform Target State

When full Azure AI licensing is approved, SpaceGenius operates on a unified Microsoft AI platform across five capability layers:

```
Layer 5: Business Intelligence (Microsoft Fabric + Power BI Copilot)
  Continuous ML model improvement for pricing
  Self-service data queries for non-technical stakeholders

Layer 4: Developer Experience (GitHub Copilot Enterprise + Copilot Workspace)
  Whole-repo AI context for all 10+ developers
  PBI-to-PR automation for every ticket
  No CLAUDE.md maintenance burden

Layer 3: AI Orchestration (Azure AI Foundry + Logic Apps)
  Org-wide versioned prompt flows for documentation pipeline
  Visual workflow authoring for non-developer modifications
  Native ADO + HelpScout + Teams connectors

Layer 2: AI Services (Azure OpenAI + Azure AI Search + Azure AI Content Safety)
  All LLM calls inside the Microsoft tenant, no third-party egress
  Persistent vector index for semantic dedup and living docs
  Content safety layer on all customer-facing AI outputs

Layer 1: Foundation (Key Vault + Managed Identity + Azure Functions + App Services + SQL MI)
  Unchanged from current state
  All services already provisioned and running
```

---

## Service-by-Service Target State

### Azure OpenAI (GPT-4o)

**Replaces:** Anthropic Claude API in all 12 solution patterns  
**Deployment model:** Two named deployments: one capacity-optimized for batch operations (documentation pipeline, estimation, backlog dedup), one quality-optimized for high-stakes outputs (Gherkin AC generation, rate management NLP, customer reservations)  
**Authentication:** DefaultAzureCredential with Managed Identity. No API keys in any code.  
**Data residency:** All data processed within the Microsoft tenant. No third-party egress.  
**Content Safety:** Azure AI Content Safety layer applied to all customer-facing generated content before it reaches the UI.

### Azure AI Foundry

**Replaces:** Custom Claude Code slash commands and ad-hoc Function implementations for documentation and SDLC automation  
**Core use cases:**

1. **Documentation pipeline prompt flow:** Meeting transcript in, structured BRD/FRD/LOE/Gherkin ACs out. Org-wide shared prompt, versioned, with quality evaluation metrics on every run. Any developer runs the same prompt with the same quality guarantees.

2. **Integration pattern library:** The NMI integration approach, the Stripe pattern, and every subsequent gateway pattern stored as an AI Foundry prompt flow. Any developer, not just Carmen, can run the proven integration prompt. The bus-factor risk is eliminated.

3. **Evaluation pipeline:** Every AI output in the platform is scored against defined quality metrics. Gherkin AC completeness. Documentation coverage. Pricing recommendation confidence. Regressions are detectable before users encounter them.

### Azure AI Search

**Replaces:** In-context Claude API semantic comparison with a 90-day scope limit  
**Core use cases:**

1. **Backlog dedup:** Persistent vector index over the full ADO backlog. Semantic similarity checked on every new PBI without token window constraints and without an LLM call for the comparison itself.

2. **Living documentation RAG:** Auto-updated on every deploy. Copilot Studio bot queries the vector index to answer consultant questions with precision that unstructured markdown cannot match.

3. **Support ticket dedup:** Vector similarity against ADO work items on every HelpScout ticket, eliminating the 90-day constraint and the LLM token cost for comparison.

### Logic Apps

**Replaces:** Chained Azure Functions pipelines written in C#/.NET  
**Core use cases:**

1. **Documentation pipeline:** Logic Apps native ADO connector creates PBIs and attaches wiki pages without custom REST code. The workflow is modifiable in the visual designer by non-developers.

2. **Support ticket triage:** Logic Apps native HelpScout connector and ADO connector replace the custom REST integration. Kathy can adjust the triage workflow in the visual designer without a developer deployment. Run history provides a compliance-grade audit trail.

3. **Pricing approval workflow:** Logic Apps Teams adaptive card approval step replaces the incoming webhook pattern. The rate manager approves or rejects in Teams with structured context. The approval event is logged in the Logic Apps run history.

### GitHub Copilot Enterprise

**Replaces:** Claude Code + CLAUDE.md for developer-facing AI assistance  
**Core impact:**

All 10+ developers have whole-repo AI context without manual CLAUDE.md authoring. Code suggestions are always current. PR descriptions, commit notes, and development testing notes are generated automatically from repo context. The CLAUDE.md maintenance burden is eliminated.

Copilot Workspace turns ADO PBI into a plan, into code, into a PR with a single click. The developer reviews and approves the plan before code is generated. The human gate principle is preserved by design.

**What does not change:** The Key Vault MCP Server remains. Credential injection via Managed Identity is correct regardless of which AI development tool is in use.

### Microsoft Fabric + Power BI Copilot

**Replaces:** SQL pre-aggregated views + one-off Claude API pricing analysis  
**Core use cases:**

1. **Dynamic pricing ML model:** Fabric lakehouse ingests all transaction, occupancy, and historical rate data. An ML model fine-tuned on SpaceGenius-specific patterns improves pricing recommendations with every sprint. The Claude API static analysis is replaced by a continuously improving model.

2. **Self-service business analytics:** Rick asks "what was the revenue impact of last month's rate changes?" in Power BI Copilot without opening a ticket or waiting for a report. The developer middleman for data questions is eliminated.

3. **QA analytics:** Jessica asks "which modules have the highest bug recurrence rate?" with no developer intervention. Test quality metrics are self-service.

### Copilot Studio

**Replaces:** Single-exchange Azure Function HTTP endpoints for conversational AI  
**Core use cases:**

1. **Customer reservation bot:** Multi-turn conversation handles ambiguous inputs natively. "I need parking in Denver next week" can be clarified across multiple turns without the single-exchange slot-filling limitation. Available on web, mobile, and Teams from one bot configuration.

2. **Consultant onboarding bot:** "How does the TransSafe iframe work?" answered conversationally by a bot with access to the living documentation vector index. No Claude Code CLI required.

3. **Internal support bot:** First-line support queries answered by a bot trained on the SpaceGenius knowledge base. Escalation to Jessica only when the bot cannot answer.

---

## Migration Sequence

When budget approval arrives, the migration sequence prioritizes value and architectural cohesion:

| Step | Action | Unlocks |
|---|---|---|
| 1 | Provision Azure OpenAI + GPT-4o deployments | All LLM calls go Azure-native; Managed Identity auth; data residency; AI Foundry eval |
| 2 | Provision GitHub Copilot Enterprise | All developers have repo context; CLAUDE.md maintenance ends; Copilot Workspace unlocked |
| 3 | Provision Azure AI Foundry | Org-wide prompt flows; documentation pipeline on shared infrastructure; eval metrics |
| 4 | Provision Azure AI Search | Vector index; backlog dedup without scope limit; living docs RAG; support dedup |
| 5 | Provision Logic Apps | Replace chained Functions for doc pipeline and support triage; visual designer for Kathy |
| 6 | Provision Copilot Studio | Multi-turn customer reservation bot; consultant onboarding bot; internal support bot |
| 7 | Provision Microsoft Fabric | Dynamic pricing ML model; Power BI Copilot for self-service analytics |

Steps 1 and 2 should be acquired together. They provide the highest combined impact per dollar and unblock steps 3 through 7.

---

## What Does Not Change

The enterprise vision changes the infrastructure. It does not change the architecture principles:

- Human approval gates before any AI-generated content affects business state
- Structured output contracts with typed data shapes between pipeline phases
- Anti-hallucination constraints at the prompt level, regardless of what infrastructure augments them
- Key Vault + Managed Identity for all credential management
- Test coverage and documentation quality enforcement in CI
- Architecture Decision Records for every significant choice, with trade-off analysis and migration paths

These are not constraints of the current limited toolset. They are the correct architecture, and they scale to the enterprise target state unchanged.
