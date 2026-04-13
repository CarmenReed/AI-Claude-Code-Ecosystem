# ADR-012: Third-Party Payment Integration Architecture

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed  
**Pain point addressed:** Each payment gateway integration starting cold with high integration risk

---

## Context

SpaceGenius integrates with multiple payment gateways: NMI is in production, WorldPay is active, and Stripe is under evaluation. Each new gateway integration historically required weeks of context-building, multiple rounds of debugging, and significant developer uncertainty about undocumented API behaviors.

Carmen's NMI integration established a new pattern: AI-assisted development with black-box deficiency prompting, full API documentation ingestion, and structured output constraints before a single line of code was written. The result was 0% logic errors on the first production test run, a result that has never been achieved in 28 years of payment integration work at SpaceGenius.

The decision documents how to make that result repeatable for every future integration.

---

## Decision

Implement a reusable payment integration pattern codified in the CLAUDE.md integration library. The pattern includes:

1. **Pre-integration silo:** Before writing any code, create a dedicated Claude Code session (or notebook equivalent) for the new gateway. Feed it: the gateway's complete API documentation (links or PDF uploads), all meeting notes from integration planning sessions, and the existing NMI integration as a reference template.

2. **Black-box deficiency prompting:** System prompt instruction: "Before generating any integration code, identify all information you would need that is not provided in the documentation or meeting notes. Ask for clarification. Do not guess API parameter names, endpoint paths, or data formats."

3. **Key Vault MCP credential injection:** Gateway credentials (API keys, merchant IDs, terminal IDs) are retrieved from Key Vault via Managed Identity during the development session. Credentials never appear in code, chat history, or configuration files.

4. **CI validation:** ADO Pipelines runs integration tests against the gateway's sandbox environment on every PR. Integration logic is validated before it reaches staging.

**The NMI pattern is the reusable asset.** Every new gateway integration inherits its structure. The Stripe integration follows the NMI pattern, not a cold start.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| Claude Code + CLAUDE.md integration library + Key Vault MCP (chosen) | Zero new Azure resources, proven production result (NMI 0% logic errors), Key Vault MCP is Carmen's existing implementation | Pattern knowledge lives in CLAUDE.md; bus-factor risk if not maintained; requires Claude Code per developer |
| Copilot Enterprise + Key Vault MCP + AI Foundry prompt flow | Pattern stored as org-wide AI Foundry asset with evaluation metrics; any developer runs it without CLAUDE.md dependency | Copilot Enterprise and AI Foundry not provisioned |
| External integration platform (MuleSoft, Zapier) | Pre-built connectors for major gateways | Not the right tool for a custom .NET payment integration with proprietary API behaviors; significant licensing cost |
| Manual integration without AI assistance | No AI dependency | Historical approach; produced the integration errors and debugging cycles that motivated the AI-assisted approach |

---

## Consequences

**Positive:**
- The NMI 0% logic error result is now a documented, repeatable pattern, not a one-time outcome
- Black-box deficiency prompting prevents the most common integration failure mode: AI-hallucinated API parameters
- Key Vault MCP eliminates the last manual credential step in the integration workflow
- Future integrations (Stripe, future gateways) inherit the NMI pattern rather than starting cold

**Negative:**
- The integration library in CLAUDE.md must be updated after each new gateway integration; the pattern compounds in value only if it is maintained
- Bus factor: the pattern authoring and Key Vault MCP setup currently depends on Carmen

**Production evidence:** Carmen's NMI integration was the first payment gateway integration in SpaceGenius history where "the very first time I ever end-to-end tested the code, I didn't get an error." That is the production case for this architecture.

---

## Azure Migration Path

1. Provision GitHub Copilot Enterprise + Azure AI Foundry
2. Store the NMI integration pattern as an AI Foundry prompt flow with input parameters (gateway name, documentation URL, meeting notes)
3. Any developer runs the integration flow: it fetches the documentation, applies the black-box deficiency system prompt, and generates the integration scaffold grounded in the NMI pattern
4. The flow includes an evaluation step that scores the generated code against the integration rubric: no hardcoded credentials, no guessed API parameters, documented error handling for all gateway error codes
5. The Key Vault MCP Server remains: credential injection via Managed Identity is correct regardless of AI tooling
6. Bus factor is eliminated: the pattern is an org-wide AI Foundry asset, not a file on Carmen's machine
