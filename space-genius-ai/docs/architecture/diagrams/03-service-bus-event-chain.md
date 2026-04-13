# Diagram 03: Service Bus Event Chain Architecture

**Purpose:** Shows how the existing Service Bus namespace is extended with new topics to power the ticket deduplication and support triage pipelines, without requiring a new Service Bus resource or tier upgrade.

---

```mermaid
graph LR
    subgraph Triggers["Event Sources"]
        ADOWebhook["ADO Webhook\nFires on new PBI creation"]
        HelpScoutWebhook["HelpScout Webhook\nFires on new support ticket"]
    end

    subgraph ServiceBus["Azure Service Bus (Existing Standard Namespace)"]
        subgraph ExistingTopics["Existing Topics (unchanged)"]
            ExistingT["Existing topics\n(unchanged)"]
        end
        subgraph NewTopics["New Topics (ARM template additions)"]
            TicketTriage["ticket-triage topic\n+ ticket-triage-subscription"]
            SupportTriage["support-triage topic\n+ support-triage-subscription"]
        end
    end

    subgraph TicketDedup["Ticket Deduplication Pipeline (ADR-003)"]
        TD_F1["Azure Function: Dedup Check\nFetches last 90 days of backlog\nvia ADO REST API"]
        TD_Claude["Claude API\nSemantic similarity comparison\nin context window"]
        TD_ADO["ADO REST API\nFlags duplicate PBI\nCreates related-item links"]
    end

    subgraph SupportTriage_Pipeline["Support Triage Pipeline (ADR-004)"]
        ST_F1["Azure Function 1: Completeness Check\nClaude API validates ticket\nhas required information"]
        ST_HelpScout["HelpScout API\nSends canned clarification\nrequest to customer"]
        ST_F2["Azure Function 2: Dedup Check\nReuses ADR-003 pattern\nagainst ADO backlog"]
        ST_F3["Azure Function 3: Gherkin ACs\nClaude API generates\nacceptance criteria"]
        ST_ADO["ADO REST API\nCreates PBI in design state\nAttaches Gherkin ACs as wiki page"]
        ST_SendGrid["SendGrid (free tier)\nNotifies Jessica via email\nthat triage-ready PBI is waiting"]
    end

    ADOWebhook -->|"HTTP POST"| TicketTriage
    HelpScoutWebhook -->|"HTTP POST"| SupportTriage

    TicketTriage --> TD_F1
    TD_F1 -->|"Backlog content"| TD_Claude
    TD_Claude -->|"Duplicate detected"| TD_ADO

    SupportTriage --> ST_F1
    ST_F1 -->|"Incomplete: requeue"| SupportTriage
    ST_F1 -->|"Incomplete: clarify"| ST_HelpScout
    ST_F1 -->|"Complete: advance"| ST_F2
    ST_F2 -->|"Unique ticket"| ST_F3
    ST_F2 -->|"Duplicate: link and close"| ST_ADO
    ST_F3 --> ST_ADO
    ST_ADO --> ST_SendGrid
```

---

## ARM Template Extensions Required

Two additions to the existing ARM template enable this architecture. No new Azure resources are provisioned outside the existing namespace.

```json
// Addition 1: ticket-triage topic
{
  "type": "Microsoft.ServiceBus/namespaces/topics",
  "name": "[concat(variables('serviceBusNamespaceName'), '/ticket-triage')]",
  "dependsOn": ["[variables('serviceBusNamespaceName')]"]
}

// Addition 2: support-triage topic  
{
  "type": "Microsoft.ServiceBus/namespaces/topics",
  "name": "[concat(variables('serviceBusNamespaceName'), '/support-triage')]",
  "dependsOn": ["[variables('serviceBusNamespaceName')]"]
}
```

Both topics use the Standard namespace tier already provisioned. No tier upgrade required. No new Azure cost.

---

## Notes

The Service Bus extension pattern is the principal architect answer to "I need a new messaging capability." The correct move is to extend the existing namespace with a new topic and subscription before requesting a new Service Bus resource. This is the constraint-first principle applied to infrastructure: use what is provisioned, extend it precisely, do not replace it.

The 90-day scope limit on the dedup function (Ticket Deduplication Pipeline) is an explicit architectural trade-off documented in ADR-003. It is represented here as a design parameter, not a bug.
