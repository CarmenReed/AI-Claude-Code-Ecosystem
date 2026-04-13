# ADR-003: Backlog Deduplication Architecture

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed  
**Pain point addressed:** Duplicate and near-duplicate ADO tickets consuming developer time

---

## Context

The SpaceGenius ADO backlog accumulates duplicate tickets because new work items are created without checking existing items. The duplication is semantic, not lexical: two tickets describing the same bug or feature use different wording and are not caught by simple string matching. Developers occasionally work duplicated work without knowing it.

The solution requires semantic similarity detection on incoming PBIs against the existing backlog. The constraint is that SpaceGenius has no Azure AI Search (no persistent vector index) and must perform semantic comparison another way.

---

## Decision

Add a new Service Bus topic (`ticket-triage`) and subscription to the existing Service Bus namespace (new ARM resource block, same namespace tier, no additional cost). Configure an ADO webhook to POST to the Service Bus topic on every new PBI creation. A new Azure Function subscriber fetches the last 90 days of backlog via ADO REST API. Claude API performs semantic comparison in-context. Duplicates are flagged in ADO with links to the existing items.

The 90-day scope limit is an explicit architectural constraint, not an oversight. Large full-backlog context would exceed Claude's token window. The 90-day window covers 99% of actionable duplicates: items older than 90 days are either completed, closed, or accepted as distinct items.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| Service Bus extension + Azure Function + Claude API (chosen) | Uses only provisioned resources, extends existing namespace with no new tier cost | 90-day scope limit; Claude API token cost on every new PBI; semantic quality limited by context window |
| Azure AI Search vector index + Service Bus + Functions | Persistent index, no scope limit, no LLM token cost per check, full backlog coverage | Azure AI Search not provisioned; requires indexing pipeline and ongoing index maintenance |
| ADO native duplicate detection | Zero additional infrastructure | Does not exist as a feature; ADO has no built-in semantic similarity detection |
| Manual triage review before PBI acceptance | Zero infrastructure | Does not scale; Jessica already has full QA queue; adding backlog review is not feasible |

---

## Consequences

**Positive:**
- Duplicate detection runs automatically on every new PBI without developer action
- Related item linking reduces the likelihood of parallel work on overlapping features
- Extends the existing Service Bus namespace with no new Azure cost tier

**Negative:**
- 90-day scope limit means very old duplicates are not detected
- Claude API semantic comparison costs tokens per check; at high PBI creation rates, this accumulates
- Semantic quality depends on in-context comparison; purpose-built vector similarity would be more precise

**Accepted constraint:** The 90-day scope limit is the correct architectural trade-off given the available tools. It is documented as a known limitation with a clear upgrade path.

---

## Azure Migration Path

1. Provision Azure AI Search with a vector index over the full ADO backlog
2. ADO webhook still fires to Service Bus on new PBI creation
3. The Function subscriber uses the Azure AI Search vector similarity API instead of Claude API in-context comparison
4. Full backlog coverage with no scope limit and no LLM token cost per comparison
5. Duplicate detection is faster, more precise, and cheaper per check
6. The 90-day scope limit is eliminated entirely
