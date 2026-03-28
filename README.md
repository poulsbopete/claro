# Elastic Observability — Competitive Workshop

Instruqt track: **`claro-elastic-serverless-observability`**
Git remote: `git@github.com:poulsbopete/claro.git`

---

## Workshop Goal

A hands-on technical workshop for **DevOps, SRE, and platform engineering** teams evaluating Elastic Observability against the Splunk ecosystem (Splunk Cloud + Splunk Observability Cloud + ITSI).

Four labs, each targeting a specific Elastic architectural advantage over Splunk.

---

## Directory Structure

```
track/
├── track.yml                          # Instruqt track configuration
├── scripts/
│   └── common.sh                      # Shared bash helpers (sourced by all setup scripts)
│
├── 01-architectural-unity/
│   ├── assignment.md                  # User-facing lab instructions
│   ├── setup-sandbox/setup.sh        # Ingest APM traces + correlated logs
│   └── solve-sandbox/solve.sh        # Auto-grade script
│
├── 02-high-cardinality-metrics/
│   ├── assignment.md
│   ├── setup-sandbox/setup.sh        # Ingest high-cardinality k8s metrics
│   └── solve-sandbox/solve.sh
│
├── 03-searchable-snapshots/
│   ├── assignment.md
│   ├── setup-sandbox/setup.sh        # Ingest 2-year-old audit logs (frozen tier sim)
│   └── solve-sandbox/solve.sh
│
└── 04-converged-operations/
    ├── assignment.md
    ├── setup-sandbox/setup.sh        # Inject security events + create detection rule
    └── solve-sandbox/solve.sh
```

---

## Labs Summary

### Lab 1: Architectural Unity
**Splunk pain:** Logs in Splunk Cloud, traces in Splunk Observability Cloud — two products, two UIs, manual trace-ID correlation.
**Elastic edge:** All signals in one Elasticsearch datastore. Pivot from APM trace → log line in one click via shared `trace.id`.

### Lab 2: High-Cardinality Metrics
**Splunk pain:** Splunk OC charges per Metric Time Series (MTS). High-cardinality Kubernetes dims (pod UID, container ID) create MTS explosion, forcing teams to drop data to control costs.
**Elastic edge:** GB-based pricing. No MTS charges. Full per-pod/container granularity at no additional cost.

### Lab 3: Searchable Snapshots
**Splunk pain:** Splunk DDAA archives to S3 but requires multi-hour/day "rehydration" before data is searchable again.
**Elastic edge:** Frozen Tier Searchable Snapshots keep data in S3 but queryable instantly via standard ES API — no rehydration.

### Lab 4: Converged Operations
**Splunk pain:** Splunk Enterprise Security requires a separate license, CIM normalization, and typically double-ingest of data.
**Elastic edge:** Security detection rules target the same Elasticsearch indices as observability. No double ingest. No second product.

---

## Environment Variables Required

Each sandbox container expects these environment variables (set via Instruqt track settings):

| Variable | Description |
|----------|-------------|
| `ES_URL` | Elasticsearch endpoint (e.g. `https://my-project.es.us-east-1.aws.elastic.cloud`) |
| `ES_API_KEY` | Elasticsearch API key |
| `KIBANA_URL` | Kibana endpoint |
| `ELASTIC_PASSWORD` | Fallback if API key auth is not used |

---

## Publishing to Instruqt

```bash
# Install the Instruqt CLI
curl -L https://github.com/instruqt/cli/releases/latest/download/instruqt-linux-amd64 -o instruqt
chmod +x instruqt && mv instruqt /usr/local/bin/

# Authenticate
instruqt auth login

# Push the track
cd track/
instruqt track push
```
