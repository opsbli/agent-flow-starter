#!/usr/bin/env bash
# Emergency abuse detection: hard-lock module after 3+ Emergency uses in 30 days.
# Extracted from agent-flow/flows/emergency.md.
# Usage: bash agent-flow/scripts/emergency-abuse-check.sh [changes-root] [module] [threshold] [window-days]

set -euo pipefail

check_emergency_abuse() {
  local changes_root="${1:-agent-flow/changes}"
  local module="$2"
  local threshold="${3:-3}"
  local window_days="${4:-30}"
  local count=0

  local now
  now=$(date +%s)

  for change_dir in "$changes_root"/*/; do
    [ -d "$change_dir" ] || continue
    local change_file="$change_dir/CHANGE.md"
    [ ! -f "$change_file" ] && continue

    if ! grep -Eiq '\[x\][[:space:]]+Emergency' "$change_file"; then
      continue
    fi

    # Extract that change's module
    local other_module
    other_module=$(grep -A1 "^## 影响范围" "$change_file" 2>/dev/null | tail -1 | xargs)
    [ -z "$other_module" ] && other_module=$(basename "$change_dir" | sed 's/^[0-9]*-//')

    [ "$other_module" != "$module" ] && continue

    # Get change date
    local change_date_str
    change_date_str=$(basename "$change_dir" | grep -Eo '^[0-9]{8}')
    [ -z "$change_date_str" ] && continue

    local change_epoch
    change_epoch=$(date -d "$(printf '%s-%s-%s' "${change_date_str:0:4}" "${change_date_str:4:2}" "${change_date_str:6:2}")" +%s 2>/dev/null || echo 0)
    [ "$change_epoch" -eq 0 ] && continue

    local diff_days=$(( (now - change_epoch) / 86400 ))
    [ "$diff_days" -le "$window_days" ] && count=$((count + 1))
  done

  if [ "$count" -ge "$threshold" ]; then
    echo "🔴 Module '$module' has $count Emergency changes in $window_days days (threshold: $threshold)."
    echo "   Recommend: hard-lock for 30 days, architecture review, and ADR creation."
    return 1
  fi

  echo "✅ Module '$module' has $count Emergency changes in $window_days days (below threshold $threshold)."
  return 0
}

if [ $# -lt 2 ]; then
  echo "Usage: $0 [changes-root] <module> [threshold=3] [window-days=30]"
  echo "Example: $0 agent-flow/changes login-module"
  exit 2
fi

check_emergency_abuse "$@"
