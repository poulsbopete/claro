---
slug: high-cardinality-metrics
id: tmnahuexgbwt
type: challenge
title: 'Competitive Edge 2: Elastic Streams — Control Cardinality and Retention Without
  Dropping Data'
teaser: Use Elastic Streams to route high-cardinality Kubernetes metrics into tiered
  streams with different retention policies — keeping full granularity short-term
  and aggregated data long-term. No MTS pricing. No agent changes.
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

    - **Set retention** — keep detailed data for 7 days, aggregated data for 90 days
    - **Apply processing rules** — drop high-cardinality fields (`pod.uid`, `container.id`) from a long-retention stream while keeping them in a short-retention stream
    - **Fork streams** — route a subset of data (e.g. only ERROR events) to a separate stream with its own lifecycle

    The result: **full per-pod granularity for recent triage, low-cardinality summaries for long-term trending** — all from the same ingest pipeline, zero agent changes.

    | Capability | Elastic Streams | Splunk |
    |------------|----------------|--------|
    | Retention per data stream | ✅ | ❌ Global policy only |
    | Drop fields inside the platform | ✅ Processing rules | ❌ Collector-level only |
    | Fork high-cardinality → short retention | ✅ | ❌ Manual re-configuration |
    | Control cardinality without agent changes | ✅ | ❌ |
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

## The Scenario

Your platform team is ingesting Kubernetes metrics with full per-pod, per-container granularity. For incident triage you need the detail. For capacity trending you only need namespace-level aggregates. In Splunk, you must choose one or the other — globally, at the agent. In Elastic, you configure both as streams.

The setup script created two streams in your Elastic Serverless project:

| Stream | Retention | Fields Kept |
|--------|-----------|-------------|
| `lab5-k8s-detailed` | **7 days** | All fields including `kubernetes.pod.uid`, `kubernetes.container.id` |
| `lab5-k8s-summary` | **90 days** | High-cardinality fields (`pod.uid`, `container.id`) dropped by processing rule |

---

## Step 1: Inspect the Streams in Kibana

Open the **Elastic Serverless** tab — you should land on the **Streams** page. Locate `lab5-k8s-detailed` and `lab5-k8s-summary` in the list.

Click each stream and review:
- The **Retention** setting (7d vs 90d)
- The **Processing rules** on `lab5-k8s-summary` — note the `drop_field` processors for `kubernetes.pod.uid` and `kubernetes.container.id`

> This is the Splunk contrast: Splunk has no equivalent in-platform processing rule layer. The only option is to modify the OpenTelemetry Collector configuration, which applies globally to all destinations.

---

## Step 2: Inspect Stream Configuration via the API

The setup used the Kibana Streams API. You can inspect the current state:

```bash
KIBANA_URL=$(agent variable get ES_KIBANA_URL)
ES_API_KEY=$(agent variable get ES_API_KEY)

# List all lab5 streams
curl -sk "${KIBANA_URL}/api/streams" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  | python3 -c "
import sys, json
streams = json.load(sys.stdin).get('streams', [])
lab5 = [s for s in streams if 'lab5' in s.get('name','')]
for s in lab5:
    print(s.get('name'), '—', json.dumps(s, indent=2))
"
```

---

## Step 3: Read the Retention and Processing Rules

```bash
KIBANA_URL=$(agent variable get ES_KIBANA_URL)
ES_API_KEY=$(agent variable get ES_API_KEY)

# Detailed stream — full granularity, short retention
echo "=== lab5-k8s-detailed ingest settings ==="
curl -sk "${KIBANA_URL}/api/streams/lab5-k8s-detailed/_ingest" \
  -H "Authorization: ApiKey ${ES_API_KEY}" | python3 -m json.tool

echo ""
echo "=== lab5-k8s-summary ingest settings ==="
curl -sk "${KIBANA_URL}/api/streams/lab5-k8s-summary/_ingest" \
  -H "Authorization: ApiKey ${ES_API_KEY}" | python3 -m json.tool
```

> In the `lab5-k8s-summary` response, look for the `processing` array. You will see `drop_field` processors for `kubernetes.pod.uid` and `kubernetes.container.id` — the exact fields Splunk customers must globally remove at the agent to control MTS costs. In Elastic, they are kept in `lab5-k8s-detailed` for triage and removed only from the long-retention summary stream.

---

## Step 4: Query Each Stream to See the Difference

Open the **Elastic Serverless** tab → **Discover → ES|QL**:

**Full-granularity query against the detailed stream (7-day window, full pod/container dims):**

```esql
FROM lab5-k8s-detailed
| WHERE @timestamp > NOW() - 30 minutes
| STATS avg_cpu_cores = AVG(kubernetes.pod.cpu.usage.nanocores) / 1000000000,
        max_cpu_cores = MAX(kubernetes.pod.cpu.usage.nanocores) / 1000000000
  BY kubernetes.pod.uid, kubernetes.container.id, kubernetes.namespace
| SORT avg_cpu_cores DESC
| LIMIT 10
```

**Aggregated query against the summary stream (90-day window, no pod/container dims):**

```esql
FROM lab5-k8s-summary
| STATS avg_cpu_cores = AVG(kubernetes.pod.cpu.usage.nanocores) / 1000000000,
        pod_count     = COUNT_DISTINCT(kubernetes.pod.name)
  BY kubernetes.namespace, kubernetes.node.name
| SORT avg_cpu_cores DESC
| LIMIT 20
```

> The second query is the only query Splunk customers can run if they dropped `pod.uid` and `container.id` to control MTS costs. In Elastic, both queries work — using different streams with different retention and cost profiles.

---

## Step 5: Calculate the Cost Difference

```bash
ES_URL=$(agent variable get ES_URL)
ES_API_KEY=$(agent variable get ES_API_KEY)

# Count unique pod UIDs in detailed stream (= Splunk MTS for those dims)
curl -sk -X POST "${ES_URL}/lab5-k8s-detailed/_search" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"size":0,"aggs":{"pods":{"cardinality":{"field":"kubernetes.pod.uid"}},"containers":{"cardinality":{"field":"kubernetes.container.id"}}}}' \
  | python3 -c "
import sys, json
r = json.load(sys.stdin)['aggregations']
pods = r['pods']['value']
conts = r['containers']['value']
mts = pods * 4
print(f'Unique pods (detailed stream):      {pods}')
print(f'Unique containers (detailed stream):{conts}')
print(f'Splunk MTS equivalent:              {mts:,}  (4 metrics × {pods} pods)')
print(f'Splunk monthly cost estimate:       \${mts * 0.012 * 730:,.0f}')
print()
print('Elastic approach:')
print('  detailed stream (7d)  — full cardinality, short-lived, low storage')
print('  summary stream (90d)  — aggregated, long-lived, drop high-cardinality fields')
print('  Total Elastic cost:   GB-based. No per-MTS charge. Ever.')
"
```

---

## Why This Matters More Than Just Pricing

Splunk's constraint forces a **one-time, irrevocable architectural decision** at the agent: drop the dimension or pay. If you drop it, you can never query per-pod data historically — not for incident review, not for billing attribution, not for compliance.

Elastic Streams lets you make this decision **declaratively, inside the platform, at any time, reversibly.** Change the retention. Add a processing rule. Fork a new stream. No agent restarts, no pipeline redeploys.

---

## ✅ Complete When:

- [ ] You inspected both streams in Kibana → Streams and confirmed different retention policies
- [ ] The `lab5-k8s-summary` ingest settings show `drop_field` processing rules for `pod.uid` and `container.id`
- [ ] The per-pod query works against `lab5-k8s-detailed` but the summary stream only returns namespace-level data
- [ ] You calculated the Splunk MTS equivalent cost using the cardinality query
