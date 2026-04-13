# ADR-002: Velocity-Grounded Estimation Architecture

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed  
**Pain point addressed:** Unpredictable estimates and ballpark pressure

---

## Context

Rick's pattern: ask for a ballpark estimate, receive one, hold the team to it. The team's pattern: give a ballpark without data because no data-grounded estimation tool exists. Deadlines slip. The cycle repeats.

The solution requires two things: historical velocity data that the team actually has, and an LLM to reason about what that data implies for the current story. The data already exists in ADO. The question is how to access it without a Power BI license or a Fabric workspace.

---

## Decision

Use the ADO Analytics OData endpoint (included free with every Azure DevOps subscription, no additional license) to query historical sprint velocity by task type. Package the velocity data with the current story description and work item details. Send to Claude API via an Azure Function. Claude returns a granular estimate with a confidence range and historical basis. Post the estimate back to the PBI as a structured comment.

The estimate format: point estimate (story points or hours), confidence range (low to high), historical basis (average cycle time for similar task type over last N sprints), and explicit caveats (blockers, unknowns, dependencies that widen the range).

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| ADO Analytics OData + Claude API via Function (chosen) | Zero additional cost, no new Azure resources, grounded in actual team velocity | Claude API analysis is static per prompt; does not learn from prior estimates |
| Power BI + ADO Analytics | Self-service visualization, Rick self-serves | Requires Power BI license; does not integrate Claude API reasoning; Rick still needs to interpret charts |
| Microsoft Fabric + Azure OpenAI fine-tuned model | Continuous improvement, learns team-specific patterns | Fabric and Azure OpenAI not provisioned; requires significant data engineering investment |
| Manual estimation with reference to prior sprint data | Zero infrastructure | Same bottleneck as today; does not solve Rick's ballpark pressure |
| ADO native estimation features | Built-in, no additional tooling | No AI reasoning layer; no confidence ranges; no connection to velocity trends |

---

## Consequences

**Positive:**
- Estimates grounded in actual team data, not intuition
- Confidence ranges replace point estimates that appear more certain than they are
- Rick gets predictability; the team is no longer held to guesses
- Zero additional Azure cost

**Negative:**
- Claude API reasoning does not improve over time; each estimate is independent
- Early sprints have limited historical grounding; estimate quality improves as sprint data accumulates
- The model cannot account for team capacity changes, vacations, or new developers

**Talking point for Rick:** "We cannot give you a ballpark. We can give you an estimate grounded in our historical velocity data with a stated confidence range. That is a fundamentally different thing."

---

## Azure Migration Path

1. Provision Azure OpenAI with a fine-tuned deployment trained on SpaceGenius sprint history
2. The fine-tuned model learns team-specific patterns: which types of tasks consistently take longer than estimated, which developers have higher velocity on which domains, which dependencies reliably introduce delays
3. Provision Power BI with Copilot: Rick asks "by when, with what confidence?" in plain English without opening a ticket or scheduling a meeting
4. The estimation loop closes: actual cycle time feeds back into the model, improving future estimates
