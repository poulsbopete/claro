---
slug: architectural-unity
id: u3xhamtxcv1b
type: challenge
title: 'Competitive Edge 1: Architectural Unity — One Platform, Zero Context Switches'
teaser: Pivot from an APM trace span to its correlated log line in one click — no
  second product, no copied trace IDs, no context switching.
notes:
- type: text
  contents: |
    ## Workshop Slides

    Follow along with the full presentation:

    **[→ Open Workshop Slides](https://poulsbopete.github.io/claro/)**

    *(Opens in a new tab)*
- type: text
  contents: |
    ## Why Splunk Forces Context Switches

    In Splunk, **logs live in Splunk Cloud** and **APM traces live in Splunk Observability Cloud** — two separate backends, two billing contracts, two query languages (SPL and SignalFlow).

    To correlate a trace to a log, a Splunk operator must:
    1. Copy a trace ID from Splunk Observability Cloud
    2. Open a second browser tab, navigate to Splunk Cloud
    3. Run a second SPL search using that trace ID
    4. Hope the log was indexed in the same time window

    **Elastic stores logs, metrics, and traces in a single Elasticsearch datastore.** The shared `trace.id` field links every signal together, and Kibana surfaces them all without leaving your context.
- type: text
  contents: |
    ## The Elastic Architecture Advantage

    | Capability | Elastic | Splunk |
    |------------|---------|--------|
    | Traces + Logs in one datastore | ✅ Elasticsearch | ❌ Two products |
    | Shared correlation field | ✅ `trace.id` everywhere | ❌ Manual copy-paste |
    | Single query language | ✅ ES\|QL | ❌ SPL (logs) + SignalFlow (APM) |
    | One billing contract | ✅ | ❌ Splunk Cloud + Splunk OC |

    > When your on-call engineer gets paged at 2 AM, **context switches cost resolution time**. Elastic's architectural unity eliminates that tax entirely.
tabs:
- id: mrvpkb0obqmz
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: uoxzjbzmibqg
  title: Live Dashboard
  type: service
  hostname: es3-api
  path: /dashboard
  port: 8090
- id: 6gcwxgihaixs
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: 35cseanknkdw
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/apm/services
  port: 8080
  custom_request_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self'' https://kibana.estccdn.com; worker-src blob: ''self'';
      style-src ''unsafe-inline'' ''self'' https://kibana.estccdn.com; style-src-elem
      ''unsafe-inline'' ''self'' https://kibana.estccdn.com'
  custom_response_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self'' https://kibana.estccdn.com; worker-src blob: ''self'';
      style-src ''unsafe-inline'' ''self'' https://kibana.estccdn.com; style-src-elem
      ''unsafe-inline'' ''self'' https://kibana.estccdn.com'
difficulty: basic
timelimit: 2700
enhanced_loading: null
---

# Competitive Edge 1: Architectural Unity

Nine Claro microservices are continuously generating **real** OpenTelemetry traces and logs — all flowing into the same Elasticsearch datastore. In this challenge you'll pivot from a live APM trace directly to its correlated log line without switching tools, tabs, or query languages.

---

## Step 1: Find High-Error Services with ES|QL

Open the **Elastic Serverless** tab → **Discover** → switch to **ES|QL** mode, and run:

```esql
FROM logs.otel, logs.otel.*
| WHERE @timestamp > NOW() - 15 MINUTES
| WHERE severity_text == "ERROR"
| STATS errors = COUNT(*) BY service.name
| SORT errors DESC
| LIMIT 10
```

> You'll see all 9 Claro services ranked by error count. Services with active chaos faults will show dramatically higher numbers — but every service is emitting errors at a background rate, giving you real data to explore.

---

## Step 2: Grab a Trace ID from a Failing Log

Find an ERROR log that has a `trace.id` — this is the link that connects logs to traces:

```esql
FROM logs.otel, logs.otel.*
| WHERE @timestamp > NOW() - 5 MINUTES
| WHERE severity_text == "ERROR" AND trace.id IS NOT NULL
| KEEP service.name, body.text, trace.id, @timestamp
| SORT @timestamp DESC
| LIMIT 5
```

Copy the `trace.id` value from any row (a 32-character hex string like `4bf92f3577b34da6a3ce929d0e0e4736`).

---

## Step 3: Pivot to All Correlated Logs — The Elastic Way

Paste your `trace.id` into this query to see **every log line from that same request**, across all services involved:

```esql
FROM logs.otel, logs.otel.*
| WHERE trace.id == "<paste-your-trace-id-here>"
| KEEP @timestamp, service.name, severity_text, body.text
| SORT @timestamp ASC
```

> **In Splunk:** You are now on your second product (Splunk Cloud), running a second search in SPL, in a different browser tab, hoping the log retention window matches.
>
> **In Elastic:** Same ES|QL, same datastore, same session. **One platform. Zero context switching.**

---

## Step 4: See Native APM ↔ Log Correlation in Kibana

No query needed — Kibana does this automatically:

1. In the **Elastic Serverless** tab go to **Applications → Service inventory**
2. Click any service — for example **mobile-core** or **billing-engine**
3. Click any **transaction** to open the trace waterfall
4. Click the **Logs** tab at the top of the trace detail panel

Kibana automatically shows every log line correlated to that trace via the shared `trace.id` field — no configuration, no copy-paste, no second product.

---

## ✅ Complete When:

- [ ] Your ES|QL error query shows Claro services ranked by error rate
- [ ] You retrieved a `trace.id` from a failing log entry
- [ ] You queried all logs for that trace with a single ES|QL statement
- [ ] You clicked the **Logs** tab inside an APM trace detail — one click, no product switch
