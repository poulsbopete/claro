#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# common.sh — shared helpers sourced by every challenge setup script
# ---------------------------------------------------------------------------
set -euo pipefail

# ---------- colour helpers --------------------------------------------------
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------- dependency bootstrap -------------------------------------------
install_deps() {
  info "Installing common dependencies..."
  apt-get update -qq
  apt-get install -y -qq \
    curl jq python3 python3-pip unzip ca-certificates gnupg lsb-release \
    netcat-openbsd 2>/dev/null
  pip3 install --quiet requests elastic-transport elasticsearch faker
  info "Dependencies ready."
}

# ---------- wait for Elasticsearch -----------------------------------------
wait_for_es() {
  local url="${ES_URL:-http://localhost:9200}"
  local key="${ES_API_KEY:-}"
  local retries=30
  info "Waiting for Elasticsearch at ${url}..."
  for i in $(seq 1 $retries); do
    local http_code
    if [[ -n "$key" ]]; then
      http_code=$(curl -sk -o /dev/null -w "%{http_code}" \
        -H "Authorization: ApiKey ${key}" "${url}/_cluster/health" || echo "000")
    else
      http_code=$(curl -sk -o /dev/null -w "%{http_code}" "${url}/_cluster/health" || echo "000")
    fi
    if [[ "$http_code" == "200" ]]; then
      info "Elasticsearch is available."
      return 0
    fi
    warn "Attempt ${i}/${retries}: HTTP ${http_code} — retrying in 10s..."
    sleep 10
  done
  error "Elasticsearch did not become available in time."
  return 1
}

# ---------- Elasticsearch helper -------------------------------------------
es_request() {
  # Usage: es_request METHOD PATH [body]
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local url="${ES_URL:-http://localhost:9200}${path}"
  local auth_header
  if [[ -n "${ES_API_KEY:-}" ]]; then
    auth_header="Authorization: ApiKey ${ES_API_KEY}"
  else
    auth_header="Authorization: Basic $(echo -n "elastic:${ELASTIC_PASSWORD:-changeme}" | base64)"
  fi

  if [[ -n "$body" ]]; then
    curl -sk -X "$method" "$url" \
      -H "$auth_header" \
      -H "Content-Type: application/json" \
      -d "$body"
  else
    curl -sk -X "$method" "$url" \
      -H "$auth_header"
  fi
}

# ---------- Kibana helper ---------------------------------------------------
kibana_request() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local url="${KIBANA_URL:-http://localhost:5601}${path}"
  local auth_header
  if [[ -n "${ES_API_KEY:-}" ]]; then
    auth_header="Authorization: ApiKey ${ES_API_KEY}"
  else
    auth_header="Authorization: Basic $(echo -n "elastic:${ELASTIC_PASSWORD:-changeme}" | base64)"
  fi

  if [[ -n "$body" ]]; then
    curl -sk -X "$method" "$url" \
      -H "$auth_header" \
      -H "Content-Type: application/json" \
      -H "kbn-xsrf: true" \
      -d "$body"
  else
    curl -sk -X "$method" "$url" \
      -H "$auth_header" \
      -H "kbn-xsrf: true"
  fi
}

# ---------- print environment summary --------------------------------------
print_env_summary() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Elastic Environment"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  ES URL    : ${ES_URL:-not set}"
  echo "  Kibana    : ${KIBANA_URL:-not set}"
  echo "  API Key   : ${ES_API_KEY:0:20}... (truncated)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}
