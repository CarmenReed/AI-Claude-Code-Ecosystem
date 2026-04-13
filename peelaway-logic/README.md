# PeelAway Logic: Agentic Job Search Pipeline

**Type:** Production Application (Personal Portfolio + Daily Driver)  
**Author:** Carmen Reed, Solutions Architect  
**Live Site:** https://carmenreed.github.io/PeelAway-Logic  
**Stack:** React, Anthropic Claude API, Azure AI Search, Semantic Kernel (Python demo)  
**Test Coverage:** 346 tests across 15 test files, CI/CD via GitHub Actions

---

## What It Is

PeelAway Logic is a multi-phase agentic pipeline that transforms the job search process from manual, disconnected tasks into a governed, human-gated workflow with AI scoring, semantic search, and resume tailoring.

The application was built to fill a specific gap: existing AI job search tools required constant manual copy-paste between disconnected prompts and had no quality gates. PeelAway Logic replaces that with a pipeline where each phase produces a structured output that feeds the next, with human approval at every gate.

Carmen used PeelAway Logic to find and apply for this Microsoft position. It is not a demo. It is production software used daily.

---

## Pipeline Phases

```
Scout Phase
  User defines role criteria, target companies, experience level, location
  Output: structured search configuration

Search Phase
  Layer 1: Adzuna API + JSearch API (capped at 10 per source)
  Layer 2: RSS feeds from 7 direct employer and job board feeds (capped at 10)
  Layer 3: ATS direct company search via web (capped at 10)
  Dedup + merge: max ~30 job descriptions per session
  Output: normalized job description array

Review Phase
  Claude API scores all ~30 JDs in batches of 8 (Haiku model for cost efficiency)
  Scoring criteria: role match, seniority fit, location/remote preference, growth signal
  Top 5 promoted to full JD fetch (Sonnet model for quality)
  Re-score with full JD content
  Output: ranked and annotated shortlist

Tailor Phase
  User uploads resume PDF
  Claude API generates tailored resume content grounded ONLY in uploaded resume
  Anti-hallucination constraint: fabrication of experience is architecturally prevented
  Output: tailored resume draft with no invented content

Complete Phase
  Application record saved to localStorage with applied/dismissed tracking
  Cross-session dedup prevents previously applied or dismissed jobs from reappearing
  Output: persistent application history
```

---

## Architecture Documentation

| Document | Description |
|---|---|
| [ARCHITECTURE.md](./docs/architecture/ARCHITECTURE.md) | C4 system overview with embedded Mermaid diagrams |
| [PROJECT_EVOLUTION.md](./PROJECT_EVOLUTION.md) | Technical narrative: from Gemini Gems to Azure AI |
| [ADR-001](./docs/architecture/decisions/ADR-001-claude-over-azure-openai.md) | Why Anthropic Claude over Azure OpenAI |
| [ADR-002](./docs/architecture/decisions/ADR-002-rest-client-over-sdk.md) | Why client-side REST over Azure SDK |
| [ADR-003](./docs/architecture/decisions/ADR-003-human-gated-pipeline.md) | Why human-gated pipeline over fully autonomous |
| [ADR-004](./docs/architecture/decisions/ADR-004-project-evolution-strategy.md) | Why refactor from Gemini Gems to agentic architecture |
| [ADR-005](./docs/architecture/decisions/ADR-005-github-pages-hosting.md) | Why GitHub Pages over Azure Static Web Apps |
| [ADR-006](./docs/architecture/decisions/ADR-006-anti-hallucination-strategy.md) | Anti-hallucination prompt engineering strategy |
| [azure-resources.bicep](./docs/architecture/azure-resources.bicep) | IaC documentation for enterprise Azure deployment |
| [GOVERNANCE.md](./docs/GOVERNANCE.md) | Documentation standards and CI quality enforcement |

---

## Azure Integration (Current)

| Service | Tier | Usage |
|---|---|---|
| Azure AI Search | F0 (free) | Semantic search over resume content and job descriptions |
| GitHub Actions | Free | CI/CD: test runner, deploy to GitHub Pages, doc quality checks |

## Azure Integration (Enterprise Migration Path)

| Service | Purpose | Migration Trigger |
|---|---|---|
| Azure Static Web Apps | Replace GitHub Pages with custom domain, staging slots | When custom domain or staging environment is needed |
| Azure OpenAI (GPT-4o) | Replace Anthropic Claude API | When Microsoft tenant data residency is required |
| Azure Cosmos DB | Replace localStorage job persistence | When multi-device sync or team access is required |
| Azure Data Factory | Scheduled job ingestion pipeline | When automated daily search refresh is required |
| Application Insights | Monitoring and telemetry | When performance baselines and alerting are needed |
| Managed Identity | Replace API key authentication | When deployed to any Azure-hosted compute |

See [azure-resources.bicep](./docs/architecture/azure-resources.bicep) for the full IaC template documenting these resources.

---

## Key Metrics

| Metric | Value |
|---|---|
| Test coverage | 346 tests, 15 test files |
| Anti-hallucination rate | 0% fabrication on resume tailoring (architecturally enforced) |
| Search performance | ~30 max results per session, ~45 second scoring time |
| API cost per session | ~$0.60 to $0.90 after layer caps (down from ~$1.00 to $1.55) |
| CI pipeline | Automated test run, doc-lint, and deploy on every push to main |
