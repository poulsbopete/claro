#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../scripts/common.sh"

source /etc/profile.d/lab3_env.sh 2>/dev/null || true

info "Verifying Lab 3 completion..."

ARCH_COUNT=$(es_request GET "/${LAB3_ARCHIVE_INDEX:-lab3-audit-logs-*}/_count" | jq -r '.count // 0')
HOT_COUNT=$(es_request GET "/${LAB3_HOT_INDEX:-lab3-audit-logs-*}/_count" | jq -r '.count // 0')
info "Archive docs: ${ARCH_COUNT}"
info "Hot docs:     ${HOT_COUNT}"

if [[ "${ARCH_COUNT}" -lt 100 ]]; then
  error "Expected ≥100 archival audit log documents."
  exit 1
fi

# Verify cross-tier query works (both tiers return data in one query)
TOTAL=$(es_request GET "/lab3-audit-logs-*/_count" | jq -r '.count // 0')
if [[ "${TOTAL}" -lt 200 ]]; then
  error "Cross-tier total expected ≥200 documents."
  exit 1
fi

info "Lab 3 PASSED."
