# AI Architecture Portfolio: Carmen Reed

**Role Target:** Principal Software Engineer, AI Focus | Microsoft  
**Interview:** April 15, 2026  
**Author:** Carmen Reed, Solutions Architect, decades of enterprise delivery

---

## Portfolio Overview

This repository is the architectural evidence base for two production AI initiatives. Both demonstrate hands-on, architecture-first AI delivery under real constraints: compliance requirements, legacy systems, budget limits, and production traffic.

| Initiative | Domain | Primary Azure Story |
|---|---|---|
| [PeelAway Logic](./peelaway-logic/README.md) | Agentic job search pipeline | Azure AI Search, Semantic Kernel, human-gated RAG |
| [SpaceGenius AI](./space-genius-ai/README.md) | Enterprise SDLC and product AI transformation | Azure Functions, Service Bus, ADO integration, ARM/Bicep |

---

## What This Portfolio Demonstrates

### Architectural Design Decisions
Every significant choice is documented in Architecture Decision Records (ADRs) with explicit trade-off analysis, alternatives considered, and an Azure Migration Path section showing what changes at enterprise scale. The gap between the pragmatic decision and the enterprise-ideal is not a gap in knowledge. It is a documented constraint with a clear upgrade path.

### System Thinking
Both initiatives required reasoning across the full system: cost, performance, compliance, team capability, and toolchain constraints. The PeelAway Logic pipeline evolved from disconnected AI tools to a multi-phase agentic architecture with 453 unit/component tests (Jest), 62 E2E tests (Microsoft Playwright), CI/CD, and cloud search integration. The SpaceGenius initiative maps 12 production pain points to solutions that use only provisioned Azure resources, paired with the enterprise vision that full Azure AI licensing unlocks.

### AI Experience in Production
- 1.5 years of production AI at SpaceGenius: automated onboarding, PR review, backlog triage, retrospective synthesis
- PeelAway Logic: anti-hallucination prompt engineering with 0% fabrication constraint on resume tailoring
- NMI payment gateway integration delivered 0% logic errors on first production test run using AI-assisted architecture
- Semantic Kernel demo showing the PeelAway pipeline logic running on Microsoft AI orchestration
- Azure AI Search integration with REST client pattern, swap-ready for Azure SDK with Managed Identity

---

## Repository Structure

```
AI-Claude-Code-Ecosystem/
  peelaway-logic/                     # Agentic job search pipeline
    README.md                         # Project overview and links
    PROJECT_EVOLUTION.md              # Technical narrative: Gemini to Azure AI
    docs/
      GOVERNANCE.md                   # Documentation standards and CI quality gates
      architecture/
        ARCHITECTURE.md               # C4 overview with embedded and linked Mermaid diagrams
        azure-resources.bicep         # IaC documentation template (7 Azure resources)
        decisions/                    # 6 Architecture Decision Records with Azure Migration Paths
        diagrams/                     # 5 standalone Mermaid diagram files

  space-genius-ai/                    # Enterprise AI transformation initiative
    README.md                         # Initiative overview with 12 pain point index
    AI_TRANSFORMATION_ROADMAP.md      # Phased 12-month implementation roadmap
    docs/
      GOVERNANCE.md                   # Documentation standards and review process
      PROJECT_EVOLUTION.md            # Production AI narrative: 1.5 years at SpaceGenius
      architecture/
        ARCHITECTURE.md               # C4 system overview with AI augmentation points
        AZURE_ENVIRONMENT_INVENTORY.md   # Current Azure asset analysis and leverage map
        SOLUTION_ARCHITECTURE.md         # 12 pain points: constrained solution and enterprise vision
        ENTERPRISE_VISION.md             # Full Azure AI target state with migration sequence
        decisions/                       # 12 Architecture Decision Records
        diagrams/                        # 4 system topology and flow diagrams
```

---

## Technology Stack

### PeelAway Logic
React (Create React App), Anthropic Claude API, Azure AI Search (F0 free tier), Semantic Kernel (Python demo), GitHub Pages, Jest (453 tests, 16 suites), Microsoft Playwright (62 E2E tests), GitHub Actions CI/CD, GitHub Copilot, Claude Code

### SpaceGenius (Production)
C# / .NET, ASP.NET Web API, React, SQL Server / SQL Managed Instance, Azure Functions, Azure App Services, Azure Service Bus, Azure Key Vault, Managed Identity, Azure DevOps Pipelines, ARM templates

---

## Elias Interview Mapping

| Elias Assessment Area | Evidence Location |
|---|---|
| Architectural Design Decisions: "explain why or why not" | All ADRs, each with Alternatives Considered and Azure Migration Path |
| System Thinking: systems-level reasoning, coaching ability | ARCHITECTURE.md diagrams, PROJECT_EVOLUTION.md, AI_TRANSFORMATION_ROADMAP.md |
| AI Experience: hands-on, production use | PROJECT_EVOLUTION.md sections 4-6, SpaceGenius SOLUTION_ARCHITECTURE.md, ADR-006 |
