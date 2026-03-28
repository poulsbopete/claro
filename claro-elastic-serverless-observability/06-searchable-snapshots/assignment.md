---
slug: searchable-snapshots
id: krwlj5l6baxp
type: challenge
title: 'Competitive Edge 3: Searchable Snapshots — Audit-Ready Archives, Zero Wait
  Time'
teaser: Query two-year-old audit logs stored in object storage instantly. No rehydration
  jobs. No waiting overnight. No support tickets.
notes:
- type: text
  contents: |
    ## Workshop Slides

    Follow along with the full presentation:

    **[→ Open Workshop Slides](https://poulsbopete.github.io/claro/)**

    *(Opens in a new tab)*
- type: text
  contents: |
    ## The Splunk DDAA Rehydration Problem

    Splunk's **Dynamic Data Active Archive (DDAA)** offloads aged data to Amazon S3 to reduce costs. The problem: **archived data is not searchable in place.** To query it, you must:

    1. File a **rehydration request** in the Splunk UI
    2. Wait for the job to copy data from S3 back into warm storage
    3. Rehydration can take **hours to days** depending on data volume
    4. During an active compliance audit or security incident, your auditors wait

    **Elastic's Frozen Tier is architecturally different.** Data stored in object storage as a Searchable Snapshot remains **directly queryable via the standard Elasticsearch API** — no copy-back, no rehydration queue, no support ticket required.
- type: text
  contents: |
    ## The Elastic Frozen Tier Architecture

    ```
    Elastic Frozen Tier (Searchable Snapshots)
    ├── Data stored as snapshots in S3 / GCS / Azure Blob
    ├── Shard metadata cached locally (minimal footprint)
    ├── On query: relevant data fetched on-demand, cached
    └── Result: full ES|QL API, zero rehydration lag

    Splunk DDAA
    ├── Data stored as Splunk-format files in S3
    ├── NOT searchable in-place
    ├── Requires full copy from S3 → warm storage first
    └── Result: hours/days of blocked auditors
    ```

    | Capability | Elastic Frozen Tier | Splunk DDAA |
    |------------|--------------------|----|
    | Query archived data directly | ✅ Instantly | ❌ Requires rehydration |
    | Rehydration time | None | Hours to days |
    | Same API as hot data | ✅ | ❌ |
    | Cross-tier queries (hot + archive) | ✅ Single query | ❌ Two operations |
tabs:
- id: j4pjehbtzbyz
  title: Demo App
  type: service
  hostname: es3-api
  path: /
  port: 8090
- id: muyjbvxgznzx
  title: Live Dashboard
  type: service
  hostname: es3-api
  path: /dashboard
  port: 8090
- id: qmlv0fcaxr0t
  title: Chaos Controller
  type: service
  hostname: es3-api
  path: /chaos
  port: 8090
- id: t5rwh0cnugeo
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
difficulty: intermediate
timelimit: 2700
enhanced_loading: null
---

# Competitive Edge 3: Searchable Snapshots

## The Scenario

Your compliance team has received a request from a SOC 2 auditor:

> *"We need all `data_export` and `privilege_escalation_attempt` events for any user in the `payments-api` service from **two years ago**. We need results within the hour."*

In Splunk: open a rehydration ticket. Wait.

In Elastic: run a query.

The setup script indexed 500 audit log events timestamped **2 years ago** and 100 recent events — both queryable on the **same wildcard pattern**, with zero tier-switching.

---

## Step 1: Confirm Both Tiers Are Queryable Together

Open the **Elastic Serverless** tab → **Discover → ES|QL**. Set the time range to **Last 3 years**, then run:

```esql
FROM lab6-audit-logs-*
| STATS doc_count = COUNT(),
        earliest  = MIN(@timestamp),
        latest    = MAX(@timestamp)
  BY tier
| SORT earliest ASC
```

> Both `hot` and `frozen` tier documents appear in the **same query result**. There was no rehydration step. This is the moment Splunk customers wish they had.

---

## Step 2: Answer the Auditor's Query

Run the exact query the compliance team needs — directly against two-year-old archival data:

```esql
FROM lab6-audit-logs-*
| WHERE `event.action` IN ("data_export", "privilege_escalation_attempt")
  AND `destination.service` == "payments-api"
| KEEP @timestamp, `user.name`, `user.id`, `event.action`,
       `event.outcome`, `source.ip`, `compliance.framework`
| SORT @timestamp DESC
```

---

## Step 3: Cross-Tier Privilege Escalation Report

A cross-2-year compliance report in a single query — combining archival and recent data:

```esql
FROM lab6-audit-logs-*
| WHERE `event.action` == "privilege_escalation_attempt"
| STATS attempt_count  = COUNT(),
        success_count  = COUNT() WHERE `event.outcome` == "success",
        services_hit   = COUNT_DISTINCT(`destination.service`)
  BY `user.name`
| WHERE attempt_count > 0
| SORT attempt_count DESC
| LIMIT 20
```

> In Splunk: (1) rehydrate archival data, (2) wait, (3) run SPL, (4) separately query Splunk ES if you need security context. In Elastic: one query, one result, one platform.

---

## Step 4: Verify in Kibana Discover

1. In **Elastic Serverless** → **Discover**, click **Open** → select the `Lab 6 - Audit Logs` data view
2. Set time range to **Last 3 years**
3. Observe that documents from 2 years ago and today appear in the same timeline
4. Add filter: `event.action : privilege_escalation_attempt`

All data — regardless of age — is immediately visible and filterable.

---

## ✅ Complete When:

- [ ] The tier query returns both `hot` and `frozen` rows in a single result
- [ ] The auditor query returns results for `data_export` / `privilege_escalation_attempt` on `payments-api`
- [ ] You confirmed results came back in seconds — not after a rehydration queue
