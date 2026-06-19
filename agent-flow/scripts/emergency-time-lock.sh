#!/usr/bin/env bash
# Emergency time-lock check: prevents same-module Emergency within 7 days.
# Extracted from agent-flow/flows/emergency.md.
# Usage: bash agent-flow/scripts/emergency-time-lock.sh <change-dir> [changes-root]
# Returns 0 if allowed, 1 if blocked by time-lock.

set -euo pipefail

check_emergency_time_lock() {
  local new_change_dir="$1"
  local changes_root="${2:-agent-flow/changes}"
  local module_name

  # Extract module name from new CHANGE.md's "影响范围" section
  module_name=$(grep -A1 "^## 影响范围" "$new_change_dir/CHANGE.md" 2>/dev/null | tail -1 | xargs)
  [ -z "$module_name" ] && module_name=$(basename "$new_change_dir" | sed 's/^[0-9]*-//')

  local now
  now=$(date +%s)

  for change_dir in "$changes_root"/*/; do
    [ -d "$change_dir" ] || continue
    [ "$change_dir" = "$new_change_dir/" ] && continue

    local change_file="$change_dir/CHANGE.md"
    [ ! -f "$change_file" ] && continue

    # Check if this is an Emergency change
    if ! grep -Eiq '\[x\][[:space:]]+Emergency' "$change_file"; then
      continue
    fi

    # Extract that change's module
    local other_module
    other_module=$(grep -A1 "^## 影响范围" "$change_file" 2>/dev/null | tail -1 | xargs)
    [ -z "$other_module" ] && other_module=$(basename "$change_dir" | sed 's/^[0-9]*-//')

    # Same module?
    [ "$other_module" != "$module_name" ] && continue

    # Get change date from directory name (format: YYYYMMDD-*)
    local change_date_str
    change_date_str=$(basename "$change_dir" | grep -Eo '^[0-9]{8}')
    [ -z "$change_date_str" ] && continue

    local change_epoch
    change_epoch=$(date -d "$(printf '%s-%s-%s' "${change_date_str:0:4}" "${change_date_str:4:2}" "${change_date_str:6:2}")" +%s 2>/dev/null || echo 0)
    [ "$change_epoch" -eq 0 ] && continue

    local diff_days=$(( (now - change_epoch) / 86400 ))
    if [ "$diff_days" -lt 7 ]; then
      echo "⛔ Time lock active for module '$module_name' (last Emergency: $(basename "$change_dir"), ${diff_days} day(s) ago). Use Heavy process instead."
      return 1
    fi
  done

  echo "✅ No time-lock conflict for module '$module_name'."
  return 0
}

if [ $# -lt 1 ]; then
  echo "Usage: $0 <change-dir> [changes-root]"
  exit 2
fi

check_emergency_time_lock "$@"
