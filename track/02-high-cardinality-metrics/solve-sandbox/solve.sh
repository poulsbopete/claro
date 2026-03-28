#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../scripts/common.sh"

source /etc/profile.d/lab2_env.sh 2>/dev/null || true

info "Verifying Lab 2 completion..."

COUNT=$(es_request GET "/lab2-k8s-metrics-*/_count" | jq -r '.count // 0')
info "K8s metric doc count: ${COUNT}"

if [[ "${COUNT}" -lt 1000 ]]; then
  error "Insufficient data. Expected ≥1000 documents."
  exit 1
fi

UNIQUE_PODS=$(es_request POST "/lab2-k8s-metrics-*/_search" "$(cat <<'EOF'
{"size":0,"aggs":{"u":{"cardinality":{"field":"kubernetes.pod.uid"}}}}
EOF
)" | jq -r '.aggregations.u.value // 0')

info "Unique pods: ${UNIQUE_PODS}"

if [[ "${UNIQUE_PODS}" -lt 100 ]]; then
  error "Expected ≥100 unique pod UIDs"
  exit 1
fi

info "Lab 2 PASSED."
