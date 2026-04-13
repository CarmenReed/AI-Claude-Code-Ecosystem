# PeelAway Logic: Agentic Job Search Pipeline

**Type:** Production Application (Personal Portfolio + Daily Driver)  
**Author:** Carmen Reed, Solutions Architect  
**Live Site:** https://carmenreed.github.io/PeelAway-Logic  
**Stack:** React (Create React App), Anthropic Claude API, Azure AI Search, Microsoft Playwright, Semantic Kernel (Python demo)  
**Dev Tools:** Claude Code (implementation), GitHub Copilot (inline questions), Claude Cowork (planning)  
**Test Coverage:** 434 unit/component tests across 17 suites (Jest + RTL), 62 E2E tests across 8 specs (Microsoft Playwright), CI/CD via GitHub Actions

---

## What It Is

PeelAway Logic is a multi-phase agentic pipeline that transforms the job search process from manual, disconnected tasks into a governed, human-gated workflow with AI scoring, semantic search, and resume tailoring.

The application was built to fill a specific gap: existing AI job search tools required constant manual copy-paste between disconnected prompts and had no quality gates. PeelAway Logic replaces that with a pipeline where each phase produces a structured output that feeds the next, with human approval at every gate.

PeelAway Logic is not a demo. It is production software used daily.

---

## Pipeline Phases

```
Scout Phase
  Upload resume (PDF or TXT) or paste text; app extracts skills, experience, location
  Configure search filters (work type, date posted, employment type, zip code + radius)
  Layer 1: Adzuna API + JSearch API (capped at 10 per source)
  Layer 2: RSS feeds (WeWorkRemotely, Remotive, RemoteOK, Himalayas, Jobicy)
  Layer 3: ATS boards (Greenhouse, Lever, Workday) via AI-driven web search
  Quick Score: paste a URL or job description for immediate scoring
  "Score & Review" deduplicates, pre-filters, scores, fetches full JDs, re-scores
  Output: scored and ranked job array

Review Phase
  Tiered results: Strong Match (8-10), Possible (6-7), Weak (3-5), Rejected (0-2)
  Sort by score, date posted (newest first), or company
  Fresh postings (within 7 days) display green badge; stale dates show orange warning
  Human Gate: user selects which jobs to advance; no API calls until explicit approval
  Output: user-approved shortlist

Complete Phase
  Each approved job displays as a card with link to original posting
  Two independent buttons per job: "Create Resume" and "Create Cover Letter"
  Each document is one click, one API call; anti-hallucination enforced at prompt layer
  Download, copy, or regenerate any document individually
  Mark jobs as applied; applied jobs tracked across sessions, excluded from future scouts
  Output: tailored documents + persistent application history
```

---

## Architecture Documentation

| Document | Description |
|---|---|
| [ARCHITECTURE.md](./docs/architecture/ARCHITECTURE.md) | C4 system overview with embedded Mermaid diagrams |
| [PROJECT_EVOLUTION.md](./PROJECT_EVOLUTION.md) | Technical narrative: from Gemini Gems to Azure AI |
| [AI_SKILLS_INVENTORY.md](https://github.com/CarmenReed/PeelAway-Logic/blob/main/docs/AI_SKILLS_INVENTORY.md) | Full inventory of AI tools, patterns, and Microsoft/Azure skills demonstrated |
| [TEST-STRATEGY-OVERVIEW.md](https://github.com/CarmenReed/PeelAway-Logic/blob/main/docs/TEST-STRATEGY-OVERVIEW.md) | Two-tier testing strategy (Jest + Playwright) with CI/CD integration |
| [ADR-001](./docs/architecture/decisions/ADR-001-claude-over-azure-openai.md) | Why Anthropic Claude over Azure OpenAI |
| [ADR-002](./docs/architecture/decisions/ADR-002-rest-client-over-sdk.md) | Why client-side REST over Azure SDK |
| [ADR-003](./docs/architecture/decisions/ADR-003-human-gated-pipeline.md) | Why human-gated pipeline over fully autonomous |
| [ADR-004](./docs/architecture/decisions/ADR-004-project-evolution-strategy.md) | Why refactor from Gemini Gems to agentic architecture |
| [ADR-005](./docs/architecture/decisions/ADR-005-github-pages-hosting.md) | Why GitHub Pages over Azure Static Web Apps |
| [ADR-006](./docs/architecture/decisions/ADR-006-anti-hallucination-strategy.md) | Anti-hallucination prompt engineering strategy |
| [azure-resources.bicep](./docs/architecture/azure-resources.bicep) | IaC documentation for enterprise Azure deployment |
| [GOVERNANCE.md](./docs/GOVERNANCE.md) | Documentation standards, HCI governance, CI quality enforcement |

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
| Unit/component tests | 434 tests across 17 suites (Jest + React Testing Library) |
| E2E tests | 62 tests across 8 specs (Microsoft Playwright + Chromium) |
| Anti-hallucination rate | 0% fabrication on resume tailoring (architecturally enforced) |
| Search performance | ~30 max results per session, ~45 second scoring time |
| API cost per session | ~$0.60 to $0.90 after layer caps (down from ~$1.00 to $1.55) |
| CI pipeline | Automated test run (Jest + Playwright), doc-lint, env-audit, HCI governance audit, and deploy on every push to main |
