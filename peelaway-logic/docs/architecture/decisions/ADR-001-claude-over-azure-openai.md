# ADR-001: Anthropic Claude API over Azure OpenAI

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed

---

## Context

PeelAway Logic requires an LLM for three distinct tasks: batch job scoring (high volume, low cost), full job description analysis (medium volume, high quality), and resume tailoring (low volume, highest quality with strict anti-hallucination constraints).

At the time of this decision, Azure OpenAI required a subscription approval process and was not available as a free-tier option for a personal portfolio project. The project needed an LLM available immediately, with a free tier for development and a pay-per-token model for production usage within personal budget constraints.

The secondary constraint was the Semantic Kernel demo: demonstrating Microsoft AI orchestration fluency was a portfolio requirement, independent of which model backed the production pipeline.

---

## Decision

Use the Anthropic Claude API as the production LLM, with the Semantic Kernel Python demo designed to be swap-ready for Azure OpenAI by changing two configuration values.

Production model selection:
- Claude Haiku: batch scoring phase (high volume, cost-sensitive, quality threshold sufficient)
- Claude Sonnet: full JD analysis and resume tailoring (quality-sensitive, anti-hallucination critical)

The Semantic Kernel demo uses a kernel abstraction layer. The model provider is injected at configuration time. Replacing `anthropic/claude-sonnet-4-6` with an Azure OpenAI deployment endpoint requires changing the kernel builder configuration and updating the credential provider. No plugin code changes.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| Azure OpenAI | Microsoft tenant data residency, Managed Identity auth, Foundry eval tooling, production-standard for enterprise environments | Requires subscription approval, no free tier, approval not available during sprint window |
| OpenAI (GPT-4o direct) | High quality, well-documented, instant access | Third-party egress, no Microsoft story, same cost structure as Claude without the SK demo alignment |
| Gemini API | Free tier, fast, prior familiarity | Disconnected Gem model was the pain point this project was built to solve; no SK alignment; weaker function calling than Claude |
| Local model (Ollama) | Zero cost, no egress | Cannot run on GitHub Pages; requires server infrastructure; quality insufficient for resume tailoring |

---

## Consequences

**Positive:**
- Immediate availability with no approval process
- Free development tier, pay-per-token production pricing
- Claude Haiku is cost-optimal for batch scoring at approximately $0.25 per million input tokens
- The SK demo decouples the portfolio AI story from the model choice, demonstrating Microsoft AI orchestration fluency independently

**Negative:**
- Data egresses to Anthropic servers, not a Microsoft tenant
- No Managed Identity authentication; API key must be managed in environment configuration
- Azure OpenAI fine-tuning and evaluation tooling not available

**Risk mitigation:**
- API key stored in environment variables, never committed to source
- The SK demo's swap-ready design means this decision is reversible in under one hour

---

## Azure Migration Path

In a Microsoft enterprise deployment, this decision changes as follows:

1. Provision an Azure OpenAI resource in the target subscription with a GPT-4o deployment
2. Replace the Anthropic API key reference in the SK kernel builder with an `AzureOpenAIChatCompletion` service using `DefaultAzureCredential`
3. Update the Semantic Kernel demo's configuration to point to the Azure OpenAI endpoint and deployment name
4. No plugin code changes required
5. Enable Azure AI Content Safety as an additional anti-hallucination layer alongside the existing prompt constraints
6. Use Azure AI Foundry evaluation metrics to measure tailoring quality over time

The production pipeline React code would require updating the Claude API call pattern to use the Azure OpenAI REST API format. The model abstraction currently exists only in the SK demo, not in the React application. A full enterprise migration would introduce a server-side API layer (Azure Functions) to abstract the LLM provider from the front end, eliminating the API key browser exposure entirely.
