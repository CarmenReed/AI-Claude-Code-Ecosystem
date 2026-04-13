# ADR-005: GitHub Pages over Azure Static Web Apps

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed

---

## Context

PeelAway Logic is a React single-page application with no server-side requirements for its core pipeline functionality. Hosting decisions for a personal portfolio project are constrained by cost, setup time, and the need to demonstrate the application working before the April 15 interview.

Two viable options existed: GitHub Pages (free, zero configuration, already used by the repository) and Azure Static Web Apps (Azure-native, better CI/CD integration, custom domain support, serverless API routes via Functions).

The time constraint was real: deploying to a new hosting platform during an active sprint where the priority was architecture documentation and Azure AI integration would consume setup time better spent on the portfolio substance.

---

## Decision

Continue hosting on GitHub Pages using the existing GitHub Actions deployment workflow. The decision is explicitly pragmatic and time-bound: GitHub Pages meets all functional requirements for the sprint and interview window, and the migration path to Azure Static Web Apps is fully documented for the interview conversation.

This decision is the direct subject of the "Azure Migration Path" section below.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| GitHub Pages (current) | Zero cost, zero configuration, already working, custom 404 handling with SPA redirect workaround | No staging slots, no custom domain without DNS configuration, no server-side API routes for Managed Identity, CORS configuration for Azure AI Search is less clean |
| Azure Static Web Apps (Free tier) | First-class Azure integration, staging slots, custom domain, API routes with Managed Identity support, native GitHub Actions integration | Free tier requires Azure account setup and configuration, global CDN not available on free tier, API routes add deployment complexity, setup time during interview sprint was a constraint |
| Azure Static Web Apps (Standard tier) | All free tier benefits plus global CDN, more API calls, custom authentication | Monthly cost ($9/month), overkill for a personal portfolio |
| Vercel | Excellent Next.js/React support, fast global CDN, generous free tier | Not Azure, adds nothing to the Microsoft portfolio story |

---

## Consequences

**Positive:**
- Zero incremental work during the interview sprint: existing GitHub Actions workflow handles build and deploy on every push to main
- Free tier with no cost ceiling concern
- GitHub Pages URL (carmenreed.github.io/PeelAway-Logic) is already indexed and shareable

**Negative:**
- No staging slots: the only live environment is production
- Azure AI Search CORS configuration must explicitly allow the GitHub Pages origin, which is a less clean pattern than using a same-origin API route
- API key for Azure AI Search is in the client bundle (query key only, not admin key); an Azure Static Web Apps API route would eliminate this exposure
- No custom domain without DNS changes

**Risk:**
No meaningful risk for a personal portfolio project. The CORS configuration is permanent and the query key exposure is accepted as documented in ADR-002.

---

## Azure Migration Path

This decision has the clearest and most direct Azure migration path of any ADR in this project. In a Microsoft enterprise deployment, the migration steps are:

1. Create an Azure Static Web App in the existing resource group (see `azure-resources.bicep`)
2. Configure the GitHub Actions workflow to use the Static Web Apps deployment action instead of the GitHub Pages deployment action (one workflow file change)
3. Move the `azureSearchService.js` REST client calls to an Azure Functions API route (`/api/search`) within the Static Web App
4. Assign a Managed Identity to the Static Web App
5. Grant the Managed Identity the `Search Index Data Reader` role on the Azure AI Search resource
6. Update the API route to use `@azure/search-documents` SDK with `DefaultAzureCredential`
7. Update the React client to call `/api/search` instead of the Azure AI Search endpoint directly
8. Remove the Azure AI Search query key from all client-side configuration
9. Configure a custom domain with an Azure-managed TLS certificate
10. Set up a staging slot for pre-production validation

Steps 1 through 4 can be executed in under two hours. The query key elimination (steps 5 through 8) takes an additional hour. The full migration to a production-grade Azure hosting pattern is a well-understood, low-risk operation.

The reason this migration has not occurred is not lack of knowledge. It is deliberate prioritization: architecture documentation and AI integration features provide more interview value in the sprint window than hosting infrastructure changes.
