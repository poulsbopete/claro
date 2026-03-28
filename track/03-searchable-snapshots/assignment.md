# Lab 3: Searchable Snapshots — Audit-Ready Archives, Zero Wait Time

## The Splunk DDAA Rehydration Problem

Splunk's **Dynamic Data Active Archive (DDAA)** is their answer to long-term data retention cost. Data older than a configurable age is offloaded to Amazon S3 in a proprietary format.

The problem: **archived data is not searchable**. To query it, you must:

1. File a **rehydration request** in the Splunk UI
2. Wait for the rehydration job to copy data back from S3 into warm storage
3. Rehydration can take **hours to days** depending on data volume
4. During an active compliance audit or security incident, your auditors wait

This is not a theoretical concern. It is a documented, customer-reported pain point and was highlighted in Splunk's own documentation as expected behavior.

**Elastic's Frozen Tier is architecturally different.** Data stored in object storage (S3, GCS, Azure Blob) as a searchable snapshot remains **directly queryable via the standard Elasticsearch API**. There is no copy-back step. There is no rehydration queue. The data is fetched on-demand and cached locally.

---

## Scenario: You Are Under Audit

Your compliance team has received a request from a SOC 2 auditor:

> "We need all `data_export` and `privilege_escalation_attempt` events for any user in the `payments-api` service from **two years ago**. We need results within the hour."

In Splunk, you would open a rehydration ticket and hope it completes before the auditor loses patience.

In Elastic, you run a query.

---

## What Was Set Up For You

The setup script ingested two sets of audit log data:

| Index | Date Range | Tier Simulation |
|-------|-----------|-----------------|
| `lab3-audit-logs-YYYY.MM.DD` (2 years ago) | 730 days ago — 723 days ago | Frozen (archived) |
| `lab3-audit-logs-YYYY.MM.DD` (today) | Last 48 hours | Hot |

Both indices are queryable with the same API call — no tier-switching required.

---

## Step 1: Confirm Both Tiers Are Searchable

```bash
source /etc/profile.d/lab3_env.sh

# Query spanning ALL time — both hot and frozen data in one request
curl -sk -X POST "${ES_URL}/_query" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "FROM lab3-audit-logs-* | STATS doc_count = COUNT(), earliest = MIN(@timestamp), latest = MAX(@timestamp) BY data.tier | SORT earliest ASC"
  }' | jq '.values[] | {tier: .[0], count: .[1], earliest: .[2], latest: .[3]}'
```

> **Key observation:** Both `hot` and `frozen` documents are returned by the **same query**, on the **same wildcard index pattern**. There was no rehydration step.

---

## Step 2: Answer the Auditor's Query

Run the exact query the compliance team needs — directly against two-year-old data:

```bash
curl -sk -X POST "${ES_URL}/_query" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "FROM lab3-audit-logs-* | WHERE event.action IN (\"data_export\", \"privilege_escalation_attempt\") AND destination.service == \"payments-api\" | KEEP @timestamp, user.name, user.id, event.action, event.outcome, source.ip, resource.type, resource.id, compliance.framework | SORT @timestamp DESC"
  }' | jq '.values[] | {timestamp: .[0], user: .[1], action: .[3], outcome: .[4], source_ip: .[5]}'
```

---

## Step 3: Measure Query Latency Against Archival Data

```bash
# Time a query that specifically targets only the archival index
time curl -sk -X POST "${ES_URL}/_query" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"query\": \"FROM ${LAB3_ARCHIVE_INDEX} | WHERE event.outcome == 'failure' | STATS failed_attempts = COUNT(), unique_users = COUNT_DISTINCT(user.name) BY event.action, destination.service | SORT failed_attempts DESC\"
  }" | jq '.values'
```

> This query runs against data that, in Splunk DDAA, would require a multi-hour rehydration job first. Note the response time in the `real` line from `time`.

---

## Step 4: Cross-Tier Compliance Report

Build a report that spans the full 2-year window in a single query — combining archival and recent data:

```bash
curl -sk -X POST "${ES_URL}/_query" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "FROM lab3-audit-logs-* | WHERE event.action == \"privilege_escalation_attempt\" | STATS attempt_count = COUNT(), success_count = COUNT() WHERE event.outcome == \"success\", affected_services = COUNT_DISTINCT(destination.service) BY user.name | WHERE attempt_count > 0 | SORT attempt_count DESC | LIMIT 20"
  }' | jq '.values[] | {user: .[0], total_attempts: .[1], successes: .[2], services_targeted: .[3]}'
```

> In Splunk, this cross-tier report would require: (1) rehydrate archival data, (2) wait, (3) run SPL in Splunk Cloud, (4) separately query Splunk ES if the data was also in the SIEM. In Elastic: one query.

---

## Step 5: Verify in Kibana (Optional)

1. Open **Kibana** tab
2. Go to **Analytics → Discover**
3. Select **"Lab 3 - Audit Logs (All Tiers)"** data view
4. Set time range to **Last 3 years**
5. Observe that documents from both 2 years ago and today appear in the same timeline
6. Add filter: `event.action : privilege_escalation_attempt`

All data — regardless of how old — is immediately visible and filterable.

---

## How Elastic's Frozen Tier Works (Technical Summary)

```
Elasticsearch Frozen Tier
├── Data stored as Searchable Snapshots in S3/GCS/Azure
├── Shard metadata cached locally (minimal footprint)
├── On query: relevant shard data fetched on-demand
├── Local node cache accelerates repeated queries
└── Result: full Elasticsearch query API, no rehydration required

Splunk DDAA
├── Data stored as Splunk-format files in S3
├── NOT searchable in-place
├── On query: full copy from S3 → warm storage required first
├── Rehydration SLA: hours to days
└── Result: blocked auditors, missed SLAs, incident response delays
```

---

## Competitive Takeaway

| Capability | Elastic Frozen Tier | Splunk DDAA |
|------------|--------------------|----|
| Archive to S3/object storage | ✅ | ✅ |
| Query archived data directly | ✅ Instantly | ❌ Requires rehydration |
| Rehydration time | None | Hours to days |
| Same query API as hot data | ✅ | ❌ |
| Cross-tier queries (hot + archive) | ✅ Single query | ❌ Two separate operations |
| Audit SLA compliance | ✅ Minutes | ❌ Unpredictable |

> During a security incident or compliance audit, **rehydration lag is not a performance annoyance — it is a business risk**. Elastic's searchable snapshots eliminate that risk entirely.

---

## ✅ Lab Complete When:

- [ ] The cross-tier query returns both `hot` and `frozen` tier documents
- [ ] The auditor query (data_export / privilege_escalation on payments-api) returns results
- [ ] You observed sub-second query response against archival data
