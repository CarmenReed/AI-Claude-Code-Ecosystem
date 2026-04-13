# SpaceGenius AI Solution Architecture

**Author:** Carmen Reed  
**Date:** April 12, 2026  
**Format:** For each of the 12 pain points: constrained solution (uses only provisioned Azure resources) and enterprise vision (full Azure AI, no ceiling).

---

## Reading This Document

The left column is the credibility story: real constraints, real assets, real architectural decisions with explicit WHYs for every non-Azure fallback. The right column is the vision story. Every constraint in the left column is an implicit pitch for what Microsoft tooling unlocks. The gap between the two columns is the opportunity.

---

## 1. Documentation Pipeline

**Pain point:** Business requirements emerge from meetings as informal notes. BRDs, FRDs, LOEs, and Gherkin ACs are written manually, often weeks late, sometimes never. Design state in ADO is frequently empty when development begins.

### Constrained Solution (Available Today)

**Stack:** Azure Function (HTTP trigger) + Key Vault + ADO REST API + Claude API

**Flow:**
1. Meeting transcript is POSTed to an Azure Function HTTP endpoint
2. Managed Identity fetches the Claude API key from Key Vault
3. Claude generates structured JSON: BRD, FRD, LOE template, Gherkin acceptance criteria
4. ADO REST API creates a PBI in design state with documents attached as ADO wiki pages
5. Human reviews the generated documentation before moving the PBI to ready

**Why this stack, not Logic Apps or AI Foundry:** No Logic Apps provisioned, no Azure OpenAI deployment. Azure Functions is already in the ARM template. Key Vault + Managed Identity keeps the Claude API key out of code and off developer machines. The principal architect principle: use what is provisioned before requesting new resources.

**Constraint:** Documentation quality depends on Claude API prompt engineering. No org-wide shared prompt versioning. No evaluation metrics on output quality.

### Enterprise Vision (Full Azure AI)

**Stack:** Azure AI Foundry prompt flow + Logic Apps + ADO native integration

**Flow:** Meeting transcript to Foundry prompt flow to BRD/FRD/LOE/Gherkin ACs to ADO PBI in design state, with org-wide shared versioned prompt flows and built-in evaluation metrics.

**Why better:** AI Foundry provides team-shared versioned prompt flows with evaluation tooling. Logic Apps has a native ADO connector eliminating custom REST code. Azure OpenAI keeps all data inside the tenant with no third-party egress.

---

## 2. Unpredictable Estimates

**Pain point:** Rick asks for ballpark estimates. The team gives ballparks without data. Rick holds the team to ballparks. Deadlines slip. The team has no data-grounded way to say "the confidence range on this estimate is wide."

### Constrained Solution (Available Today)

**Stack:** Azure Function + ADO Analytics OData + Key Vault + Claude API

**Flow:**
1. Function queries ADO Analytics OData feed (included free with all ADO subscriptions) for historical sprint velocity by task type
2. Velocity data is packaged with the story description and work item details
3. Claude API returns a granular estimate with a confidence range
4. Estimate posts back to the PBI as a structured comment: point estimate, confidence range, historical basis

**Why ADO Analytics OData, not Power BI or Fabric:** ADO Analytics OData is zero additional cost. No Power BI or Fabric license required. Claude API provides the reasoning layer that interprets velocity trends. Same ARM-deployed Function, new route, no new provisioning.

**Constraint:** Estimate quality improves as more sprint data accumulates. Early sprints have limited historical grounding.

### Enterprise Vision (Full Azure AI)

**Stack:** ADO Analytics + Azure OpenAI fine-tuned on velocity + Power BI Copilot

**Why better:** Fine-tuned model improves with every sprint. Power BI Copilot lets Rick ask "by when, with what confidence?" in plain English without a developer in the loop.

---

## 3. Backlog Hygiene / Ticket Deduplication

**Pain point:** The ADO backlog accumulates duplicate and near-duplicate tickets. New tickets are created without checking existing items. Developers work duplicated work without knowing it.

### Constrained Solution (Available Today)

**Stack:** Service Bus (new topic in existing namespace) + Azure Functions + ADO REST API + Claude API

**Flow:**
1. ADO webhook fires on new PBI creation
2. Webhook POSTs to a new Service Bus topic (added to existing namespace, no new cost tier)
3. Function subscriber fetches last 90 days of backlog via ADO REST
4. Claude API performs semantic comparison in-context
5. Duplicates flagged in ADO with links to existing items; related items auto-linked

**Why extend, not replace, and why the 90-day scope limit:** The single Service Bus is a namespace, not a hard cap on topics. A principal architect extends the ARM template with a new topic and subscription block. No Azure AI Search means no persistent vector index; Claude API does semantic comparison in-context. The tradeoff: large backlogs exceed token limits. Mitigation: scope to last 90 days, which covers 99% of actionable duplicates.

**Constraint:** The 90-day scope window misses duplicates in older backlog items. Semantic similarity quality is limited by context window, not by a purpose-built vector index.

### Enterprise Vision (Full Azure AI)

**Stack:** Azure AI Search (vector index) + Service Bus + Azure Functions

**Why better:** Persistent vector index eliminates the 90-day scope constraint. AI Search finds semantic duplicates regardless of phrasing, without consuming LLM tokens on every check.

---

## 4. Support Ticket Triage (HelpScout to ADO)

**Pain point:** Support tickets arrive in HelpScout and are manually triaged, duplicated, and copied into ADO. Jessica triages manually. Gherkin ACs are never generated for support-originated bugs. Development testing notes are sparse.

### Constrained Solution (Available Today)

**Stack:** HelpScout webhook + Service Bus + Azure Functions pipeline chain + Claude API + HelpScout API + SendGrid (free tier)

**Flow:**
1. HelpScout webhook POSTs to Service Bus topic
2. Function 1: completeness check via Claude API. If incomplete, HelpScout API sends canned clarification response
3. Function 2: semantic dedup check against ADO backlog (same pattern as Pain Point 3)
4. Function 3: Gherkin AC generation via Claude API
5. ADO REST API creates PBI with Gherkin ACs attached
6. SendGrid free tier (100 emails/day) notifies Jessica via email

**Why Functions chain, not Logic Apps:** No Logic Apps provisioned. A chained Azure Functions pipeline in C#/.NET replicates the Logic Apps orchestration pattern in Carmen's native stack. HelpScout has a REST API for automated replies. SendGrid free tier handles notifications. No new Azure services.

**Constraint:** No visual designer for non-developer modifications. No built-in run history audit trail. Kathy cannot modify the workflow without a developer deployment.

### Enterprise Vision (Full Azure AI)

**Stack:** Logic Apps + Azure OpenAI + ADO native connector + HelpScout connector

**Why better:** Logic Apps native connectors eliminate all custom REST code. Kathy can adjust the workflow in a visual designer without developer involvement. Run history provides a compliance-grade audit trail out of the box.

---

## 5. QA Automation / AI-Generated Tests

**Pain point:** QA automation coverage is low. Playwright tests are written manually after development is complete. Gherkin ACs exist but are not connected to test files. Jessica's testing scope depends on what developers document.

### Constrained Solution (Available Today)

**Stack:** Claude Code slash command + ADO REST API + Azure Pipelines (existing) + Playwright

**Flow:**
1. `/generate-tests` Claude Code slash command reads Gherkin ACs from ADO PBI via REST
2. Generates a Playwright test file with full codebase context from CLAUDE.md
3. Commits test file to the feature branch
4. Existing ADO Pipelines runs Playwright
5. Results posted back to the PBI as pass/fail comments

**Why Claude Code, not Copilot Enterprise:** Copilot Enterprise is not licensed. Claude Code with a comprehensive CLAUDE.md fills the repo-context gap. ADO Pipelines is already provisioned. PAT authenticates both ADO queries and pipeline triggers. Zero new Azure services. Full closed loop: PBI Gherkin to test file to pass/fail back to PBI.

**Constraint:** CLAUDE.md requires manual maintenance as the codebase evolves. Context quality degrades if CLAUDE.md is not updated after significant refactors.

### Enterprise Vision (Full Azure AI)

**Stack:** GitHub Copilot Enterprise + Azure Pipelines + Playwright

**Why better:** Copilot Enterprise whole-repo context is always current with no CLAUDE.md maintenance burden. Copilot Workspace turns ADO PBI into plan into code into PR automatically.

---

## 6. Consultant Onboarding / Living Documentation

**Pain point:** New consultants and contractors need 2 to 4 weeks to become productive. Documentation is sparse, outdated, or non-existent. Knowledge lives in individuals' heads. Bus factor is high.

### Constrained Solution (Available Today)

**Stack:** ADO Pipeline post-deploy step + Azure Function + CLAUDE.md knowledge base + Claude Code + Azure Translator API (free tier)

**Flow:**
1. Post-deploy ADO Pipelines step triggers an Azure Function
2. Function diffs release notes and PR changed files
3. Claude API updates structured CLAUDE.md knowledge base sections affected by the deploy
4. Claude Code is the natural language query interface for consultants
5. Azure Translator API free tier (2M characters/month) localizes key onboarding docs on demand

**Why CLAUDE.md-as-RAG, not Azure AI Search:** No Azure AI Search provisioned. CLAUDE.md-driven knowledge base with Claude Code as the query layer is the pragmatic equivalent. Auto-updated on every deploy. Azure Translator free tier covers localization without any new license.

**Constraint:** Unstructured markdown search is less precise than vector similarity. Claude Code compensates with large context windows, but the query interface requires Claude Code CLI access.

### Enterprise Vision (Full Azure AI)

**Stack:** Azure AI Foundry RAG + pipeline deploy hook + Azure AI Translator + Copilot Studio bot

**Why better:** Vector index is always more precise than markdown search. Copilot Studio gives consultants a conversational interface without requiring Claude Code CLI knowledge.

---

## 7. Developer Productivity / Auto-PR and Commit Notes

**Pain point:** PR descriptions are minimal. ADO ticket links are missing. Development testing notes are empty. Reviewers lack context. Jessica retests what developers already verified.

### Constrained Solution (Available Today)

**Stack:** Claude Code + Key Vault MCP Server + custom slash commands

**Flow:**
1. Key Vault MCP Server injects ADO PAT and database credentials safely into Claude Code session
2. `/create-pr` slash command generates PR description from `git diff` and linked ADO ticket
3. `/update-ticket` posts structured development testing notes back to the PBI
4. CLAUDE.md provides full codebase context without requiring Copilot Enterprise

**Why Claude Code + custom MCP, not Copilot Workspace:** No Copilot Enterprise license. The Key Vault MCP Server is Carmen's own production implementation. Extending it with ADO-specific slash commands leverages existing architecture. Claude Code reads the full codebase via CLAUDE.md. Slash commands are authored once and shared across the team.

**Constraint:** CLAUDE.md requires maintenance. Slash commands require Carmen's authoring and each developer's Claude Code configuration.

### Enterprise Vision (Full Azure AI)

**Stack:** GitHub Copilot Enterprise + Copilot Workspace + Claude Code MCP

**Why better:** Copilot Enterprise context is always current with no CLAUDE.md authoring. Copilot Workspace makes the PBI-to-PR loop a one-click action for every developer.

---

## 8. Third-Party Payment Integrations

**Pain point:** Each new payment gateway integration requires significant context-building and carries integration risk. The NMI integration was the first to use AI-assisted development.

### Constrained Solution (Available Today)

**Stack:** Claude Code + CLAUDE.md integration library + Key Vault MCP + ADO Pipelines

**Flow:**
1. CLAUDE.md codifies the NMI integration as the reusable template pattern
2. Key Vault MCP injects gateway credentials, no plaintext ever in session context
3. Claude Code reads the entire codebase and the new gateway's documentation
4. Black-box deficiency prompting prevents hallucinated API parameters
5. ADO Pipelines runs integration tests in CI against the dev environment

**Production evidence:** Carmen's NMI integration delivered 0% logic errors on first production test run using this exact approach. The Stripe integration will reuse the NMI pattern.

**Constraint:** Pattern knowledge lives in CLAUDE.md. If CLAUDE.md is not updated after each integration, future integrations lose the pattern library.

### Enterprise Vision (Full Azure AI)

**Stack:** Copilot Enterprise + Key Vault MCP Server + AI Foundry reusable prompt flow

**Why better:** AI Foundry stores the integration pattern as an org-wide reusable asset with evaluation metrics. Any developer runs it, not bus-factor dependent on Carmen's CLAUDE.md.

---

## 9. Options / Rate Page NLP UI

**Pain point:** Parking operators manage rates through a complex form-based UI. Non-technical operators make errors. Rate changes require developer involvement for anything beyond the simplest adjustments.

### Constrained Solution (Available Today)

**Stack:** App Services (new route, no new resource) + Claude API structured output + human approval gate

**Flow:**
1. New NLP controller added to existing App Service (same ARM deployment, new route)
2. Claude API with structured JSON output system prompt interprets natural language rate request
3. Returns typed ChangeSet object (rate_type, location, value, effective_date, operator_notes)
4. React UI renders the change preview for human review
5. Operator approves; existing .NET data layer executes the change set

**Why App Service extension, not Semantic Kernel:** Semantic Kernel requires Azure OpenAI as its backing model, which is not deployed. Claude API with a structured-output system prompt is the functional equivalent of Semantic Kernel function calling. Running inside the existing App Service means no new resource. Human approval gate before execution is a first-class architectural requirement.

**Constraint:** No function calling type safety. Structured JSON output relies on prompt engineering, not SDK-enforced schemas.

### Enterprise Vision (Full Azure AI)

**Stack:** Azure OpenAI + Semantic Kernel function calling + Blazor/React front end

**Why better:** Semantic Kernel function calling is strongly typed, testable, and auditable. Azure OpenAI keeps all data in the tenant. Plugin library compounds across multiple UI surfaces.

---

## 10. Customer-Facing Natural Language Reservations

**Pain point:** The reservation flow is form-based. Customers who want to "just tell it what they need" must navigate a multi-step form. Conversion rate suffers on mobile.

### Constrained Solution (Available Today)

**Stack:** Azure Function (HTTP trigger) + Claude API intent classification + slot-filling + existing booking API

**Flow:**
1. New HTTP-triggered Azure Function receives customer natural language input
2. Claude API with intent-classification and slot-filling prompt (location, dates, vehicle type) extracts structured parameters
3. Returns typed reservation parameters as JSON
4. Hands off to existing booking API layer
5. UI renders confirmation for customer review before commit

**Why Functions, not Copilot Studio or Bot Service:** No Copilot Studio subscription, no Azure Bot Service tier provisioned. For a structured reservation intake, a stateless HTTP call is sufficient. Slot-filling within a single exchange handles clarification without requiring multi-turn conversation state.

**Constraint:** Single-exchange slot-filling breaks when a customer gives incomplete or contradictory inputs. The fallback is the existing form-based flow.

### Enterprise Vision (Full Azure AI)

**Stack:** Azure Copilot Studio + Azure OpenAI + Azure Bot Service

**Why better:** Multi-turn conversation handles ambiguity natively. Copilot Studio allows dialog authoring without developer deployment. Bot Service adds SMS and Teams channels at no additional cost.

---

## 11. Dynamic Pricing Intelligence

**Pain point:** Pricing decisions are made on intuition or manual review of reports. There is no system that analyzes occupancy trends and suggests optimal rate changes. Operators leave revenue on the table during high-demand periods.

### Constrained Solution (Available Today)

**Stack:** Azure Function (timer trigger) + SQL Managed Instance + Claude API + Teams incoming webhook

**Flow:**
1. Scheduled Azure Function queries SQL MI with pre-aggregated occupancy and transaction statistics
2. Claude API analyzes trends and generates structured pricing recommendation with rationale
3. Recommendation posts to a Teams channel via free incoming webhook
4. Rate manager reviews in Teams and approves
5. Approval triggers the existing rate update API endpoint

**Why SQL + Claude API, not Fabric or ML workspace:** No Microsoft Fabric or ML workspace provisioned. SQL MI already holds all transaction data. Timer-triggered Functions are available at no additional cost. Teams incoming webhook is free. Claude API replaces an ML model for trend reasoning with no training pipeline required. Pre-aggregated SQL views ground Claude's reasoning in actual numbers, not raw rows.

**Constraint:** No continuous model improvement. Each pricing recommendation is independent; Claude does not learn from prior recommendations or their outcomes.

### Enterprise Vision (Full Azure AI)

**Stack:** Microsoft Fabric + Azure OpenAI + Power BI Copilot

**Why better:** Fabric lakehouse ingests all transaction history. ML model improves recommendations over time. Power BI Copilot lets business users ask pricing questions in plain English with no developer involvement.

---

## 12. Legacy .NET Modernization + CI/CD

**Pain point:** The SpaceGenius codebase targets an aging .NET version. Deprecated API warnings accumulate. A Bicep migration from the monolithic ARM template is architecturally correct but is a significant commitment during active feature development.

### Constrained Solution (Available Today)

**Stack:** Claude Code + ARM template parameterization + ADO Pipelines + App Service deployment slots

**Flow:**
1. Claude Code (full CLAUDE.md codebase context) audits deprecated APIs and generates a module-by-module .NET migration plan
2. ARM template is parameterized with environment slots (dev/staging/prod App Service plans) using ARM template functions
3. ADO Pipelines adds multi-target build (net8.0 + net10.0) to catch regressions per PR

**Why extend ARM, not migrate to Bicep:** The existing ARM template is production-deployed infrastructure. A principal architect does not replace running infrastructure without a migration plan and business case. The right move is parameterizing the existing template with environment slots and conditional resource blocks: zero downtime, no new toolchain. Bicep migration is a phase-2 goal once the .NET modernization stabilizes.

**Constraint:** ARM JSON is harder to maintain at scale than Bicep modules. The parameterization approach is a bridge, not a long-term target.

### Enterprise Vision (Full Azure AI)

**Stack:** Copilot Enterprise + .NET Upgrade Assistant + Azure Bicep + Azure Pipelines

**Why better:** Bicep is the Azure-native IaC standard. .NET Upgrade Assistant automates breaking-change fixes. Copilot Enterprise flags deprecated APIs inline during development. AI-reviewed PRs gate regressions automatically.
