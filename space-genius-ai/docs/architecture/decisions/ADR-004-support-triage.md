# ADR-004: Support Ticket Triage Pipeline Architecture

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed  
**Pain point addressed:** HelpScout support tickets to ADO PBIs with Gherkin ACs

---

## Context

HelpScout receives customer support tickets. Those tickets are manually triaged, and complete enough items are manually copied into ADO as PBIs. Gherkin acceptance criteria are never generated for support-originated bugs. Jessica retests without clear scope. Development testing notes on support tickets are sparse.

The solution requires an automated pipeline from HelpScout ticket to ADO PBI with completeness validation, deduplication, and Gherkin AC generation. The constraint is that SpaceGenius has no Logic Apps and no Azure OpenAI.

---

## Decision

Implement a three-stage chained Azure Functions pipeline using the existing Service Bus namespace. HelpScout is configured with a webhook pointing to a Service Bus topic. Three separate Function subscribers process the event in sequence:

- Function 1: Completeness check via Claude API. If the ticket lacks required information (steps to reproduce, affected version, customer impact), the HelpScout API is called to send a canned clarification response to the customer. The event is requeued for re-evaluation after clarification.
- Function 2: Semantic dedup check against the ADO backlog (reuses the pattern from ADR-003).
- Function 3: Gherkin AC generation via Claude API. ADO REST API creates a PBI in design state with the ACs attached. SendGrid free tier (100 emails per day) notifies Jessica that a triage-ready PBI is waiting.

Human review is required before the PBI advances from design to ready.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| Chained Azure Functions + Claude API + Service Bus (chosen) | Uses only provisioned resources, C#/.NET is Carmen's native stack, no new Azure services required | No visual designer for Kathy to modify workflow, no built-in run history audit trail, manual REST code for HelpScout and ADO |
| Logic Apps + Azure OpenAI + native ADO and HelpScout connectors | Visual designer, native connectors, run history audit trail, Kathy self-serves | Logic Apps not provisioned, Azure OpenAI not deployed; requires both to be approved |
| Power Automate + HelpScout connector | Kathy-accessible visual designer, native HelpScout integration | Power Automate licensing unclear, Azure OpenAI not available |
| Manual triage with Claude chat assist | Zero infrastructure | Does not solve the pipeline problem; still requires manual ADO entry; Gherkin ACs still manually generated |

---

## Consequences

**Positive:**
- Every HelpScout ticket that passes completeness check and dedup produces a design-state ADO PBI with Gherkin ACs automatically
- Incomplete tickets trigger automatic clarification requests, reducing back-and-forth with developers
- Zero new Azure resources required

**Negative:**
- Kathy cannot modify the triage workflow without a developer deployment
- No built-in run history or audit trail; logging must be implemented explicitly in Function code
- SendGrid free tier (100 emails/day) is an additional dependency; high ticket volume would require upgrading to a paid tier

---

## Azure Migration Path

1. Provision Logic Apps Standard
2. Replace the chained Functions pipeline with a Logic Apps workflow using the native HelpScout connector and the native ADO connector
3. Kathy can modify triage rules (escalation conditions, canned response text) in the visual designer without a developer deployment
4. Logic Apps run history provides a compliance-grade audit trail of every ticket processed
5. Replace Claude API with Azure OpenAI for data residency
6. Replace SendGrid with an Azure Communication Services email action within Logic Apps
