---
slug: high-cardinality-metrics
id: jfly0yxvwbrz
type: challenge
title: 'Competitive Edge 2: High-Cardinality Metrics — Scale Without the Bill Shock'
teaser: Ingest per-pod, per-container Kubernetes metrics with full granularity. No
  MTS caps. No forced pre-aggregation. No surprise invoices.
notes:
- type: text
  contents: |
    ## Why Splunk's MTS Pricing Punishes Scale

    Splunk Observability Cloud prices on **Metric Time Series (MTS)** — every unique combination of metric name + dimension values is a separate billable unit.

    In a Kubernetes environment, each pod × metric × container = a new MTS. A cluster with 2,000 pods reporting 4 metrics each = **8,000 MTS** — just for the basics. At scale this explodes:

    - Pod churn during deployments creates transient MTS spikes
    - High-cardinality dimensions (pod UID, container ID) multiply costs
    - Teams are forced to **drop granular data** to control the bill

    **Elastic stores metrics as documents.** Indexed by compressed GB, not by cardinality. Ingesting 10,000 unique pod metrics costs the same per-GB as ingesting 10.
- type: text
  contents: |
    ## The Elastic Pricing Advantage for Kubernetes

    | Scenario | Elastic | Splunk Observability Cloud |
    |----------|---------|---------------------------|
    | Pricing model | ✅ GB-based | ❌ Per-MTS |
    | Per-pod granularity | ✅ Always available | ❌ Dropped to control costs |
    | Deployment pod churn | ✅ No cost impact | ❌ MTS spike = invoice spike |
    | Container-level drill-down | ✅ Free to keep | ❌ Pre-aggregate or pay |

    > **The Splunk MTS model creates a perverse incentive: drop the granularity you need most precisely when your system is under stress.**
tabs:
- id: ii5idhibvbld
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: ehitf9l3r5af
  title: Live Dashboard
  type: service
  hostname: es3-api
  path: /dashboard
  port: 8090
- id: jfkuxkdzvwat
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: fubi4jj7ikek
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/discover
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

# Competitive Edge 2: High-Cardinality Kubernetes Metrics

The setup script ingested a synthetic Kubernetes cluster dataset: **50 nodes, 20 namespaces, ~200 deployments** — with per-pod and per-container CPU, memory, and network metrics scraped at 30-second intervals for the last hour.

---

## Step 1: Measure the Cardinality — Your MTS Equivalent

Open the **Elastic Serverless** tab → **Discover → ES|QL** and run:

```esql
FROM lab5-k8s-metrics-*
| STATS
    unique_pods       = COUNT_DISTINCT(kubernetes.pod.uid),
    unique_containers = COUNT_DISTINCT(kubernetes.container.id),
    unique_namespaces = COUNT_DISTINCT(kubernetes.namespace),
    total_docs        = COUNT()
| EVAL splunk_mts_estimate      = unique_pods * 4,
       splunk_monthly_cost_usd  = splunk_mts_estimate * 0.012 * 730
```

> `splunk_mts_estimate` = the MTS count Splunk OC would bill for (4 metrics × unique pods).
> `splunk_monthly_cost_usd` = estimated monthly Splunk cost at ~$0.012/MTS/hour × 730 hours.
>
> In Elastic, this entire dataset costs based only on **compressed GB stored**.

---

## Step 2: Query With Full Per-Container Granularity

This is a query **Splunk customers cannot run** without dropping the `container.id` dimension first (doing so would require pre-aggregation, losing the ability to drill into individual containers):

```esql
FROM lab5-k8s-metrics-*
| WHERE @timestamp > NOW() - 30 minutes
| STATS avg_cpu_cores = AVG(kubernetes.pod.cpu.usage.nanocores) / 1000000000,
        max_cpu_cores = MAX(kubernetes.pod.cpu.usage.nanocores) / 1000000000
  BY kubernetes.container.id, kubernetes.pod.name, kubernetes.namespace
| SORT avg_cpu_cores DESC
| LIMIT 10
```

---

## Step 3: Namespace-Level Capacity View

The view Splunk customers *can* build — but Elastic gives you both levels without forcing a choice:

```esql
FROM lab5-k8s-metrics-*
| WHERE @timestamp > NOW() - 5 minutes
| STATS avg_cpu_cores = AVG(kubernetes.pod.cpu.usage.nanocores) / 1000000000,
        avg_mem_gb    = AVG(kubernetes.pod.memory.rss.bytes) / 1073741824,
        pod_count     = COUNT_DISTINCT(kubernetes.pod.uid)
  BY kubernetes.namespace
| SORT avg_cpu_cores DESC
| LIMIT 20
```

---

## Step 4: Visualize in Kibana (Recommended)

1. In **Elastic Serverless** → **Discover** select the `Lab 5 - Kubernetes Metrics` data view
2. Set time range to **Last 1 hour**
3. Add fields: `kubernetes.namespace`, `kubernetes.pod.uid`, `kubernetes.pod.cpu.usage.nanocores`
4. Click **Visualize** on the CPU field → **Top values by kubernetes.pod.uid**

> Splunk OC customers must pre-aggregate `pod.uid` away to control MTS costs. In Elastic it is just a field in a document — always available, always free to filter by.

---

## ✅ Complete When:

- [ ] The cardinality query returns `splunk_mts_estimate` and `splunk_monthly_cost_usd`
- [ ] The per-container CPU query returns results grouped by `container.id` (impossible in Splunk without cost penalty)
- [ ] The namespace capacity view returns data for all 20 namespaces
