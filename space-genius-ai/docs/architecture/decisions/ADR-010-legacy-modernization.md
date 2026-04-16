# ADR-010: Legacy .NET Modernization and CI/CD Architecture

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed  
**Pain point addressed:** Aging .NET target version, deprecated API accumulation, ARM template maintainability

---

## Context

The SpaceGenius codebase targets an aging .NET version with accumulated deprecated API warnings. The existing ARM template is a non-modular single file that is increasingly difficult to maintain as the environment grows. A full Bicep migration would be architecturally correct but represents a significant infrastructure risk during active feature development.

Two separate but related decisions are made here: the .NET modernization approach and the IaC modernization approach. Both share the same principle: extend what is deployed before replacing it.

---

## Decision

**For .NET modernization:**  
Use Claude Code with full CLAUDE.md codebase context to audit deprecated APIs and generate a module-by-module migration plan. The migration plan covers .NET 8 to .NET 10 in phases, with ADO Pipelines adding multi-target build (`net8.0;net10.0`) to catch regressions per PR. Development proceeds incrementally: no "big bang" migration that freezes the codebase.

**For IaC modernization:**  
Parameterize the existing ARM template with environment slots (dev/staging/prod App Service plans) using ARM template functions and conditional resource blocks. This is not a Bicep migration. Bicep compiles to ARM JSON, so the deployed infrastructure would be identical, but the migration requires rewriting the template in a new authoring format, validating parity, and retraining the team on the new syntax. The team's IaC investment is better spent on the .NET modernization right now. The Bicep migration is the correct long-term target and is deferred to after the .NET modernization stabilizes.

---

## Alternatives Considered

**For .NET modernization:**

| Option | Pros | Cons |
|---|---|---|
| Claude Code + CLAUDE.md migration plan (chosen) | Full codebase context, no Copilot Enterprise license required, generates module-specific migration guidance | CLAUDE.md maintenance required; not as automated as Upgrade Assistant |
| GitHub Copilot Enterprise + .NET Upgrade Assistant | Upgrade Assistant automates breaking-change fixes; Copilot Enterprise flags deprecated APIs inline | Copilot Enterprise not licensed; Upgrade Assistant available independently but without repo context |
| All-at-once migration | Simplest to plan | Freezes active feature development; high regression risk; unacceptable for production-serving codebase |

**For IaC modernization:**

| Option | Pros | Cons |
|---|---|---|
| ARM template parameterization (chosen) | Zero toolchain change, zero deployment risk, same deployment model as today | ARM JSON harder to maintain at scale; does not address the long-term Bicep migration need |
| Full Bicep migration | Azure-native IaC standard, modular, parameterized, easier to maintain | Requires rewriting the template in a new authoring format and validating ARM output parity; team investment is better spent on .NET modernization first |
| No IaC change | Zero risk | Maintenance burden accumulates; environment inconsistencies grow |

---

## Consequences

**Positive:**
- .NET modernization proceeds incrementally without freezing the codebase
- Multi-target CI build catches regressions before they reach staging or production
- ARM parameterization provides environment slots for dev/staging/prod with zero deployment risk
- No new Azure resources required

**Negative:**
- ARM JSON is harder to maintain than Bicep at scale; this decision defers but does not eliminate the Bicep migration
- CLAUDE.md context quality limits the depth of migration guidance for modules not well-documented in the knowledge base

**Sequencing note:** The Bicep migration is the correct long-term target. It is deferred, not abandoned. The trigger for beginning the Bicep migration is: .NET modernization stabilized (multi-target build passing clean), documentation pipeline (ADR-001) reducing the documentation burden per migration PR, and a dedicated infrastructure sprint allocated.

---

## Azure Migration Path

1. Provision GitHub Copilot Enterprise: deprecated API warnings appear inline during development; no CLAUDE.md authoring required for codebase context
2. .NET Upgrade Assistant (available free, no Azure resource required): automates breaking-change fixes identified in the migration plan
3. Begin the Bicep migration: decompose the monolithic ARM template into Bicep modules (networking, compute, storage, AI services) using the existing parameter structure as the starting point
4. Use Azure Deployment Environments for dev/test environment provisioning from Bicep modules: self-service environment creation without infrastructure team involvement
5. AI-reviewed PRs (via Copilot Enterprise) gate infrastructure regressions automatically
