# PeelAway Logic: Project Evolution Narrative

**Author:** Carmen Reed  
**Date:** April 12, 2026  
**Purpose:** Technical narrative explaining the architectural decisions, pivots, and growth of PeelAway Logic from its origin through current production state and the enterprise vision.

This document exists because architecture decisions without context are just rules. The context is what makes them transferable.

---

## Chapter 1: Genesis (February 2026)

The origin was a problem every senior engineer recognizes: the job search process was consuming enormous cognitive overhead with almost no return.

Each application required the same sequence of manual steps:
1. Find relevant job descriptions across multiple platforms
2. Read and mentally score each one against personal criteria
3. Copy-paste the job description into a separate AI chat window
4. Copy-paste the resume into the same window
5. Prompt for tailoring
6. Copy-paste the result back out
7. Repeat with no tracking, no history, no deduplication

The toolset at the time was disconnected Gemini Gems: individual AI instances, each with a specific persona and prompt, but with no way to pass structured data between them. Every hand-off between phases was a manual copy-paste. There were no quality gates. There was no pipeline.

The result was high effort, inconsistent output quality, and a growing suspicion that the AI was occasionally fabricating resume content to fill gaps between the job requirements and the uploaded resume.

---

## Chapter 2: The Core Problem

Three problems drove the architectural pivot:

**Problem 1: No pipeline.** Each phase of the job search process was isolated. Output from phase one did not flow automatically into phase two. There was no data contract between phases, no structured output, and no way to enforce consistency.

**Problem 2: No quality gates.** Nothing prevented a phase from producing output that was reviewed by no one and applied directly. Hallucinated resume content could reach a hiring manager without the user noticing.

**Problem 3: No observability.** There was no record of which jobs had been applied to, dismissed, or surfaced before. Every search started from zero. The same jobs appeared repeatedly.

These are not UI problems. They are architecture problems. The solution required designing a data pipeline, not building a better prompt.

---

## Chapter 3: The Pivot (Late February 2026)

The pivot was from disconnected prompts to a governed, multi-phase agentic pipeline built with Claude Code and React.

The key architectural decisions made at this stage:

**Decision: Claude Code over Gemini.** Claude Code's ability to maintain full codebase context via CLAUDE.md, combined with its agentic subagent capabilities, made it the right tool for building a codebase iteratively. Gemini's Gem model required manual context injection for every session. See [ADR-004](./docs/architecture/decisions/ADR-004-project-evolution-strategy.md).

**Decision: Human gates at every phase transition.** No phase output advances to the next phase without explicit user approval. This is not a UX nicety. It is an architectural requirement that prevents AI hallucinations from propagating through the pipeline. The user reviews scored jobs before any JD fetch occurs. The user reviews tailored content before any application action is taken. See [ADR-003](./docs/architecture/decisions/ADR-003-human-gated-pipeline.md).

**Decision: Structured output contracts between phases.** Each phase produces a typed data structure. The Scout phase produces scored and ranked job arrays after searching, deduplicating, and scoring. The Review phase adds human-approved selection status. The Complete phase generates tailored documents grounded only in the uploaded resume. Data contracts prevent downstream phases from operating on undefined or malformed input.

**Decision: localStorage for persistence, with a documented migration path.** For a client-side-only application deployed to GitHub Pages, localStorage was the correct scope. Cross-session applied and dismissed job tracking is implemented using two localStorage keys. The migration path to Cosmos DB is documented in the Bicep template.

---

## Chapter 4: Growth (March 2026)

Growth happened in three areas: test coverage, search quality, and CI/CD maturity.

**Test coverage.** Starting from zero, the test suite grew to 453 unit and component tests across 17 suites (Jest + React Testing Library), plus 62 E2E tests across 8 spec files (Microsoft Playwright + Chromium). Tests cover layer-level search logic, scoring batch behavior, resume parsing, anti-hallucination constraints, deduplication, and complete user workflows through all four pipeline phases. The anti-hallucination tests explicitly assert that tailored content does not introduce phrases not present in the uploaded resume. All external APIs are mocked at the network layer (Jest mocks for unit tests, Playwright `page.route()` for E2E), so tests are deterministic and free to run.

**Search layer performance.** Early versions returned uncapped results: Layer 2 RSS alone could return 350 items across 7 feeds. Scoring 100+ jobs at 8 per batch with 15-second delays produced 3 to 10 minutes of waiting per search. The fix was a per-layer cap of 10 results post-dedup, producing a maximum of ~30 job descriptions per session. Scoring time dropped from 3 to 10 minutes to approximately 45 seconds. API cost per search dropped approximately 40%.

**CI/CD maturity.** Four GitHub Actions workflows now run on push to main:
- Test runner (Jest: 453 tests must pass; Playwright: 62 E2E tests against Chromium)
- Doc quality (doc-lint.js checks em-dash violations, broken internal links, stale version numbers)
- Env audit (blocks pushes containing QA references in production docs)
- Deploy (build and push to GitHub Pages)

No deployment occurs if tests fail or doc-lint reports violations. This is the same quality-gate philosophy applied to documentation that most teams only apply to code.

---

## Chapter 5: Azure Integration (April 2026)

Two Azure integrations were added to demonstrate Microsoft AI platform fluency.

**Azure AI Search (REST client pattern).** A new service module wraps the Azure AI Search REST API with no Azure SDK dependency. This allows the application to remain a static deployment to GitHub Pages with zero server-side infrastructure. The trade-off is explicit: no Managed Identity, no token refresh. The enterprise migration path uses the @azure/search-documents SDK with DefaultAzureCredential against an Azure Static Web App. See [ADR-002](./docs/architecture/decisions/ADR-002-rest-client-over-sdk.md).

**Semantic Kernel Python demo.** A standalone Python module implements the PeelAway pipeline phases as Semantic Kernel plugins. The demo is explicitly swap-ready: the backing model is abstracted behind the SK kernel, and swapping from Anthropic Claude to Azure OpenAI requires changing two lines of configuration. See [ADR-001](./docs/architecture/decisions/ADR-001-claude-over-azure-openai.md).

---

## Chapter 6: Recursive Refinement

One of the most architecturally interesting aspects of this project is that it was built using the same agentic, iterative AI-assisted approach that it demonstrates.

The sprint plan for this Azure integration phase was itself audited by Claude Code agents. The agent reviewed the plan for gaps (missing IaC awareness artifact, no ADR for anti-hallucination), added phases that would directly address architectural assessment criteria, and produced a talking-point mapping to the three core assessment areas. The output of that recursive refinement is the MASTER_PLAN_AZURE_SPRINT.md document in the QA repository.

This is the practical argument for agentic AI in architecture work: the AI is not a code generator. It is a planning partner that can reason about the completeness of an architecture document the same way it reasons about the completeness of a codebase.

---

## Chapter 7: Enterprise Vision

If PeelAway Logic were deployed as an enterprise product with full Azure access, the architecture changes are well-understood and already documented.

| Component | Current | Enterprise Target |
|---|---|---|
| LLM | Anthropic Claude API | Azure OpenAI GPT-4o with Managed Identity |
| Search | Azure AI Search REST client | Azure AI Search SDK with DefaultAzureCredential |
| Hosting | GitHub Pages | Azure Static Web Apps with staging slots |
| Persistence | localStorage | Azure Cosmos DB with multi-device sync |
| Ingestion | Manual search trigger | Azure Data Factory scheduled pipeline |
| Monitoring | None | Application Insights with custom dashboards |
| Orchestration | Custom React pipeline | Azure AI Foundry prompt flows |

The Bicep template at [azure-resources.bicep](./docs/architecture/azure-resources.bicep) documents all seven of these resources as they would be provisioned in an enterprise deployment.

The pattern that scales: human-gated pipeline, structured output contracts between phases, anti-hallucination constraints, and grounded scoring criteria. Those do not change with the infrastructure. They are architecture decisions, not implementation choices.
