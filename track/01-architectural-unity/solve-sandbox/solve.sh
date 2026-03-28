#!/usr/bin/env bash
# Auto-solve script for Lab 1 (used by Instruqt check/solve)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../scripts/common.sh"

source /etc/profile.d/lab1_env.sh 2>/dev/null || true

info "Verifying Lab 1 completion..."

# Check trace index count
TRACE_COUNT=$(es_request GET "/lab1-apm-traces-*/_count" | jq -r '.count // 0')
LOG_COUNT=$(es_request GET "/lab1-app-logs-*/_count"   | jq -r '.count // 0')

info "Trace count: ${TRACE_COUNT}"
info "Log count:   ${LOG_COUNT}"

if [[ "${TRACE_COUNT}" -lt 100 ]] || [[ "${LOG_COUNT}" -lt 100 ]]; then
  error "Insufficient data. Expected ≥100 in each index."
  exit 1
fi

# Verify correlation is possible (a log exists with the sample trace ID)
if [[ -n "${LAB1_TRACE_ID:-}" ]]; then
  CORR=$(es_request GET "/lab1-app-logs-*/_search?q=trace.id:${LAB1_TRACE_ID}&size=1" | \
         jq -r '.hits.total.value // 0')
  if [[ "$CORR" -lt 1 ]]; then
    error "No log found for trace ID ${LAB1_TRACE_ID}"
    exit 1
  fi
  info "Correlation verified: trace ${LAB1_TRACE_ID} → log found"
fi

info "Lab 1 PASSED."
