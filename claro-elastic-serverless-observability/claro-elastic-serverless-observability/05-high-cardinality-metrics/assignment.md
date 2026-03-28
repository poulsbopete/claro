---
slug: high-cardinality-metrics
id: tmnahuexgbwt
type: challenge
title: 'Competitive Edge 2: Elastic Streams — Control Cardinality and Retention Without
  Dropping Data'
teaser: Use Elastic Streams to inspect and configure retention and field-level processing
  rules on live data streams — no agent changes required. Splunk can only do this
  at the collector, globally, irreversibly.
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

    In Splunk Observability Cloud, every unique combination of metric name + dimension values is a billable **Metric Time Series (MTS)**. A Kubernetes pod metric with dimensions `pod.uid`, `container.id`, and `node.name` creates a new MTS for every pod restart, every rollout, every ephemeral container — regardless of whether that data is ever queried.

    Splunk's only cost levers are at the **collector/agent level**: teams must choose which high-cardinality dimensions to drop *before* the data ever reaches Splunk. Once that decision is made, it is permanent. There is no in-platform mechanism to keep high-cardinality data for a short window and drop it automatically afterwards.

    **Elastic Streams solves this at the platform level**, without touching your agents.
- type: text
  contents: |
    ## What Elastic Streams Enables

    **Elastic Streams** is a first-class data management layer built into Kibana. For each stream you can:

    - **Set retention** — keep data for 7 days, 90 days, or indefinitely
    - **Apply processing rules** — drop high-cardinality fields (`pod.uid`, `container.id`) on write, without changing your agent config
    - **Fork streams** — route a subset of data (e.g. only ERROR events) to a separate stream with its own lifecycle

    The result: **full granularity for recent triage, low-cardinality summaries for long-term trending** — all from the same ingest pipeline, zero agent changes.

    | Capability | Elastic Streams | Splunk |
    |------------|----------------|--------|
    | Retention per data stream | ✅ | ❌ Global policy only |
    | Drop fields inside the platform | ✅ Processing rules | ❌ Collector-level only |
    | Change cardinality control without agent restart | ✅ | ❌ |
    | Reversible — add the field back any time | ✅ | ❌ Data already gone |
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

# Competitive Edge 2: Elastic Streams — Cardinality and Retention Control

The Claro scenario generates real Kubernetes metrics, host metrics, and OTel logs — all flowing into Elastic Streams. In this challenge you'll use the Streams UI to inspect retention settings, add a processing rule to drop a high-cardinality field, and understand why Splunk customers are forced to make this same decision permanently at the agent.

---

## Step 1: Explore the Streams Page

Open the **Elastic Serverless** tab — you should land on the **Streams** page.

You'll see all active data streams for this project:

| Stream | What flows here |
|--------|----------------|
| `logs.otel` | All Claro OTel application logs |
| `traces-generic.otel-default` | Distributed traces from 9 services |
| `metrics-generic.otel-default` | Host and Kubernetes metrics |
| `logs-nginx.access.otel-default` | Nginx access logs |

Click **`logs.otel`** to open its detail page.

---

## Step 2: Inspect Retention and Processing Rules

Inside the `logs.otel` stream, look at:

1. **Retention** — the current setting (likely `7d` after setup, or `Indefinite` if unchanged). This is what Splunk sets globally via DDAA policies. In Elastic, every stream has its own retention.

2. **Processing rules** — the setup script attempted to add a `drop_field` rule for `kubernetes.pod.uid`. If visible, this demonstrates field-level control at the platform — not the agent.

> **The Splunk contrast:** Splunk has no equivalent in-platform field processing layer. To drop `kubernetes.pod.uid`, you must modify the OpenTelemetry Collector configuration — which applies to **all destinations globally**. You cannot keep it in one stream and drop it in another.

---

## Step 3: Add a Processing Rule via the UI

If the processing rule isn't already visible, add one manually:

1. In the `logs.otel` stream detail → click **Processing**
2. Click **Add processor**
3. Select **Drop field**
4. Enter field name: `kubernetes.pod.uid`
5. Leave condition blank (applies to all documents)
6. Click **Save**

This rule now drops `kubernetes.pod.uid` from every new document written to `logs.otel` — **without changing any agent configuration or restarting any collector**.

> In Splunk, this same change requires modifying `otelcol-contrib.yaml`, redeploying the Collector to all nodes, and accepting that the field is now gone from **all Splunk destinations**.

---

## Step 4: Inspect Streams via the API

You can also inspect the stream configuration programmatically. Open a terminal in the **Demo App** tab and run:

```bash
KIBANA_URL=$(agent variable get ES_KIBANA_URL)
ES_API_KEY=$(agent variable get ES_API_KEY)

# List all streams
curl -sk "${KIBANA_URL}/api/streams" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "kbn-xsrf: true" \
  | python3 -c "
import sys, json
data = json.load(sys.stdin)
streams = data.get('streams', data if isinstance(data, list) else [])
print(f'Total streams: {len(streams)}')
for s in streams:
    name = s.get('name', s.get('id', '?'))
    print(f'  {name}')
"
```

Then inspect `logs.otel` specifically:

```bash
curl -sk "${KIBANA_URL}/api/streams/logs.otel" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "kbn-xsrf: true" \
  | python3 -m json.tool | head -40
```

Look for the `ingest.lifecycle.dsl.data_retention` and `ingest.processing` fields.

---

## Step 5: Query Live Log Cardinality with ES|QL

Go to **Discover → ES|QL** and run this to see how many unique services are generating logs — and how fast the cardinality grows:

```esql
FROM logs.otel
| WHERE @timestamp > NOW() - 15 MINUTES
| STATS
    log_count = COUNT(*),
    error_count = COUNT(*) WHERE severity_text == "ERROR",
    services = COUNT_DISTINCT(service.name)
  BY DATE_TRUNC(1 minute, @timestamp)
| SORT `DATE_TRUNC(1 minute, @timestamp)` DESC
| LIMIT 15
```

> Each unique `service.name` × `host.name` × `severity_text` combination would be a **billable MTS in Splunk Observability Cloud**. In Elastic, you pay for storage (GB), not for the number of unique dimension combinations. High-cardinality data costs the same as low-cardinality data.

---

## The Cost Calculation

Claro's 9 services × 3 cloud hosts × 3 severity levels = **81 Metric Time Series** just for log-derived metrics in Splunk.

At Splunk's published MTS pricing (~$0.012/MTS/month × 730 hours):
- **81 MTS × $8.76 = $709/month** just for these dimensions
- Add Kubernetes pod metrics (thousands of unique `pod.uid` values) and the bill explodes

**Elastic's pricing:** You pay for the GB of data stored. Adding more dimensions costs nothing extra.

---

## ✅ Complete When:

- [ ] You explored the Streams page and found `logs.otel` with its retention setting
- [ ] You confirmed (or added) a processing rule to drop a field from `logs.otel`
- [ ] You ran the ES|QL cardinality query and saw log volume by service and minute
- [ ] You understand why Elastic's GB-based pricing eliminates the MTS cardinality tax
