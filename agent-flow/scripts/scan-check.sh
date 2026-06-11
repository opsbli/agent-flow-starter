#!/usr/bin/env bash
set -euo pipefail

change_dir=""
project_root="."
strict=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --change-dir|-ChangeDir)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      change_dir="$2"; shift 2 ;;
    --project-root|-ProjectRoot)
      if [ "$#" -lt 2 ]; then echo "Missing value for $1" >&2; exit 2; fi
      project_root="$2"; shift 2 ;;
    --strict|-Strict)
      strict=true; shift ;;
    -h|--help)
      echo "Usage: scan-check.sh --change-dir <change-dir> [--project-root <path>] [--strict]"
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
project_root="$(cd "$project_root" 2>/dev/null && pwd || echo "$project_root")"
scan_path="$change_dir/CODE_SCAN.md"

if [ ! -f "$scan_path" ]; then
  echo "Scan check failed:"
  echo " - Missing CODE_SCAN.md"
  exit 2
fi

read_rules() {
  local file="$rules_dir/$1"
  [ -f "$file" ] || { echo "Rule file not found: $file" >&2; exit 2; }
  grep -Ev '^[[:space:]]*(#|$)' "$file"
}

flow="Unknown"
if [ -f "$change_dir/CHANGE.md" ]; then
  if grep -Eiq '\[x\][[:space:]]+Emergency' "$change_dir/CHANGE.md"; then flow="Emergency"
  elif grep -Eiq '\[x\][[:space:]]+Heavy' "$change_dir/CHANGE.md"; then flow="Heavy"
  elif grep -Eiq '\[x\][[:space:]]+Standard' "$change_dir/CHANGE.md"; then flow="Standard"
  elif grep -Eiq '\[x\][[:space:]]+Light' "$change_dir/CHANGE.md"; then flow="Light"
  fi
fi

key_value() {
  local key="$1"
  sed -nE "s/^[[:space:]]*$key[[:space:]]*:[[:space:]]*(.+)$/\1/ip" "$scan_path" | head -n 1
}

meaningful() {
  local value="$1"
  [ -n "$(printf '%s' "$value" | tr -d '[:space:]')" ] || return 1
  ! printf '%s' "$value" | grep -Eiq 'TODO|TBD|path/to|example|\{.+\}'
}

normalize_entry() {
  printf '%s\n' "$1" | sed 's#\\#/#g; s/^[[:space:]]*//; s/[[:space:]]*$//; s/^[`"'"'"']//; s/[`"'"'"']$//'
}

list_entries() {
  local key="$1"
  local inline
  inline="$(key_value "$key" || true)"
  if meaningful "$inline"; then
    printf '%s\n' "$inline" | tr ',;' '\n' | while IFS= read -r item; do normalize_entry "$item"; done
  fi
  awk -v key="$key" '
    $0 ~ "^[[:space:]]*" key "[[:space:]]*:[[:space:]]*$" { in_section = 1; next }
    in_section && /^[[:space:]]*##[[:space:]]+/ { in_section = 0 }
    in_section && /^[[:space:]]*[A-Za-z0-9_-]+[[:space:]]*:[[:space:]]*$/ { in_section = 0 }
    in_section && /^[[:space:]]*-/ { print }
  ' "$scan_path" | sed 's/^[[:space:]]*-[[:space:]]*//' | while IFS= read -r item; do normalize_entry "$item"; done |
    grep -Eiv '^[[:space:]]*(none|n/a|na|no-change|no change)[[:space:]]*$' |
    awk 'NF' |
    sort -u
}

issues=()
mapfile -t required < <(read_rules code-scan-light.keys)
if [ "$flow" = "Standard" ] || [ "$flow" = "Heavy" ]; then
  mapfile -t extra < <(read_rules code-scan-standard-heavy.keys)
  required+=("${extra[@]}")
fi

for key in "${required[@]}"; do
  content="$(key_value "$key")"
  if ! meaningful "$content"; then
    issues+=("CODE_SCAN.md key '$key' is missing or still empty.")
  fi
done

for key in read_files write_files; do
  if ! grep -Eiq "^[[:space:]]*$key[[:space:]]*:|^##[[:space:]]+$key[[:space:]]*$" "$scan_path"; then
    issues+=("CODE_SCAN.md must declare $key.")
  fi
done

if [ "$strict" = true ]; then
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    if [ ! -e "$project_root/$file" ]; then
      issues+=("Strict read_files path does not exist: $file")
    fi
  done < <(list_entries read_files)

  while IFS= read -r file; do
    [ -n "$file" ] || continue
    path="$project_root/$file"
    parent="$(dirname "$path")"
    if [ ! -e "$path" ] && [ ! -d "$parent" ]; then
      issues+=("Strict write_files path or parent does not exist: $file")
    fi
  done < <(list_entries write_files)
fi

if [ "${#issues[@]}" -gt 0 ]; then
  echo "Scan check failed:"
  printf ' - %s\n' "${issues[@]}"
  exit 2
fi

if [ "$strict" = true ]; then
  echo "Scan check passed for $flow change (strict)."
else
  echo "Scan check passed for $flow change."
fi
