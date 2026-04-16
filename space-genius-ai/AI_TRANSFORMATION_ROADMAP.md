# SpaceGenius AI Transformation Roadmap

**Author:** Carmen Reed, Solutions Architect  
**Date:** April 12, 2026  
**Horizon:** 12 months  
**Constraint:** All Phase 1 and Phase 2 solutions use only currently provisioned Azure resources

---

## Roadmap Overview

```
Phase 0: Foundation (Month 1)
  Key Vault MCP Server, CLAUDE.md knowledge base, dev tooling baseline

Phase 1: Developer Productivity (Months 1 to 3)
  Auto-PR, commit notes, ticket updates, payment integration library

Phase 2: SDLC Automation (Months 2 to 4)
  Documentation pipeline, estimation intelligence, backlog hygiene

Phase 3: QA Automation (Months 3 to 5)
  AI-generated Playwright tests, ADO closed loop, CI integration

Phase 4: Product AI (Months 5 to 8)
  Rate page NLP UI, customer-facing natural language reservations, dynamic pricing

Phase 5: Full Azure AI Platform (Months 6 to 12, budget-dependent)
  Azure OpenAI deployment, AI Foundry, AI Search, Logic Apps, Copilot Enterprise
```

---

## Phase 0: Foundation

**Duration:** Month 1  
**Owner:** Carmen Reed  
**Azure resources required:** Key Vault (existing), Azure Functions (existing), ADO (existing)

The foundation phase establishes the infrastructure that all subsequent phases depend on. None of this is visible to Rick or end users. It is the architectural scaffolding.

### Deliverable 1: Key Vault MCP Server

A Node.js MCP (Model Context Protocol) server that injects Azure Key Vault secrets into Claude Code sessions. This eliminates the last remaining manual step in AI-assisted development: credential injection.

Current state: developers manually copy-paste database credentials and API keys into prompts or environment files during development sessions.  
Target state: Claude Code requests credentials by name, the MCP server fetches them from Key Vault using Managed Identity, and the credentials are available in the session context without ever appearing in code or chat history.

**Implementation:** Node.js wrapper around the Azure Key Vault SDK, registered as a Claude Code MCP server in each developer's settings.

**Security:** Credentials flow through Managed Identity. No secrets in code, no secrets in Claude Code session logs, no secrets on developer machines.

### Deliverable 2: CLAUDE.md Knowledge Architecture

A structured CLAUDE.md file for the SpaceGenius codebase that encodes:
- Module map: what each project and namespace does
- Integration patterns: how NMI, TransSafe, Tiba, and other third-party systems are integrated
- Naming conventions and code patterns
- DevOps pipeline structure
- Known sharp edges (the code behaviors that have burned developers before)

This is Carmen's version of what Copilot Enterprise provides out of the box: codebase awareness for the AI assistant. Unlike Copilot Enterprise, it requires intentional authoring. Unlike Copilot Enterprise, it is not a recurring license cost.

**Auto-update mechanism:** A post-deploy ADO Pipelines step triggers an Azure Function that diffs release notes and PR changed files, then updates the CLAUDE.md knowledge base automatically. Developers always have a current knowledge base without manual maintenance burden.

---

## Phase 1: Developer Productivity

**Duration:** Months 1 to 3  
**Owner:** Carmen Reed, Jason Kistler  
**Azure resources required:** Key Vault MCP Server (Phase 0), ADO REST API (existing), ADO Pipelines (existing)

### Feature 1: Auto-PR with ADO ticket link

**Pain point:** Developers write minimal PR descriptions. Reviewers lack context. ADO tickets are not consistently linked.

**Solution:** A Claude Code slash command `/create-pr` that:
1. Reads `git diff` for the current branch
2. Fetches the linked ADO ticket via ADO REST API (using PAT from Key Vault MCP)
3. Generates a structured PR description: summary, changed files with rationale, testing notes, acceptance criteria reference
4. Creates the PR via GitHub/ADO API with the ticket link populated

**Impact:** Every PR has a complete description and ticket link. Code reviewers have context. Jessica's sprint board stays accurate. No developer writes a PR description manually again.

### Feature 2: Development testing notes auto-population

**Pain point:** ADO tickets reach QA with empty development testing notes. Jessica retests what was already verified. Bugs resurface.

**Solution:** A Claude Code slash command `/update-ticket` that:
1. Reads the test run output from the most recent CI pipeline execution
2. Generates structured development testing notes: what was changed, what was tested, what passed, known limitations
3. Posts the notes back to the ADO PBI via REST API

**Impact:** Zero empty development testing notes. Jessica's QA scope is clearly defined before she touches the ticket.

### Feature 3: Payment integration library

**Pain point:** Each new payment gateway integration starts cold. The NMI integration required significant context-building before productive AI-assisted development was possible.

**Solution:** A CLAUDE.md integration library section that codifies the NMI integration as the reusable template pattern. Stripe, WorldPay, or any future gateway integration starts from the proven NMI pattern with the Key Vault MCP injecting gateway credentials.

**Expected outcome:** Stripe integration uses the same 0% logic error approach as NMI. Carmen has already verified this approach end-to-end.

---

## Phase 2: SDLC Automation

**Duration:** Months 2 to 4  
**Owner:** Carmen Reed  
**Azure resources required:** Azure Functions (existing), Service Bus (existing), ADO REST API (existing), Key Vault (existing)

### Feature 1: Documentation pipeline

**Current state:** Business requirements come out of meetings as informal notes. BRDs, FRDs, LOEs, and Gherkin acceptance criteria are written manually, sometimes weeks after the meeting, sometimes never.

**Target state:** Meeting transcript is POSTed to an Azure Function HTTP endpoint. The Function calls Claude API (key from Key Vault) and returns structured JSON: BRD, FRD, LOE template, and Gherkin ACs. The Function calls ADO REST API to create a PBI in design state with all documents attached as wiki pages.

**Business impact:** Design state with complete documentation is available within minutes of a meeting ending. Rick gets his documentation. The team gets their Gherkin ACs for test generation (Phase 3). Jessica's sprint board populates automatically.

**Architectural principle:** The meeting-to-ADO pipeline is the single highest-value automation in the entire roadmap. It replaces the most common failure mode in the SpaceGenius delivery process: the gap between "we talked about it" and "it is documented and ticketed."

### Feature 2: Velocity-grounded estimation

**Current state:** Rick asks for ballpark estimates. The team gives ballparks without data. Rick holds the team to ballparks. Deadlines slip.

**Target state:** An Azure Function queries ADO Analytics OData (included free with every Azure DevOps subscription, no Power BI required) for historical sprint velocity by task type. The velocity data is packaged with the story description and sent to Claude API. Claude returns a granular estimate with a confidence range. The estimate is posted back to the PBI as a structured comment.

**Business impact:** "Here is a ballpark" becomes "here is an estimate grounded in your team's actual velocity data, with a 70% confidence range." Rick gets the predictability he wants. The team is no longer held to guesses.

### Feature 3: Backlog hygiene

**Current state:** The ADO backlog accumulates duplicate and near-duplicate tickets. New tickets are created without checking for existing items. Developers sometimes work duplicated work.

**Target state:** An ADO webhook fires on every new PBI creation. The webhook POSTs to a new Service Bus topic (added to the existing namespace, no new cost tier). A Function subscriber fetches the last 90 days of backlog via ADO REST. Claude API performs semantic comparison. Duplicates are flagged in ADO with links to the existing items. Auto-links are created for related items.

**Constraint:** No Azure AI Search means no persistent vector index. Claude API performs semantic comparison in-context. The 90-day scope limit mitigates token window constraints while covering 99% of actionable duplicates.

---

## Phase 3: QA Automation

**Duration:** Months 3 to 5  
**Owner:** Carmen Reed, Jason Kistler, Jessica  
**Azure resources required:** ADO Pipelines (existing), ADO REST API (existing), Claude Code

### Feature: AI-Generated Playwright Tests

A Claude Code slash command `/generate-tests` that:
1. Reads the Gherkin acceptance criteria from the linked ADO PBI via REST API
2. Reads the relevant source code files using CLAUDE.md context
3. Generates a Playwright test file with tests for each acceptance criteria scenario
4. Commits the test file to the feature branch
5. ADO Pipelines runs Playwright on the committed tests
6. Pass/fail results are posted back to the PBI

**Impact:** Every PBI with Gherkin ACs gets an automated test suite. Test coverage grows proportionally with the backlog. Jessica shifts from manual regression to test maintenance and edge case identification.

---

## Phase 4: Product AI

**Duration:** Months 5 to 8  
**Owner:** Carmen Reed  
**Azure resources required:** App Services (new route, no new resource), Azure Functions (new HTTP trigger), Key Vault (existing)

Three customer-facing AI features that directly improve the SpaceGenius product:

1. **Options / Rate page NLP UI:** Natural language rate management for parking operators. "Set weekend rates 15% below weekday rates for the downtown lot starting Friday" understood and executed with a human approval gate before the rate update API is called.

2. **Customer-facing natural language reservations:** "I need parking in Denver from the 15th to the 18th for a sedan" handled by a Function endpoint using Claude API slot-filling. Structured reservation parameters passed to the existing booking API layer. User sees a confirmation for approval before commit.

3. **Dynamic pricing intelligence:** A timer-triggered Function queries SQL MI for occupancy and transaction data. Claude API analyzes trends and generates a pricing recommendation with rationale. The recommendation posts to a Teams channel via the free incoming webhook. The rate manager approves in Teams. Approval triggers the existing rate update API.

---

## Phase 5: Full Azure AI Platform

**Duration:** Months 6 to 12 (budget approval required)  
**Dependencies:** Executive sponsor approval, Azure OpenAI deployment approval, Logic Apps provisioning

When full Azure AI platform access is approved, every Phase 1 through Phase 4 solution has a documented upgrade path. See [ENTERPRISE_VISION.md](./docs/architecture/ENTERPRISE_VISION.md) for the full target state.

The short version: every Claude API call becomes an Azure OpenAI call with Managed Identity auth and no third-party data egress. Every custom Function pipeline becomes a Logic Apps workflow with native ADO connectors. Every CLAUDE.md knowledge query becomes an Azure AI Foundry RAG pipeline with persistent vector index. Every manual Playwright test authoring session becomes a Copilot Workspace PBI-to-PR loop.

The architecture does not change. The infrastructure upgrades. That is intentional.

---

## Investment and Sequencing Rationale

Phase 0 and Phase 1 have zero net new Azure infrastructure cost: they use existing provisioned resources. Claude API token consumption is an operational expense tracked separately from Azure resource provisioning.

Phase 2 adds a Service Bus topic (no additional cost tier on the existing namespace) and new Azure Function routes (included in existing App Service plan).

Phase 3 adds no new Azure resources: Claude Code and ADO Pipelines are the only tools.

Phase 4 adds one new App Service route and one new Azure Function HTTP trigger: both within the existing ARM template.

Phase 5 is the only phase that requires budget approval for new Azure services.

**The first four phases of a 12-month AI transformation roadmap require zero new Azure infrastructure provisioning.** Claude API token costs are operational, not capital. That is the architecture argument for approval.
