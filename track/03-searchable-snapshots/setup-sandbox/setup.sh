#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Lab 3 Setup: Searchable Snapshots (Frozen Tier)
# Ingest synthetic "archival" log data timestamped 2+ years ago, then
# simulate mounting it in the Frozen Tier so users can query it instantly
# without rehydration — contrasting with Splunk DDAA behaviour.
# ---------------------------------------------------------------------------
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../scripts/common.sh"

install_deps
wait_for_es
print_env_summary

TODAY=$(date -u +%Y-%m-%d)
TWO_YEARS_AGO=$(date -u -d "2 years ago" +%Y-%m-%d 2>/dev/null || \
                date -u -v-2y +%Y-%m-%d 2>/dev/null || \
                python3 -c "from datetime import datetime, timedelta; print((datetime.utcnow()-timedelta(days=730)).strftime('%Y-%m-%d'))")

ARCHIVE_INDEX="lab3-audit-logs-${TWO_YEARS_AGO//-/.}"
HOT_INDEX="lab3-audit-logs-$(date -u +%Y.%m.%d)"

info "Archive index: ${ARCHIVE_INDEX}"
info "Hot index:     ${HOT_INDEX}"

# ---------------------------------------------------------------------------
# 1. Create ILM policy to simulate Frozen Tier (for on-prem; on Serverless
#    the frozen tier is managed automatically via data tiers)
# ---------------------------------------------------------------------------
info "Creating ILM policy for Frozen Tier simulation..."
es_request PUT "/_ilm/policy/lab3-frozen-policy" "$(cat <<'EOF'
{
  "policy": {
    "phases": {
      "hot":    { "min_age": "0ms",  "actions": { "rollover": { "max_age": "7d" } } },
      "warm":   { "min_age": "30d",  "actions": { "shrink": { "number_of_shards": 1 }, "forcemerge": { "max_num_segments": 1 } } },
      "cold":   { "min_age": "90d",  "actions": { "searchable_snapshot": { "snapshot_repository": "found-snapshots" } } },
      "frozen": { "min_age": "365d", "actions": { "searchable_snapshot": { "snapshot_repository": "found-snapshots" } } },
      "delete": { "min_age": "2555d","actions": { "delete": {} } }
    }
  }
}
EOF
)" | jq -r '.acknowledged // .error'

# ---------------------------------------------------------------------------
# 2. Create index template for audit logs
# ---------------------------------------------------------------------------
info "Creating audit log index template..."
es_request PUT "/_index_template/lab3-audit-logs" "$(cat <<'EOF'
{
  "index_patterns": ["lab3-audit-logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    },
    "mappings": {
      "properties": {
        "@timestamp":          { "type": "date" },
        "event.action":        { "type": "keyword" },
        "event.category":      { "type": "keyword" },
        "event.outcome":       { "type": "keyword" },
        "event.type":          { "type": "keyword" },
        "user.name":           { "type": "keyword" },
        "user.id":             { "type": "keyword" },
        "user.roles":          { "type": "keyword" },
        "source.ip":           { "type": "ip" },
        "destination.service": { "type": "keyword" },
        "http.request.method": { "type": "keyword" },
        "url.path":            { "type": "keyword" },
        "http.response.status_code": { "type": "integer" },
        "resource.type":       { "type": "keyword" },
        "resource.id":         { "type": "keyword" },
        "change.before":       { "type": "keyword" },
        "change.after":        { "type": "keyword" },
        "message":             { "type": "text" },
        "data.tier":           { "type": "keyword" },
        "compliance.framework":{ "type": "keyword" }
      }
    }
  }
}
EOF
)" | jq -r '.acknowledged // .error'

# ---------------------------------------------------------------------------
# 3. Ingest archival audit logs (timestamped 2 years ago)
# ---------------------------------------------------------------------------
info "Generating archival audit log data (timestamped ~2 years ago)..."

python3 - <<PYEOF
import json, random, requests, os, uuid
from datetime import datetime, timedelta, timezone

ES_URL      = os.environ.get("ES_URL", "http://localhost:9200")
ES_KEY      = os.environ.get("ES_API_KEY", "")
ES_PASS     = os.environ.get("ELASTIC_PASSWORD", "changeme")
ARCH_INDEX  = os.environ.get("ARCHIVE_INDEX", "lab3-audit-logs-2023.03.28")
HOT_INDEX   = os.environ.get("HOT_INDEX",   "lab3-audit-logs-$(date -u +%Y.%m.%d)")

headers = {"Content-Type": "application/json"}
auth    = None
if ES_KEY:
    headers["Authorization"] = f"ApiKey {ES_KEY}"
else:
    from requests.auth import HTTPBasicAuth
    auth = HTTPBasicAuth("elastic", ES_PASS)

BASE_DATE   = datetime.now(timezone.utc) - timedelta(days=730)
USERS       = [f"user_{uuid.uuid4().hex[:6]}" for _ in range(40)]
SERVICES    = ["payments-api","user-mgmt","reporting","data-export","admin-portal"]
ACTIONS     = ["login","logout","data_access","configuration_change","data_export",
                "privilege_escalation_attempt","bulk_delete","schema_change","api_key_created"]
FRAMEWORKS  = ["SOC2","PCI-DSS","HIPAA","ISO-27001"]
IP_POOL     = [f"10.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(1,254)}"
               for _ in range(80)]

bulk_body = ""
doc_count = 0

# 500 archival events spread across a 7-day window 2 years ago
for i in range(500):
    ts      = BASE_DATE + timedelta(
                  days=random.randint(0, 6),
                  hours=random.randint(0, 23),
                  minutes=random.randint(0, 59),
                  seconds=random.randint(0, 59))
    ts_str  = ts.strftime("%Y-%m-%dT%H:%M:%S.000Z")
    action  = random.choice(ACTIONS)
    user    = random.choice(USERS)
    svc     = random.choice(SERVICES)
    outcome = "failure" if action == "privilege_escalation_attempt" else random.choice(["success","success","success","failure"])

    doc = {
        "@timestamp":          ts_str,
        "event.action":        action,
        "event.category":      "authentication" if "login" in action else "database",
        "event.outcome":       outcome,
        "event.type":          "access",
        "user.name":           user,
        "user.id":             uuid.uuid5(uuid.NAMESPACE_DNS, user).hex[:12],
        "user.roles":          random.sample(["readonly","analyst","admin","superuser"], 1),
        "source.ip":           random.choice(IP_POOL),
        "destination.service": svc,
        "http.request.method": random.choice(["GET","POST","PUT","DELETE"]),
        "url.path":            f"/api/v2/{svc.split('-')[0]}/{random.choice(['records','config','export','users'])}",
        "http.response.status_code": 200 if outcome == "success" else random.choice([401,403,500]),
        "resource.type":       random.choice(["customer_record","payment_data","config","api_key"]),
        "resource.id":         uuid.uuid4().hex[:16],
        "message":             f"User {user} performed {action} on {svc} — outcome: {outcome}",
        "data.tier":           "frozen",
        "compliance.framework": random.choice(FRAMEWORKS)
    }

    bulk_body += json.dumps({"index": {"_index": ARCH_INDEX}}) + "\n"
    bulk_body += json.dumps(doc) + "\n"
    doc_count += 1

r = requests.post(f"{ES_URL}/_bulk",
                  data=bulk_body,
                  headers={**headers, "Content-Type": "application/x-ndjson"},
                  auth=auth, verify=False, timeout=60)
errors = r.json().get("errors", True)
print(f"  Archival docs indexed: {doc_count} (errors={errors})")

# Also ingest 100 recent events for contrast
bulk_body = ""
NOW = datetime.now(timezone.utc)
for i in range(100):
    ts = NOW - timedelta(hours=random.randint(0, 48))
    ts_str = ts.strftime("%Y-%m-%dT%H:%M:%S.000Z")
    action = random.choice(ACTIONS)
    user   = random.choice(USERS)
    svc    = random.choice(SERVICES)

    doc = {
        "@timestamp":          ts_str,
        "event.action":        action,
        "event.category":      "authentication" if "login" in action else "database",
        "event.outcome":       random.choice(["success","success","failure"]),
        "event.type":          "access",
        "user.name":           user,
        "user.id":             uuid.uuid5(uuid.NAMESPACE_DNS, user).hex[:12],
        "user.roles":          random.sample(["readonly","analyst","admin"], 1),
        "source.ip":           random.choice(IP_POOL),
        "destination.service": svc,
        "message":             f"User {user} performed {action} on {svc}",
        "data.tier":           "hot",
        "compliance.framework": random.choice(FRAMEWORKS)
    }

    bulk_body += json.dumps({"index": {"_index": HOT_INDEX}}) + "\n"
    bulk_body += json.dumps(doc) + "\n"

r = requests.post(f"{ES_URL}/_bulk",
                  data=bulk_body,
                  headers={**headers, "Content-Type": "application/x-ndjson"},
                  auth=auth, verify=False, timeout=60)
errors = r.json().get("errors", True)
print(f"  Recent docs indexed:   100 (errors={errors})")

with open("/tmp/lab3_meta.json", "w") as f:
    json.dump({"archive_index": ARCH_INDEX, "hot_index": HOT_INDEX,
               "archival_doc_count": doc_count, "base_date": BASE_DATE.strftime("%Y-%m-%d")}, f)
print("Done.")
PYEOF

# ---------------------------------------------------------------------------
# 4. Expose metadata
# ---------------------------------------------------------------------------
ARCHIVE_TS=$(python3 -c "from datetime import datetime, timedelta; print((datetime.utcnow()-timedelta(days=730)).strftime('%Y.%m.%d'))")
cat > /etc/profile.d/lab3_env.sh <<ENVEOF
export LAB3_ARCHIVE_INDEX="lab3-audit-logs-${ARCHIVE_TS}"
export LAB3_HOT_INDEX="${HOT_INDEX}"
export LAB3_ARCHIVE_DATE="${TWO_YEARS_AGO}"
export ES_URL="${ES_URL:-}"
export ES_API_KEY="${ES_API_KEY:-}"
export KIBANA_URL="${KIBANA_URL:-}"
ENVEOF

info "Creating Kibana data view for audit logs (best-effort)..."
sleep 5
kibana_request POST "/api/data_views/data_view" "$(cat <<EOF
{
  "data_view": {
    "name": "Lab 3 - Audit Logs (All Tiers)",
    "title": "lab3-audit-logs-*",
    "timeFieldName": "@timestamp"
  },
  "override": true
}
EOF
)" > /dev/null 2>&1 || warn "Could not create Kibana data view"

info "Lab 3 setup complete."
info "Archive date range: ${TWO_YEARS_AGO}"
