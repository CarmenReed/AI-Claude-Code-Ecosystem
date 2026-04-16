# ADR-002: Client-Side REST Client over Azure SDK

**Status:** Accepted  
**Date:** 2026-04-12  
**Deciders:** Carmen Reed

---

## Context

PeelAway Logic is a React single-page application deployed to GitHub Pages as a static site. GitHub Pages serves only static files: HTML, CSS, JavaScript, and assets. There is no server, no Node.js runtime in production, no Azure Functions backend, and no compute environment beyond the user's browser.

Azure AI Search integration was required as a portfolio demonstration of Microsoft AI platform fluency. The official Azure AI Search client library (`@azure/search-documents`) depends on Node.js runtime features that are not available in a browser environment without a full bundling and polyfill strategy that would significantly increase the bundle size and maintenance complexity.

The constraint was: demonstrate Azure AI Search integration without introducing a server-side component or breaking the static deployment model.

---

## Decision

Implement `azureSearchService.js` as a thin REST client using the browser-native `fetch` API against the Azure AI Search REST endpoint directly. The service module encapsulates the endpoint URL, API key configuration, and query construction. It exposes typed functions for index queries and returns structured result objects.

This keeps the application deployable to GitHub Pages with zero server infrastructure while demonstrating the Azure AI Search query model, index schema design, and result handling patterns.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| @azure/search-documents SDK | Official client, Managed Identity support, TypeScript types, automatic retry | Node.js runtime dependency, browser bundle incompatible without complex polyfills, would require switching to a server-side rendering framework or adding a backend |
| Azure Functions proxy | Full SDK usage, Managed Identity, no API key in browser | Requires provisioning Azure Functions, adds infrastructure cost and complexity, breaks the static deployment model |
| Azure Static Web Apps with API routes | First-class static + API hosting, Managed Identity available in API routes, custom domain support | Not free tier, deployment complexity higher than GitHub Pages, out of scope for personal project budget |
| Skip Azure AI Search | Zero complexity | Loses the Microsoft AI platform demonstration entirely, weakens the portfolio story |

---

## Consequences

**Positive:**
- Zero server infrastructure required
- Static deployment to GitHub Pages continues to work unchanged
- Demonstrates Azure AI Search REST API knowledge: endpoint format, query syntax, index schema, result handling
- Thin service module is easy to test with mocked fetch responses

**Negative:**
- API key is visible in the client-side JavaScript bundle; mitigated by using a query-only key with read permissions only and no index modification rights
- No Managed Identity; API key rotation is manual
- No automatic retry or circuit breaker from the SDK

**Accepted tradeoff:**
The query key (not the admin key) is exposed in the client bundle. Azure AI Search query keys have no ability to modify index data, create indexes, or access other Azure resources. The risk is limited to someone querying the portfolio's search index with the same key, which has no security or financial consequence beyond minor index usage.

**Note:** The `azureSearchService.js` module also exports admin-key functions (`createJobIndex`, `indexJobs`, `deleteIndex`) used during development and demo setup. In production use, only query-key search operations are called from the browser. The admin-key functions would move to a server-side API route in the Azure Static Web Apps migration (see Azure Migration Path below).

---

## Azure Migration Path

In a Microsoft enterprise deployment, this decision changes as follows:

1. Provision an Azure Static Web App (replacing GitHub Pages)
2. Move the Azure AI Search calls from the React client to an Azure Functions API route within the Static Web App
3. In the API route, use the `@azure/search-documents` SDK with `DefaultAzureCredential` (Managed Identity)
4. No API key in client code; the API route authenticates to Azure AI Search using the Static Web App's managed identity
5. Remove `azureSearchService.js` from the React client and replace with calls to the `/api/search` route
6. Add Application Insights to the API route for query latency monitoring and error tracking

This migration path is fully documented in [azure-resources.bicep](../azure-resources.bicep) under the `staticWebApp` and `searchService` resource definitions.
