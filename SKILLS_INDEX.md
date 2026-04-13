# AI Skills Index

**Author:** Carmen Reed  
**Last Updated:** April 12, 2026  
**Purpose:** Inventory of production-proven AI skills, patterns, and architectural decisions across both portfolio initiatives.

---

## Skill Categories

### 1. Agentic Pipeline Architecture

| Skill | Production Evidence | Azure Path |
|---|---|---|
| Multi-phase human-gated pipelines | PeelAway Logic: Scout, Review, Complete phases (4-phase pipeline) with explicit human approval gates | Azure AI Foundry prompt flows with approval steps |
| Anti-hallucination prompt engineering | PeelAway Logic: black-box deficiency prompting, strict output constraints, 0% fabrication rate on resume tailoring | Azure AI Content Safety + Foundry evaluation metrics |
| Recursive AI-assisted refinement | PeelAway architecture iterated using Claude Code agents auditing their own output | Azure AI Foundry evaluation pipeline |
| Context window management | Resume + job description combined into single grounded prompt to prevent hallucination | Azure AI Foundry RAG with Azure AI Search |

### 2. Azure AI Services

| Skill | Production Evidence | Azure Path |
|---|---|---|
| Azure AI Search integration | PeelAway Logic: REST client against F0 free tier, resume + JD semantic similarity | Full SDK with DefaultAzureCredential + Managed Identity |
| Microsoft Playwright E2E testing | PeelAway Logic: 62 E2E tests across 7 specs, network-level API mocking via page.route(), CI/CD integration with Chromium | Azure DevOps Pipelines with Playwright Test |
| Semantic Kernel orchestration | PeelAway SK Python demo: pipeline phases as SK plugins, swap-ready for Azure OpenAI | Production SK with Azure OpenAI, Managed Identity, function calling |
| Azure Functions event-driven AI | SpaceGenius: HTTP-triggered functions as Claude API proxy, timer-triggered pricing intelligence | Logic Apps native connectors + Azure OpenAI |
| Service Bus event chaining | SpaceGenius: ADO webhook to Service Bus topic to chained Function subscribers | Full Logic Apps workflow with run history audit |
| Key Vault + Managed Identity | SpaceGenius: Key Vault MCP Server, API keys never in code or on dev machines | DefaultAzureCredential across all Azure services |

### 3. Architecture Documentation

| Skill | Production Evidence | Azure Path |
|---|---|---|
| Architecture Decision Records (ADRs) | 18 ADRs across both initiatives, each with trade-off tables and Azure Migration Path | Azure Architecture Center ADR templates |
| C4 architecture diagrams | PeelAway: system context, container, pipeline flow, Azure integration, evolution timeline | Azure Architecture diagrams |
| IaC documentation | PeelAway Bicep template documents 7 enterprise Azure resources | Bicep modules with parameter files, Deployment Environments |
| Governance enforcement | Doc-lint CI workflow, em-dash rules, broken link checks, stale version detection | Azure DevOps branch policies + quality gates |

### 4. Legacy Modernization

| Skill | Production Evidence | Azure Path |
|---|---|---|
| Strangler Fig extraction | SpaceGenius NMI integration: isolated payment gateway with clean API boundary | Azure API Management gateway layer |
| AI-assisted dependency auditing | SpaceGenius: Claude Code with full CLAUDE.md context maps deprecated APIs before migration | Copilot Enterprise + .NET Upgrade Assistant |
| ARM template parameterization | SpaceGenius: environment slots (dev/staging/prod) via ARM template functions | Bicep module decomposition |
| CI/CD for .NET modernization | SpaceGenius: ADO Pipelines multi-target build (net8.0 + net10.0) catching regressions per PR | Azure Pipelines with environment gates |

### 5. Developer Productivity and SDLC Automation

| Skill | Production Evidence | Azure Path |
|---|---|---|
| AI-generated test suites | PeelAway: 453 unit/component tests (16 suites, Jest) + 62 E2E tests (7 specs, Playwright); SpaceGenius: Claude Code /generate-tests slash command from Gherkin ACs | Copilot Workspace PBI-to-PR loop |
| Automated PR descriptions | SpaceGenius: /create-pr slash command from git diff + ADO ticket link | Copilot Enterprise whole-repo context |
| Requirements ingestion pipeline | SpaceGenius doc pipeline: raw meeting notes to BRD/FRD/LOE/Gherkin ACs via Claude API | Azure AI Foundry prompt flow + ADO native connector |
| Velocity-grounded estimation | SpaceGenius: ADO Analytics OData feed + Claude API generates granular estimate with confidence range | Azure OpenAI fine-tuned on team velocity data |
| CLAUDE.md knowledge architecture | SpaceGenius: structured knowledge base auto-updated on every deploy, Claude Code as natural language query interface | Azure AI Foundry RAG + Copilot Studio bot |

### 6. Compliance and Governance

| Skill | Production Evidence | Azure Path |
|---|---|---|
| PCI-compliant payment architecture | PeelAway Logic and SpaceGenius: NMI, WorldPay, Authorize.Net integrations with 0% logic errors | Azure Payment HSM, Azure Key Vault, PCI DSS compliance center |
| Human approval gates | Both initiatives: no autonomous execution of financial or user-facing changes without human review | Logic Apps approval connectors, Azure Managed Applications |
| Traceability matrices | SpaceGenius ADO: every business request linked to a technical implementation artifact | ADO work item hierarchy, Azure Boards queries |
| Documentation quality enforcement | PeelAway CI: doc-lint.js checks em-dash violations, broken links, stale versions | Azure DevOps branch policies with custom quality gates |

---

## Neuro-Inclusive Design Principles Applied

Carmen's AI systems are explicitly designed to reduce cognitive load:

- Binary visual logic for complex workflows (yes/no gates, not prose descriptions)
- Automated executive-function tasks (documentation generation, ticket creation, dependency mapping)
- Structured output over free-form narrative wherever AI produces content consumed by developers
- Bullet-first formatting in all AI-generated content

These are not personal preferences. They are a production-proven principle that compound their value when AI is coaching 10+ engineers simultaneously.
