#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Lab 4 Setup: Converged Operations (Observability → Security)
# Activate a pre-built Kibana Security detection rule targeting the application
# logs ingested in Lab 1, and inject a suspicious event to trigger an alert.
# Demonstrates zero-ingest-cost SIEM coverage on existing observability data.
# ---------------------------------------------------------------------------
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../scripts/common.sh"

install_deps
wait_for_es
print_env_summary

TODAY=$(date -u +%Y.%m.%d)
LAB1_LOG_INDEX="lab1-app-logs-${TODAY}"

# ---------------------------------------------------------------------------
# 1. Check that Lab 1 data exists; if not, re-create the index with seed data
# ---------------------------------------------------------------------------
info "Checking for Lab 1 log data..."
COUNT=$(es_request GET "/${LAB1_LOG_INDEX}/_count" | jq -r '.count // 0' 2>/dev/null || echo "0")

if [[ "$COUNT" -lt 10 ]]; then
  warn "Lab 1 data not found or insufficient (count=${COUNT}). Seeding minimal dataset..."

  es_request PUT "/_index_template/lab1-app-logs" "$(cat <<'EOF'
{
  "index_patterns": ["lab1-app-logs-*"],
  "template": {
    "settings": { "number_of_shards": 1, "number_of_replicas": 0 },
    "mappings": {
      "properties": {
        "@timestamp":          { "type": "date" },
        "trace.id":            { "type": "keyword" },
        "log.level":           { "type": "keyword" },
        "message":             { "type": "text" },
        "service.name":        { "type": "keyword" },
        "url.path":            { "type": "keyword" },
        "http.response.status_code": { "type": "integer" },
        "error.message":       { "type": "text" },
        "source.ip":           { "type": "ip" },
        "user.name":           { "type": "keyword" }
      }
    }
  }
}
EOF
  )" | jq -r '.acknowledged // .error'

  python3 - <<'PYEOF'
import json, random, uuid, requests, os
from datetime import datetime, timedelta, timezone

ES_URL  = os.environ.get("ES_URL", "http://localhost:9200")
ES_KEY  = os.environ.get("ES_API_KEY", "")
ES_PASS = os.environ.get("ELASTIC_PASSWORD", "changeme")
INDEX   = f"lab1-app-logs-{datetime.utcnow().strftime('%Y.%m.%d')}"

headers = {"Content-Type": "application/json"}
auth    = None
if ES_KEY:
    headers["Authorization"] = f"ApiKey {ES_KEY}"
else:
    from requests.auth import HTTPBasicAuth
    auth = HTTPBasicAuth("elastic", ES_PASS)

NOW      = datetime.now(timezone.utc)
bulk_str = ""

for i in range(50):
    ts  = NOW - timedelta(minutes=random.randint(0, 60))
    ts_s= ts.strftime("%Y-%m-%dT%H:%M:%S.000Z")
    doc = {
        "@timestamp":                ts_s,
        "trace.id":                  uuid.uuid4().hex,
        "log.level":                 random.choice(["INFO","WARN","ERROR"]),
        "message":                   f"checkout-service request completed status={random.choice([200,200,200,500])}",
        "service.name":              "checkout-service",
        "url.path":                  "/api/checkout",
        "http.response.status_code": random.choice([200,200,500]),
        "source.ip":                 f"10.0.{random.randint(0,255)}.{random.randint(1,254)}",
        "user.name":                 f"user_{i % 10}"
    }
    bulk_str += json.dumps({"index": {"_index": INDEX}}) + "\n"
    bulk_str += json.dumps(doc) + "\n"

r = requests.post(f"{ES_URL}/_bulk",
                  data=bulk_str,
                  headers={**headers, "Content-Type": "application/x-ndjson"},
                  auth=auth, verify=False)
print(f"  Seeded 50 docs into {INDEX} (errors={r.json().get('errors', True)})")
PYEOF
fi

# ---------------------------------------------------------------------------
# 2. Inject a suspicious security event into the existing log index
#    (brute-force pattern: repeated 401s from same IP, then a 200)
# ---------------------------------------------------------------------------
info "Injecting suspicious security events (brute-force pattern)..."

python3 - <<PYEOF
import json, requests, os, uuid
from datetime import datetime, timedelta, timezone

ES_URL    = os.environ.get("ES_URL", "http://localhost:9200")
ES_KEY    = os.environ.get("ES_API_KEY", "")
ES_PASS   = os.environ.get("ELASTIC_PASSWORD", "changeme")
INDEX     = f"lab1-app-logs-{datetime.utcnow().strftime('%Y.%m.%d')}"

headers = {"Content-Type": "application/json"}
auth    = None
if ES_KEY:
    headers["Authorization"] = f"ApiKey {ES_KEY}"
else:
    from requests.auth import HTTPBasicAuth
    auth = HTTPBasicAuth("elastic", ES_PASS)

NOW        = datetime.now(timezone.utc)
ATTACK_IP  = "198.51.100.42"   # RFC 5737 documentation address (safe to use)
ATTACK_USER= "admin"
bulk_str   = ""

# 15 failed login attempts in a 5-minute window
for i in range(15):
    ts = NOW - timedelta(minutes=5, seconds=i*20)
    doc = {
        "@timestamp":                ts.strftime("%Y-%m-%dT%H:%M:%S.000Z"),
        "trace.id":                  uuid.uuid4().hex,
        "log.level":                 "WARN",
        "message":                   f"Authentication failed for user '{ATTACK_USER}' from {ATTACK_IP}",
        "service.name":              "checkout-service",
        "url.path":                  "/api/auth/login",
        "http.response.status_code": 401,
        "source.ip":                 ATTACK_IP,
        "user.name":                 ATTACK_USER,
        "event.action":              "authentication_failure",
        "event.outcome":             "failure"
    }
    bulk_str += json.dumps({"index": {"_index": INDEX}}) + "\n"
    bulk_str += json.dumps(doc) + "\n"

# One successful login — brute force succeeded
ts = NOW - timedelta(minutes=4, seconds=50)
doc = {
    "@timestamp":                ts.strftime("%Y-%m-%dT%H:%M:%S.000Z"),
    "trace.id":                  uuid.uuid4().hex,
    "log.level":                 "INFO",
    "message":                   f"Authentication succeeded for user '{ATTACK_USER}' from {ATTACK_IP}",
    "service.name":              "checkout-service",
    "url.path":                  "/api/auth/login",
    "http.response.status_code": 200,
    "source.ip":                 ATTACK_IP,
    "user.name":                 ATTACK_USER,
    "event.action":              "authentication_success",
    "event.outcome":             "success"
}
bulk_str += json.dumps({"index": {"_index": INDEX}}) + "\n"
bulk_str += json.dumps(doc) + "\n"

r = requests.post(f"{ES_URL}/_bulk",
                  data=bulk_str,
                  headers={**headers, "Content-Type": "application/x-ndjson"},
                  auth=auth, verify=False)
errors = r.json().get("errors", True)
print(f"  Security events injected: 15 failures + 1 success (errors={errors})")
print(f"  Attack IP: {ATTACK_IP}")
print(f"  Attack index: {INDEX}")

with open("/tmp/lab4_meta.json", "w") as f:
    import json
    json.dump({"log_index": INDEX, "attack_ip": ATTACK_IP, "attack_user": ATTACK_USER}, f)
print("Done.")
PYEOF

# ---------------------------------------------------------------------------
# 3. Create a Kibana Security detection rule targeting the observability logs
# ---------------------------------------------------------------------------
info "Creating Kibana Security detection rule (best-effort)..."
sleep 8

RULE_PAYLOAD=$(cat <<'EOF'
{
  "type": "query",
  "language": "kuery",
  "name": "[Lab 4] Brute Force: Multiple Auth Failures Followed by Success",
  "description": "Detects when a source IP generates 10+ authentication failures within 5 minutes, followed by a successful login — a classic brute-force pattern. This rule targets the same application logs used for APM observability in Lab 1, demonstrating zero-cost SIEM coverage.",
  "severity": "high",
  "risk_score": 73,
  "enabled": true,
  "tags": ["lab4", "brute-force", "observability-logs", "no-double-ingest"],
  "index": ["lab1-app-logs-*"],
  "query": "http.response.status_code: 401 AND event.action: authentication_failure",
  "filters": [],
  "from": "now-6m",
  "interval": "5m",
  "max_signals": 100,
  "references": [],
  "false_positives": [],
  "threat": [
    {
      "framework": "MITRE ATT&CK",
      "tactic": { "id": "TA0006", "name": "Credential Access", "reference": "https://attack.mitre.org/tactics/TA0006/" },
      "technique": [{ "id": "T1110", "name": "Brute Force", "reference": "https://attack.mitre.org/techniques/T1110/" }]
    }
  ],
  "author": ["Elastic Workshop"],
  "license": "Elastic License v2",
  "rule_id": "lab4-brute-force-detection-001",
  "version": 1,
  "actions": []
}
EOF
)

RULE_RESPONSE=$(kibana_request POST "/api/detection_engine/rules" "${RULE_PAYLOAD}" 2>/dev/null || echo '{"error": "skipped"}')
RULE_ID=$(echo "$RULE_RESPONSE" | jq -r '.id // "unknown"')

if [[ "$RULE_ID" != "unknown" && "$RULE_ID" != "null" ]]; then
  info "Detection rule created: ID=${RULE_ID}"
  cat > /etc/profile.d/lab4_env.sh <<ENVEOF
export LAB4_RULE_ID="${RULE_ID}"
export LAB4_LOG_INDEX="${LAB1_LOG_INDEX}"
export LAB4_ATTACK_IP="198.51.100.42"
export LAB4_ATTACK_USER="admin"
export ES_URL="${ES_URL:-}"
export ES_API_KEY="${ES_API_KEY:-}"
export KIBANA_URL="${KIBANA_URL:-}"
ENVEOF
else
  warn "Detection rule creation may have failed (Kibana Security not enabled or API unavailable)"
  warn "Students can create the rule manually — instructions in the assignment"
  cat > /etc/profile.d/lab4_env.sh <<ENVEOF
export LAB4_RULE_ID="manual"
export LAB4_LOG_INDEX="${LAB1_LOG_INDEX}"
export LAB4_ATTACK_IP="198.51.100.42"
export LAB4_ATTACK_USER="admin"
export ES_URL="${ES_URL:-}"
export ES_API_KEY="${ES_API_KEY:-}"
export KIBANA_URL="${KIBANA_URL:-}"
ENVEOF
fi

info "Lab 4 setup complete."
echo ""
echo "  Attack events are in: ${LAB1_LOG_INDEX}"
echo "  Attack IP:  198.51.100.42"
echo "  Run the detection query:"
echo "  curl -sk \"\${ES_URL}/${LAB1_LOG_INDEX}/_search?q=source.ip:198.51.100.42\" \\"
echo "    -H \"Authorization: ApiKey \${ES_API_KEY}\" | jq '.hits.total'"
echo ""
