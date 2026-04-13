# ADR-011: Consultant Onboarding and Living Documentation Architecture

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed  
**Pain point addressed:** High onboarding cost for new consultants and contractors, knowledge residing in individuals rather than systems

---

## Context

SpaceGenius onboards new consultants and contractors regularly. The ramp-up time is 2 to 4 weeks before a new team member becomes productive. Documentation is sparse and outdated. Knowledge lives in the heads of senior engineers. Bus factor is high.

The solution requires documentation that stays current automatically (not dependent on developer initiative to update it) and is queryable in natural language (not requiring new team members to know where to look). The constraint is that SpaceGenius has no Azure AI Search, no AI Foundry, and no Copilot Studio.

---

## Decision

Implement a post-deploy ADO Pipelines step that triggers an Azure Function after every successful deployment. The Function diffs the release notes and the PR changed files against the existing CLAUDE.md knowledge base. Claude API identifies which knowledge base sections are affected by the changes and generates updated content. The updated CLAUDE.md is committed back to the repository.

Claude Code is the query interface for consultants: they ask natural language questions about the codebase and receive answers grounded in the CLAUDE.md knowledge base with full codebase context.

Azure Translator API free tier (2 million characters per month) localizes key onboarding sections on demand for Spanish-speaking contractors (Rosa, Alfredo).

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| ADO Pipelines + Azure Function + CLAUDE.md + Claude Code (chosen) | Uses only provisioned resources, auto-updated on every deploy, localization via free Azure Translator tier | Unstructured markdown search is less precise than vector similarity; requires Claude Code CLI access for queries |
| Azure AI Foundry RAG + vector index + Copilot Studio bot | Persistent vector index, always-precise retrieval, conversational bot accessible without CLI | AI Foundry, AI Search, and Copilot Studio not provisioned; requires multiple new resource approvals |
| SharePoint wiki manually maintained | No Azure AI cost, familiar interface | Requires developer initiative to update; documentation immediately starts drifting on every deploy |
| Confluence + AI plugin | Rich documentation platform, AI search available | Not part of the current Azure toolchain; additional license cost |

---

## Consequences

**Positive:**
- Documentation is always current: every deploy triggers an update to the affected sections
- Natural language queries via Claude Code reduce the "where do I look" friction for new team members
- Azure Translator localization for Rosa and Alfredo with no additional license cost
- Zero new Azure resources required

**Negative:**
- Claude Code CLI is required for natural language queries; new consultants must install and configure it
- Unstructured markdown search is less precise than a vector index: ambiguous queries may return less targeted results
- CLAUDE.md file size grows with the codebase; very large knowledge bases may approach context window limits

---

## Azure Migration Path

1. Provision Azure AI Search: the CLAUDE.md markdown knowledge base is indexed as a vector store
2. Every deploy triggers the same Function, but instead of updating CLAUDE.md, it updates the Azure AI Search index with new or modified documentation chunks
3. Queries are vector similarity searches against the index: precision improves significantly over markdown search
4. Provision Copilot Studio: consultants ask questions via a conversational bot without requiring Claude Code CLI access
5. The bot answers "how does the TransSafe iframe work?" with retrieved documentation chunks, not markdown file navigation
6. Azure AI Translator integration moves from free-tier markdown localization to real-time localization in the Copilot Studio bot response
