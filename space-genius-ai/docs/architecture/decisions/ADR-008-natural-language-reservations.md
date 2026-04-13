# ADR-008: Customer-Facing Natural Language Reservation Architecture

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed  
**Pain point addressed:** Form-based reservation flow driving mobile conversion rate below customer expectations

---

## Context

The SpaceGenius reservation flow is form-based. Customers who want to express a reservation in natural language ("I need parking in Denver from the 15th to the 18th for a sedan") must navigate a multi-step form that asks for the same information in a less intuitive sequence. Mobile conversion suffers.

The solution requires a natural language intake that extracts structured reservation parameters from a single customer message and passes them to the existing booking API. The constraint is that SpaceGenius has no Copilot Studio subscription and no Azure Bot Service tier provisioned.

A key architectural observation: the customer reservation intake does not require multi-turn conversation in most cases. The customer provides location, dates, and vehicle type in a single message. Slot-filling within a single exchange handles the common case. The constraint of a stateless HTTP call is acceptable for the primary use case, with the existing form as fallback for ambiguous inputs.

---

## Decision

Implement a new HTTP-triggered Azure Function that accepts the customer's natural language reservation request. Claude API with an intent-classification and slot-filling system prompt extracts the structured parameters: `{ location, start_date, end_date, vehicle_type, special_requirements }`. The Function returns the typed parameters as JSON.

The UI renders a reservation confirmation card showing the interpreted parameters in human-readable form before the customer confirms. On confirmation, the existing booking API layer creates the reservation. On rejection or ambiguity (missing required parameters), the UI falls back to the form-based flow with the extracted parameters pre-populated.

No reservation is created without customer confirmation. The human approval gate is preserved.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| Azure Functions HTTP + Claude API slot-filling (chosen) | No new Azure services, handles the common case (complete information in one message), stateless design is simple and testable | Single-exchange slot-filling breaks when customer input is ambiguous or incomplete; no multi-channel support |
| Azure Copilot Studio | Multi-turn conversation handles ambiguity natively, visual dialog authoring, web + mobile + Teams from one config, conversation analytics | Copilot Studio not provisioned; requires new subscription approval |
| Azure Bot Service | Multi-channel bot deployment, Teams integration, structured conversation flows | Bot Service not provisioned; requires setup investment beyond the sprint window |
| Embedded form with AI pre-fill | Familiar UX, no new infrastructure | Does not address the natural language input experience; customers still interact with a form |

---

## Consequences

**Positive:**
- Customers can initiate a reservation in natural language on mobile without navigating a multi-step form
- Single-exchange design is stateless, simple to implement in an existing Function, and easy to test
- Fallback to the pre-populated form preserves conversion for ambiguous inputs
- No new Azure resources required

**Negative:**
- Single-exchange slot-filling breaks when a customer provides contradictory or incomplete information across multiple messages
- No multi-channel support: web only, no SMS or Teams
- Third-party data egress to Anthropic servers for customer-provided reservation data

**Accepted constraint:** The single-exchange limitation is acceptable for the MVP. The form fallback handles ambiguous cases. Multi-turn conversation (via Copilot Studio) is the Phase 5 upgrade.

---

## Azure Migration Path

1. Provision Azure Copilot Studio with an Azure OpenAI backing model
2. Author the reservation dialog as a Copilot Studio topic with multi-turn conversation flows
3. Multi-turn handles: missing parameters (bot asks follow-up questions), contradictory dates (bot asks for clarification), special requirements (bot offers available options)
4. Azure Bot Service channel configuration adds SMS and Teams delivery for the same dialog at no additional authoring cost
5. Conversation analytics surface drop-off points in the reservation flow, enabling data-driven dialog improvement
6. The existing booking API integration is unchanged: the typed reservation parameters still POST to the same endpoint
