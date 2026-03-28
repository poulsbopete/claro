---
slug: high-cardinality-metrics
id: tmnahuexgbwt
type: challenge
title: 'Competitive Edge 2: Elastic Streams — Intelligent Partitioning Without Agent
  Changes'
teaser: Elastic analyzes your live data and suggests routing rules automatically.
  Accept a suggestion and your logs instantly split into per-service streams with
  independent retention and processing rules — zero Collector restarts.
notes:
- type: text
  contents: |
    ## Workshop Slides

    Follow along with the full presentation:

    **[→ Open Workshop Slides](https://poulsbopete.github.io/claro/)**

    *(Opens in a new tab)*
- type: text
  contents: |
    ## How Splunk Forces a Cardinality Trade-off

    In Splunk, every unique metric dimension combination is a billable **Metric Time Series (MTS)**. High-cardinality fields like `pod.uid` or `container.id` multiply your bill with every deployment. The only cost lever is at the **OpenTelemetry Collector** — drop the field globally, permanently, before it reaches Splunk.

    **Elastic Streams gives you control inside the platform.** Instead of dropping fields at the agent, you route data into per-service streams — each with its own retention policy and field-level processing rules — without touching a single agent config.
- type: text
  contents: |
    ## What You'll Do

    Elastic Streams **analyzes your live data** and automatically suggests how to partition it. For the Claro scenario, it detects that `logs.otel` contains logs from 9 different services and suggests creating child streams like:

    - `logs.otel.billing-engine` — billing and OCS charging events
    - `logs.otel.mobile-core` — 5G/4G core network events
    - `logs.otel.voice-platform` — SIP/IMS events
    - (and 6 more...)

    Each child stream is **completely independent**: set 7-day retention on `billing-engine` for fast incident triage, 90-day on `network-analytics` for capacity trending. Add a `drop_field` rule to one without affecting the others.

    | Capability | Elastic Streams | Splunk |
    |------------|----------------|--------|
    | Auto-detect routing candidates | ✅ Analyzes live data | ❌ Manual pipeline config |
    | Per-service retention | ✅ Each child independent | ❌ Global DDAA policy |
    | Drop fields per-stream | ✅ Processing rules | ❌ Global Collector change |
    | Zero agent changes | ✅ | ❌ Requires Collector restart |
tabs:
- id: addwrseojmxt
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: wdbv3fub6chb
  title: Live Dashboard
  type: service
  hostname: es3-api
  path: /dashboard
  port: 8090
- id: feqdqyofcddf
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: uinbtoljou0s
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/streams
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
difficulty: intermediate
timelimit: 2700
enhanced_loading: null
---

# Competitive Edge 2: Elastic Streams — Intelligent Partitioning

Elastic has already been watching the live Claro log stream. Open the **Elastic Serverless** tab — you're on the Streams page.

---

## Step 1: Open logs.otel and Review Partitioning Suggestions

1. Click **`logs.otel`** in the Streams list
2. Click the **Partitioning** tab at the top

Kibana has analyzed the last 1,000 documents from `logs.otel` and automatically identified that this stream contains data from multiple Claro services. You'll see suggested child streams like:

- `logs.otel.billing-engine`
- `logs.otel.mobile-core`
- `logs.otel.voice-platform`
- `logs.otel.noc-dashboard`
- `logs.otel.content-delivery`
- ... (one per service)

Each suggestion shows the **percentage of log volume** that service represents, along with a live **Data Preview** of the actual log messages that would be routed there.

> **Why this matters:** Kibana did the analysis automatically. In Splunk, a platform engineer would need to manually write Collector routing rules — reading the data schema, choosing split dimensions, testing in staging, then deploying. Here, Elastic shows you the answer.

---

## Step 2: Accept Two Partitions

Click **Accept** on **at least two** of the suggested partitions — for example:

1. `logs.otel.billing-engine` — billing and OCS charging events (highest financial impact)
2. `logs.otel.mobile-core` — 5G/4G core network events

After accepting, Kibana immediately:
- Creates the child streams `logs.otel.billing-engine` and `logs.otel.mobile-core`
- Sets up routing rules so new logs from those services go to their dedicated stream
- `logs.otel` continues receiving logs from all other services

> **The Splunk equivalent:** Modify `otelcol-contrib.yaml` with routing processor rules, deploy to all collector nodes, wait for restart, verify in Splunk. No data preview. No automatic suggestions. And if you get it wrong, data goes to the wrong destination until you fix and redeploy.

---

## Step 3: Set Different Retention on Each Child Stream

Click **`logs.otel.billing-engine`** from the Streams list.

1. Click the **Retention** tab
2. Change retention to **7 days** → Save
   - Billing logs need detail for rapid incident triage, but OCS CDR data has compliance rules

Now click **`logs.otel.mobile-core`**:

1. Click the **Retention** tab
2. Change retention to **30 days** → Save
   - 5G core events are needed longer for capacity planning and handover analysis

> In Splunk, retention is set at the **index level** via DDAA — a global policy. You cannot set different retention for different services within the same index. If `billing-engine` and `mobile-core` share an index (to save MTS costs), they share a retention policy. Period.

---

## Step 4: Add a Processing Rule to Drop a High-Cardinality Field

Click **`logs.otel.mobile-core`** → **Processing** tab:

1. Click **Add processor**
2. Select **Drop field**
3. Enter field name: `kubernetes.pod.uid`
4. Leave condition blank (applies to all documents)
5. Click **Save**

This drops `kubernetes.pod.uid` **only from the mobile-core stream** — the billing-engine stream still retains it for pod-level incident correlation.

> **This is the core Splunk cost problem:** In Splunk Observability Cloud, `kubernetes.pod.uid` creates a new MTS for every pod. With hundreds of 5G pods cycling on every deployment, bills explode. The only fix is dropping it at the Collector — globally, for all destinations. In Elastic, you drop it from one stream while keeping it in another.

---

## Step 5: Verify in the Streams List

Go back to the Streams list. You should now see your child streams alongside `logs.otel`:

| Stream | Purpose | Retention |
|--------|---------|-----------|
| `logs.otel` | All other services | Indefinite |
| `logs.otel.billing-engine` | OCS/CDR billing events | 7 days |
| `logs.otel.mobile-core` | 5G/4G core events | 30 days |

Switch to the **Elastic Serverless** tab → **Discover → ES|QL** and confirm data is routing to the child streams:

```esql
FROM logs.otel, logs.otel.*
| WHERE @timestamp > NOW() - 5 MINUTES
| STATS log_count = COUNT(*) BY data_stream.dataset, service.name
| SORT log_count DESC
```

You'll see `billing-engine` and `mobile-core` logs appearing under their own `data_stream.dataset` values — routed automatically, zero agent changes.

---

## ✅ Complete When:

- [ ] You reviewed the auto-generated partitioning suggestions in `logs.otel → Partitioning`
- [ ] You accepted at least two partition suggestions and new child streams appeared
- [ ] You set different retention policies on each child stream
- [ ] You added a `drop_field` processing rule to one stream (without affecting others)
