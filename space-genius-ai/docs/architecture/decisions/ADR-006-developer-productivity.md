# ADR-006: Developer Productivity Architecture (Auto-PR, Commit Notes, Ticket Updates)

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed  
**Pain point addressed:** Empty PR descriptions, missing ticket links, sparse development testing notes

---

## Context

Developers consistently under-document their work. PR descriptions are minimal. ADO ticket links are missing. Development testing notes are empty or describe only the happy path. Code reviewers lack context. Jessica retests what was already verified.

The solution must reduce the documentation burden for developers without requiring them to change their workflow significantly. The most effective approach is to make documentation generation a one-command action that happens after the work is done, using the context the developer already has: the git diff, the linked ticket, and the test run output.

---

## Decision

Implement two Claude Code slash commands that developers run after completing a feature:

**`/create-pr`:** Reads `git diff` for the current branch. Fetches the linked ADO ticket via ADO REST API using the PAT from Key Vault MCP. Generates a structured PR description including summary, changed files with rationale, testing notes, acceptance criteria reference, and risk assessment. Creates the PR via ADO REST with the ticket link populated.

**`/update-ticket`:** Reads the most recent CI pipeline test run output. Generates structured development testing notes: what changed, what was tested, what passed, known limitations, and testing environment details. Posts the notes to the ADO PBI via REST API.

Both commands are defined as CLAUDE.md slash commands and are available to any developer who configures Claude Code with the Key Vault MCP server.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| Claude Code slash commands + Key Vault MCP (chosen) | No new Azure resources, slash commands shared across team once authored, Key Vault MCP is already built | Each developer must install and configure Claude Code; CLAUDE.md requires maintenance; not automatic |
| GitHub Copilot Enterprise + Copilot Workspace | Automatic PR description generation, always-current repo context, no CLAUDE.md burden | Not licensed |
| ADO PR template enforcement | Zero additional tooling | Static template; no AI reasoning about the specific changes; developers still write the content |
| Azure DevOps post-commit hook with Function + Claude API | Automatic, no developer action required | Commit hook context is more limited than git diff + CLAUDE.md context; harder to customize per team |

---

## Consequences

**Positive:**
- PR descriptions are consistently complete with ticket links and rationale
- Development testing notes are generated from actual test output, not written from memory after the fact
- The Key Vault MCP server extends cleanly: adding new ADO-specific capabilities requires only new slash command definitions, not new Azure resources

**Negative:**
- Requires developer adoption: each developer must configure Claude Code and the Key Vault MCP server
- Not automatic: developers must invoke the slash commands
- Quality depends on CLAUDE.md codebase context accuracy

---

## Azure Migration Path

1. Provision GitHub Copilot Enterprise: the need for manually authored slash commands is eliminated; Copilot suggests PR descriptions automatically as part of the PR creation flow
2. Copilot Workspace closes the full loop: PBI to plan to code to PR, including description and test notes
3. The Key Vault MCP server remains: credential injection via Managed Identity is correct regardless of AI development tooling
4. Development testing notes transition from slash-command-generated to Copilot-generated based on the PR diff and linked test results
