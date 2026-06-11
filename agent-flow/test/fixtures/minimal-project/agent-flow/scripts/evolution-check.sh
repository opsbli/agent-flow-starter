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
rules_dir="$(cd "$script_dir/.." && pwd)/rules"

read_rules() {
  local file="$rules_dir/$1"
  [ -f "$file" ] || { echo "Rule file not found: $file" >&2; exit 2; }
  grep -Ev '^[[:space:]]*(#|$)' "$file"
}

flow="Unknown"
if [ -f "$change_dir/CHANGE.md" ]; then
  if grep -Eiq '\[x\][[:space:]]+Heavy' "$change_dir/CHANGE.md"; then flow="Heavy"
  elif grep -Eiq '\[x\][[:space:]]+Standard' "$change_dir/CHANGE.md"; then flow="Standard"
  elif grep -Eiq '\[x\][[:space:]]+Light' "$change_dir/CHANGE.md"; then flow="Light"
  fi
fi

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

meaningful() {
  local value="$1"
  [ -n "$(printf '%s' "$value" | tr -d '[:space:]')" ] || return 1
  ! printf '%s' "$value" | grep -Eiq 'TODO|TBD|待填写|\{.+\}'
}

issues=()
mapfile -t required < <(read_rules evolution.keys)
for key in "${required[@]}"; do
  content="$(key_value "$key")"
  if ! meaningful "$content"; then
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
