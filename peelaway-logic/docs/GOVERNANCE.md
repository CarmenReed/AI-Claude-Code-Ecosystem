# Documentation Governance

**Author:** Carmen Reed  
**Date:** April 12, 2026  
**Scope:** PeelAway Logic documentation standards, quality gates, and CI enforcement

---

## Why Documentation Governance Exists

Documentation without enforcement degrades. Rules without automation are aspirational. This document defines the standards that govern all documentation in PeelAway Logic and the automated checks that enforce those standards on every push to main.

The same philosophy that requires tests to pass before code merges requires documentation to meet quality standards before it deploys. A broken link in architecture docs is a defect, not cosmetic.

---

## Writing Standards

### No Em-Dashes

Em-dashes are prohibited in all documentation. This is an absolute rule with no exceptions.

**Why:** Em-dashes interrupt reading flow for users with screen readers and create parsing ambiguity in structured documents. Every sentence that relies on an em-dash can be rewritten with a comma, a colon, a period, or a sentence break.

**Enforcement:** `doc-lint.js` detects the Unicode em-dash character and the double-hyphen pattern used as an em-dash substitute. Any violation fails the CI pipeline.

**Alternatives:**
- Use a comma for a parenthetical aside
- Use a colon to introduce a list or elaboration
- Use a period to split into two sentences
- Use parentheses for supplemental information

### Consistent Terminology

| Preferred Term | Do Not Use |
|---|---|
| PeelAway Logic | PeelAway, Peel Away |
| Azure AI Search | Cognitive Search, Azure Search |
| Anthropic Claude API | Claude, the AI, GPT |
| phase | step, stage (in pipeline context) |
| human gate | approval gate, checkpoint (use human gate) |
| Architecture Decision Record (ADR) | decision doc, design doc |

### Required Sections by Document Type

| Document Type | Required Sections |
|---|---|
| ADR | Context, Decision, Alternatives Considered, Consequences, Azure Migration Path |
| Architecture diagram file | Purpose, Mermaid code block, Notes |
| Phase documentation | Input, Process, Output, Human Gate |
| README | What It Is, Architecture Documentation table, Technology Stack |

---

## Automated Quality Gates

### doc-lint.js

Location: `scripts/doc-lint.js`  
Runs on: every push to main via GitHub Actions `doc-quality.yml`  
Language: Node.js, no external dependencies

**Checks performed:**

| Check | Failure Behavior | Warning Behavior |
|---|---|---|
| Em-dash detection (Unicode and double-hyphen) | Fails build | N/A |
| Broken internal links (relative Markdown links) | Fails build | N/A |
| Missing required ADR sections | Fails build | N/A |
| Version numbers that do not match package.json | Warns | Does not fail |
| Common misspellings | Warns | Does not fail |

### CI Workflow

File: `.github/workflows/doc-quality.yml`  
Trigger: push to main, pull request to main

```yaml
# Conceptual workflow structure (actual file in .github/workflows/)
steps:
  - checkout
  - setup-node
  - run: node scripts/doc-lint.js
  # If doc-lint exits non-zero, the workflow fails
  # Deployment does not proceed until this passes
```

---

## Review Checklist

Before committing any new or updated documentation:

- [ ] No em-dash characters present (search: Unicode U+2014 and double-hyphen used as punctuation)
- [ ] All relative links verified to point to existing files
- [ ] Terminology matches the Consistent Terminology table above
- [ ] ADRs include all five required sections
- [ ] Mermaid diagrams tested in Mermaid Live Editor or VS Code preview
- [ ] Version numbers cross-referenced with package.json
- [ ] No placeholder text (TODO, TBD, PLACEHOLDER) in committed files

---

## File Organization Standards

```
docs/
  GOVERNANCE.md                  This file
  architecture/
    ARCHITECTURE.md              Overview with embedded diagrams
    decisions/
      ADR-NNN-short-title.md     ADR files, zero-padded number prefix
    diagrams/
      NN-descriptive-name.md     Diagram files, numbered for sequence
    azure-resources.bicep        IaC documentation template
```

New files must follow the naming convention. ADRs must use the zero-padded number prefix. Diagram files must use the numbered prefix to preserve reading order.
