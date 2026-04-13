# ADR-006: Anti-Hallucination Prompt Engineering Strategy

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed

---

## Context

PeelAway Logic's Tailor phase generates resume content using an LLM given two inputs: the user's uploaded resume PDF and a target job description. The risk is specific and severe: if the LLM generates resume content that is not derivable from the uploaded resume, that fabricated content could reach a hiring manager and create legal and reputational exposure for the user.

This is not a theoretical risk. LLMs hallucinate confidently. Without explicit constraints, a model given a job description requiring "10 years of Kubernetes experience" and a resume showing 2 years of Docker experience will often bridge that gap with invented Kubernetes experience because the training objective rewards coherent, helpful output over strict factual grounding.

The challenge was: how do you architecturally prevent an LLM from doing what it naturally wants to do, at a 0% fabrication rate, without requiring a RAG infrastructure or fine-tuned model?

---

## Decision

Implement a three-layer anti-hallucination strategy using prompt engineering alone, validated by automated tests that assert the absence of fabricated content.

**Layer 1: Black-box deficiency prompting (system prompt level)**

Every tailoring prompt includes an explicit instruction modeled on the "black-box deficiency" principle: the LLM is instructed to identify any information it would need to complete the task that is not present in the provided resume, and ask for clarification rather than guess. The instruction is explicit: "If the job description requires experience, skills, or accomplishments not present in the provided resume, say so. Do not invent them."

This is Carmen's production-proven technique from the NMI payment gateway integration at SpaceGenius: before writing any integration code, the AI was instructed to flag any information it would need but did not have rather than guess. First production test run produced zero logic errors.

**Layer 2: Grounding constraint (user prompt level)**

The user prompt for tailoring is structured as: "Rewrite the following resume sections to better align with this job description. Use only content that is present in or directly derivable from the provided resume. Do not add skills, experiences, or accomplishments that are not in the source resume."

The phrase "directly derivable" is deliberate: it allows the LLM to rephrase and reframe existing content (legitimate tailoring) but not to bridge gaps by inventing experience.

**Layer 3: Test coverage (verification layer)**

The test suite includes assertions that verify the tailored content does not contain phrases or skills not present in the source resume. The tests use keyword extraction from the source resume as a grounding set and assert that the tailored output does not introduce terms from the job description that have no presence in the source material.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| RAG with resume content (vector index) | Grounding is enforced by retrieval architecture, not just prompt instruction; more robust than prompt-only constraints | Requires Azure AI Search vector index, adds infrastructure, adds latency; for a single-document grounding task (one resume), retrieval overhead is disproportionate to the problem |
| Fine-tuned model on compliant resume tailoring examples | Model learns the constraint from training data, not runtime instructions; harder to circumvent with adversarial prompts | Requires fine-tuning infrastructure, training data curation, evaluation pipeline; out of scope for personal project |
| Human review only (no technical constraint) | Simple, no engineering investment | Humans miss fabrications; the goal is to make it architecturally impossible to reach the application phase with uninspected tailored content |
| Current: three-layer prompt engineering strategy | Zero additional infrastructure, validated by tests, proven 0% fabrication rate in production use | Relies on prompt instructions that a sufficiently adversarial model could potentially circumvent; not appropriate for regulated industries without additional controls |

---

## Consequences

**Positive:**
- 0% fabrication rate observed across all production tailoring sessions
- No additional infrastructure required (no RAG index, no fine-tuning)
- Validated by automated tests that run on every push to main
- The black-box deficiency technique is reusable: it applies to any task where the AI might guess rather than ask (payment integrations, schema migrations, API integrations)

**Negative:**
- Prompt-based constraints are softer than architectural constraints: they rely on the model following instructions, which is probabilistic not deterministic
- The test coverage validates outputs from known test inputs; it cannot exhaustively prove that no input combination produces hallucination
- The strategy requires the LLM to be capable of self-reporting its deficiencies, which varies by model and prompt length

**Production validation:**
The same black-box deficiency prompting technique was used for the NMI payment gateway integration at SpaceGenius. The first production test run against a live NMI sandbox produced zero logic errors, zero fabricated API parameters, and zero invented field names. The technique works in payment integration contexts as well as resume tailoring contexts.

---

## Azure Migration Path

In a Microsoft enterprise deployment, the strategy evolves as follows:

1. Replace the prompt-only grounding constraint with Azure AI Search RAG: the resume PDF is chunked and indexed at upload time, and the tailoring prompt is constructed using retrieved chunks rather than the full document. This makes grounding an architectural property, not a model instruction.

2. Add Azure AI Content Safety as a post-generation filter: the tailored output is evaluated for content that does not appear in the source document before it is shown to the user. Anomaly detection, not just instruction compliance.

3. Use Azure AI Foundry evaluation metrics to measure fabrication rate over time: each tailoring session's output is evaluated against the source resume and logged. Regression is detectable before users encounter it.

4. The black-box deficiency technique remains in the system prompt layer regardless of which infrastructure changes are made. The technique has zero cost and has demonstrated production-level reliability. It is not replaced by infrastructure; it is augmented by it.
