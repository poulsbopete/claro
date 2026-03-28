#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Lab 1 Setup: Architectural Unity
# Ingest synthetic APM traces + correlated application logs so the user
# can pivot from a trace span to its matching log line in Kibana.
# ---------------------------------------------------------------------------
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../scripts/common.sh"

install_deps
wait_for_es
print_env_summary

# ---------------------------------------------------------------------------
# 1. Create the APM index template (simplified — mirrors ECS APM schema)
# ---------------------------------------------------------------------------
info "Creating APM traces index template..."
es_request PUT "/_index_template/lab1-apm-traces" "$(cat <<'EOF'
{
  "index_patterns": ["lab1-apm-traces-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    },
    "mappings": {
      "properties": {
        "@timestamp":          { "type": "date" },
        "trace.id":            { "type": "keyword" },
        "transaction.id":      { "type": "keyword" },
        "span.id":             { "type": "keyword" },
        "span.name":           { "type": "keyword" },
        "span.duration.us":    { "type": "long" },
        "service.name":        { "type": "keyword" },
        "service.environment": { "type": "keyword" },
        "http.response.status_code": { "type": "integer" },
        "url.path":            { "type": "keyword" },
        "transaction.name":    { "type": "keyword" },
        "transaction.duration.us": { "type": "long" },
        "error":               { "type": "boolean" },
        "error.message":       { "type": "text" }
      }
    }
  }
}
EOF
)" | jq -r '.acknowledged // .error'

# ---------------------------------------------------------------------------
# 2. Create the application log index template
# ---------------------------------------------------------------------------
info "Creating application log index template..."
es_request PUT "/_index_template/lab1-app-logs" "$(cat <<'EOF'
{
  "index_patterns": ["lab1-app-logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    },
    "mappings": {
      "properties": {
        "@timestamp":     { "type": "date" },
        "trace.id":       { "type": "keyword" },
        "transaction.id": { "type": "keyword" },
        "span.id":        { "type": "keyword" },
        "log.level":      { "type": "keyword" },
        "message":        { "type": "text" },
        "service.name":   { "type": "keyword" },
        "http.request.method": { "type": "keyword" },
        "url.path":       { "type": "keyword" },
        "http.response.status_code": { "type": "integer" },
        "error.message":  { "type": "text" },
        "error.stack_trace": { "type": "text" }
      }
    }
  }
}
EOF
)" | jq -r '.acknowledged // .error'

# ---------------------------------------------------------------------------
# 3. Generate synthetic APM + correlated log data with Python
# ---------------------------------------------------------------------------
info "Generating synthetic APM traces and correlated logs..."

python3 - <<'PYEOF'
import json, random, time, uuid, requests, os
from datetime import datetime, timedelta, timezone

ES_URL    = os.environ.get("ES_URL", "http://localhost:9200")
ES_KEY    = os.environ.get("ES_API_KEY", "")
ES_PASS   = os.environ.get("ELASTIC_PASSWORD", "changeme")

headers = {"Content-Type": "application/json"}
if ES_KEY:
    headers["Authorization"] = f"ApiKey {ES_KEY}"
else:
    from requests.auth import HTTPBasicAuth
    auth = HTTPBasicAuth("elastic", ES_PASS)

def post(path, body):
    url = f"{ES_URL}{path}"
    r = requests.post(url, json=body, headers=headers,
                      auth=None if ES_KEY else auth, verify=False)
    return r

SERVICES   = ["checkout-service", "inventory-service", "payment-gateway"]
ENDPOINTS  = ["/api/checkout", "/api/inventory/reserve", "/api/payment/charge"]
TODAY      = datetime.now(timezone.utc)
TRACE_DOCS = []
LOG_DOCS   = []

# Produce 200 transactions across the last 2 hours.
# Inject a latency spike in the last 30 minutes for one service.
for i in range(200):
    svc_idx     = i % len(SERVICES)
    service     = SERVICES[svc_idx]
    endpoint    = ENDPOINTS[svc_idx]
    trace_id    = uuid.uuid4().hex
    txn_id      = uuid.uuid4().hex[:16]
    span_id     = uuid.uuid4().hex[:16]
    minutes_ago = random.randint(0, 120)
    ts          = TODAY - timedelta(minutes=minutes_ago)
    ts_str      = ts.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"

    # Inject spike: checkout-service in last 30 min gets high latency + errors
    spike = (service == "checkout-service" and minutes_ago < 30)
    if spike:
        duration_us = random.randint(4_000_000, 12_000_000)  # 4–12 s
        status_code = random.choice([500, 503, 500, 500])
        is_error    = True
        err_msg     = random.choice([
            "upstream timeout from payment-gateway",
            "database connection pool exhausted",
            "circuit breaker OPEN on inventory-service",
        ])
    else:
        duration_us = random.randint(20_000, 400_000)         # 20ms–400ms
        status_code = 200
        is_error    = False
        err_msg     = None

    TRACE_DOCS.append({
        "@timestamp":                ts_str,
        "trace.id":                  trace_id,
        "transaction.id":            txn_id,
        "span.id":                   span_id,
        "span.name":                 f"HTTP {endpoint}",
        "span.duration.us":          duration_us,
        "service.name":              service,
        "service.environment":       "production",
        "http.response.status_code": status_code,
        "url.path":                  endpoint,
        "transaction.name":          f"GET {endpoint}",
        "transaction.duration.us":   duration_us,
        "error":                     is_error,
        **({"error.message": err_msg} if err_msg else {})
    })

    log_level = "ERROR" if is_error else random.choice(["INFO", "INFO", "INFO", "WARN"])
    if is_error:
        log_msg = f"[{service}] Request failed: {err_msg}"
        stack   = f"at {service}/handlers/route.js:142\n  at processTicksAndRejections (internal/process/task_queues.js:95)"
    else:
        log_msg = f"[{service}] {endpoint} completed in {duration_us//1000}ms status={status_code}"
        stack   = None

    LOG_DOCS.append({
        "@timestamp":                ts_str,
        "trace.id":                  trace_id,
        "transaction.id":            txn_id,
        "span.id":                   span_id,
        "log.level":                 log_level,
        "message":                   log_msg,
        "service.name":              service,
        "http.request.method":       "GET",
        "url.path":                  endpoint,
        "http.response.status_code": status_code,
        **({"error.message": err_msg, "error.stack_trace": stack} if is_error else {})
    })

# Bulk index traces
trace_index = f"lab1-apm-traces-{TODAY.strftime('%Y.%m.%d')}"
bulk_body   = ""
for doc in TRACE_DOCS:
    bulk_body += json.dumps({"index": {"_index": trace_index}}) + "\n"
    bulk_body += json.dumps(doc) + "\n"

r = requests.post(f"{ES_URL}/_bulk",
                  data=bulk_body,
                  headers={**headers, "Content-Type": "application/x-ndjson"},
                  auth=None if ES_KEY else auth, verify=False)
result = r.json()
errors = result.get("errors", True)
print(f"  APM traces indexed: errors={errors}")

# Bulk index logs
log_index = f"lab1-app-logs-{TODAY.strftime('%Y.%m.%d')}"
bulk_body  = ""
for doc in LOG_DOCS:
    bulk_body += json.dumps({"index": {"_index": log_index}}) + "\n"
    bulk_body += json.dumps(doc) + "\n"

r = requests.post(f"{ES_URL}/_bulk",
                  data=bulk_body,
                  headers={**headers, "Content-Type": "application/x-ndjson"},
                  auth=None if ES_KEY else auth, verify=False)
result = r.json()
errors = result.get("errors", True)
print(f"  App logs indexed:   errors={errors}")

# Store a sample slow trace ID for the assignment to reference
slow_traces = [d for d in TRACE_DOCS if d.get("error") and d["service.name"] == "checkout-service"]
if slow_traces:
    sample = slow_traces[0]
    with open("/tmp/lab1_sample_trace.json", "w") as f:
        json.dump({
            "trace_id":   sample["trace.id"],
            "trace_index": trace_index,
            "log_index":   log_index,
            "timestamp":  sample["@timestamp"]
        }, f, indent=2)
    print(f"  Sample trace saved: {sample['trace.id']}")

print("Done.")
PYEOF

# ---------------------------------------------------------------------------
# 4. Expose the sample trace ID to the lab environment
# ---------------------------------------------------------------------------
if [[ -f /tmp/lab1_sample_trace.json ]]; then
  SAMPLE_TRACE=$(jq -r '.trace_id' /tmp/lab1_sample_trace.json)
  TRACE_INDEX=$(jq -r '.trace_index' /tmp/lab1_sample_trace.json)
  LOG_INDEX=$(jq -r '.log_index' /tmp/lab1_sample_trace.json)

  # Write env file sourced by the user's shell
  cat > /etc/profile.d/lab1_env.sh <<ENVEOF
export LAB1_TRACE_ID="${SAMPLE_TRACE}"
export LAB1_TRACE_INDEX="${TRACE_INDEX}"
export LAB1_LOG_INDEX="${LOG_INDEX}"
export ES_URL="${ES_URL:-}"
export ES_API_KEY="${ES_API_KEY:-}"
export KIBANA_URL="${KIBANA_URL:-}"
ENVEOF

  info "Sample trace ID: ${SAMPLE_TRACE}"
  info "Trace index: ${TRACE_INDEX}"
  info "Log index:   ${LOG_INDEX}"
fi

# ---------------------------------------------------------------------------
# 5. Create a saved search in Kibana for easy access (best-effort)
# ---------------------------------------------------------------------------
info "Creating Kibana data views (best-effort)..."
sleep 5  # allow Kibana to stabilise

kibana_request POST "/api/data_views/data_view" "$(cat <<EOF
{
  "data_view": {
    "name": "Lab 1 - APM Traces",
    "title": "lab1-apm-traces-*",
    "timeFieldName": "@timestamp"
  },
  "override": true
}
EOF
)" > /dev/null 2>&1 || warn "Could not create APM data view (Kibana may not be available yet)"

kibana_request POST "/api/data_views/data_view" "$(cat <<EOF
{
  "data_view": {
    "name": "Lab 1 - App Logs",
    "title": "lab1-app-logs-*",
    "timeFieldName": "@timestamp"
  },
  "override": true
}
EOF
)" > /dev/null 2>&1 || warn "Could not create Logs data view (Kibana may not be available yet)"

info "Lab 1 setup complete."
echo ""
echo "  Run this to verify data ingested:"
echo "  curl -sk \"\${ES_URL}/lab1-apm-traces-*/_count\" -H \"Authorization: ApiKey \${ES_API_KEY}\" | jq .count"
echo ""
