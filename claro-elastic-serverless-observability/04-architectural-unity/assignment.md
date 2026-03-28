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

The setup script injected a **latency spike and error storm** into `checkout-service` by indexing synthetic APM traces and correlated log lines into your Elastic Cloud Serverless project. Every trace and its matching log share the same `trace.id` field.

---

## Step 1: Find the Latency Spike With ES|QL

Open the **Elastic Serverless** tab, navigate to **Discover → ES|QL**, and run:

```esql
FROM lab4-apm-traces-*
| WHERE @timestamp > NOW() - 30 minutes AND error == true
| STATS avg_ms = AVG(span.duration.us) / 1000,
        error_count = COUNT()
  BY service.name
| SORT avg_ms DESC
| LIMIT 10
```

> `checkout-service` will show dramatically higher latency and error count. This is your smoking gun.

---

## Step 2: Drill Into a Failing Trace

```esql
FROM lab4-apm-traces-*
| WHERE service.name == "checkout-service" AND error == true
| KEEP @timestamp, trace.id, span.duration.us, error.message
| SORT @timestamp DESC
| LIMIT 1
```

Copy the `trace.id` value from the result (32-character hex string).

---

## Step 3: Pivot to the Correlated Log — The Elastic Way

Query the **application log index** with the same `trace.id`. Replace `<your-trace-id>` with the value from Step 2:

```esql
FROM lab4-app-logs-*
| WHERE trace.id == "<your-trace-id>"
| KEEP @timestamp, log.level, message, error.message
```

> **In Splunk:** You are now on your second product, running a second search, in a different query language.
>
> **In Elastic:** Same ES|QL, same datastore, same session. **One platform. Zero context switching.**

---

## Step 4: See Native APM ↔ Log Correlation in Kibana

1. In the **Elastic Serverless** tab go to **Applications → Services → checkout-service**
2. Click any failing transaction → **Trace** tab → **Logs** tab
3. Kibana automatically correlates the trace to its logs via the shared `trace.id` — no configuration required

---

## ✅ Complete When:

- [ ] The ES|QL spike query shows `checkout-service` with elevated latency and errors
- [ ] You retrieved a correlated log line using a `trace.id` from the APM index
- [ ] You observed the native APM → Logs correlation in Kibana (one click, no product switch)
