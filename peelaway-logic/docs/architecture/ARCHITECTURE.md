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

    User -->|"Searches, scores, reviews, tailors"| PeelAway
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
    subgraph Browser["Browser (React SPA)"]
        Scout["Scout Phase\nRole criteria input\nSearch configuration builder"]
        Search["Search Phase\nLayer 1: Adzuna + JSearch\nLayer 2: RSS feeds\nLayer 3: ATS web search\nDedup and merge"]
        Review["Review Phase\nBatch scoring via Claude Haiku\nFull JD fetch for top 5\nRe-score via Claude Sonnet"]
        Tailor["Tailor Phase\nResume PDF upload\nGrounded tailoring via Claude Sonnet\nAnti-hallucination constraints"]
        Complete["Complete Phase\nApplication record saved\nApplied/dismissed tracking"]
        Storage["localStorage\nasp-applied-jobs\njsp-dismissed-jobs\nSearch configuration cache"]
        AzureSearchClient["azureSearchService.js\nREST client for Azure AI Search\nNo SDK dependency"]
    end

    subgraph External["External Services"]
        ClaudeAPI["Anthropic Claude API"]
        AzureSearchService["Azure AI Search\nF0 free tier"]
        JobAPIs["Job APIs\nAdzuna, JSearch, RSS"]
    end

    Scout --> Search
    Search --> Review
    Review --> Tailor
    Tailor --> Complete
    Complete --> Storage
    Search -->|"Reads applied/dismissed"| Storage
    Search --> AzureSearchClient
    Review -->|"Scoring prompts"| ClaudeAPI
    Tailor -->|"Tailoring prompts"| ClaudeAPI
    AzureSearchClient -->|"REST queries"| AzureSearchService
    Search -->|"Fetch listings"| JobAPIs
```

---

## Pipeline Data Flow

The data contract between phases: what goes in, what comes out, and where the human gates sit.

```mermaid
flowchart TD
    A["Scout Phase\nInput: role title, location, seniority, keywords\nOutput: SearchConfig object"]

    Gate1{{"Human Gate: Review and confirm search configuration"}}

    B["Search Phase\nInput: SearchConfig\nProcess: Layer 1 + 2 + 3, dedup, cap at 10 per layer\nOutput: RawJob array, max ~30 items"]

    Gate2{{"Human Gate: Review search results summary"}}

    C["Review Phase\nInput: RawJob array\nProcess: batch score via Haiku, promote top 5\nFetch full JDs, re-score via Sonnet\nOutput: ScoredJob array with rationale and rank"]

    Gate3{{"Human Gate: User selects jobs to tailor, dismisses others"}}

    D["Tailor Phase\nInput: Selected ScoredJob + resume PDF\nProcess: ground tailoring prompt in resume content only\nOutput: TailoredResume object, no invented content"]

    Gate4{{"Human Gate: User reviews and approves tailored content"}}

    E["Complete Phase\nInput: Approved TailoredResume + ScoredJob\nProcess: save to localStorage, mark as applied\nOutput: persistent application record"]

    A --> Gate1 --> B --> Gate2 --> C --> Gate3 --> D --> Gate4 --> E
```

---

## Azure Integration Architecture

How Azure AI Search and the Semantic Kernel demo fit into the system.

```mermaid
graph LR
    subgraph PeelAway_Current["PeelAway Logic (Current)"]
        AzureClient["azureSearchService.js\nREST client pattern\nFetch + JSON, no SDK"]
        SKDemo["Semantic Kernel Demo\nPython, standalone\nPlugins: Scout, Score, Tailor"]
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
    section October 2025
        Genesis : Disconnected Gemini Gems
                : Manual copy-paste between phases
                : No data contracts, no gates, no tests
                : Hallucination risk in resume tailoring
    section November 2025
        Pivot : Rebuilt with Claude Code and React
              : Multi-phase pipeline architecture
              : Human gates at every phase transition
              : Structured output contracts between phases
              : localStorage persistence with dedup
    section December 2025 to February 2026
        Growth : 346 tests across 15 test files
               : CI/CD via GitHub Actions (3 workflows)
               : Anti-hallucination tests as first-class coverage
               : Doc-lint quality enforcement
    section March to April 2026
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
