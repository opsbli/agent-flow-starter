#!/usr/bin/env bash

agent_flow_common_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
agent_flow_root="$(cd "$agent_flow_common_dir/.." && pwd)"

flow_level() {
  local file="$1/CHANGE.md"
  if [ ! -f "$file" ]; then
    echo "Unknown"
  elif grep -Eiq '\[x\][[:space:]]+Emergency' "$file"; then
    echo "Emergency"
  elif grep -Eiq '\[x\][[:space:]]+Heavy' "$file"; then
    echo "Heavy"
  elif grep -Eiq '\[x\][[:space:]]+Standard' "$file"; then
    echo "Standard"
  elif grep -Eiq '\[x\][[:space:]]+Light' "$file"; then
    echo "Light"
  else
    echo "Unknown"
  fi
}

get_rule_list() {
  local name="$1"
  local path="$agent_flow_root/rules/$name"
  if [ ! -f "$path" ]; then
    echo "Rule file not found: $path" >&2
    return 1
  fi
  grep -Ev '^[[:space:]]*(#|$)' "$path" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g'
}

meaningful() {
  local value="$1"
  local allow_slash="${2:-false}"
  local invalid_pattern="${3:-TODO|TBD|path/to|example|\{.+\}}"

  [ -n "$(printf '%s' "$value" | tr -d '[:space:]')" ] || return 1
  ! printf '%s' "$value" | grep -Eiq "$invalid_pattern" || return 1
  if [ "$allow_slash" != true ] && printf '%s' "$value" | grep -Eq '[[:space:]]/[[:space:]]'; then
    return 1
  fi
  return 0
}

meaningful_file() {
  local path="$1"
  shift || true

  [ -f "$path" ] || return 1
  local text
  text="$(cat "$path")"
  [ -n "$(printf '%s' "$text" | tr -d '[:space:]')" ] || return 1
  for placeholder in "$@"; do
    if printf '%s' "$text" | grep -qF "$placeholder"; then
      return 1
    fi
  done
  return 0
}
