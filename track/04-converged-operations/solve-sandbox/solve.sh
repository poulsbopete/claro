#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../scripts/common.sh"

source /etc/profile.d/lab4_env.sh 2>/dev/null || true

info "Verifying Lab 4 completion..."

ATTACK_IP="${LAB4_ATTACK_IP:-198.51.100.42}"
LOG_INDEX="${LAB4_LOG_INDEX:-lab1-app-logs-*}"

ATTACK_COUNT=$(es_request GET "/${LOG_INDEX}/_count?q=source.ip:${ATTACK_IP}" | jq -r '.count // 0')
info "Attack events found for ${ATTACK_IP}: ${ATTACK_COUNT}"

if [[ "${ATTACK_COUNT}" -lt 10 ]]; then
  error "Expected ≥10 brute-force events from ${ATTACK_IP}"
  exit 1
fi

# Verify the detection rule exists in Kibana
if [[ "${LAB4_RULE_ID:-manual}" != "manual" ]]; then
  RULE_STATUS=$(kibana_request GET "/api/detection_engine/rules?rule_id=lab4-brute-force-detection-001" | \
                jq -r '.enabled // "unknown"')
  info "Detection rule enabled: ${RULE_STATUS}"
fi

info "Lab 4 PASSED."
