# Documentation and HCI Governance

**Author:** Carmen Reed  
**Date:** April 13, 2026  
**Scope:** PeelAway Logic documentation standards, HCI change governance, quality gates, and CI enforcement

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

### CI Workflows

Four GitHub Actions workflows run on every push to main:

| Workflow | File | Purpose |
|---|---|---|
| Deploy | `deploy.yml` | Build and deploy to GitHub Pages |
| Doc Quality | `doc-quality.yml` | Run doc-lint.js (em-dash, broken link, ADR section checks) |
| Environment Audit | `env-audit.yml` | Block pushes containing QA-environment references in production docs |
| Update Docs | `update-docs.yml` | Auto-update test counts and documentation sync after source changes |

No deployment occurs if tests fail or doc-lint reports violations.

### Documentation Sync

Script: `scripts/docs-sync.js`  
Command: `npm run docs-sync`

Rewrites test file lists, structural counts, and per-spec test counts in documentation so they never drift from the source tree. Hand-written descriptions on existing entries are preserved; new files get descriptions extracted from leading comments or a placeholder. The same script also runs as a step inside `update-docs.yml` so drift is caught even when developers forget.

---

## HCI Governance

Automated tests verify that code is correct. They do not verify that the user experience is still correct. A refactor can keep every test green while quietly rewiring how a real user moves through the Scout, Review, Human Gate, and Complete phases. The HCI governance process catches these changes before they reach production.

### How It Works

Script: `scripts/hci-audit.js`  
Command: `npm run hci-audit`

The audit scans the diff between `origin/main` and the working tree, classifies every changed file into a tier, looks for HCI impact signals (routing changes, new interactive elements, copy edits, CSS rule changes, accessibility regressions), and emits a verdict.

### Verdict Tiers

| Verdict | Meaning | Action |
|---|---|---|
| GREEN | No HCI-relevant changes | Commit as normal |
| YELLOW | Minor HCI impact, spot check recommended | Commit, then spot check before promotion |
| RED | Significant HCI impact, UAT cycle warranted | Run UAT scenarios, record sign-off, then promote |

The gate is non-blocking. RED warns loudly but the script exits `0`. The developer is trusted to act on the warning.

### File Classification

| Tier | What It Covers |
|---|---|
| Tier 1 (journey) | Phase orchestrators, routing, progress stepper, landing screen, header |
| Tier 2 (interaction) | User-facing React components, user-visible copy sources |
| Tier 3 (visual) | CSS and front-end assets |
| Tier 4 (copy) | User story documents with acceptance criteria |
| Non-HCI | Tests, scripts, config, non-user-story docs |

### Accessibility Test Coverage

The HCI audit's static heuristic (ARIA removals, alt text drops, keyboard handler removals) is paired with two dynamic test suites:

- **Unit level** (`src/__tests__/accessibility.test.jsx`): uses `jest-axe` inside jsdom. Covers image alt text, button names, link names, form labels, ARIA validity, SVG labeling, and list structure.
- **Browser level** (`e2e/09-accessibility.spec.ts`): uses `@axe-core/playwright` inside Chromium. Covers color contrast (WCAG 1.4.3), focus visibility, landmark regions, heading order, and keyboard reachability.

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
