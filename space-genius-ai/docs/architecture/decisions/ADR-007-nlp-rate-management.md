# ADR-007: Natural Language Rate Management Architecture

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed  
**Pain point addressed:** Options / Rate page complexity requiring developer involvement for operator rate changes

---

## Context

Parking operators manage rates through a complex form-based UI. Non-technical operators frequently make errors navigating the rate configuration forms. Rate changes that should take 30 seconds require developer involvement when operators encounter confusion or edge cases.

The solution requires a natural language interface that translates an operator's plain English rate request into a typed data structure that the existing .NET rate update API can execute. The constraint is that SpaceGenius has no Azure OpenAI deployment and no Semantic Kernel backing model.

A critical architectural requirement regardless of implementation: no rate change executes automatically. The human approval gate is non-negotiable. Revenue impact and compliance risk make unreviewed automated rate changes unacceptable.

---

## Decision

Add a new NLP controller route to the existing App Service (same ARM deployment, new route, no new resource). The controller receives a plain English rate request. Claude API with a structured JSON output system prompt interprets the request and returns a typed `ChangeSet` object: `{ rate_type, location, value_type, value, effective_date, expiration_date, operator_notes }`.

The React UI renders the change preview using the structured ChangeSet before the operator confirms. The operator reviews the interpreted request in human-readable form ("Set weekend parking rate for downtown lot to $12.00/hour starting Friday April 18, no expiration"). On approval, the existing .NET data layer executes the change set against the database. On rejection, the operator revises their request.

No rate change executes without explicit operator approval. This is an architectural constraint, not a UX choice.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| App Service extension + Claude API structured output (chosen) | No new Azure resources, Claude API structured output is functionally equivalent to Semantic Kernel function calling, human approval gate preserved | Structured JSON output relies on prompt engineering rather than SDK-enforced type safety |
| Azure OpenAI + Semantic Kernel function calling | Strongly typed, testable, auditable function calls; data stays in tenant; plugin library grows reusably | Azure OpenAI not deployed; Semantic Kernel requires Azure OpenAI as backing model |
| Custom forms improvement | No AI dependency, reliable | Does not solve the fundamental usability problem; operators still navigate complex forms |
| Power Automate + Azure OpenAI + Forms | Low-code authoring | Azure OpenAI not deployed; Power Automate licensing unclear; not C#/.NET native |

---

## Consequences

**Positive:**
- Operators express rate changes in plain English rather than navigating forms
- Structured ChangeSet output is strongly enough typed for the existing .NET data layer
- Human approval gate prevents automated execution
- No new Azure resources required

**Negative:**
- Claude API structured JSON output lacks the compile-time type safety of Semantic Kernel function calling
- Prompt engineering must be maintained as the ChangeSet schema evolves
- Third-party data egress to Anthropic servers for rate management requests

---

## Azure Migration Path

1. Provision Azure OpenAI with a GPT-4o deployment
2. Replace the Claude API call in the App Service controller with an Azure OpenAI call using Managed Identity authentication
3. Implement the rate management interface as a Semantic Kernel plugin with strongly typed function parameters matching the ChangeSet schema
4. The plugin is testable, auditable, and type-safe: the compiler, not a prompt, enforces the output schema
5. The human approval gate is preserved unchanged: Semantic Kernel function calling still returns a typed preview before execution
6. The plugin library grows: additional Semantic Kernel plugins for other rate management operations (bulk rate changes, seasonal pricing templates) are added incrementally
