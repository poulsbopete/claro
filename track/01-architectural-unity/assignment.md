# Lab 1: Architectural Unity — One Platform, Zero Context Switches

## The Problem with Splunk's Architecture

When you run Splunk, your data lives in **two separate products**:

- **Splunk Cloud** → your logs
- **Splunk Observability Cloud** → your traces and metrics

Correlating an error in a distributed trace to the exact log line that caused it requires:
1. Copy a trace ID from Splunk Observability Cloud
2. Open a second browser tab, navigate to Splunk Cloud
3. Run a new SPL search using that trace ID
4. Hope the log was indexed under the same timestamp window

**In Elastic, this takes one click.** Everything — logs, traces, metrics, profiles — lives in a single Elasticsearch datastore, and Kibana's unified interface surfaces all of them together.

---

## What Was Set Up For You

The setup script ingested two correlated datasets into your Elastic Serverless environment:

| Index | Contents |
|-------|----------|
| `lab1-apm-traces-*` | 200 synthetic APM spans from `checkout-service`, `inventory-service`, and `payment-gateway` |
| `lab1-app-logs-*` | Corresponding application log lines — **every log shares the same `trace.id` as its APM span** |

A latency spike and error storm was injected into `checkout-service` in the last 30 minutes.

---

## Step 1: Confirm Your Data Is Loaded

Open the **Terminal** tab and verify both indices are populated:

```bash
# Count APM traces
curl -sk "${ES_URL}/lab1-apm-traces-*/_count" \
  -H "Authorization: ApiKey ${ES_API_KEY}" | jq .count

# Count correlated logs
curl -sk "${ES_URL}/lab1-app-logs-*/_count" \
  -H "Authorization: ApiKey ${ES_API_KEY}" | jq .count
```

You should see approximately **200 documents** in each index.

---

## Step 2: Find the Latency Spike in APM Traces

Run this ES|QL query in the terminal (or paste it into Kibana → **Discover → ES|QL**) to find the slowest transactions in the last 30 minutes:

```bash
curl -sk -X POST "${ES_URL}/_query" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "FROM lab1-apm-traces-* | WHERE @timestamp > NOW() - 30 minutes AND error == true | STATS avg_duration_ms = AVG(span.duration.us) / 1000, count = COUNT() BY service.name | SORT avg_duration_ms DESC | LIMIT 10"
  }' | jq '.values'
```

> **What you are seeing:** `checkout-service` has dramatically higher average latency and an error rate that does not appear on the other services. This is your smoking gun.

---

## Step 3: Drill Into a Specific Failing Trace

Fetch the trace ID of a failed checkout-service request:

```bash
curl -sk -X POST "${ES_URL}/_query" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "FROM lab1-apm-traces-* | WHERE service.name == \"checkout-service\" AND error == true | KEEP @timestamp, trace.id, span.duration.us, error.message | SORT @timestamp DESC | LIMIT 1"
  }' | jq '.values[0]'
```

Copy the `trace.id` value from the output (second column). It will look like a 32-character hex string.

Save it to a variable:

```bash
export TRACE_ID="<paste-trace-id-here>"
# Or load the pre-saved one from setup:
# source /etc/profile.d/lab1_env.sh && export TRACE_ID="${LAB1_TRACE_ID}"
```

---

## Step 4: Pivot to the Correlated Log — The Elastic Way

Now query the **application log index** for that exact trace ID:

```bash
curl -sk -X POST "${ES_URL}/_query" \
  -H "Authorization: ApiKey ${ES_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"query\": \"FROM lab1-app-logs-* | WHERE \\\"trace.id\\\" == \\\"${TRACE_ID}\\\" | KEEP @timestamp, log.level, message, error.message, error.stack_trace\"
  }" | jq '.values'
```

> **In Splunk:** You would now be on your second product, running a second search, hoping the timestamps align.
>
> **In Elastic:** The same `trace.id` field, the same query language (ES|QL), the same datastore. **One query. One platform. Zero context switching.**

---

## Step 5: Visualize in Kibana (Optional — Strongly Recommended)

1. Open the **Kibana** tab
2. Navigate to **Observability → APM → Services**
3. Click on **checkout-service**
4. You will see the latency spike rendered in the service timeline
5. Click on any failing transaction → **Trace** tab → **Logs** tab

Kibana automatically correlates the trace to its logs using the shared `trace.id` field. This is native correlation — no configuration required.

---

## Competitive Takeaway

| Capability | Elastic | Splunk |
|------------|---------|--------|
| Traces + Logs in one datastore | ✅ Elasticsearch | ❌ Two products |
| Pivot trace → log | ✅ One click | ❌ Copy ID, open second UI |
| Unified query language | ✅ ES\|QL everywhere | ❌ SPL (logs) / SignalFlow (APM) |
| Single billing contract | ✅ | ❌ Splunk Cloud + Splunk OC |

> When your on-call engineer gets paged at 2 AM, **context switches cost resolution time**. Elastic's architectural unity eliminates that tax entirely.

---

## ✅ Lab Complete When:

- [ ] Both index counts return ~200 documents
- [ ] The ES|QL spike query shows `checkout-service` with elevated latency
- [ ] You successfully retrieved a correlated log line using a `trace.id` from the APM index
