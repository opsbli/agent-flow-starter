#!/usr/bin/env bash
set -euo pipefail

change_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: evolution-check.sh --change-dir <change-dir>"
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

flow="$(flow_level "$change_dir")"

path="$change_dir/EVOLUTION.md"
if [ ! -f "$path" ]; then
  if [ "$flow" = "Light" ]; then
    echo "SKIP: Light change has no EVOLUTION.md."
    exit 0
  fi
  echo "Evolution check failed:"
  echo " - Missing EVOLUTION.md"
  exit 2
fi

key_value() {
  local key="$1"
  sed -nE "s/^[[:space:]]*$key[[:space:]]*:[[:space:]]*(.+)$/\1/ip" "$path" | head -n 1
}

issues=()
mapfile -t required < <(get_rule_list evolution.keys)
for key in "${required[@]}"; do
  content="$(key_value "$key")"
  if ! meaningful "$content" true 'TODO|TBD|待填写|\{.+\}'; then
    issues+=("EVOLUTION.md key '$key' is missing or still empty.")
  fi
done

if ! grep -Eiq 'knowledge|ADR|gate|template|script|不调整|无|none|no change' "$path"; then
  issues+=("EVOLUTION.md must record either concrete upgrades or explicit no-change decisions.")
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Evolution check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Evolution check passed for $flow change."
