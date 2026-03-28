# Lab 2: High-Cardinality Metrics — Scale Without the Bill Shock

## Why High Cardinality Breaks Splunk's Pricing Model

Splunk Observability Cloud prices on **Metric Time Series (MTS)**. An MTS is defined as:

> One unique combination of {metric name} + {dimension values}

Consider a single Kubernetes pod metric — `container.cpu.usage`:

| Dimension | Value |
|-----------|-------|
| `cluster` | `prod-us-east-1` |
| `namespace` | `ns-payments` |
| `pod.uid` | `3f8a1c...` (unique per pod instance) |
| `container.id` | `containerd://9b2c...` (unique per container) |
| `node.name` | `ip-10-0-112-45` |

Every unique pod/container combination creates a **new MTS**. A cluster with 2,000 pods × 4 metrics × 3 containers = **24,000 MTS** — just for CPU, memory, and network. Enterprise Kubernetes environments regularly exceed **500,000–1,000,000+ MTS**.

Splunk charges per MTS. Teams are forced to:
- **Drop high-cardinality dimensions** (pod UID, container ID, user ID)
- **Pre-aggregate before ingest** — losing the ability to drill into individual pods
- **Pay surprise invoices** when rollouts temporarily spike pod counts

**Elastic has no MTS pricing.** Storage is charged by compressed GB. Ingesting a metric with 10,000 unique pod dimensions costs the same per-GB as ingesting 10.

---

## What Was Set Up For You

The setup script ingested a synthetic Kubernetes cluster dataset:

| Attribute | Value |
|-----------|-------|
| Cluster | `prod-us-east-1` |
| Nodes | 50 |
| Namespaces | 20 |
| Deployments | ~200 |
| Metrics captured | CPU, Memory, Network RX/TX |
| Time range | Last 60 minutes (30-second scrape intervals) |

---

## Step 1: Confirm Data Volume and Unique Cardinality

```bash
source /etc/profile.d/lab2_env.sh

# Total document count
curl -sk "${ES_URL}/lab2-k8s-metrics-*/_count" \
  -H "Authorization: ApiKey ${ES_API_KEY}" | jq .count

# Unique pod UIDs — this is your MTS count in Splunk
curl -sk -X POST "${ES_URL}/lab2-k8s-metrics-*/_search" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "size": 0,
    "aggs": {
      "unique_pods": { "cardinality": { "field": "kubernetes.pod.uid" } },
      "unique_containers": { "cardinality": { "field": "kubernetes.container.id" } }
    }
  }' | jq '.aggregations'
```

---

## Step 2: Calculate the Splunk MTS Cost Equivalent

Run this ES|QL query to expose the MTS cost dimension that Splunk would charge for:

```bash
curl -sk -X POST "${ES_URL}/_query" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "FROM lab2-k8s-metrics-* | STATS unique_pods = COUNT_DISTINCT(kubernetes.pod.uid), unique_containers = COUNT_DISTINCT(kubernetes.container.id), unique_namespaces = COUNT_DISTINCT(kubernetes.namespace), unique_nodes = COUNT_DISTINCT(kubernetes.node.name), total_docs = COUNT() | EVAL splunk_mts_estimate = unique_pods * 4, splunk_monthly_cost_usd = splunk_mts_estimate * 0.012 * 730"
  }' | jq '.values[0]'
```

> **Reading the output:**
> - `splunk_mts_estimate` = the MTS count Splunk would bill for (4 metrics × unique pod count)
> - `splunk_monthly_cost_usd` = estimated monthly Splunk OC cost at ~$0.012/MTS/hour
> - In Elastic, this data costs based on **compressed GB stored** — no per-MTS charge

---

## Step 3: Query With Full Granularity — No Dimension Dropping

Run a query that Splunk customers **cannot run** without dropping dimensions first:

```bash
# Find the top 10 most CPU-hungry containers by their exact container ID
# (Splunk customers must pre-aggregate away container.id to control MTS costs)
curl -sk -X POST "${ES_URL}/_query" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "FROM lab2-k8s-metrics-* | WHERE @timestamp > NOW() - 30 minutes | STATS avg_cpu = AVG(kubernetes.pod.cpu.usage.nanocores), max_cpu = MAX(kubernetes.pod.cpu.usage.nanocores) BY kubernetes.container.id, kubernetes.pod.name, kubernetes.namespace, kubernetes.node.name | SORT avg_cpu DESC | LIMIT 10"
  }' | jq '.values[] | {container: .[2], pod: .[3], namespace: .[4], avg_cpu_cores: (.[0] / 1000000000 | . * 100 | round / 100)}'
```

---

## Step 4: Namespace-Level Capacity View

This is the aggregated view Splunk customers CAN build — but Elastic gives you both levels:

```bash
curl -sk -X POST "${ES_URL}/_query" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "FROM lab2-k8s-metrics-* | WHERE @timestamp > NOW() - 5 minutes | STATS avg_cpu_cores = AVG(kubernetes.pod.cpu.usage.nanocores) / 1000000000, avg_mem_gb = AVG(kubernetes.pod.memory.rss.bytes) / 1073741824, pod_count = COUNT_DISTINCT(kubernetes.pod.uid) BY kubernetes.namespace | SORT avg_cpu_cores DESC | LIMIT 20"
  }' | jq '.values[] | {namespace: .[3], pods: .[2], avg_cpu_cores: (.[0] | . * 100 | round / 100), avg_mem_gb: (.[1] | . * 100 | round / 100)}'
```

---

## Step 5: Visualize in Kibana (Optional)

1. Open the **Kibana** tab
2. Go to **Analytics → Discover**
3. Select the **"Lab 2 - Kubernetes Metrics"** data view
4. Set the time range to **Last 1 hour**
5. In the field sidebar, add:
   - `kubernetes.namespace`
   - `kubernetes.pod.uid`
   - `kubernetes.pod.cpu.usage.nanocores`
   - `kubernetes.container.memory.limit.bytes`
6. Click **Visualize** on `kubernetes.pod.cpu.usage.nanocores` → **Top 10 values by kubernetes.pod.uid**

> In Splunk OC, visualizing by `pod.uid` requires that dimension to be in the MTS — adding an MTS per pod. In Elastic, it is just a field in a document.

---

## Competitive Takeaway

| Capability | Elastic | Splunk Observability Cloud |
|------------|---------|---------------------------|
| Pricing model | ✅ GB-based | ❌ Per-MTS |
| High-cardinality pod/container dims | ✅ Free to keep | ❌ Forces pre-aggregation |
| Drill to individual container | ✅ Always available | ❌ Dropped to control costs |
| Predictable costs during scaling events | ✅ | ❌ MTS spike = invoice spike |
| Kubernetes rollouts | ✅ No cost impact | ❌ Pod churn drives MTS explosion |

> **The Splunk MTS model creates a perverse incentive: drop the granularity you need most precisely when your system is under stress.** Elastic's document model means your instrumentation decisions are never constrained by your billing model.

---

## ✅ Lab Complete When:

- [ ] You can see unique pod/container cardinality counts in the aggregation
- [ ] The MTS cost equivalent query returns a `splunk_monthly_cost_usd` value
- [ ] You successfully ran the container-level CPU query (the one Splunk customers must drop)
