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
    - ✅ Explore the Executive Dashboard for the Claro scenario
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
    Mobile Core · Billing Engine · SMS Gateway · Customer Portal · Content Delivery · Network Analytics · Voice Platform · IoT Connect · NOC Dashboard

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

    **5G PDU session latency over time:**
    ```
    TS metrics*
    | WHERE @timestamp > NOW() - 30 MINUTES
    | EVAL minute = DATE_TRUNC(1 minute, @timestamp)
    | STATS avg_pdu_latency = AVG(mobile_core.pdu_session_latency_ms) BY minute
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
- `service.name`: `mobile-core`, `billing-engine`, `sms-gateway`, `customer-portal`, `content-delivery`, `network-analytics`, `voice-platform`, `iot-connect`, `noc-dashboard`
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
   - `claro-aws-core-01` (AWS us-east-1 — Mobile Core & Billing)
   - `claro-gcp-digital-01` (GCP us-central1 — Digital Services)
   - `claro-azure-ops-01` (Azure eastus — Voice, IoT & NOC)
3. Click a host to see CPU, memory, disk, and network metrics

> **Note:** If hosts don't appear immediately, wait 1–2 minutes for the host metrics generator to send its first batch.

---

## Explore #4 — ES|QL Time Series Queries

In the **Elastic Serverless** tab → **Discover** → **ES|QL** mode, try these queries against the live metrics stream.

### 5G core health at a glance
```esql
TS metrics*
| WHERE @timestamp > NOW() - 15 MINUTES
| EVAL minute = DATE_TRUNC(1 minute, @timestamp)
| STATS
    sessions_5g    = AVG(mobile_core.active_sessions_5g),
    sessions_lte   = AVG(mobile_core.active_sessions_lte),
    pdu_latency_ms = AVG(mobile_core.pdu_session_latency_ms),
    ho_success_pct = AVG(mobile_core.handover_success_rate)
  BY minute
| SORT minute DESC
```

### Spot an OCS billing latency spike before subscribers notice
```esql
TS metrics*
| WHERE @timestamp > NOW() - 30 MINUTES
| EVAL minute = DATE_TRUNC(1 minute, @timestamp)
| STATS avg_ocs_latency = AVG(billing_engine.ocs_ccr_latency_ms) BY minute
| EVAL status = CASE(
    avg_ocs_latency > 2000, "🔴 CRITICAL — Prepaid subscribers blocked",
    avg_ocs_latency > 500,  "🟡 DEGRADED — OCS responding slowly",
    "🟢 HEALTHY"
  )
| SORT minute DESC
```

### CDN cache hit rate vs origin load (Claro TV)
```esql
TS metrics*
| WHERE @timestamp > NOW() - 20 MINUTES
| EVAL minute = DATE_TRUNC(1 minute, @timestamp)
| STATS
    cache_hit_pct = AVG(content_delivery.cache_hit_rate),
    origin_rps    = AVG(content_delivery.origin_rps),
    rebuffer_pct  = AVG(content_delivery.video_rebuffer_rate)
  BY minute
| EVAL cdn_health = CASE(
    cache_hit_pct < 30, "🔴 PURGE STORM — origin overloaded",
    cache_hit_pct < 70, "🟡 DEGRADED",
    "🟢 HEALTHY"
  )
| SORT minute DESC
```

### Multi-cloud voice trunk, IoT broker, and NOC alert rate
```esql
TS metrics*
| WHERE @timestamp > NOW() - 30 MINUTES
| EVAL bucket5m = DATE_TRUNC(5 minutes, @timestamp)
| STATS
    sip_trunk_util   = AVG(voice_platform.sip_trunk_utilization_pct),
    mqtt_connections = AVG(iot_connect.mqtt_connections),
    noc_alert_rate   = AVG(noc_dashboard.alert_rate_per_min)
  BY bucket5m
| EVAL voice_risk = CASE(
    sip_trunk_util > 90, "🔴 SIP SATURATED",
    sip_trunk_util > 70, "🟡 HIGH LOAD",
    "🟢 OK"
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

**Elastic Serverless** tab → **Dashboards** → search "Claro" (or "Executive")

✅ **Ready to continue when** you've seen logs, traces, or metrics in Elastic Serverless and confirmed services are healthy.
