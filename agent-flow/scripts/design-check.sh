#!/usr/bin/env bash
set -euo pipefail

change_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: design-check.sh --change-dir <change-dir>"
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

cell_value() {
  local line="$1" index="$2"
  awk -F'|' -v idx="$index" '{ value=$idx; gsub(/^[[:space:]]+|[[:space:]]+$/, "", value); print value }' <<< "$line"
}

flow="$(flow_level "$change_dir")"
if [ "$flow" = "Light" ] || [ "$flow" = "Emergency" ]; then
  echo "SKIP: design-check is not required for $flow changes."
  exit 0
fi
if [ "$flow" = "Unknown" ]; then
  echo "Cannot determine flow level from CHANGE.md. Mark one of Light / Standard / Heavy / Emergency." >&2
  exit 1
fi

design="$change_dir/DESIGN.md"
if [ ! -f "$design" ]; then
  echo "DESIGN.md not found in $change_dir" >&2
  exit 1
fi

issues=()

decision_status="$(awk '
  BEGIN { IGNORECASE = 1 }
  /^[[:space:]]*Decision Status:[[:space:]]*/ {
    value=$0
    sub(/^.*Decision Status:[[:space:]]*/, "", value)
    sub(/[[:space:]].*$/, "", value)
    print tolower(value)
    exit
  }
' "$design")"

if [ -z "$decision_status" ]; then
  issues+=("Decision Status is missing. Use 'Decision Status: accepted' after API/Permission/Auth decisions are finalized.")
elif [ "$decision_status" != "accepted" ]; then
  issues+=("Decision Status must be accepted before planning or implementation.")
fi

while IFS= read -r key; do
  key="$(printf '%s' "$key" | xargs)"
  [ -n "$key" ] || continue

  line="$(grep -F "| $key |" "$design" | head -n 1 || true)"
  if [ -z "$line" ]; then
    issues+=("Missing design decision row: $key")
    continue
  fi
  decision="$(cell_value "$line" 3)"
  evidence="$(cell_value "$line" 4)"
  if ! meaningful "$decision" false 'TODO|TBD|pending|\{.+\}'; then
    issues+=("Design decision '$key' has no final decision. Replace option lists with one value like unchanged/new/modified/deleted/not-applicable.")
  fi
  if ! meaningful "$evidence" true 'TODO|TBD|pending|\{.+\}'; then
    issues+=("Design decision '$key' needs evidence or a reason.")
  fi
done < <(get_rule_list "design-decision.keys")

impact="$(awk '
  BEGIN { IGNORECASE = 1 }
  /^[[:space:]]*State Machine Impact:[[:space:]]*(yes|no|not-applicable)[[:space:]]*$/ {
    value=$0
    sub(/^.*State Machine Impact:[[:space:]]*/, "", value)
    print tolower(value)
    exit
  }
' "$design")"

if [ -z "$impact" ]; then
  issues+=("State Machine Impact must be explicit: yes, no, or not-applicable.")
elif [ "$impact" = "yes" ]; then
  for section in "Status Vocabulary" "Status Mapping" "Legacy Compatibility"; do
    if ! grep -Eiq "^[[:space:]]*#+[[:space:]]+$section[[:space:]]*$" "$design"; then
      issues+=("State Machine Impact is yes, but section is missing: $section")
    fi
  done
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "design-check failed:" >&2
  for issue in "${issues[@]}"; do echo " - $issue" >&2; done
  exit 2
fi

echo "design-check passed."
