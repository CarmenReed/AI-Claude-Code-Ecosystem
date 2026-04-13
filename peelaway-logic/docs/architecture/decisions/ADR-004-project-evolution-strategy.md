# ADR-004: Refactor from Gemini Gems to Agentic Pipeline Architecture

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed

---

## Context

The origin of PeelAway Logic was a set of disconnected Gemini Gems: individual AI instances, each configured with a specific persona and system prompt, used manually for different phases of the job search process. The Gem model had no mechanism for passing structured data between instances. Every hand-off required manual copy-paste.

The problems were architectural, not cosmetic:
- No data contract between phases (output format was freeform, not typed)
- No deduplication (same jobs appeared across searches)
- No quality gates (AI output could advance to application without human review)
- No test coverage (impossible to test a prompt-based workflow with no code)
- No observability (no record of which jobs had been processed)
- Hallucination risk in resume tailoring (no constraint preventing the AI from inventing experience)

The question was: rebuild on the same Gemini toolchain with better prompts, or migrate to a different architecture that could actually solve the structural problems?

---

## Decision

Rebuild as a React single-page application with Claude Code as the primary development tool, using a multi-phase agentic pipeline architecture with structured output contracts between phases, human gates at every transition, and full test coverage from the start.

The choice of Claude Code over Gemini Code Assist or other tools was based on three factors:

1. **CLAUDE.md context architecture.** Claude Code maintains full codebase context via a structured CLAUDE.md file. This allows the AI assistant to reason about the entire codebase when generating code, writing tests, or evaluating architectural decisions. Gemini's Gem model required manual context injection per session.

2. **Agentic subagent capabilities.** Claude Code can spawn specialized subagents for research, exploration, and planning tasks. This mirrors the pipeline architecture of PeelAway Logic itself: not a single AI doing everything, but specialized agents for specialized tasks.

3. **Alignment with the portfolio goal.** The goal was not just to build a better job search tool. It was to demonstrate agentic AI architecture in production. Building the tool with the same agentic principles it embodies makes the portfolio story coherent.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| Improve Gemini Gems with better prompts | Zero rebuild cost, familiar toolchain | Does not solve the structural problems: no data contracts, no tests, no dedup, no gates; better prompts in a broken architecture is polishing a broken architecture |
| Rebuild on OpenAI Assistants API | Persistent threads, built-in memory, function calling | No Claude Code equivalent for development tooling; less alignment with Microsoft portfolio story; no CLAUDE.md equivalent for context management |
| Rebuild on Azure AI Foundry | Microsoft-native, prompt flow architecture, eval tooling | Not available as personal free tier at time of decision; requires Azure OpenAI deployment; adds infrastructure cost and setup time |
| Current: React SPA with Claude Code | Full test coverage from day one, structured pipeline, human gates, CLAUDE.md context, agentic development tooling | Claude API is not Azure-native; requires SK demo to tell the Microsoft AI story separately |

---

## Consequences

**Positive:**
- Rebuilt with comprehensive test coverage from the first sprint (now 434 unit/component tests + 62 E2E tests), covering every layer and phase
- Data contracts between phases eliminate the copy-paste and format ambiguity of the Gem model
- Claude Code's CLAUDE.md architecture means every development session starts with full project context, not a cold start
- The project can be documented, tested, and maintained like production software, not like a collection of prompts

**Negative:**
- Complete rebuild from the Gem-based toolchain: no code reuse, time investment significant
- Two parallel AI stories required for the portfolio: Claude Code for the pipeline, Semantic Kernel for the Microsoft AI demo

**Validation:**
PeelAway Logic has been used to find and score real job opportunities. The system works as designed in production.

---

## Azure Migration Path

In a Microsoft enterprise deployment, the architectural patterns transfer directly. The specific tools change:

1. The multi-phase pipeline becomes an Azure AI Foundry prompt flow with the same phase sequence: Scout, Review, Complete
2. The CLAUDE.md knowledge architecture becomes a RAG index in Azure AI Search, updated via a DevOps pipeline step on every deploy
3. The human gate UI becomes Azure Logic Apps approval connectors or Teams adaptive card approvals for enterprise integration
4. Claude Code as the development tool becomes GitHub Copilot Enterprise with full repo context, eliminating the manual CLAUDE.md authoring burden
5. The test suite structure (phase-level tests, contract validation tests, anti-hallucination assertion tests) carries over unchanged; only the mocking strategy adapts to Azure SDK patterns
