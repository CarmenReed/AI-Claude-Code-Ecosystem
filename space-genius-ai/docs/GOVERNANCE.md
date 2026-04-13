# Documentation Governance

**Author:** Carmen Reed  
**Date:** April 12, 2026  
**Scope:** SpaceGenius AI initiative documentation standards, quality gates, and review process

---

## Why Documentation Governance Exists

The SpaceGenius AI transformation spans 12 production pain points, 12 ADRs, 4 system diagrams, an enterprise vision, and a 12-month implementation roadmap. Documentation at this scale degrades without enforced standards: terminology drifts, links break, em-dashes appear, and the gap between what the document says and what the system does widens.

This governance document defines the standards that apply to all documentation in the SpaceGenius AI initiative and the review process that enforces them before any document is shared with a stakeholder.

The same discipline that governs the PeelAway Logic portfolio ([peelaway-logic/docs/GOVERNANCE.md](../../peelaway-logic/docs/GOVERNANCE.md)) applies here with SpaceGenius-specific terminology additions.

---

## Writing Standards

### No Em-Dashes

Em-dashes are prohibited in all documentation. This is an absolute rule with no exceptions.

**Why:** Em-dashes interrupt reading flow for users with screen readers and create parsing ambiguity in structured documents. Every sentence that relies on an em-dash can be rewritten with a comma, a colon, a period, or a sentence break.

**Alternatives:**
- Use a comma for a parenthetical aside
- Use a colon to introduce a list or elaboration
- Use a period to split into two sentences
- Use parentheses for supplemental information

### Consistent Terminology

| Preferred Term | Do Not Use |
|---|---|
| SpaceGenius | Space Genius, SG |
| Azure Functions | Function Apps, Functions App |
| Azure AI Foundry | AI Studio, Azure AI Studio |
| Azure OpenAI | OpenAI, AOAI (in prose) |
| GitHub Copilot Enterprise | Copilot, CoPilot |
| Managed Identity | MSI, Service Principal (unless distinguishing) |
| Architecture Decision Record (ADR) | decision doc, design doc |
| human gate | approval gate, checkpoint (use human gate) |
| constrained solution | current solution, workaround |
| enterprise vision | ideal solution, future state (use enterprise vision) |
| pain point | issue, problem, challenge (use pain point for consistency with the pain-point map) |
| CLAUDE.md | claude.md, claude-md |
| Key Vault MCP Server | Key Vault MCP, MCP server (capitalize consistently) |
| Claude Code | ClaudeCode, claude-code |
| slash command | slash-command, custom command |
| ADO | Azure DevOps, AzDO (ADO is acceptable shorthand in context) |
| SQL Managed Instance (SQL MI) | SQL Server, managed SQL |

### Tone and Voice

All documents are written from the perspective of a Principal Solutions Architect explaining decisions to a peer. The voice is direct, evidence-based, and constraint-aware.

**Do:**
- State the constraint before explaining the workaround
- Quantify trade-offs where possible ("90-day scope limit," "0% logic errors")
- Acknowledge negatives in ADR Consequences sections without hedging
- Reference real team members only in context that a peer review would find appropriate

**Do not:**
- Use hedging language ("might," "could potentially," "probably")
- Apologize for constrained solutions
- Present a workaround as equivalent to the enterprise target
- Omit the Azure Migration Path from any ADR

---

## Required Sections by Document Type

### Architecture Decision Record (ADR)

| Section | Required | Notes |
|---|---|---|
| Status | Yes | Accepted, Proposed, Superseded, or Deprecated |
| Date | Yes | ISO 8601 format (YYYY-MM-DD) |
| Deciders | Yes | Name and role |
| Pain point addressed | Yes | One sentence referencing the source pain point |
| Context | Yes | What problem drove this decision; what constraints apply |
| Decision | Yes | What was chosen and what it does |
| Alternatives Considered | Yes | Table with at least 3 options including the chosen one |
| Consequences | Yes | Positive and negative, clearly labeled |
| Azure Migration Path | Yes | Numbered steps to reach the enterprise target |

### Architecture Overview Document (ARCHITECTURE.md)

| Section | Required | Notes |
|---|---|---|
| System Context (C4 Level 1) | Yes | Mermaid diagram |
| Container Diagram (C4 Level 2) | Yes | Mermaid diagram |
| AI Augmentation Points table | Yes | Maps pain points to containers and ADRs |
| Architecture Decision Records table | Yes | All ADRs with links |
| Technology Stack table | Yes | Current stack with version notes where relevant |
| Diagram Cross-Reference | Yes | Links to all diagram files |

### Diagram Files

| Section | Required | Notes |
|---|---|---|
| Purpose | Yes | One sentence describing what the diagram shows and why it exists |
| Mermaid code block | Yes | Valid, renderable Mermaid syntax |
| Notes | Yes | At least one paragraph explaining what is shown and any significant trade-offs or constraints visible in the diagram |

### Solution Architecture Document

| Section | Required | Notes |
|---|---|---|
| Pain point description | Yes | Two to three sentences from the business perspective |
| Constrained Solution stack | Yes | Named Azure resources only |
| Constrained Solution flow | Yes | Numbered steps |
| Why this stack (constraint rationale) | Yes | Explicit reasoning for each non-ideal choice |
| Constraint acknowledgment | Yes | What the solution cannot do |
| Enterprise Vision stack | Yes | Named Azure resources with no provisioning constraint |
| Why better | Yes | Concrete improvement over the constrained solution |

---

## Version Accuracy Rules

Documentation goes stale when it refers to implementation details that change without triggering a documentation update. The following rules prevent accuracy drift:

1. All references to Azure resource tiers (Standard SKU, Consumption plan, S1, F0) must be verified against the current ARM template before publishing.
2. All ADO pipeline route counts and trigger types must match the current ARM template.
3. The 90-day scope limit in ADR-003 is a design parameter, not an implementation detail. Do not update it without a corresponding ADR amendment.
4. Cost estimates in the enterprise vision document (ENTERPRISE_VISION.md) are approximate. Do not represent them as current Azure pricing. Label them "estimated" or provide the pricing page reference.
5. Team member names (Rick, Jessica, Rosa, Alfredo, Jason, Jackie, Carmen) may be used in context that is appropriate for a peer-reviewed architecture document. Do not use them in negative or speculative framing.

---

## Review Process

All new or significantly modified documentation goes through a two-step review before sharing with external stakeholders.

### Step 1: Self-Review Checklist

- [ ] No em-dashes present (character U+2014 or double-hyphen used as em-dash substitute)
- [ ] Consistent terminology with the table above
- [ ] All required sections present for the document type
- [ ] Azure Migration Path present in every ADR
- [ ] Mermaid diagrams tested in a live renderer (mermaid.live or VS Code preview)
- [ ] All internal links resolve correctly
- [ ] No version numbers or implementation details that require verification are unverified
- [ ] Consequences section in every ADR includes both positive and negative points

### Step 2: Peer Review (for stakeholder-facing documents)

Peer review is required before any document is included in a stakeholder presentation or shared outside the team. The reviewer should check:

- Does the constrained solution accurately reflect the current Azure environment?
- Does the enterprise vision reference Azure services by their correct current names?
- Is the Azure Migration Path actionable? Could another architect follow it?
- Are the trade-off tables complete? Is any option obviously missing?

---

## Naming Conventions

| File type | Naming pattern | Example |
|---|---|---|
| ADR | ADR-NNN-kebab-case-topic.md | ADR-003-backlog-dedup.md |
| Architecture diagram | NN-kebab-case-description.md | 02-ai-augmented-sdlc.md |
| Solution or overview doc | SCREAMING-SNAKE-CASE.md | SOLUTION_ARCHITECTURE.md |
| Root-level initiative docs | SCREAMING-SNAKE-CASE.md | AI_TRANSFORMATION_ROADMAP.md |

ADR numbers are sequential and permanent. An ADR that is superseded retains its number; a new ADR is created with the next number and references the superseded ADR.

---

## Enforcement

Unlike the PeelAway Logic portfolio, the SpaceGenius AI initiative does not have a deployed CI pipeline that enforces documentation quality. The enforcement mechanism is the review process above.

When the documentation pipeline (ADR-001) is implemented and ADO Pipelines is running on the SpaceGenius repository, a doc-lint step should be added to the CI workflow following the PeelAway model: em-dash detection and broken internal link checking at minimum.
