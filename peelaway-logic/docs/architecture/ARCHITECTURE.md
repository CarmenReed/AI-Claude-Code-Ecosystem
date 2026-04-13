# PeelAway Logic: Architecture Overview

**Author:** Carmen Reed  
**Date:** April 12, 2026  
**Standard:** C4 Model (Context, Container, Component, Code)  
**Diagrams:** Mermaid (rendered in GitHub, VS Code, and Mermaid Live Editor)

---

## System Context (C4 Level 1)

The outermost view: PeelAway Logic in its ecosystem, showing the user and all external systems it depends on.

```mermaid
graph TB
    User["Job Seeker\n(Carmen Reed)"]

    subgraph External_APIs["External Job Sources"]
        Adzuna["Adzuna API\nJob listing aggregator"]
        JSearch["JSearch API\nReal-time job boards"]
        RSS["RSS Feeds\n7 employer and job board feeds"]
        ATS["ATS Direct Search\nCompany careers pages via web"]
    end

    subgraph AI_Services["AI Services"]
        Claude["Anthropic Claude API\nHaiku: batch scoring\nSonnet: full JD analysis and tailoring"]
        AzureSearch["Azure AI Search\nF0 free tier\nSemantic resume and JD similarity"]
    end

    subgraph Hosting["Hosting"]
        GHPages["GitHub Pages\nStatic React application"]
        GHActions["GitHub Actions\nCI/CD: test, lint, deploy"]
    end

    PeelAway["PeelAway Logic\nMulti-phase agentic\njob search pipeline"]

    User -->|"Searches, scores, reviews, generates docs"| PeelAway
    PeelAway -->|"Fetch job listings"| Adzuna
    PeelAway -->|"Fetch job listings"| JSearch
    PeelAway -->|"Parse feeds"| RSS
    PeelAway -->|"Prompt for company-direct listings"| ATS
    PeelAway -->|"Scoring and tailoring prompts"| Claude
    PeelAway -->|"Semantic search queries"| AzureSearch
    PeelAway -.->|"Deployed to"| GHPages
    GHActions -.->|"Builds and deploys"| GHPages
```

---

## Container Diagram (C4 Level 2)

The internal structure of PeelAway Logic: what runs where, what stores what, and how the parts communicate.

```mermaid
graph TB
    subgraph Browser["Browser (React SPA, Create React App)"]
        Scout["Scout Phase\nResume upload + profile extraction\n3 search layers (Adzuna, JSearch, RSS, ATS)\nDedup, pre-filter, score, fetch JDs, re-score"]
        Review["Review Phase\nTiered results (Strong/Possible/Weak/Rejected)\nSort by score, date, company\nHuman Gate: explicit job selection"]
        Complete["Complete Phase\nResume + cover letter generation per job\nAnti-hallucination constraints\nDownload, copy, mark as applied"]
        Storage["localStorage\nPipeline state, applied jobs,\ndismissed jobs, search config"]
        AzureSearchClient["azureSearchService.js\nREST client for Azure AI Search\nNo SDK dependency"]
    end

    subgraph External["External Services"]
        ClaudeAPI["Anthropic Claude API\nHaiku: scoring\nSonnet: tailoring"]
        AzureSearchService["Azure AI Search\nF0 free tier"]
        JobAPIs["Job APIs\nAdzuna, JSearch, RSS"]
    end

    Scout --> Review
    Review --> Complete
    Complete --> Storage
    Scout -->|"Reads applied/dismissed"| Storage
    Scout --> AzureSearchClient
    Scout -->|"Scoring prompts"| ClaudeAPI
    Complete -->|"Tailoring prompts"| ClaudeAPI
    AzureSearchClient -->|"REST queries"| AzureSearchService
    Scout -->|"Fetch listings"| JobAPIs
```

---

## Pipeline Data Flow

The data contract between phases: what goes in, what comes out, and where the human gates sit.

```mermaid
flowchart TD
    A["Scout Phase\nInput: resume (PDF/TXT/paste), search filters\nProcess: extract profile, run 3 search layers (cap 10 each),\ndedup, pre-filter, score via Haiku, fetch JDs, re-score via Sonnet\nOutput: scored and ranked job array"]

    Gate1{{"Human Gate: Score & Review triggers scoring; results presented in tiers"}}

    B["Review Phase\nInput: ScoredJob array\nDisplay: Strong (8-10), Possible (6-7), Weak (3-5), Rejected (0-2)\nSort by score, date posted, or company\nOutput: user-selected shortlist"]

    Gate2{{"Human Gate: User selects jobs to advance, dismisses others"}}

    C["Complete Phase\nInput: Selected ScoredJob + resume\nProcess: generate resume and cover letter per job (one click, one API call each)\nAnti-hallucination: content grounded only in uploaded resume\nOutput: tailored documents + applied status in localStorage"]

    A --> Gate1 --> B --> Gate2 --> C
```

---

## Azure Integration Architecture

How Azure AI Search and the Semantic Kernel demo fit into the system.

```mermaid
graph LR
    subgraph PeelAway_Current["PeelAway Logic (Current)"]
        AzureClient["azureSearchService.js\nREST client pattern\nFetch + JSON, no SDK"]
        SKDemo["Semantic Kernel Demo\nPython, standalone\nPlugins: JobScoring, ResumeParser"]
    end

    subgraph Azure_Current["Azure (F0 Free Tier)"]
        SearchIndex["Azure AI Search\npeelaway-search\nIndex: resumes + job descriptions"]
    end

    subgraph Azure_Enterprise["Enterprise Migration Target"]
        SearchSDK["Azure AI Search SDK\n@azure/search-documents\nDefaultAzureCredential"]
        AOAI["Azure OpenAI\nGPT-4o deployment\nReplaces Claude API"]
        SKProd["Semantic Kernel Production\nPlugins as Azure Functions\nManaged Identity auth"]
        StaticWebApp["Azure Static Web Apps\nReplaces GitHub Pages\nStaging slots, custom domain"]
        CosmosDB["Azure Cosmos DB\nReplaces localStorage\nMulti-device sync"]
    end

    AzureClient -->|"GET /indexes/jobs/docs/search"| SearchIndex
    SKDemo -->|"claude-3-5-sonnet (swap-ready)"| ClaudeAPI["Anthropic Claude API"]

    AzureClient -.->|"Enterprise migration"| SearchSDK
    SKDemo -.->|"Swap 2 config lines"| AOAI
    SearchSDK --> SearchIndex
    AOAI --> SKProd
```

---

## Evolution Timeline

The architectural journey from disconnected AI tools to a governed agentic pipeline.

```mermaid
timeline
    title PeelAway Logic: Architectural Evolution
    section Mid-February 2026
        Genesis : Disconnected Gemini Gems
                : Manual copy-paste between phases
                : No data contracts, no gates, no tests
                : Hallucination risk in resume tailoring
    section Late February 2026
        Pivot : Rebuilt with Claude Code and React
              : Multi-phase pipeline architecture
              : Human gates at every phase transition
              : Structured output contracts between phases
              : localStorage persistence with dedup
    section March 2026
        Growth : 453 unit/component tests across 16 suites (Jest + RTL)
               : 62 E2E tests across 7 specs (Microsoft Playwright + Chromium)
               : CI/CD via GitHub Actions (4 workflows)
               : Anti-hallucination tests as first-class coverage
               : Doc-lint and env-audit quality enforcement
    section April 2026
        Azure Integration : Azure AI Search (F0, REST client)
                          : Semantic Kernel Python demo
                          : 6 Architecture Decision Records
                          : Bicep IaC documentation template
                          : Search layer caps: 10/layer, ~30 max, ~45s scoring
```

---

## Architecture Decisions

All architectural decisions are documented as ADRs in [decisions/](./decisions/).

| ADR | Decision | Status |
|---|---|---|
| [ADR-001](./decisions/ADR-001-claude-over-azure-openai.md) | Anthropic Claude over Azure OpenAI, with swap-ready design | Accepted |
| [ADR-002](./decisions/ADR-002-rest-client-over-sdk.md) | Client-side REST over Azure SDK | Accepted |
| [ADR-003](./decisions/ADR-003-human-gated-pipeline.md) | Human-gated pipeline over fully autonomous agents | Accepted |
| [ADR-004](./decisions/ADR-004-project-evolution-strategy.md) | Refactor from Gemini Gems to agentic architecture | Accepted |
| [ADR-005](./decisions/ADR-005-github-pages-hosting.md) | GitHub Pages over Azure Static Web Apps | Accepted |
| [ADR-006](./decisions/ADR-006-anti-hallucination-strategy.md) | Black-box deficiency prompt engineering strategy | Accepted |

---

## Standalone Diagram Files

Each diagram above is also available as a standalone `.mermaid` file in [diagrams/](./diagrams/) for use in documentation pipelines, presentation tools, and diagram renderers that accept raw Mermaid source.

| File | Diagram |
|---|---|
| [system-context.mermaid](./diagrams/system-context.mermaid) | C4 Level 1: System Context |
| [container-diagram.mermaid](./diagrams/container-diagram.mermaid) | C4 Level 2: Container Diagram |
| [pipeline-data-flow.mermaid](./diagrams/pipeline-data-flow.mermaid) | Pipeline Data Flow with Human Gates |
| [azure-integration.mermaid](./diagrams/azure-integration.mermaid) | Azure Integration and Enterprise Migration |
| [evolution-timeline.mermaid](./diagrams/evolution-timeline.mermaid) | Architectural Evolution Timeline |
