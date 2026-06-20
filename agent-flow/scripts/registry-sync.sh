#!/usr/bin/env bash
# Check agent-flow script registry coverage.

set -euo pipefail

project_root="."
write=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project-root|-ProjectRoot) project_root="$2"; shift 2 ;;
    --check|-Check) shift ;;
    --write|-Write) write=true; shift ;;
    -h|--help)
      echo "Usage: registry-sync.sh [--project-root .] [--check] [--write]"
      exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

project_root="$(cd "$project_root" && pwd)"
manifest="$project_root/agent-flow/manifest.yaml"
gate_rules="$project_root/agent-flow/rules/gates.txt"
scripts_dir="$project_root/agent-flow/scripts"

[ -f "$manifest" ] || { echo "Missing manifest: $manifest" >&2; exit 2; }
[ -f "$gate_rules" ] || { echo "Missing gate registry: $gate_rules" >&2; exit 2; }
[ -d "$scripts_dir" ] || { echo "Missing scripts dir: $scripts_dir" >&2; exit 2; }

mapfile -t public_scripts < <(
  find "$scripts_dir" -maxdepth 1 -type f \( -name '*.ps1' -o -name '*.sh' \) \
    ! -name '_*' -printf 'agent-flow/scripts/%f\n' | sort -u
)
mapfile -t classified < <(
  grep -E '^[[:space:]]*-[[:space:]]+agent-flow/scripts/[^[:space:]#]+[[:space:]]*$' "$manifest" |
    sed -E 's/^[[:space:]]*-[[:space:]]+//;s/[[:space:]]*$//' |
    sort -u
)
mapfile -t gate_registry < <(
  grep -Ev '^[[:space:]]*(#|$)' "$gate_rules" |
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' |
    sort -u
)

issues=()
contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [ "$item" = "$needle" ] && return 0
  done
  return 1
}

for script in "${public_scripts[@]}"; do
  contains "$script" "${classified[@]}" || issues+=("Unclassified public script: $script")
  contains "$script" "${gate_registry[@]}" || issues+=("Public script missing from gates.txt: $script")
done
for entry in "${classified[@]}"; do
  [ -f "$project_root/$entry" ] || issues+=("Classified script missing on disk: $entry")
done

if [ "$write" = true ]; then
  {
    echo "# One required public script per line. Keep paths relative to project root."
    echo "# Internal shared libraries such as _common.ps1/.sh are checked by scaffold-health, not listed here."
    echo "# This file is synchronized from the public script inventory by registry-sync."
    echo
    printf '%s\n' "${public_scripts[@]}"
  } > "$gate_rules"
  echo "Updated agent-flow/rules/gates.txt from public script inventory."
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Registry sync check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

echo "Registry sync check passed."
