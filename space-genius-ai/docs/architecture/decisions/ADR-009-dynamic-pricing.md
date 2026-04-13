# ADR-009: Dynamic Pricing Intelligence Architecture

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed  
**Pain point addressed:** Intuition-based pricing decisions leaving revenue on the table during high-demand periods

---

## Context

Parking facility operators make pricing decisions based on intuition or periodic manual review of reports. No system analyzes occupancy trends and recommends rate adjustments. High-demand events, seasonal patterns, and competitive rate changes pass without the pricing response that would maximize revenue.

The solution requires trend analysis over occupancy and transaction data and a pricing recommendation with rationale that a rate manager can review and approve. The constraint is that SpaceGenius has no Microsoft Fabric, no ML workspace, and no Power BI. All transaction data already exists in the SQL Managed Instance.

---

## Decision

Implement a timer-triggered Azure Function that runs on a configurable schedule (daily or weekly). The Function queries SQL MI with pre-aggregated views over occupancy and transaction data. The query output is a structured data package: current occupancy rates by location and time slot, transaction volume trends, historical pricing performance, competitive context (if available). Claude API analyzes the data package and returns a structured pricing recommendation: `{ location, recommended_change, current_rate, proposed_rate, confidence_level, rationale, supporting_data }`.

The recommendation is posted to a designated Teams channel via the free incoming webhook. The rate manager reviews the recommendation in Teams and approves or rejects via a reaction or response. Approval triggers the existing rate update API endpoint.

No rate change executes without rate manager approval. This is a hard architectural constraint.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| Azure Functions timer + SQL MI + Claude API + Teams webhook (chosen) | Uses only provisioned resources, Teams webhook is free, rate manager reviews in the tool they already use, SQL MI holds all necessary data | Claude API reasoning is static per prompt; no continuous improvement; no self-service analytics |
| Microsoft Fabric + Azure OpenAI + Power BI Copilot | Continuous ML improvement, self-service analytics for Rick, model learns team-specific patterns | Fabric and Azure OpenAI not provisioned; significant data engineering investment |
| Scheduled SQL report via email | Zero AI investment, familiar pattern | No trend reasoning, no recommendation, no rationale; Rick receives data but still interprets it manually |
| Manual pricing review with AI chat assist | No infrastructure investment | Not automatic; depends on rate manager initiative; no scheduled trigger |

---

## Consequences

**Positive:**
- Pricing decisions are informed by data analysis, not intuition
- Rate manager retains full control: no automated rate change execution
- Teams is the approval interface: rate managers work where they already are
- Zero additional Azure cost

**Negative:**
- Claude API analysis is static per prompt: the model does not improve over time based on pricing outcomes
- Pre-aggregated SQL views require maintenance as the database schema evolves
- No self-service analytics: Rick cannot ask follow-up questions about the recommendation

**Revenue case:** Even a 5% revenue improvement from data-informed pricing decisions on a $10M annual transaction volume justifies the development investment. The upside is measurable against the zero infrastructure cost.

---

## Azure Migration Path

1. Provision Microsoft Fabric: lakehouse ingests full transaction, occupancy, and historical rate data
2. Provision Azure OpenAI: fine-tune on SpaceGenius-specific pricing patterns (correlate rate changes to occupancy response, revenue impact, competitive movement)
3. The fine-tuned model improves recommendations over time: it learns which rate changes drove revenue increases and which did not
4. Power BI Copilot: Rick asks "what was the revenue impact of last month's rate changes?" without a developer or a scheduled report
5. The approval workflow moves from Teams webhook to a Logic Apps adaptive card: richer approval UX with structured feedback that feeds back into the model
