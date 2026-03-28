---
slug: explore-telemetry
id: sxt25jeemymj
type: challenge
title: Explore Live OpenTelemetry Data
teaser: Navigate Elastic Serverless to see logs, distributed traces, and host metrics
  flowing from 9 simulated microservices across three cloud providers.
notes:
- type: text
  contents: |
    ## Lab 2 — Explore Live OpenTelemetry Data

    **By the end of this challenge you will:**

    - ✅ Query live logs with ES|QL in Discover
    - ✅ View distributed traces and service maps in APM
    - ✅ Inspect host metrics across 3 simulated cloud providers
    - ✅ Explore the Executive Dashboard for the Fanatics scenario
    - ✅ Run time-series ES|QL queries against live metric streams

    **Your data is real.** Every log, trace, and metric is generated fresh and shipped via OTLP directly to Elastic — no recordings, no synthetic replay.
- type: text
  contents: |
    ## Three Signals, One Store

    Elastic correlates logs, metrics, and traces in a single data store — no switching tools, no context loss.

    | Signal | Where to look | Index pattern |
    |--------|--------------|---------------|
    | **Logs** | Discover → ES\|QL | `logs*` |
    | **Traces** | Applications → Service inventory | `traces-*` |
    | **Metrics** | Observability → Infrastructure | `metrics-*` |

    Signals connect automatically — a trace span links to its log lines via `trace.id`, and error spikes correlate with host CPU in the same timeline.
- type: text
  contents: |
    ## What's Generating Telemetry

    **9 scenario microservices** (application logs + traces):
    Auction Engine · Card Printing · Payment Processing · Fan Engagement · Loyalty Rewards · Streaming CDN · Navigation · Fraud Detection · Fulfillment

    **Background generators** (infrastructure telemetry):
    - 3 cloud hosts (AWS, GCP, Azure) — CPU, memory, disk, network
    - Kubernetes node + pod metrics
    - Nginx access logs and MySQL slow query logs
    - VPC flow logs and distributed trace chains

    > **Tip:** Set the time range to **Last 15 minutes** to see the freshest data.
- type: text
  contents: |
    ## ES|QL: Query Telemetry Like a Pipeline

    ES|QL is Elastic's pipe-based query language. Run these in **Discover → ES|QL** during the challenge:

    **Error spike by service:**
    ```
    FROM logs*
    | WHERE @timestamp > NOW() - 15 MINUTES
    | WHERE severity_text == "ERROR"
    | STATS errors = COUNT(*) BY service.name
    | SORT errors DESC
    ```

    **Latency trend over time:**
    ```
    TS metrics*
    | WHERE @timestamp > NOW() - 30 MINUTES
    | EVAL minute = DATE_TRUNC(1 minute, @timestamp)
    | STATS avg_latency = AVG(auction.bid_latency_ms) BY minute
    | SORT minute DESC
    ```
tabs:
- id: zwxgngz79zta
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: lulkkj99gnak
  title: Live Dashboard
  type: service
  hostname: es3-api
  path: /dashboard
  port: 8090
- id: vfexjvy3bluo
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: awkrxylku1hz
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/dashboards#/list?_g=(filters:!(),refreshInterval:(pause:!f,value:30000),time:(from:now-30m,to:now))
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
timelimit: 0
enhanced_loading: null
---

# Explore Live OpenTelemetry Telemetry

Now that your scenario is running, let's explore the data flowing into Elastic. Open the **Elastic Serverless** tab.

---

## What's Generating Telemetry

The platform runs several background generators simultaneously:

| Generator | What It Produces |
|-----------|-----------------|
| **9 scenario services** | Application logs, traces, errors |
| **Host metrics** | CPU, memory, disk, network for 3 cloud hosts |
| **Kubernetes metrics** | Node, pod, container metrics |
| **Nginx metrics + logs** | Access logs, error logs, request spans |
| **MySQL logs** | Slow query + error logs |
| **VPC flow logs** | Network flow telemetry |
| **Distributed traces** | Multi-service request chains |

---

## Explore #1 — Logs via ES|QL

1. In the **Elastic Serverless** tab → **Discover**
2. Switch to **ES|QL** mode (top-left toggle)
3. Run this query:

```esql
FROM logs*
| WHERE @timestamp > NOW() - 5 MINUTES
| KEEP service.name, body.text, severity_text, @timestamp
| SORT @timestamp DESC
| LIMIT 50
```

You should see a stream of logs from multiple services. Once you confirm data is flowing, try filtering to errors only:

```esql
FROM logs*
| WHERE @timestamp > NOW() - 15 MINUTES
| WHERE severity_text == "ERROR"
| STATS error_count = COUNT(*) BY service.name
| SORT error_count DESC
```

**Things to notice:**
- `service.name`: `auction-engine`, `card-printing-system`, `digital-marketplace`, `packaging-fulfillment`, `cloud-inventory-scanner`, `nginx-proxy`, `mysql-primary`, and more
- `severity_text`: `INFO`, `WARN`, `ERROR`
- `body.text` contains the raw log message and error type

---

## Explore #2 — APM / Services

1. In the **Elastic Serverless** tab → **Applications → Service inventory**
2. You should see **7 services** — the 5 application services plus `nginx-proxy` and `mysql-primary`
   > The remaining 2 network/infrastructure services (`wifi-controller`, `network-controller`, `firewall-gateway`, `dns-dhcp-service`) emit logs only — no traces — so they won't appear here
3. Click any service to see latency, throughput, and error rate
4. Open a transaction to see the **distributed trace waterfall**

---

## Explore #3 — Infrastructure / Hosts

1. In the **Elastic Serverless** tab → **Observability → Infrastructure**
2. You should see 3 hosts — one per cloud provider:
   - `fanatics-aws-host-01`
   - `fanatics-gcp-host-01`
   - `fanatics-azure-host-01`
3. Click a host to see CPU, memory, disk, and network metrics

> **Note:** If hosts don't appear immediately, wait 1–2 minutes for the host metrics generator to send its first batch.

---

## Explore #4 — ES|QL Time Series Queries

In the **Elastic Serverless** tab → **Discover** → **ES|QL** mode, try these queries against the live metrics stream.

### Auction health at a glance
```esql
TS metrics*
| WHERE @timestamp > NOW() - 15 MINUTES
| EVAL minute = DATE_TRUNC(1 minute, @timestamp)
| STATS
    active_auctions = AVG(auction.active_auctions),
    bid_latency_ms  = AVG(auction.bid_latency_ms),
    bids_per_min    = AVG(auction.bids_per_min),
    websocket_conns = AVG(auction.websocket_connections)
  BY minute
| SORT minute DESC
```

### Spot a latency spike before users notice
```esql
TS metrics*
| WHERE @timestamp > NOW() - 30 MINUTES
| EVAL minute = DATE_TRUNC(1 minute, @timestamp)
| STATS avg_latency = AVG(auction.bid_latency_ms) BY minute
| EVAL status = CASE(
    avg_latency > 45, "🔴 CRITICAL",
    avg_latency > 30, "🟡 DEGRADED",
    "🟢 HEALTHY"
  )
| SORT minute DESC
```

### Card printing throughput vs queue depth
```esql
TS metrics*
| WHERE @timestamp > NOW() - 20 MINUTES
| EVAL minute = DATE_TRUNC(1 minute, @timestamp)
| STATS
    queue_depth    = AVG(card_printing.queue_depth),
    throughput     = AVG(card_printing.throughput),
    substrate_temp = AVG(card_printing.substrate_temp)
  BY minute
| EVAL backlog_ratio = ROUND(queue_depth / throughput, 2)
| SORT minute DESC
```

### Multi-cloud compliance drift
```esql
TS metrics*
| WHERE @timestamp > NOW() - 30 MINUTES
| EVAL bucket5m = DATE_TRUNC(5 minutes, @timestamp)
| STATS
    aws_compliance   = AVG(cloud_inventory.aws.compliance_pct),
    gcp_compliance   = AVG(cloud_inventory.gcp.compliance_pct),
    azure_compliance = AVG(cloud_inventory.azure.compliance_pct)
  BY bucket5m
| EVAL lowest = LEAST(aws_compliance, gcp_compliance, azure_compliance)
| EVAL at_risk_cloud = CASE(
    lowest == aws_compliance, "AWS",
    lowest == gcp_compliance, "GCP",
    "Azure"
  )
| SORT bucket5m DESC
```

### Log volume by service and severity over time
```esql
FROM logs*
| WHERE @timestamp > NOW() - 30 MINUTES
| EVAL minute = DATE_TRUNC(1 minute, @timestamp)
| STATS
    errors = COUNT(*) WHERE severity_text == "ERROR",
    warnings = COUNT(*) WHERE severity_text == "WARN",
    total  = COUNT(*)
  BY minute, service.name
| SORT minute DESC, total DESC
```

> **Tip:** After triggering a chaos fault in the next challenge, re-run this query to watch the error count spike for the affected service in real time — while healthy services stay flat.

---

## Explore #5 — Dashboards

The deployer created an **Executive Dashboard** pre-configured for your scenario. Find it in:

**Elastic Serverless** tab → **Dashboards** → search "Fanatics" (or "Executive")

✅ **Ready to continue when** you've seen logs, traces, or metrics in Elastic Serverless and confirmed services are healthy.
