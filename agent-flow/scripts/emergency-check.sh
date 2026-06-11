#!/usr/bin/env bash
set -euo pipefail

change_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: emergency-check.sh --change-dir <change-dir>"
      exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$change_dir" ] || [ ! -d "$change_dir" ]; then
  echo "ChangeDir not found: $change_dir" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/_common.sh"

change_path="$change_dir/CHANGE.md"
if [ ! -f "$change_path" ]; then
  echo "Emergency check failed:"
  echo " - Missing CHANGE.md"
  exit 2
fi

if [ "$(flow_level "$change_dir")" != "Emergency" ]; then
  echo "SKIP: emergency-check only applies to Emergency changes."
  exit 0
fi

field_value() {
  local key="$1"
  sed -nE "s/^[[:space:]]*-?[[:space:]]*$key[[:space:]]*:[[:space:]]*(.+)$/\1/ip" "$change_path" | head -n 1 | xargs
}

issues=()
emergency_invalid='TODO|TBD|\{.+\}|pending-user|your-name'
level="$(field_value "Level")"
approved_by="$(field_value "Approved by")"
bypass_reason="$(field_value "Bypass reason")"
deadline="$(field_value "Backfill deadline")"
status="$(field_value "Backfill status")"

printf '%s' "$level" | grep -Eiq '^(P0|P1)$' || issues+=("Emergency Level must be P0 or P1.")
meaningful "$approved_by" true "$emergency_invalid" || issues+=("Emergency Approved by must name an accountable approver.")
meaningful "$bypass_reason" true "$emergency_invalid" || issues+=("Emergency Bypass reason must explain why the full flow was skipped.")
meaningful "$deadline" true "$emergency_invalid" || issues+=("Emergency Backfill deadline must be set.")
printf '%s' "$status" | grep -Eiq '^(pending|done|waived)$' || issues+=("Emergency Backfill status must be pending, done, or waived.")

for file in CODE_SCAN.md TASKS.md VERIFY.md REPORT.md EVOLUTION.md; do
  [ -f "$change_dir/$file" ] || issues+=("Emergency change must include $file.")
done

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Emergency check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Emergency check passed."
