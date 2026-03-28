#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Lab 2 Setup: High-Cardinality Kubernetes Metrics
# Ingest a synthetic dataset representing per-pod, per-container metrics
# across a large Kubernetes cluster to demonstrate that Elastic's pricing
# model is immune to MTS explosion.
# ---------------------------------------------------------------------------
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../scripts/common.sh"

install_deps
wait_for_es
print_env_summary

# ---------------------------------------------------------------------------
# 1. Create index template for k8s metrics (TSDS-style)
# ---------------------------------------------------------------------------
info "Creating Kubernetes metrics index template..."
es_request PUT "/_index_template/lab2-k8s-metrics" "$(cat <<'EOF'
{
  "index_patterns": ["lab2-k8s-metrics-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    },
    "mappings": {
      "properties": {
        "@timestamp":                    { "type": "date" },
        "kubernetes.namespace":          { "type": "keyword" },
        "kubernetes.node.name":          { "type": "keyword" },
        "kubernetes.pod.uid":            { "type": "keyword" },
        "kubernetes.pod.name":           { "type": "keyword" },
        "kubernetes.container.name":     { "type": "keyword" },
        "kubernetes.container.id":       { "type": "keyword" },
        "kubernetes.deployment.name":    { "type": "keyword" },
        "kubernetes.cluster.name":       { "type": "keyword" },
        "kubernetes.pod.cpu.usage.nanocores":    { "type": "long" },
        "kubernetes.pod.memory.rss.bytes":       { "type": "long" },
        "kubernetes.pod.network.rx.bytes":       { "type": "long" },
        "kubernetes.pod.network.tx.bytes":       { "type": "long" },
        "kubernetes.container.cpu.limit.nanocores": { "type": "long" },
        "kubernetes.container.memory.limit.bytes":  { "type": "long" },
        "kubernetes.container.status.restarts":     { "type": "integer" },
        "kubernetes.container.status.ready":        { "type": "boolean" },
        "unique_dimension_count":        { "type": "integer" },
        "ingest.simulation.mts_equivalent": { "type": "long" }
      }
    }
  }
}
EOF
)" | jq -r '.acknowledged // .error'

# ---------------------------------------------------------------------------
# 2. Generate high-cardinality metric data with Python
# ---------------------------------------------------------------------------
info "Generating synthetic high-cardinality Kubernetes metrics..."
info "Simulating a cluster with 50 nodes, 20 namespaces, 200 deployments, ~2000 pods..."

python3 - <<'PYEOF'
import json, random, time, uuid, requests, os
from datetime import datetime, timedelta, timezone

ES_URL  = os.environ.get("ES_URL", "http://localhost:9200")
ES_KEY  = os.environ.get("ES_API_KEY", "")
ES_PASS = os.environ.get("ELASTIC_PASSWORD", "changeme")

headers = {"Content-Type": "application/json"}
auth    = None
if ES_KEY:
    headers["Authorization"] = f"ApiKey {ES_KEY}"
else:
    from requests.auth import HTTPBasicAuth
    auth = HTTPBasicAuth("elastic", ES_PASS)

# Cluster topology
CLUSTER     = "prod-us-east-1"
NODES       = [f"ip-10-0-{random.randint(0,255)}-{random.randint(0,255)}" for _ in range(50)]
NAMESPACES  = [f"ns-{app}" for app in [
    "frontend","backend","payments","auth","data","ml","monitoring",
    "logging","tracing","infra","ci","staging","search","cache",
    "messaging","gateway","reporting","analytics","security","tools"
]]
DEPLOYMENTS = {}
for ns in NAMESPACES:
    count = random.randint(5, 15)
    DEPLOYMENTS[ns] = [f"{ns}-{svc}-v{random.randint(1,3)}" for svc in
                       [f"svc{i}" for i in range(count)]]

TODAY = datetime.now(timezone.utc)
INDEX = f"lab2-k8s-metrics-{TODAY.strftime('%Y.%m.%d')}"

# Track how many unique pod UIDs we create (= MTS equivalent in Splunk)
all_pod_uids = set()
bulk_batches = []
current_batch = ""
batch_count   = 0
doc_count     = 0

# For each scrape interval (every 30s for the last hour = 120 intervals)
for interval in range(120):
    ts = TODAY - timedelta(seconds=interval * 30)
    ts_str = ts.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"

    for ns, deployments in DEPLOYMENTS.items():
        for deployment in deployments:
            # Each deployment has 2-8 replica pods
            replica_count = random.randint(2, 8)
            for replica in range(replica_count):
                pod_uid  = str(uuid.uuid5(uuid.NAMESPACE_DNS,
                               f"{deployment}-{replica}-{ns}"))
                pod_name = f"{deployment}-{uuid.uuid4().hex[:8]}-{uuid.uuid4().hex[:5]}"
                node     = random.choice(NODES)

                all_pod_uids.add(pod_uid)

                containers_per_pod = random.randint(1, 3)
                for cnum in range(containers_per_pod):
                    cname = f"container-{cnum}" if cnum > 0 else deployment.split("-")[1]
                    cid   = f"containerd://{uuid.uuid4().hex}"

                    cpu_limit = random.choice([500_000_000, 1_000_000_000, 2_000_000_000])
                    mem_limit = random.choice([536_870_912, 1_073_741_824, 2_147_483_648])

                    doc = {
                        "@timestamp":                        ts_str,
                        "kubernetes.cluster.name":           CLUSTER,
                        "kubernetes.namespace":              ns,
                        "kubernetes.node.name":              node,
                        "kubernetes.pod.uid":                pod_uid,
                        "kubernetes.pod.name":               pod_name,
                        "kubernetes.container.name":         cname,
                        "kubernetes.container.id":           cid,
                        "kubernetes.deployment.name":        deployment,
                        "kubernetes.pod.cpu.usage.nanocores":    random.randint(10_000_000, cpu_limit),
                        "kubernetes.pod.memory.rss.bytes":       random.randint(52_428_800, mem_limit),
                        "kubernetes.pod.network.rx.bytes":       random.randint(1_000, 50_000_000),
                        "kubernetes.pod.network.tx.bytes":       random.randint(1_000, 20_000_000),
                        "kubernetes.container.cpu.limit.nanocores":  cpu_limit,
                        "kubernetes.container.memory.limit.bytes":   mem_limit,
                        "kubernetes.container.status.restarts":      random.randint(0, 3),
                        "kubernetes.container.status.ready":         random.random() > 0.02,
                        "unique_dimension_count":            len(all_pod_uids),
                        "ingest.simulation.mts_equivalent":  len(all_pod_uids) * 4
                    }

                    current_batch += json.dumps({"index": {"_index": INDEX}}) + "\n"
                    current_batch += json.dumps(doc) + "\n"
                    doc_count += 1

                    if doc_count % 500 == 0:
                        r = requests.post(
                            f"{ES_URL}/_bulk",
                            data=current_batch,
                            headers={**headers, "Content-Type": "application/x-ndjson"},
                            auth=auth, verify=False, timeout=60)
                        errs = r.json().get("errors", True)
                        print(f"  Indexed {doc_count} docs (errors={errs})")
                        current_batch = ""

# Flush remaining
if current_batch:
    r = requests.post(
        f"{ES_URL}/_bulk",
        data=current_batch,
        headers={**headers, "Content-Type": "application/x-ndjson"},
        auth=auth, verify=False, timeout=60)
    errs = r.json().get("errors", True)

mts_equiv = len(all_pod_uids) * 4   # 4 metrics per pod: cpu, mem, net_rx, net_tx

# Save metadata
with open("/tmp/lab2_meta.json", "w") as f:
    json.dump({
        "doc_count":      doc_count,
        "unique_pods":    len(all_pod_uids),
        "mts_equivalent": mts_equiv,
        "index":          INDEX,
        "namespaces":     len(NAMESPACES),
        "deployments":    sum(len(v) for v in DEPLOYMENTS.values())
    }, f, indent=2)

print(f"\n  Total docs indexed:    {doc_count}")
print(f"  Unique pod UIDs:       {len(all_pod_uids)}")
print(f"  MTS equivalent (Splunk): {mts_equiv:,}  (4 metrics × {len(all_pod_uids)} pods)")
print(f"  Elastic cost driver:   {doc_count} documents (GB-based, not MTS-based)")
print("Done.")
PYEOF

# ---------------------------------------------------------------------------
# 3. Expose metadata for the lab
# ---------------------------------------------------------------------------
if [[ -f /tmp/lab2_meta.json ]]; then
  DOC_COUNT=$(jq -r '.doc_count' /tmp/lab2_meta.json)
  UNIQUE_PODS=$(jq -r '.unique_pods' /tmp/lab2_meta.json)
  MTS_EQUIV=$(jq -r '.mts_equivalent' /tmp/lab2_meta.json)
  LAB2_INDEX=$(jq -r '.index' /tmp/lab2_meta.json)

  cat > /etc/profile.d/lab2_env.sh <<ENVEOF
export LAB2_DOC_COUNT="${DOC_COUNT}"
export LAB2_UNIQUE_PODS="${UNIQUE_PODS}"
export LAB2_MTS_EQUIVALENT="${MTS_EQUIV}"
export LAB2_INDEX="${LAB2_INDEX}"
export ES_URL="${ES_URL:-}"
export ES_API_KEY="${ES_API_KEY:-}"
export KIBANA_URL="${KIBANA_URL:-}"
ENVEOF

  info "Lab 2 data summary:"
  info "  Documents indexed:     ${DOC_COUNT}"
  info "  Unique pods:           ${UNIQUE_PODS}"
  info "  Splunk MTS equivalent: ${MTS_EQUIV}"
  info "  Index:                 ${LAB2_INDEX}"
fi

# Create data view in Kibana (best-effort)
info "Creating Kibana data view for k8s metrics (best-effort)..."
sleep 5
kibana_request POST "/api/data_views/data_view" "$(cat <<EOF
{
  "data_view": {
    "name": "Lab 2 - Kubernetes Metrics",
    "title": "lab2-k8s-metrics-*",
    "timeFieldName": "@timestamp"
  },
  "override": true
}
EOF
)" > /dev/null 2>&1 || warn "Could not create Kibana data view"

info "Lab 2 setup complete."
