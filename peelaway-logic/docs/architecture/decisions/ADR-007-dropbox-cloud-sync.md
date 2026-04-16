# ADR-007: Dropbox OAuth Cloud Sync over localStorage-Only Persistence

**Status:** Accepted  
**Date:** 2026-04-16  
**Deciders:** Carmen Reed

---

## Context

PeelAway Logic originally persisted all state (scout results, applied jobs, dismissed jobs, tailored documents) in browser localStorage. This worked for single-device, single-browser use but had three limitations:

1. Data was siloed to one browser. Switching between machines (desktop at home, laptop on the go) meant starting fresh or manually exporting/importing.
2. Resume files had to be re-uploaded each session. There was no persistent document store.
3. localStorage has no backup mechanism. Clearing browser data or a browser reset erased the entire job search history.

The solution required cloud persistence for cross-device sync and document storage without introducing a backend server, since PeelAway Logic deploys as a static SPA on GitHub Pages.

---

## Decision

Integrate Dropbox as the cloud sync and document storage layer using the Dropbox JavaScript SDK with OAuth 2.0 implicit flow. The integration adds three capabilities:

1. **Cloud sync:** Job search state (applied jobs, scout results, tailored documents) is saved to a JSON file in the user's Dropbox. State is loaded from Dropbox on app start, enabling cross-device continuity.
2. **Resume import:** Users can select a resume PDF directly from their Dropbox via the Dropbox Chooser, eliminating re-upload on each session.
3. **Document export:** Tailored resumes and cover letters can be saved directly to Dropbox for organized storage.

localStorage remains the primary local cache and offline fallback. Dropbox sync is additive: the app works without it, and the user opts in via OAuth login.

Authentication uses the OAuth 2.0 implicit flow with a popup window. Access tokens are stored in localStorage for silent background sync without repeated authentication prompts.

---

## Alternatives Considered

| Option | Pros | Cons |
|---|---|---|
| Dropbox OAuth + implicit flow (chosen) | Zero backend required, works with static SPA, generous free tier, file chooser UI built-in, cross-device sync without infrastructure | OAuth implicit flow is less secure than PKCE; token stored in localStorage; vendor dependency |
| Google Drive API | Similar feature set, larger user base | More complex OAuth setup for static apps; API quota management; same vendor dependency |
| Azure Cosmos DB | Microsoft-native, multi-device sync, team access potential | Requires backend or Azure Functions proxy; cannot work from GitHub Pages static deployment; cost |
| localStorage only (original) | Zero dependencies, zero cost, zero complexity | No cross-device sync, no document storage, no backup, data loss on browser clear |
| IndexedDB + custom sync | More storage than localStorage, structured data | Still browser-local; custom sync requires a server; significantly more complexity |

---

## Consequences

**Positive:**
- Cross-device job search continuity without infrastructure changes
- Resume import from cloud storage eliminates per-session re-upload
- Tailored document export provides organized storage outside the browser
- Additive integration: app works fully without Dropbox; the feature is opt-in
- No backend server required; compatible with GitHub Pages static deployment

**Negative:**
- OAuth implicit flow stores access token in localStorage; token theft via XSS is a risk (mitigated: the token grants access only to the app's folder in Dropbox, not the user's full Dropbox)
- Dropbox API availability is an external dependency; sync failures must degrade gracefully to localStorage
- The Dropbox Chooser and Saver UI are third-party components with their own UX constraints
- Adds a client-side JavaScript SDK dependency

---

## Azure Migration Path

1. Provision Azure Cosmos DB (serverless) as the persistence layer, replacing both localStorage and Dropbox sync
2. Move sync logic to an Azure Functions API route behind the Static Web App
3. Use Managed Identity for Cosmos DB authentication (no connection strings in client code)
4. Resume storage moves to Azure Blob Storage with SAS token access
5. Dropbox integration can be retained as an additional import/export option alongside Azure-native storage
6. The localStorage fallback remains for offline capability
