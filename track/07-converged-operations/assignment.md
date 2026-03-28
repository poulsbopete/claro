---
slug: converged-operations
id: urvrw8ilmvn9
type: challenge
title: 'Competitive Edge 4: Converged Operations — SIEM Value Without Double Ingest'
teaser: Enable a security detection rule on logs you already ingested. No separate
  Splunk ES license. No second ingest pipeline. Zero extra cost.
notes:
- type: text
  contents: |
    ## The Splunk Enterprise Security Tax

    To get SIEM detection on application logs in Splunk, you need:

    - **Splunk Cloud** — for observability (logs, metrics)
    - **Splunk Enterprise Security** — a separate, expensive product with its own license
    - **CIM normalization** — your logs must be mapped to Splunk's Common Information Model
    - **Double ingest** — data typically flows into both Splunk Cloud *and* Splunk ES separately

    The result: SIEM coverage on app logs costs approximately **2× the ingest cost** plus an additional ES license plus CIM mapping work.

    **In Elastic, observability data is security data.** The same Elasticsearch index that powers your APM dashboards can be targeted by Elastic Security detection rules — no additional ingest, no second license, no CIM.
- type: text
  contents: |
    ## The Elastic Converged Operations Advantage

    | Capability | Elastic | Splunk |
    |------------|---------|--------|
    | Detection rules on observability data | ✅ Same index | ❌ Separate product |
    | Extra ingest for SIEM coverage | ✅ Zero | ❌ Full double-ingest |
    | CIM / normalization required | ✅ None (ECS native) | ❌ CIM mapping required |
    | Alert → trace correlation | ✅ Same platform | ❌ Cross-product navigation |
    | Single license for obs + security | ✅ | ❌ Cloud + ES licenses |

    > **Splunk's model creates a financial disincentive to security coverage.** Every log that could be a security signal costs twice as much to protect.
tabs:
- id: xufxvrksrpet
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: lkg2icza9qwo
  title: Live Dashboard
  type: service
  hostname: es3-api
  path: /dashboard
  port: 8090
- id: rfolxbyvzemr
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: pcswyicg95ws
  title: Elastic Serverless
  type: service
  hostname: es3-api
  path: /app/security/alerts
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

# Competitive Edge 4: Converged Operations

## The Scenario

The setup script injected a **brute-force attack pattern** into `lab4-app-logs-*` — the same observability index used in Challenge 1:

- **15 authentication failures** from IP `198.51.100.42` within 5 minutes
- **1 successful login** at the end — the brute force succeeded
- **Target user:** `admin` on `/api/auth/login`

A Kibana Security detection rule was pre-created targeting this index.

---

## Step 1: Confirm the Attack Is in Your Observability Index

Open the **Elastic Serverless** tab → **Discover → ES|QL**:

```esql
FROM lab4-app-logs-*
| WHERE source.ip == "198.51.100.42"
| KEEP @timestamp, log.level, message, event.action, event.outcome,
       http.response.status_code
| SORT @timestamp ASC
```

> **This is the critical insight:** You are querying `lab4-app-logs-*` — the **same observability index from Challenge 1.** No separate SIEM ingest. No data duplication. No additional cost.

---

## Step 2: Run the Brute-Force Detection Logic

This is the logic underlying your detection rule:

```esql
FROM lab4-app-logs-*
| WHERE @timestamp > NOW() - 15 minutes
  AND http.response.status_code == 401
| STATS failure_count    = COUNT(),
        endpoints_hit    = COUNT_DISTINCT(url.path)
  BY source.ip, user.name
| WHERE failure_count >= 5
| SORT failure_count DESC
```

---

## Step 3: View the Detection Rule in Kibana Security

1. In the **Elastic Serverless** tab navigate to **Security → Rules → Detection Rules**
2. Find **"[Lab 7] Brute Force: Auth Failures on Observability Logs"**
3. Confirm:
   - Status: **Enabled**
   - Index pattern: `lab4-app-logs-*` ← your observability index, not a SIEM-specific index
   - MITRE ATT&CK mapping: `T1110 - Brute Force`

---

## Step 4: View the Generated Alert

1. Navigate to **Security → Alerts**
2. Click any alert to expand it
3. Note the source index in the alert details: `lab4-app-logs-*`
4. Click **Investigate in Timeline** — you see the raw log events directly

> In Splunk ES, this alert would reference data from a CIM-normalized SIEM datastore, separate from your observability data. In Elastic, the alert points directly to the **original observability log document.**

---

## Step 5: Pivot Alert → Trace (The Full Circle)

From the alert Timeline view, find a log event and note the `trace.id` field.

Run this in ES|QL to close the loop — from security alert to the original APM trace:

```esql
FROM lab4-apm-traces-*
| WHERE trace.id == "<trace-id-from-alert>"
| KEEP @timestamp, service.name, span.duration.us,
       http.response.status_code, error.message
```

> Security → Observability → APM — all in one platform, all at zero additional data cost.

---

## ✅ Complete When:

- [ ] The ES|QL query confirms the brute-force events exist in `lab4-app-logs-*` (the observability index)
- [ ] The detection rule in Kibana Security shows `lab4-app-logs-*` as its target index
- [ ] A security alert is visible in Security → Alerts
- [ ] You confirmed no separate SIEM index or double-ingest was required
