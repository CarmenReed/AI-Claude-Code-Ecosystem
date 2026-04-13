# ADR-003: Human-Gated Pipeline over Fully Autonomous Agents

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed

---

## Context

PeelAway Logic is an agentic pipeline where AI makes scoring and tailoring decisions that directly affect the user's job search and career materials. The pipeline produces two categories of output with meaningfully different risk profiles:

**Scoring output:** A ranked shortlist of job descriptions with AI-generated rationale. If the scoring is wrong, the user spends time on a poor-fit opportunity or misses a good one. The consequence is wasted effort, recoverable.

**Tailoring output:** Resume content generated from the user's uploaded PDF and the job description. If the tailoring fabricates experience that is not in the resume, that fabricated content could reach a hiring manager. The consequence is reputational damage, not recoverable by undoing a click.

The question was: at what points does a fully autonomous agent create unacceptable risk, and what is the minimum gate structure that contains that risk without making the pipeline so slow that it offers no benefit over manual work?

---

## Decision

Implement a human gate at every phase transition. No phase output advances to the next phase without explicit user action.

The gate structure:

| Gate | User Action Required | Risk Contained |
|---|---|---|
| Scout to Search | User confirms search configuration | Prevents a misconfigured search from wasting API credits on irrelevant results |
| Search to Review | User reviews result summary | Prevents scoring a set of results that are obviously wrong (wrong location, wrong seniority) |
| Review to Tailor | User selects which jobs to tailor and dismisses the rest | Prevents resume tailoring for jobs the user has not consciously chosen |
| Tailor to Complete | User reviews and approves tailored content | Prevents fabricated or misaligned content from reaching an application |

The gates are implemented as UI state transitions. The pipeline does not advance programmatically. The user clicks to proceed.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| Fully autonomous pipeline | Fastest end-to-end, zero user interaction, scales to batch processing | Unacceptable risk for tailoring phase: fabricated resume content could reach hiring managers; no human accountability for scoring decisions |
| Autonomous with flags | Pipeline runs fully, flags anomalies for review | Humans review exceptions, not every output; exception detection logic is a second AI layer with its own error rate; cognitive overhead of reviewing flagged items is higher than reviewing all items at defined gates |
| Current: gates at every transition | Human reviews every phase output before proceeding | Slower than fully autonomous; optimal for high-stakes career materials where every decision warrants human judgment |
| Gates only at tailoring phase | Faster than all gates; highest-risk phase still gated | Search and scoring errors propagate unchecked; user may invest in reviewing scores without having vetted the search itself |

---

## Consequences

**Positive:**
- The user is never surprised by what the pipeline did in their absence
- Fabricated resume content is architecturally prevented from reaching the application phase
- Each gate provides a natural point for user course-correction: wrong search configuration caught before API credit spend; bad scoring caught before JD fetch
- The human-in-the-loop model is the correct default for any AI system affecting financial, legal, or reputational outcomes

**Negative:**
- Slower than a fully autonomous run; a full pipeline pass from Scout to Complete requires active user time at four gates
- Not suitable for high-volume batch processing without a redesign

**Evolution:**
The gate design evolved from hard blocking gates to a model where the user can choose to proceed quickly (approve all defaults) or pause and review. The cognitive load is kept low by presenting a structured summary at each gate, not raw AI output.

---

## Azure Migration Path

In a Microsoft enterprise deployment, this decision's implementation changes but the principle does not:

1. Implement the pipeline as an Azure AI Foundry prompt flow with explicit human approval steps between high-risk phases
2. Use Logic Apps approval connectors for the tailoring gate: an approval email or Teams adaptive card notifies the user that tailored content is ready for review
3. Collect approval decisions as events in Application Insights for audit trail
4. The autonomy model can evolve per phase: scoring may eventually run autonomously with flag-based review (high-confidence scores bypass the gate, low-confidence scores require it), while the tailoring gate remains a hard human requirement indefinitely

The principle scales to enterprise: no AI output with reputational or financial consequences should advance without human review. The implementation mechanism changes from a UI button to a workflow approval step. The architecture is the same.
