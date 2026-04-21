# SpaceGenius AI: Production AI Strategy Evolution

**Author:** Carmen Reed, Solutions Architect  
**Date:** April 12, 2026  
**Purpose:** Technical narrative documenting 1.5 years of production AI at SpaceGenius: what was tried, what worked, why it worked, and what the architecture became.

This document is the credibility story. The architecture documents explain the decisions. This document explains the journey.

---

## Chapter 1: The Starting Point

When Carmen joined SpaceGenius, the codebase was a 15-year-old .NET monolith: production-serving, revenue-critical, and largely undocumented. The team had no systematic use of AI. Developers used ChatGPT occasionally and informally, with no shared patterns, no credential security, and no connection to the production toolchain.

The first AI tools appeared from the team independently:

Jason Kistler built a Microsoft Teams chat tool using Codex AI and an Azure DevOps board tracker. Jackie Muto used ChatGPT to generate landing page content from an image. These were one-off explorations, not architectural investments. There was no shared infrastructure, no prompt versioning, and no way to reuse what any individual had learned.

The organizational state was: AI-curious but architecturally unprepared. The gap between "we should be using AI" and "we have a production-grade AI architecture" was not being closed.

---

## Chapter 2: The Architecture Problem

Carmen's role as Solutions Architect created a specific angle on the AI opportunity: the problem was not that the team lacked AI enthusiasm. The problem was that AI was being used tactically without architectural intention.

Three structural problems were visible:

**Problem 1: No shared infrastructure.** Every developer's AI setup was personal. API keys were in chat histories and environment files. There was no Key Vault-secured credential injection, no shared prompt library, no way for one developer's learned pattern to transfer to another.

**Problem 2: No SDLC integration.** AI tools were used outside the delivery pipeline. Developers used AI in a browser tab, then manually copied results into code or documentation. The AI had no access to the codebase context, the ADO tickets, or the deployment history. The quality ceiling was low because the input quality was low.

**Problem 3: No governance.** AI-generated content entered the codebase with no quality gates. Hallucinated API parameters appeared in payment integrations. Invented documentation appeared in comments. Without architectural constraints, the AI was as likely to produce confident wrong answers as correct ones.

The architecture intervention had to address all three problems at once, within the Azure resources that SpaceGenius had already provisioned.

---

## Chapter 3: The Foundation (Phase 0)

The first architectural decision was to establish secure credential injection before anything else. Every AI solution that required a third-party API key would be vulnerable to credential exposure if this was not solved first.

Carmen implemented the Key Vault MCP Server: a Node.js MCP (Model Context Protocol) server that injects Azure Key Vault secrets into Claude Code sessions using Managed Identity. Developers request a credential by name. The MCP server fetches it from Key Vault. The credential is available in the Claude Code session context without ever appearing in code, chat history, or a terminal command.

This was not a glamorous deliverable. It did not produce a visible feature. It was the foundation that made every subsequent AI solution secure by default, rather than requiring each developer to independently solve credential management.

The second foundational decision was the CLAUDE.md knowledge architecture. A structured CLAUDE.md file for the SpaceGenius codebase was authored to encode: the module map, integration patterns (NMI, TransSafe, Tiba), naming conventions, DevOps pipeline structure, and known sharp edges. This was Carmen's version of what GitHub Copilot Enterprise provides out of the box: codebase awareness for the AI assistant. Unlike Copilot Enterprise, it required intentional authoring. Unlike Copilot Enterprise, it was not a recurring license cost.

With these two foundations in place, Claude Code became a productive development partner for the SpaceGenius codebase. Without them, it was a generic chat tool.

---

## Chapter 4: The First Production Result

The NMI payment gateway integration was the first production validation of the AI-assisted architecture.

Carmen used the pattern that would become ADR-012: a dedicated Claude Code session, the NMI API documentation fed as context, the existing codebase available via CLAUDE.md, and black-box deficiency prompting as the system constraint. The black-box deficiency prompt instructed the AI: before writing any integration code, identify all information not present in the provided documentation. Ask for clarification. Do not guess API parameter names, endpoint paths, or data formats.

The result: the very first time Carmen ran an end-to-end integration test in the NMI sandbox, there were zero logic errors. Not one. In 28 years of payment gateway integration work, that had never happened before.

That result was not luck. It was the output of an architecture designed to prevent the most common failure mode in LLM-assisted development: confident hallucination of API behaviors that are not in the training data. The black-box deficiency constraint forces the AI to acknowledge what it does not know before generating code, rather than filling the gap with a plausible-sounding guess.

The NMI integration became the template for every subsequent payment integration. The Stripe integration follows the NMI pattern. Any future gateway integration starts from the same documented, tested foundation.

---

## Chapter 5: SDLC Automation

With the foundation proven, the next phase extended AI into the delivery pipeline. The specific pain points were identified from the same meeting where Carmen, Jason, and Jackie were strategizing on AI adoption for SpaceGenius.

The highest-value pain point was the documentation pipeline. Business requirements emerged from meetings as informal notes. BRDs, FRDs, LOEs, and Gherkin acceptance criteria were written manually, often weeks after the meeting that produced the knowledge, sometimes never. ADO PBIs reached development in design state with no documentation. Developers interpreted requirements verbally. Requirements were lost.

The documentation pipeline (ADR-001) converted meeting transcripts directly into structured documentation and ADO work items. The flow: transcript to Azure Function HTTP endpoint, Claude API with structured JSON output system prompt, ADO REST API creates PBI with BRD, FRD, LOE template, and Gherkin ACs attached as wiki pages. Human review before the PBI advances from design to ready. The AI does not auto-promote work items.

The estimation intelligence solution (ADR-002) was architecturally elegant precisely because of its constraint: no Power BI, no Fabric, no ML workspace. ADO Analytics OData (included free with every Azure DevOps subscription) provided the historical sprint velocity data. Claude API provided the reasoning layer that translated velocity data into a granular estimate with confidence range. The estimate posted back to the PBI as a structured comment. "Here is a ballpark" became "here is an estimate grounded in your team's actual velocity data, with a confidence range."

Backlog hygiene (ADR-003) demonstrated the constraint-first principle at its most transparent: no Azure AI Search meant no persistent vector index. The solution used Claude API for semantic comparison in-context with a 90-day scope limit that mitigates but does not eliminate the token window constraint. The trade-off is documented, quantified, and visible in the ADR.

Each of these solutions follows the same structural pattern: identify the Azure resources that are provisioned, design the solution within those constraints, document the gap between the constrained solution and the enterprise target explicitly. That gap is not a failure. It is the business case for Phase 5.

---

## Chapter 6: The Architectural Principle That Emerged

Across 12 pain points, 12 ADRs, and multiple production implementations, a consistent architectural principle emerged:

The Claude API plus Azure Functions pattern is functionally equivalent to Azure OpenAI plus Logic Apps, but with a different security posture, auditability profile, and maintenance model.

The equivalence holds because:
- Azure Functions is the execution layer in both architectures. The compute model does not change.
- Claude API and Azure OpenAI are LLM APIs with equivalent capabilities for the structured output tasks in these solutions. The provider changes; the prompt pattern and output contract do not.
- Key Vault + Managed Identity provides the same security model for Claude API credentials as it does for Azure OpenAI Managed Identity auth. The credential never appears in code.

The non-equivalences are equally important to state clearly:
- Azure OpenAI keeps all data within the Microsoft tenant. Claude API sends data to Anthropic servers. For SpaceGenius solutions that process pricing data, reservation data, or support tickets, this is a trade-off that requires explicit business and legal review.
- Logic Apps provides a visual designer, native connectors, and a compliance-grade run history audit trail. Chained Azure Functions requires developer-maintained code and custom logging for the equivalent audit trail.
- Azure AI Foundry provides org-wide versioned prompt flows with evaluation metrics. CLAUDE.md + slash commands are a per-project, Carmen-dependent equivalent.

The swap-readiness of the constrained architecture is intentional. Every Claude API call is behind a Function that abstracts the LLM provider. Swapping to Azure OpenAI requires changing one Key Vault secret and one environment variable. The business logic, the prompt structure, and the output contract do not change.

---

## Chapter 7: Lessons for Enterprise AI Architecture

The 1.5-year arc from ad-hoc developer experimentation to 12 documented production solutions produced five transferable lessons:

**Lesson 1: Secure credential injection is the prerequisite, not an afterthought.** The Key Vault MCP Server was built before the first AI feature. Every subsequent solution inherited the security pattern without additional effort. If credential management had been deferred, each solution would have introduced its own credential risk.

**Lesson 2: The CLAUDE.md knowledge architecture compounds.** The first time the NMI pattern was documented, it helped one integration. By the time the Stripe integration began, the NMI pattern was the starting point, not a reference. Every documented pattern reduces the cold-start cost of the next similar problem. The bus-factor risk is the price: the pattern knowledge lives with Carmen. The enterprise migration to AI Foundry prompt flows is the answer to that risk.

**Lesson 3: Human gates are not concessions to caution. They are architectural requirements.** No solution in the SpaceGenius initiative executes AI-generated content against a business system without human review. Not one. Rate changes, documentation creation, pricing recommendations, PBI creation: all require a human approval step. This is the same principle implemented in PeelAway Logic. The AI augments human judgment. It does not replace it.

**Lesson 4: Constraint-first architecture produces more honest documentation.** Every ADR in this portfolio acknowledges what the constrained solution cannot do. Those constraints are not embarrassing. They are the most useful parts of the documents. A reader who sees the constraint and the workaround understands both the decision and its upgrade path. A reader who sees only the solution understands neither the trade-off nor what changes at enterprise scale.

**Lesson 5: The gap between what is provisioned and what Azure AI provides is the business case, not a failure.** The 12 constrained solutions work. They are in production or production-ready. They produce real value within real constraints. The enterprise vision documents show exactly what Azure OpenAI, AI Foundry, Logic Apps, and Copilot Enterprise provide. The gap between the two columns is the budget request. The constrained solutions prove the concept while making the investment case.

---

## What the Architecture Becomes

The SpaceGenius AI initiative does not end at Phase 4. Phase 5 is when the architecture becomes what it should be. [ENTERPRISE_VISION.md](./architecture/ENTERPRISE_VISION.md) documents that target state in full.

The migration sequence is intentional: Azure OpenAI and GitHub Copilot Enterprise first, because they provide disproportionate value and unblock every subsequent service. Then AI Foundry, AI Search, Logic Apps, Copilot Studio, and Fabric in sequence, each enabling a documented upgrade path from the constrained solution already running.

The architecture does not change when the infrastructure upgrades. Human gates, structured output contracts, Key Vault + Managed Identity, test coverage, documentation quality gates: these are architecture decisions, not implementation choices. They scale to the enterprise target state unchanged.

That is the architecture story. The infrastructure is what you buy. The architecture is what you design.
